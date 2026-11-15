// LiveKit SFU JWT Minting Edge Function for ACT LIKE IT™
// Deploy with: supabase functions deploy livekit-token
// Required Supabase Edge Function Secrets:
//   supabase secrets set LIVEKIT_API_KEY=... LIVEKIT_API_SECRET=...

declare const Deno: {
  env: { get(key: string): string | undefined };
  serve(handler: (req: Request) => Response | Promise<Response>): void;
};

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

function base64UrlEncode(data: Uint8Array): string {
  let binary = '';
  for (let i = 0; i < data.length; i += 1) {
    binary += String.fromCharCode(data[i]);
  }
  return btoa(binary)
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=+$/, '');
}

function encodeJsonSegment(payload: Record<string, unknown>): string {
  const bytes = new TextEncoder().encode(JSON.stringify(payload));
  return base64UrlEncode(bytes);
}

async function signLiveKitJwt(
  apiKey: string,
  apiSecret: string,
  claims: Record<string, unknown>,
): Promise<string> {
  const headerSegment = encodeJsonSegment({ alg: 'HS256', typ: 'JWT' });
  const payloadSegment = encodeJsonSegment(claims);
  const signingInput = `${headerSegment}.${payloadSegment}`;

  const cryptoKey = await crypto.subtle.importKey(
    'raw',
    new TextEncoder().encode(apiSecret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign'],
  );

  const signature = await crypto.subtle.sign(
    'HMAC',
    cryptoKey,
    new TextEncoder().encode(signingInput),
  );

  const signatureSegment = base64UrlEncode(new Uint8Array(signature));
  return `${signingInput}.${signatureSegment}`;
}

Deno.serve(async (req: Request): Promise<Response> => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { status: 204, headers: corsHeaders });
  }

  if (req.method !== 'POST') {
    return new Response(
      JSON.stringify({ error: 'Method not allowed. Use POST.' }),
      {
        status: 405,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      },
    );
  }

  try {
    const apiKey = Deno.env.get('LIVEKIT_API_KEY')?.trim() ?? '';
    const apiSecret = Deno.env.get('LIVEKIT_API_SECRET')?.trim() ?? '';

    if (!apiKey || !apiSecret) {
      return new Response(
        JSON.stringify({
          error:
            'Missing LIVEKIT_API_KEY or LIVEKIT_API_SECRET in Supabase Edge Function Secrets.',
        }),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        },
      );
    }

    const body = (await req.json()) as {
      room_name?: string;
      identity?: string;
      display_name?: string;
      role?: string;
    };

    const roomName = (body.room_name ?? '').trim();
    const identity = (body.identity ?? '').trim();
    const displayName = (body.display_name ?? 'StageActor').trim();
    const role = (body.role ?? 'activePerformer').trim();

    if (!roomName || !identity) {
      return new Response(
        JSON.stringify({
          error: 'Both room_name and identity are required.',
        }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        },
      );
    }

    const isSpectator =
      role === 'remoteSpectator' || role.toLowerCase() === 'spectator';

    const nowSec = Math.floor(Date.now() / 1000);
    const claims: Record<string, unknown> = {
      iss: apiKey,
      sub: identity,
      name: displayName,
      nbf: nowSec - 10,
      exp: nowSec + 7200,
      video: {
        room: roomName,
        roomJoin: true,
        canPublish: !isSpectator,
        canSubscribe: true,
        canPublishData: true,
      },
    };

    const token = await signLiveKitJwt(apiKey, apiSecret, claims);

    return new Response(
      JSON.stringify({
        token,
        room_name: roomName,
        identity,
        role: isSpectator ? 'remoteSpectator' : 'activePerformer',
      }),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      },
    );
  } catch (err) {
    return new Response(
      JSON.stringify({
        error: err instanceof Error ? err.message : 'Failed to mint token.',
      }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      },
    );
  }
});
