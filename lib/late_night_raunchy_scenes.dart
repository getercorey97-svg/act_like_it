import 'ui/lobby_models_and_realtime.dart';
import 'ui/parody_scenes_catalog.dart';

/// ============================================================================
/// 18+ MIDNIGHT SPEAKEASY — 50 NEW UNCENSORED RATED-R / TV-MA SCENES & 20 DARES
/// ============================================================================
/// Organized across 3 Spice Filter Tiers:
/// - Tier 1 (ln_01..ln_04 + ln_11..ln_28 = 22 scenes): 🔥 Tier 1: Messy Hookups & Raunchy Comedy [1.15x]
/// - Tier 2 (ln_05..ln_07 + ln_29..ln_44 = 19 scenes): 💋 Tier 2: Bedroom Walk-Ins & Seductive Noir [1.25x]
/// - Tier 3 (ln_08..ln_10 + ln_45..ln_60 = 19 scenes): 🧨 Tier 3: Unhinged TV-MA Meltdowns & Filthy Roasts [1.35x]

enum SpeakeasySpiceTier {
  all('ALL 60 SCENES', '🔞 All 60 Uncensored Scenes', 1.25),
  tier1MessyHookups(
    'TIER 1 · 1.15x',
    '🔥 Tier 1: Messy Hookups & Raunchy Comedy [1.15x]',
    1.15,
  ),
  tier2BedroomNoir(
    'TIER 2 · 1.25x',
    '💋 Tier 2: Bedroom Walk-Ins & Seductive Noir [1.25x]',
    1.25,
  ),
  tier3UnhingedRoasts(
    'TIER 3 · 1.35x',
    '🧨 Tier 3: Unhinged TV-MA Meltdowns & Filthy Roasts [1.35x]',
    1.35,
  );

  final String shortBadge;
  final String label;
  final double multiplier;
  const SpeakeasySpiceTier(this.shortBadge, this.label, this.multiplier);
}

SpeakeasySpiceTier getSpiceTierForSceneId(String id) {
  final numPart = int.tryParse(id.replaceFirst('ln_', '')) ?? 1;
  if (numPart <= 4 || (numPart >= 11 && numPart <= 28)) {
    return SpeakeasySpiceTier.tier1MessyHookups;
  } else if ((numPart >= 5 && numPart <= 7) ||
      (numPart >= 29 && numPart <= 44)) {
    return SpeakeasySpiceTier.tier2BedroomNoir;
  } else {
    return SpeakeasySpiceTier.tier3UnhingedRoasts;
  }
}

const List<ScenePrompt> kFiftyNewRatedRSpeakeasyScenes = [
  // ===========================================================================
  // 🔥 TIER 1: MESSY HOOKUPS & RAUNCHY COMEDY [1.15x] (ln_11 to ln_28)
  // ===========================================================================
  ScenePrompt(
    id: 'ln_11',
    title: 'The Uber Pool Walk-of-Shame Inquisition',
    filmOrSeries: 'Sunday Morning Walk of Shame (Rated-R Parody)',
    releaseYear: 2026,
    characterName: 'Hungover VIP & Judgmental Commuter',
    promptScript:
        'Yes, Kevin, I am wearing a sequin tuxedo jacket over gym shorts at 8:15 on a Sunday morning, mind your fucking business! Do not give me that side-eye from the front seat when I went out for one tequila soda, made some questionable executive decisions in a penthouse jacuzzi, and frankly my cardio stats have never looked better!',
    duetLeadA:
        'Yes, I am wearing last night\'s tuxedo jacket over gym shorts at 8:15 AM, mind your fucking business!',
    duetLeadB:
        'We are literally in the same Uber Pool heading to the company retreat, and you are wearing my brother\'s college hoodie.',
    directorCue:
        'Play the first half like you are testifying before Congress, then pivot into bragging about how good the night was.',
    emotionalTarget: 'Defiant Hungover Shamelessness [Tier 1 · 1.15x]',
    improvTwist:
        'TWIST AT 15s: You realize the other passenger in the back seat of the Uber Pool is your boss from accounting!',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 3,
  ),
  ScenePrompt(
    id: 'ln_12',
    title: 'Accidental Thirst-Trap Screen Share at the All-Hands',
    filmOrSeries: 'Boardroom AirDrop Scandal (Rated-R Parody)',
    releaseYear: 2026,
    characterName: 'VP of Marketing & Frantic IT Lead',
    promptScript:
        'If everyone looks closely at Slide 4—okay, no, that is not the Q3 revenue projection, that is me in a towel flexing under bathroom LED lighting! How the fuck did AirDrop sync my "Private Vault" folder directly to the boardroom 85-inch display?! Before HR starts typing furiously, let us acknowledge the impeccable core lighting!',
    duetLeadA:
        'How the fuck did my "Do Not Open" camera roll folder sync directly to the 85-inch boardroom display?!',
    duetLeadB:
        'Stop clicking the wireless mouse, you just zoomed in 400 percent on the leopard-print briefs in front of the CEO!',
    directorCue:
        'Start with professional corporate smoothness as your voice cracks higher with every excuse.',
    emotionalTarget: 'Frantic Corporate Damage Control [Tier 1 · 1.15x]',
    improvTwist:
        'TWIST AT 15s: The CEO unmutes and asks what filter you used because the lighting is actually elite!',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'ln_13',
    title: 'The Morning-After Toothbrush Territorial War',
    filmOrSeries: 'No Brunch Clause (Rated-R Parody)',
    releaseYear: 2026,
    characterName: 'Commitment-Phobe & Overeager Hookup',
    promptScript:
        'Hold the fuck up—did you just put your toothbrush inside my ceramic holder like you pay utilities around here?! Last night was an Olympic-level performance, ten out of ten, I pulled a hamstring I didn\'t know existed, but leaving toiletries on the vanity after one hookup is basically common-law marriage in this zip code!',
    duetLeadA:
        'Hold the fuck up—did you just put your toothbrush in my ceramic holder like you pay utilities here?!',
    duetLeadB:
        'Relax, Romeo, you were the one crying happy tears at 2 AM asking what we should name our golden retriever!',
    directorCue:
        'Smile way too hard while backing toward the apartment door like a cornered cat.',
    emotionalTarget: 'Charming Commitment-Phobe Panic [Tier 1 · 1.15x]',
    improvTwist:
        'TWIST AT 15s: Their mom FaceTimes them on speakerphone because you accidentally liked a 2019 beach photo at 3 AM!',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 3,
  ),
  ScenePrompt(
    id: 'ln_14',
    title: 'Caught Roleplaying as Sexy TSA Agents',
    filmOrSeries: 'PreCheck Denied (Rated-R Parody)',
    releaseYear: 2026,
    characterName: 'Agent Frisk & Early-Flight Roommate',
    promptScript:
        'Ma\'am, step away from the bedroom doorway—this is a Level-4 bedroom security pat-down and you do not have TSA PreCheck! Don\'t look at me like that, why the hell was your flight from Vegas three hours early?! Yes, I am wearing a reflective vest with nothing underneath and holding a Dyson hairdryer like a wand, it\'s called keeping the spark alive!',
    duetLeadA:
        'Step away from the doorway—this is a Level-4 bedroom pat-down and you do not have TSA PreCheck!',
    duetLeadB:
        'Why the hell are you wearing my reflective running vest with no pants on a Tuesday afternoon?!',
    directorCue:
        'Never break your fake TSA officer posture even while explaining why you are in your underwear.',
    emotionalTarget: 'Mortified Deadpan Authority [Tier 1 · 1.15x]',
    improvTwist:
        'TWIST AT 15s: The novelty handcuffs click shut and neither of you actually knows where the tiny silver key went!',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'ln_15',
    title: 'The Wrong Group Chat Voice Note Meltdown',
    filmOrSeries: 'Nana\'s 80th Birthday Chat (TV-MA Parody)',
    releaseYear: 2026,
    characterName: 'Panicked Sinner & Chaos Bestie',
    promptScript:
        'Oh sweet mother of fuck, I didn\'t send that 45-second spicy voice note to Jordan—I sent it to "Nana\'s 80th Birthday Planning Chat"! And Uncle Gary already gave it a thumbs-up reaction! Listen to me, family: my phone was possessed by an erotic audiobook narrator, do NOT press play on that file!',
    duetLeadA:
        'I didn\'t send that spicy voice note to you—I just dropped it in "Nana\'s 80th Birthday Family Chat"!',
    duetLeadB:
        'Wait, the one where you described what we just did on the kitchen island?! Delete the whole family right now!',
    directorCue:
        'Stare at your phone in horror, then try to gaslight the entire family group chat with a straight face.',
    emotionalTarget: 'Sweating Bullets Desperation [Tier 1 · 1.15x]',
    improvTwist:
        'TWIST AT 15s: Nana replies "Typing..." for ten agonizing seconds and drops a fire emoji!',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'ln_16',
    title: 'Hiding in the Closet During the Landlord Inspection',
    filmOrSeries: 'Cedar Shelf Squat (Rated-R Parody)',
    releaseYear: 2026,
    characterName: 'Boxer-Brief Fugitive & Frantic Tenant',
    promptScript:
        'Stop shushing me! I am crouched between your winter parkas in my boxers because you forgot the super was fixing the radiator! My left calf is cramping so hard I\'m seeing ancestors, and why the fuck did you tell him I\'m a "large decorative mannequin"?! Mannequins don\'t sweat tequila and breathe like a pug!',
    duetLeadA:
        'Stop shushing me! I am crouched between your winter parkas in my boxers because you forgot the landlord was coming!',
    duetLeadB:
        'If you sneeze right now he\'s raising my rent by four hundred bucks—hold your breath and hug the dry cleaning!',
    directorCue:
        'Start in a fierce stage whisper crunched inside a tiny space, then burst out when your knee cramps.',
    emotionalTarget: 'Claustrophobic Whispered Rage [Tier 1 · 1.15x]',
    improvTwist:
        'TWIST AT 15s: Your phone alarm starts blasting a humiliating hype song at full volume from your pants on the bedroom floor!',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 3,
  ),
  ScenePrompt(
    id: 'ln_17',
    title: 'The Wedding Open-Bar Groomsman Confession',
    filmOrSeries: 'Photo Booth Flash (Rated-R Parody)',
    releaseYear: 2026,
    characterName: 'Disheveled Groomsman & Bridesmaid Accomplice',
    promptScript:
        'First of all, nobody was using the bridal suite photo booth during the father-daughter dance, so technically we were recycling space. Second of all, how the hell is it my fault the flash went off four times while my cummerbund was around my ankles?! Wait—those glossy prints go directly onto the bride\'s scrapbook table?!',
    duetLeadA:
        'Wait—those photo booth strips print directly onto the bride\'s guestbook table?!',
    duetLeadB:
        'Act natural and button your vest, the maid of honor is walking toward the scrapbook with a magnifying glass!',
    directorCue:
        'Lean against an imaginary coat-check counter, fixing your hair while trying to act completely innocent.',
    emotionalTarget: 'Tipsy Conspiratorial Glee [Tier 1 · 1.15x]',
    improvTwist:
        'TWIST AT 15s: The wedding DJ announces he is projecting the photo booth slideshow live onto the dance floor wall!',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 3,
  ),
  ScenePrompt(
    id: 'ln_18',
    title: 'When the Edibles Hit at the In-Laws\' Dinner',
    filmOrSeries: 'Fifty Milligrams Later (TV-MA Parody)',
    releaseYear: 2026,
    characterName: 'Astral-Projecting Partner & Sober Co-Conspirator',
    promptScript:
        'Did you say that gummy was five milligrams or FIFTY, because your father\'s mustache is currently undulating like a sea anemone! I have been chewing this single piece of garlic bread for nineteen minutes trying to look like a sober, tax-paying adult—why the fuck did you wink and whisper "nobody knows"?! EVERYBODY KNOWS, BABE, THE DOG KNOWS!',
    duetLeadA:
        'Did you say that gummy was five milligrams or FIFTY?! Your dad\'s mustache is moving in 4D!',
    duetLeadB:
        'Put the decorative plastic pear down, stop trying to eat the centerpiece, and smile at my mother!',
    directorCue:
        'Speak with exaggerated slow-motion gravitas as if every syllable takes three business days to form.',
    emotionalTarget: 'Paranoid Philosophical Euphoria [Tier 1 · 1.15x]',
    improvTwist:
        'TWIST AT 15s: They ask you to say grace over the roast beef while you cannot stop giggling at the gravy boat!',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'ln_19',
    title: 'The Hot Mic After the Breakup Sex',
    filmOrSeries: 'Unmuted Discord Squad (TV-MA Parody)',
    releaseYear: 2026,
    characterName: 'Hypocrite Exes on Open Mic',
    promptScript:
        'Look, we signed an emotional treaty: we hate each other\'s guts from 9 AM to 10 PM, and after midnight it\'s strictly recreational cardio. Nobody in our friend group can ever find out you\'re in my bed—wait... why the fuck is my gaming headset glowing green on the nightstand?! Did I leave the party chat unmuted for forty minutes?!',
    duetLeadA:
        'Why is my headset glowing green?! Did we just broadcast forty minutes of breakup sex to the whole squad?!',
    duetLeadB:
        'Tell them my performance was at least a nine point five or I\'m revoking your weekend rematch!',
    directorCue:
        'Start cocky and self-assured until you realize your best friends heard every single word.',
    emotionalTarget: 'Post-Hookup Hypocrisy [Tier 1 · 1.15x]',
    improvTwist:
        'TWIST AT 15s: Twelve people in the voice channel start slow-clapping and rating your stamina out of ten!',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'ln_20',
    title: 'Roommate\'s Sock-on-the-Doorknob Violation',
    filmOrSeries: 'Mozzarella Stick Cockblock (Rated-R Parody)',
    releaseYear: 2026,
    characterName: 'Cockblocked Roommate & Air-Fryer Bandit',
    promptScript:
        'Do you see this argyle dress sock, Tyler?! It was hanging on the exterior brass handle in accordance with the Lease Agreement! You don\'t barge into a bedroom mid-thrust asking if you can borrow the air fryer for mozzarella sticks! You made direct eye contact with my bare ass, nodded like a butler, and still plugged it in!',
    duetLeadA:
        'You don\'t barge into a bedroom mid-thrust asking to borrow the air fryer for mozzarella sticks!',
    duetLeadB:
        'The sock fell off the handle, bro! And honestly your form looked like it needed a five-minute halftime break anyway.',
    directorCue:
        'Wave an imaginary tube sock like a prosecutorial exhibit in a murder trial.',
    emotionalTarget: 'Outraged Domestic Betrayal [Tier 1 · 1.15x]',
    improvTwist:
        'TWIST AT 15s: Your date actually asks if she can have two of the mozzarella sticks before you guys finish!',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 3,
  ),
  ScenePrompt(
    id: 'ln_21',
    title: 'Explaining the Mysterious Hickey Before the Board Pitch',
    filmOrSeries: 'Carotid Cupping Therapy (Rated-R Parody)',
    releaseYear: 2026,
    characterName: 'Bruised Founder & Vampire Co-Founder',
    promptScript:
        'Stop dabbing my neck with that beige concealer sponge, I look like I got attacked by a sentient vacuum cleaner in the stairwell! Why the hell did you go full vampire on my carotid artery twenty minutes before I pitch the Series B investors?! Button my collar to the top and stop smirking while I talk about market penetration!',
    duetLeadA:
        'Why the hell did you go full vampire on my neck twenty minutes before I pitch the Series B investors?!',
    duetLeadB:
        'Because you looked way too stressed in that elevator, and honestly that shade of purple brings out your eyes.',
    directorCue:
        'Hold your chin high and sell the most absurd medical lie imaginable with total Wall Street confidence.',
    emotionalTarget: 'Brazen Executive Bullshitting [Tier 1 · 1.15x]',
    improvTwist:
        'TWIST AT 15s: You turn to the mirror and realize there is an identical lipstick print on the back of your white collar!',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 3,
  ),
  ScenePrompt(
    id: 'ln_22',
    title: 'The Threesome Negotiation PowerPoint',
    filmOrSeries: 'Laminated Bedroom NDA (TV-MA Parody)',
    releaseYear: 2026,
    characterName: 'Type-A Planner & Amused Partners',
    promptScript:
        'Before anyone takes their clothes off, I have prepared a six-slide deck covering hydration intervals, safe words, and post-game snack logistics! Don\'t laugh at me—the last time I winged a spontaneous Cabo three-way, somebody pulled a groin and two people cried in an IHOP! Initial the bottom of the waiver and let\'s get weird.',
    duetLeadA:
        'Before anyone takes their shirt off, please review Slide 3 of my eye-contact distribution matrix!',
    duetLeadB:
        'Did you seriously laminate a bedroom NDA with color-coded snack breaks?! That is weirdly the hottest thing you\'ve ever done.',
    directorCue:
        'Treat an ultra-spicy bedroom proposal like a meticulous Silicon Valley product roadmap.',
    emotionalTarget: 'Over-Prepared Type-A Lunacy [Tier 1 · 1.15x]',
    improvTwist:
        'TWIST AT 15s: Both of them pull out red pens and start negotiating amendments to Clause 4 on the spot!',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'ln_23',
    title: 'Drunk-Texting the Ex From the VIP Bathroom',
    filmOrSeries: 'Two Tequila Personalities (Rated-R Parody)',
    releaseYear: 2026,
    characterName: 'Espresso-Martini Menace & Bathroom Lifeguard',
    promptScript:
        'Give me my phone back! No, wait, take it away from me! Why did you let me drink three espresso martinis when Mercury is in retrograde?! I just texted him "I hope she chokes on your mediocre playlists, also are you awake?" in the same fucking paragraph! Wait—three bubbles are popping up... unblock the door, we\'re either fighting or fucking in ten minutes!',
    duetLeadA:
        'I just texted him "I hate your guts forever, also what are you wearing right now" in the same paragraph!',
    duetLeadB:
        'Put the phone in the sink! You are two tequila shots away from booking an Uber to his apartment!',
    directorCue:
        'Lean against an imaginary marble sink, alternating between fierce pride and instant self-disgust.',
    emotionalTarget: 'Melodramatic Tequila Regret [Tier 1 · 1.15x]',
    improvTwist:
        'TWIST AT 15s: The bathroom door swings open and your ex\'s new partner asks to borrow your lip gloss!',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'ln_24',
    title: 'The Smart Speaker Broadcasts the Bedroom Playlist',
    filmOrSeries: 'Bluetooth Betrayal (TV-MA Parody)',
    releaseYear: 2026,
    characterName: 'Patio Host & Router Yanker',
    promptScript:
        'ALEXA, STOP! ALEXA, SHUT THE FUCK UP! Why are you playing "Sensual Slow Jams for Sinners" on the patio Bluetooth speakers?! My parents and the neighbors are eating potato salad on the deck listening to 90s R&B moaning tracks at eighty decibels! Yank the router out of the drywall before Track 4 starts!',
    duetLeadA:
        'Why the fuck is the living room speaker blasting your "Do Not Disturb" bedroom playlist to the entire dinner party?!',
    duetLeadB:
        'Stop yelling at the ceiling and unplug the router before it auto-plays our voice memo from Cabo!',
    directorCue:
        'Yell commands at an invisible smart speaker that refuses to listen while your guests sit outside.',
    emotionalTarget: 'Techno-Panic Meltdown [Tier 1 · 1.15x]',
    improvTwist:
        'TWIST AT 15s: The smart speaker announces out loud: "Now reading your last incoming text message from Hot Bartender!"',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 3,
  ),
  ScenePrompt(
    id: 'ln_25',
    title: 'Dating App Catfish Turns Out to Be Your Boss\'s Ex',
    filmOrSeries: 'Alimony Tapas (Rated-R Parody)',
    releaseYear: 2026,
    characterName: 'Underpaid Associate & Revenge Ex-Spouse',
    promptScript:
        'Wait a damn minute—you\'re not "Lucas, 29, Landscape Architect," you\'re Richard\'s ex-spouse from the Christmas party lawsuit! Don\'t shush me across the tapas table, I recognize that Rolex! Honestly? That bastard cut my bonus in half last quarter, so sleeping with you feels like union collective bargaining—order the lobster mac on the alimony card!',
    duetLeadA:
        'Hold on—you\'re my boss\'s ex from the divorce settlement! Why did your profile say "Landscape Architect"?!',
    duetLeadB:
        'Because if I put "Professional Alimony Collector Looking for Revenge," people swipe left too fast—now drink your mezcal.',
    directorCue:
        'Go from shocked recognition to wicked, opportunistic intrigue in five seconds flat.',
    emotionalTarget: 'Scandalized Scheming Chemistry [Tier 1 · 1.15x]',
    improvTwist:
        'TWIST AT 15s: Your boss walks into the exact same restaurant three booths behind you!',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'ln_26',
    title: 'The Hot Tub Jet Mishap in Cabo',
    filmOrSeries: 'Turbo Hydro-Therapy (Rated-R Parody)',
    releaseYear: 2026,
    characterName: 'Suitless Swimmer & Margarita Bystander',
    promptScript:
        'Nobody warned me that pressing the red "TURBO HYDRO-THERAPY" button turns this jacuzzi into a firehose powered by Satan! One second I was whispering something seductive in your ear, the next second a pressurized jet launched my swimsuit bottoms into a palm tree! Grab the pool skimmer and rescue my dignity from the hibiscus bush!',
    duetLeadA:
        'That turbo jacuzzi jet just launched my swimsuit bottoms into the resort palm tree—stop laughing and grab the pool net!',
    duetLeadB:
        'I can\'t reach the palm tree because the foam bubbles are already four feet high and security is walking up the stairs!',
    directorCue:
        'Shiver dramatically wrapped in an imaginary towel while defending your dignity.',
    emotionalTarget: 'Soaked Chaotic Improv [Tier 1 · 1.15x]',
    improvTwist:
        'TWIST AT 15s: Half a bottle of complimentary champagne foam starts overflowing across the entire hotel terrace!',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 3,
  ),
  ScenePrompt(
    id: 'ln_27',
    title: 'Fake Moaning to Scare Off the Thin-Walled Neighbor',
    filmOrSeries: 'Drywall Psychological Warfare (TV-MA Parody)',
    releaseYear: 2026,
    characterName: 'Petty Tenants in 4A',
    promptScript:
        'Oh, so Connor in 4B wants to bang his headboard against our drywall at 3 AM on a Tuesday like a caffeinated woodpecker?! Two can play that game—help me bounce on the box spring, slap the leather couch cushion, and yell "NOT THE CHANDELIER!" Look at that—dead silence on the other side of the wall. Now pass me my Cheez-Its.',
    duetLeadA:
        'Help me bounce on the mattress and slap this leather pillow so 4B thinks we\'re breaking Olympic records in here!',
    duetLeadB:
        'Why are you yelling "NOT THE TRAPEZE" at the drywall?! Keep going, he actually stopped thumping his headboard!',
    directorCue:
        'Treat this like an Olympic sound-effects competition against the apartment next door.',
    emotionalTarget: 'Petty Competitive Petty-Fest [Tier 1 · 1.15x]',
    improvTwist:
        'TWIST AT 15s: The neighbor knocks on the wall and yells through the vent asking for your workout routine!',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 3,
  ),
  ScenePrompt(
    id: 'ln_28',
    title: 'The Bachelor Party Stripper Is Your Cousin\'s Accountant',
    filmOrSeries: 'Tax Season Tear-Aways (Rated-R Parody)',
    releaseYear: 2026,
    characterName: 'Best Man & Officer Candy CPA',
    promptScript:
        'Hold the boombox—wait a second, Officer Candy... didn\'t you file my cousin Vinny\'s LLC quarterly taxes in Paramus last April?! I knew I recognized those cheekbones! You saved him eleven grand on depreciation and now you\'re doing a split in tear-away cargo pants—take this twenty and tell me if I can write off this VIP suite!',
    duetLeadA:
        'Wait a minute—Officer Candy, didn\'t you file my cousin\'s LLC taxes in New Jersey last April?!',
    duetLeadB:
        'Tax season ends April 15th, sweetheart, and glute season is year-round—now tuck that twenty in the utility belt!',
    directorCue:
        'Switch rapidly between throwing cash and asking serious questions about itemized deductions.',
    emotionalTarget: 'Awkward Financial Arousal [Tier 1 · 1.15x]',
    improvTwist:
        'TWIST AT 15s: They pull out a pocket calculator mid-dance and audit your bachelor party receipts!',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 4,
  ),

  // ===========================================================================
  // 💋 TIER 2: BEDROOM WALK-INS & SEDUCTIVE NOIR [1.25x] (ln_29 to ln_44)
  // ===========================================================================
  ScenePrompt(
    id: 'ln_29',
    title: 'The Velvet Rope Safe-Word Misunderstanding',
    filmOrSeries: 'Midnight Pumpernickel (TV-MA Parody)',
    releaseYear: 2026,
    characterName: 'Silk-Tie Dom & Hungry Sub',
    promptScript:
        'Wait—stop kissing my collarbone for two seconds, why the hell did we make the safe word "Pumpernickel" when you literally get hungry at midnight?! I can\'t tell if you\'re begging for mercy or asking me to DoorDash a Reuben sandwich from the deli downstairs! Pick a normal word like "Pineapple" so I know whether to untie your wrists!',
    duetLeadA:
        'Why the hell did we make the safe word "Pumpernickel" when you always get hungry right in the middle of foreplay?!',
    duetLeadB:
        'I wasn\'t using the safe word, I was genuinely fantasizing—now tighten the silk knot before the deli closes!',
    directorCue:
        'Deliver every line in a low, smoky bedroom purr before snapping into hilarious practical frustration.',
    emotionalTarget: 'Sultry Deadpan Confusion [Tier 2 · 1.25x]',
    improvTwist:
        'TWIST AT 15s: The DoorDash driver buzzes the intercom downstairs with two actual pastrami sandwiches!',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'ln_30',
    title: 'Caught in the Dressing Room Trailer Between Takes',
    filmOrSeries: 'Method Blocking (Rated-R Parody)',
    releaseYear: 2026,
    characterName: 'Co-Stars With Tangled Mics',
    promptScript:
        'Fix your lipstick and wipe that smudge off my jaw before the First AD bangs on this trailer door again! We were supposed to be rehearsing the emotional courtroom scene, not fogging up the vanity mirror until the wardrobe rack collapsed! If the director asks why my mic pack is tangled in your corset, tell him it\'s method blocking!',
    duetLeadA:
        'Wipe that lipstick off my jaw before the First AD bangs on this trailer door—we\'re due on set in sixty seconds!',
    duetLeadB:
        'Your wireless lav mic is still clipped to my corset, darling—I think the sound booth already knows how rehearsal went.',
    directorCue:
        'Fix your disheveled wardrobe hurriedly while pretending you were only "running lines."',
    emotionalTarget: 'Breathless Hollywood Scandal [Tier 2 · 1.25x]',
    improvTwist:
        'TWIST AT 15s: You hear the sound mixer over the walkie-talkie say your wireless lav mics were transmitting the whole time!',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'ln_31',
    title: 'The Penthouse Balcony Skinny-Dip Lockout',
    filmOrSeries: 'Forty Floors Above Sunset (TV-MA Parody)',
    releaseYear: 2026,
    characterName: 'Locked-Out Lovers & Potted Fern',
    promptScript:
        'Tell me that heavy glass terrace door didn\'t just click shut while both of our silk robes are inside on the barstool! We are forty floors above Sunset Boulevard, soaking wet, with nothing between us and a tourist helicopter except a decorative fern! Hold this cushion over my waist while I jimmy the latch with your hairpin!',
    duetLeadA:
        'That terrace door just locked behind us and the only thing covering us on this balcony is a decorative fern!',
    duetLeadB:
        'Hand me your hairpin, stand right behind me so we share the shadow, and stop distracting me while I pick the lock.',
    directorCue:
        'Hold a tiny object strategically in front of yourself while sweet-talking your way out of disaster.',
    emotionalTarget: 'Seductive Shameless Improvisation [Tier 2 · 1.25x]',
    improvTwist:
        'TWIST AT 15s: Room service rolls a champagne cart into the suite inside and stares through the glass door!',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'ln_32',
    title: 'The Femme Fatale Interrogation Under the Red Lamp',
    filmOrSeries: 'Trench Coat Alibi (Rated-R Parody)',
    releaseYear: 2026,
    characterName: 'Detective Vane & Diamond Suspect',
    promptScript:
        'You walked into my office at 2 AM wearing nothing under that trench coat but a subpoena and three alibis that don\'t match. Don\'t pour me that bourbon and look at me with those bedroom eyes like you didn\'t just clean out the casino vault—tell me where you hid the diamonds before we ruin this desk and both our reputations!',
    duetLeadA:
        'You walked in here at 2 AM wearing nothing under that trench coat but a fake alibi and expensive perfume.',
    duetLeadB:
        'Frisk me properly then, Detective—or are you afraid of what you\'ll find before you read me my rights?',
    directorCue:
        'Circle the camera slowly like a 1940s noir detective who knows they are walking into a trap.',
    emotionalTarget: 'Smoky Sin-City Tension [Tier 2 · 1.25x]',
    improvTwist:
        'TWIST AT 15s: You reach into your trench coat pocket for handcuffs and pull out a glittery novelty bachelorette tiara instead!',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'ln_33',
    title: 'Rival Co-Stars Forced to Film the Love Scene After a Fight',
    filmOrSeries: 'Close-Up Chemistry (TV-MA Parody)',
    releaseYear: 2026,
    characterName: 'Feuding Leads Under Hot Lights',
    promptScript:
        'Listen to me, you arrogant little bastard—the cameras are rolling in five seconds, so look at me like I\'m the only oxygen in this room! I still hate you for stealing my close-up yesterday, so don\'t think pinning me against this prop wall makes us friends... wait, why are you holding the back of my neck like you actually mean it?!',
    duetLeadA:
        'The cameras are rolling in five seconds—look at me like you\'re dying for me even if we hated each other at lunch.',
    duetLeadB:
        'Who said I was acting, sweetheart? Stop talking before you miss your cue to kiss me.',
    directorCue:
        'Deliver fierce whispered insults through a passionate movie-star gaze inches from the lens.',
    emotionalTarget: 'Explosive Enemies-to-Lovers Heat [Tier 2 · 1.25x]',
    improvTwist:
        'TWIST AT 15s: The intimacy coordinator yells from off-camera reminding you that the script only called for a polite handshake!',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'ln_34',
    title: 'The Midnight Hotel Ice-Machine Encounter',
    filmOrSeries: 'Suite 1408 After Hours (Rated-R Parody)',
    releaseYear: 2026,
    characterName: 'Silk-Robe Strangers on the 14th Floor',
    promptScript:
        'Nobody actually needs ice at 3:15 in the morning, which means you stepped into this hallway hoping you\'d run into me. You\'re standing there in a hotel robe holding an empty plastic bucket like the worst spy in Manhattan—my room is 1408, drop the bucket and tell me how quiet you can be before sunrise.',
    duetLeadA:
        'Nobody actually needs ice at 3:15 AM—admit you walked into this hallway hoping my door would open.',
    duetLeadB:
        'Maybe I just wanted to see if you looked this good under terrible hotel fluorescent lighting—spoiler alert, you do.',
    directorCue:
        'Play the quiet hallway tension where every whispered line sounds like a dare.',
    emotionalTarget: 'Electric Late-Night Flirtation [Tier 2 · 1.25x]',
    improvTwist:
        'TWIST AT 15s: The noisy ice machine suddenly dumps forty pounds of ice all over the hallway carpet!',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 3,
  ),
  ScenePrompt(
    id: 'ln_35',
    title: 'When the Couples Massage Turns Into a Confession Booth',
    filmOrSeries: 'Eucalyptus Oil & Pan Flutes (Rated-R Parody)',
    releaseYear: 2026,
    characterName: 'Face-Cradle Whisperers',
    promptScript:
        'Psst—babe, look at me through the little face-hole in the massage table! Why is this Swedish guy oiling my inner thigh like a rotisserie chicken?! Every time you giggle, I clench my glutes and the masseuse thinks I\'m asking for extra elbow pressure—as soon as they step out, we\'re locking this candlelit door for fifteen minutes!',
    duetLeadA:
        'Psst—look at me through the massage table face-hole! Why does this oil smell like a sensual hibachi grill?!',
    duetLeadB:
        'Stop making me laugh while my back is bare, grab my hand between the tables and behave for sixty seconds!',
    directorCue:
        'Talk as if your face is pressed through a massage table cradle trying to whisper to the table next to you.',
    emotionalTarget: 'Hushed Sensual Chaos [Tier 2 · 1.25x]',
    improvTwist:
        'TWIST AT 15s: You realize the masseuses quietly left the room four minutes ago and you\'ve been whispering to the floor!',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 3,
  ),
  ScenePrompt(
    id: 'ln_36',
    title: 'The Silk Robe & Alibi in the Billionaire\'s Study',
    filmOrSeries: 'Tie on the Chandelier (TV-MA Parody)',
    releaseYear: 2026,
    characterName: 'Gala Escapee & Secret Lover',
    promptScript:
        'Keep your voice down—there are thirty guests drinking champagne by the infinity pool and your silk tie is still hanging from my chandelier! If the detectives ask where you were between midnight and two, tell them we were appraising your private art collection in the dark—now button your cuffs over those scratch marks!',
    duetLeadA:
        'There are thirty guests by the infinity pool and your silk tie is still hanging from my chandelier.',
    duetLeadB:
        'Let them look—half of them wish they had a better alibi than the one you just gave me.',
    directorCue:
        'Channel a glossy late-night thriller where everyone is guilty and dangerously attractive.',
    emotionalTarget: 'Dangerous Luxury Seduction [Tier 2 · 1.25x]',
    improvTwist:
        'TWIST AT 15s: The wall safe behind the oil painting beeps open by itself because your elbow hit the secret switch!',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'ln_37',
    title: 'Caught Steaming Up the Limo Partition',
    filmOrSeries: 'Five Blocks to the Premiere (Rated-R Parody)',
    releaseYear: 2026,
    characterName: 'Red-Carpet Nominees in the Backseat',
    promptScript:
        'Did you actually press the privacy partition button, or has the chauffeur been watching us in the rearview mirror since Fifth Avenue?! Look at this backseat—my cufflinks are in the ice bucket, your dress is half-unzipped, and we\'re pulling up to the red carpet in ninety seconds! Tell the driver to circle the block one more time!',
    duetLeadA:
        'We are pulling up to the red carpet in ninety seconds and your dress is still half-unzipped in this backseat!',
    duetLeadB:
        'Tell the chauffeur to circle the block—we haven\'t even finished what we started at the Midtown tunnel.',
    directorCue:
        'Brace yourself against an imaginary leather seat as the limo takes a sharp corner.',
    emotionalTarget: 'Glamorous Backseat Recklessness [Tier 2 · 1.25x]',
    improvTwist:
        'TWIST AT 15s: The partition rolls down and the driver politely offers you a lint roller and two breath mints!',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'ln_38',
    title: 'The Private Jet Mile-High Turbulence Gamble',
    filmOrSeries: 'Gulfstream Lavatory (TV-MA Parody)',
    releaseYear: 2026,
    characterName: 'High-Altitude Rebels at 40,000 Feet',
    promptScript:
        'The captain just turned the fasten-seatbelt sign on, which means we have roughly four minutes before the flight attendant knocks on this lavatory door! How the hell did we fit two grown adults and a bottle of Dom Pérignon into a carbon-fiber bathroom at forty thousand feet?! Brace your hands against the bulkhead and don\'t touch the flush button!',
    duetLeadA:
        'How the hell did we fit two people and a bottle of Dom Pérignon into this jet bathroom at forty thousand feet?!',
    duetLeadB:
        'Stop complaining about legroom and hold onto my waist before we hit another pocket of turbulence.',
    directorCue:
        'Sway with the cabin turbulence while refusing to return to your assigned seat.',
    emotionalTarget: 'High-Altitude Adrenaline Lust [Tier 2 · 1.25x]',
    improvTwist:
        'TWIST AT 15s: Your elbow hits the yellow attendant call button four times in a row!',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'ln_39',
    title: 'The Secret Office After-Hours Elevator Stall',
    filmOrSeries: 'Between Floor 28 & 29 (TV-MA Parody)',
    releaseYear: 2026,
    characterName: 'Overtime Rivals in the Express Lift',
    promptScript:
        'Did you just hit the emergency stop button between the 28th and 29th floors, or did fate finally read my mind? We have spent six months pretending to care about quarterly spreadsheets while eye-fucking across the conference table—take off that ridiculous lanyard, pin me against the brass handrail, and show me why we stayed late!',
    duetLeadA:
        'Did you just hit the emergency stop button between floors, or did this elevator finally read my mind?',
    duetLeadB:
        'We have twelve minutes before maintenance checks the panel—stop talking about spreadsheets and come here.',
    directorCue:
        'Glance up at the imaginary security camera in the corner of the elevator, then lean in closer.',
    emotionalTarget: 'Forbidden Corporate Heat [Tier 2 · 1.25x]',
    improvTwist:
        'TWIST AT 15s: The elevator intercom crackles and the night guard asks if you want him to put on some Barry White!',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'ln_40',
    title: 'Undressing Under the Speakeasy Booth Table',
    filmOrSeries: 'Velvet Tablecloth Alibi (TV-MA Parody)',
    releaseYear: 2026,
    characterName: 'Corner-Booth Sinners',
    promptScript:
        'Smile at the waiter and act normal—if you slide your foot one inch higher under this tablecloth I am going to knock over the candle! We are sitting in a velvet corner booth five feet from the jazz quartet and you just unhooked your garter like a bank robber—as soon as the saxophone solo hits, we\'re slipping out the back door!',
    duetLeadA:
        'Act normal while the waiter pours the wine—if your foot goes one inch higher under this tablecloth I\'m losing my composure!',
    duetLeadB:
        'Take a sip of your bourbon, look me dead in the eyes, and pretend we\'re discussing the stock market.',
    directorCue:
        'Keep your upper body poised and sophisticated while reacting to scandalous activity under the table.',
    emotionalTarget: 'Wicked Public Stealth [Tier 2 · 1.25x]',
    improvTwist:
        'TWIST AT 15s: The jazz singer walks right up to your table with a spotlight to dedicate a slow ballad to you two!',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'ln_41',
    title: 'The Lingerie Delivery Mix-Up With the Neighbor',
    filmOrSeries: 'Wrong Apartment 6B (Rated-R Parody)',
    releaseYear: 2026,
    characterName: '6A Buyer & 6B Package Opener',
    promptScript:
        'Before you apologize for opening my mail in 6B, let\'s discuss why you look that good holding my black lace bodysuit. Clearly the courier saw both our apartment numbers and decided this hallway needed community outreach—so either hand the box back, or step inside, lock the deadbolt, and help me test how all those gold straps fasten!',
    duetLeadA:
        'So you opened my package by mistake in 6B—now are you returning it, or helping me test the fit?',
    duetLeadB:
        'Considering how long I\'ve been waiting for an excuse to knock on your door, I think quality control requires two people.',
    directorCue:
        'Lean in the doorway holding an opened package with zero embarrassment and 100% confidence.',
    emotionalTarget: 'Brazen Flirtatious Escalation [Tier 2 · 1.25x]',
    improvTwist:
        'TWIST AT 15s: The box also contains a battery-operated novelty item that accidentally switches ON in your hands!',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 3,
  ),
  ScenePrompt(
    id: 'ln_42',
    title: 'The Wine Cellar Tasting That Went Off-Script',
    filmOrSeries: 'Reserve 1998 Cellar (Rated-R Parody)',
    releaseYear: 2026,
    characterName: 'Private Sommelier & VIP Guest',
    promptScript:
        'Forget the 1998 Bordeaux—we haven\'t tasted a single bottle since we locked the cellar grate twenty minutes ago. Careful with your elbows, that rack behind your back is worth forty grand and the way you\'re arching against it is a structural hazard—wipe that burgundy stain off my lower lip before someone comes down the stairs!',
    duetLeadA:
        'Careful against that wine rack—those bottles are from 1998 and you\'re making the whole shelf rattle.',
    duetLeadB:
        'Then hold me steadier, darling, because I have zero intention of going back upstairs to the dinner party.',
    directorCue:
        'Swirl an imaginary cabernet while backing your co-star against a rack of vintage bottles.',
    emotionalTarget: 'Intoxicated Aristocratic Lust [Tier 2 · 1.25x]',
    improvTwist:
        'TWIST AT 15s: A dusty antique bottle rolls off the top shelf and you have to catch it mid-kiss with one hand!',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'ln_43',
    title: 'The Fake Marriage Decoy in the Honeymoon Suite',
    filmOrSeries: 'Mirror on the Ceiling (Rated-R Parody)',
    releaseYear: 2026,
    characterName: 'Undercover Newlyweds',
    promptScript:
        'Okay, when the agency booked us undercover as "newlyweds," I didn\'t realize the suite came with a mirror on the ceiling and one heart-shaped king bed! Stop throwing rose petals at me and laughing—if anyone looks through the balcony curtains right now, we better climb under the silk duvet and make this cover story look convincing!',
    duetLeadA:
        'There is one heart-shaped bed and a mirror on the ceiling—how the hell are we supposed to stay professional in here?!',
    duetLeadB:
        'Professionalism is overrated when the room is already paid for—lose the blazer and get over here.',
    directorCue:
        'Survey a ridiculously romantic heart-shaped bed while trying to maintain your professional cover story.',
    emotionalTarget: 'Slow-Burn Romantic Tension [Tier 2 · 1.25x]',
    improvTwist:
        'TWIST AT 15s: Hotel staff knocks with complimentary chocolate-covered strawberries and demands to see a newlywed kiss!',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 3,
  ),
  ScenePrompt(
    id: 'ln_44',
    title: 'Midnight Piano Bar Encore After Closing Time',
    filmOrSeries: 'Low C-Sharp After Hours (Rated-R Parody)',
    releaseYear: 2026,
    characterName: 'Late-Night Pianist & Front-Row Patron',
    promptScript:
        'The bartender flipped the chairs twenty minutes ago, the neon sign is off, and you\'re still sitting on the edge of my piano bench. Don\'t ask me to play another ballad when you\'ve been undressing me with your eyes since the second set—careful where you put your hips, that low C-sharp echoes through the whole building!',
    duetLeadA:
        'The bar closed twenty minutes ago—are you here for another song, or did you stay to ruin my concentration?',
    duetLeadB:
        'Close the keyboard lid before we break a Steinway, because I didn\'t stay after hours to talk about jazz.',
    directorCue:
        'Lean across an imaginary grand piano lid as the neon bar sign flickers off.',
    emotionalTarget: 'Velvet Late-Night Intimacy [Tier 2 · 1.25x]',
    improvTwist:
        'TWIST AT 15s: Your hip slams a dramatic dissonant chord on the piano keys that echoes through the empty lounge!',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 4,
  ),

  // ===========================================================================
  // 🧨 TIER 3: UNHINGED TV-MA MELTDOWNS & FILTHY ROASTS [1.35x] (ln_45 to ln_60)
  // ===========================================================================
  ScenePrompt(
    id: 'ln_45',
    title: 'The Scorched-Earth VIP Section Breakup Roast',
    filmOrSeries: 'Declined in VIP (TV-MA Parody)',
    releaseYear: 2026,
    characterName: 'Unstoppable Ex & Broke Club Promoter',
    promptScript:
        'Turn the fucking DJ booth down because everyone in VIP needs to hear why Chad\'s credit card just got declined on a $400 tab! You brought me to this club to soft-launch a breakup while wearing a chain I bought you, you audacity-powered clown! Keep the watered-down vodka, I\'m leaving with the promoter and taking the valet ticket, bitch!',
    duetLeadA:
        'Turn the fucking music down—everyone in VIP needs to hear how your card just declined on a $400 bottle tab!',
    duetLeadB:
        'Wait—it was a fraud alert because I bought these fake veneers! Don\'t leave with the DJ, give me the valet ticket!',
    directorCue:
        'Stand up in the booth and roast your ex with surgical comedic precision and zero filter.',
    emotionalTarget: 'Nuclear Champagne Fury [Tier 3 · 1.35x]',
    improvTwist:
        'TWIST AT 15s: The club bottle girls march out holding a giant LED sign spelling out your ex\'s declined card alert!',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'ln_46',
    title: 'The Unhinged Best Man Toast That Ruins Two Families',
    filmOrSeries: 'Scottsdale Receipts (TV-MA Parody)',
    releaseYear: 2026,
    characterName: 'Rogue Best Man & Panicked Groom',
    promptScript:
        'Testing, testing—fuck these polite index cards, let\'s talk about what actually happened in Scottsdale three nights ago! Everybody raise your champagne glasses to the groom, a man who promised he\'d pay back my five grand right before I caught him DMing the wedding planner! May your marriage last longer than your hairline, bro—peace out!',
    duetLeadA:
        'Fuck these polite index cards—let\'s tell Table 1 what actually happened in Scottsdale three nights ago!',
    duetLeadB:
        'Cut his mic! DJ, play the Cha-Cha Slide right fucking now before he mentions the Cabo yacht receipt!',
    directorCue:
        'Tap the mic so it squeals, rip up the polite speech cards, and go full scorched-earth.',
    emotionalTarget: 'Chaotic Truth-Bomb Apocalypse [Tier 3 · 1.35x]',
    improvTwist:
        'TWIST AT 15s: The bride grabs a second microphone and starts cheering you on to spill the rest of the tea!',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'ln_47',
    title: 'Roasting the Pretentious Method Actor on Set',
    filmOrSeries: 'Nasal Spray Method (TV-MA Parody)',
    releaseYear: 2026,
    characterName: 'Fed-Up Co-Star & Pretentious Thespian',
    promptScript:
        'If you tell me one more fucking time that "your character wouldn\'t pass the salt," I am shoving this craft-services bagel down your throat! We are filming a three-minute commercial for allergy nasal spray, Julian, you are not Daniel Day-Lewis in Florence! Hit your mark and read the cue card before I replace you with a golden retriever in a wig!',
    duetLeadA:
        'We are filming a commercial for allergy nasal spray, Julian—stop telling me your character needs "emotional motivation"!',
    duetLeadB:
        'You wouldn\'t understand my artistic process! My nasal passages carry generational trauma from the second act!',
    directorCue:
        'Stalk across the soundstage dismantling an insufferable co-star in front of the entire crew.',
    emotionalTarget: 'Volcanic Veteran Fed-Up Rage [Tier 3 · 1.35x]',
    improvTwist:
        'TWIST AT 15s: The boom mic operator drops the boom pole slightly into frame because he\'s laughing so hard!',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'ln_48',
    title: 'The 4 AM Diner Showdown After the Club Fight',
    filmOrSeries: 'Waffle House Forensics (TV-MA Parody)',
    releaseYear: 2026,
    characterName: 'Glitter-Covered Survivors at Booth 4',
    promptScript:
        'Pass the fucking waffle syrup and nobody say a single word until I pull this glitter extension piece out of my eyelashes! Whose bright idea was it to tell the 300-pound bouncer he looked like a thumb with a goatee?! Now we\'re banned from every lounge on the strip—eat your hash browns and split the check four ways!',
    duetLeadA:
        'Whose bright idea was it to tell the 300-pound bouncer he looked like a thumb in a tight polo?!',
    duetLeadB:
        'In my defense, he started it by asking for a cover charge when my heels were already killing me—now pass the bacon!',
    directorCue:
        'Point a fork across a vinyl diner booth while dissecting everyone\'s atrocious life choices.',
    emotionalTarget: 'Greasy-Spoon Delirious Savagery [Tier 3 · 1.35x]',
    improvTwist:
        'TWIST AT 15s: The bouncer you insulted walks into the exact same diner to pick up his takeout order!',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'ln_49',
    title: 'Confronting the Serial Cheater With Printed Screenshots',
    filmOrSeries: 'FedEx Office High-Gloss (TV-MA Parody)',
    releaseYear: 2026,
    characterName: 'Forensic Partner & Caught Copy-Paster',
    promptScript:
        'Don\'t "babe, let me explain" me—I went to FedEx Office and printed your DM history in high-gloss color at sixty cents a page! Exhibit A: you told me you were "helping your buddy move a couch," yet here you are at 11:42 PM copy-pasting the exact same dirty paragraph to three people like a horny mail-merge! Pack your air fryer and get out!',
    duetLeadA:
        'I went to FedEx Office and printed your DM history in high-gloss color—explain Exhibit A right fucking now!',
    duetLeadB:
        'Wait—did you use my rewards points at FedEx to print my own incriminating evidence?! That\'s cold-blooded!',
    directorCue:
        'Slam imaginary laminated screenshots onto the table like a district attorney closing a RICO case.',
    emotionalTarget: 'Forensic Courtroom Vengeance [Tier 3 · 1.35x]',
    improvTwist:
        'TWIST AT 15s: Two of the other people from the screenshots walk out of your kitchen wearing matching robes to back you up!',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'ln_50',
    title: 'The Reality TV Reunion Couch Meltdown',
    filmOrSeries: 'Mykonos Receipts Reunion (TV-MA Parody)',
    releaseYear: 2026,
    characterName: 'Reunion Queen & Exposed Rival',
    promptScript:
        'Don\'t roll the clip, Andy—I will tell America right now what this fake-tanned sociopath said when the cameras went down in Mykonos! You spent ten episodes crying about "loyalty" while sneaking into my pool cabana with the sound guy\'s brother! Zoom in on my face, Camera 2: I brought the Venmo logs and the valet footage—roll THAT fucking tape!',
    duetLeadA:
        'Don\'t roll the clip—I brought the Venmo logs, the valet footage, and the Mykonos receipts right in my dress!',
    duetLeadB:
        'Keep my skincare line out of your mouth before I tell Andy who really clogged the yacht plumbing in Episode 6!',
    directorCue:
        'Point dramatic manicured fingers across the reunion stage while refusing to let the host interrupt.',
    emotionalTarget: 'High-Glamour Petty Warfare [Tier 3 · 1.35x]',
    improvTwist:
        'TWIST AT 15s: The mystery sound guy walks out from backstage holding a bouquet and a microphone!',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'ln_51',
    title: 'Firing Your Agent Over Speakerphone in Traffic',
    filmOrSeries: '405 Freeway Rampage (TV-MA Parody)',
    releaseYear: 2026,
    characterName: 'A-List Diva & Sweating Talent Agent',
    promptScript:
        'Ten percent?! You take ten fucking percent of my gross to send me an audition for "Guy Who Gets Eaten by a CGI Shark in Scene 1"?! I have a Golden Globe nomination and you pitched me for a non-union yogurt commercial in Burbank where I play the bloated stomach! Consider yourself fired, blocked, and uninvited from my wrap party!',
    duetLeadA:
        'You take ten fucking percent of my paycheck to book me as "Bloated Guy #2" in a probiotic yogurt commercial?!',
    duetLeadB:
        'First of all, it\'s a national spot with residuals, and second of all, you owed three months on your lease—sign the deal!',
    directorCue:
        'Channel an iconic high-decibel Beverly Hills talent meltdown stuck on the 405 freeway.',
    emotionalTarget: 'Hollywood Mogul Rampage [Tier 3 · 1.35x]',
    improvTwist:
        'TWIST AT 15s: You realize your car window is rolled down and the celebrity director you worship is in the convertible next to you!',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'ln_52',
    title: 'The Bachelor Pad Blacklight Forensics Audit',
    filmOrSeries: 'Chernobyl Futon (TV-MA Parody)',
    releaseYear: 2026,
    characterName: 'UV Inspector & Defensive Bachelor',
    promptScript:
        'Why the fuck did I bring a UV flashlight into your bedroom?! This futon looks like a radioactive Jackson Pollock painting! Do you ever wash your sheets, or are you running a biological weapons lab under a duvet cover from Target?! Burn the mattress, call a priest, and don\'t touch my purse until you\'ve dipped both hands in bleach!',
    duetLeadA:
        'Why does your bedroom glow like Chernobyl under this blacklight?! Did you ever wash these sheets once in 2025?!',
    duetLeadB:
        'Turn that CSI flashlight off! Half of that is tonic water from the glow party and the other half is none of your business!',
    directorCue:
        'Shine an imaginary UV blacklight across a horrific bachelor apartment and recoil in theatrical terror.',
    emotionalTarget: 'Disgusted Comedic Horror [Tier 3 · 1.35x]',
    improvTwist:
        'TWIST AT 15s: You shine the blacklight on your own jacket sleeve and realize you leaned against the beanbag chair!',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'ln_53',
    title: 'Thanksgiving Clapback at the Nosy Relative Table',
    filmOrSeries: 'Pass the Cranberry & Receipts (TV-MA Parody)',
    releaseYear: 2026,
    characterName: 'Wine-Fueled Black Sheep & Nosy Aunt',
    promptScript:
        'If one more person at this table asks why I\'m still single at thirty-two, I am reading Uncle Richard\'s secret dating profile over the turkey! Yeah, I said it! Pass the cranberry sauce while we talk about why cousin Brenda\'s "spiritual retreat in Sedona" was actually county probation—now pour me the rest of the Cabernet and mind your fucking business!',
    duetLeadA:
        'Ask me why I\'m still single one more time and I\'m reading everybody\'s browser history over the stuffing!',
    duetLeadB:
        'Sit down and pass the gravy—Grandma\'s recording this for her TikTok and you\'re blocking the ring light!',
    directorCue:
        'Stand up at the dining table after your third glass of pinot noir and settle every family score at once.',
    emotionalTarget: 'Wine-Fueled Holiday Liberation [Tier 3 · 1.35x]',
    improvTwist:
        'TWIST AT 15s: Grandma clinks her glass and slides you a fifty-dollar bill under the mashed potatoes for roasting Uncle Richard!',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'ln_54',
    title: 'The Yacht Party NDA Mutiny',
    filmOrSeries: 'Biscayne Bay Mutiny (TV-MA Parody)',
    releaseYear: 2026,
    characterName: 'Mutinous VIP Guest & Fake Billionaire Host',
    promptScript:
        'You invited twelve models and three comedians onto a rented yacht in Miami and now you want us to sign a forty-page NDA before you open the tequila?! What the fuck are you hiding down in the cabin, Trevor—nuclear launch codes or the fact that you rent your Lamborghini by the hour?! Unlock the Don Julio or we\'re livestreaming your hairline in 4K!',
    duetLeadA:
        'Nobody is signing a forty-page NDA just to watch you DJ shirtless on a rented boat in Biscayne Bay!',
    duetLeadB:
        'Sign the clipboard or swim back to South Beach—my lawyer drafted Clause 9 specifically because of your Instagram stories!',
    directorCue:
        'Toss an imaginary stack of legal papers over the yacht railing while roasting the billionaire host.',
    emotionalTarget: 'Champagne-Soaked Rebellion [Tier 3 · 1.35x]',
    improvTwist:
        'TWIST AT 15s: The Coast Guard pulls up alongside the yacht and recognizes the host from a tax evasion poster!',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'ln_55',
    title: 'The Comedy Club Heckler Destruction',
    filmOrSeries: 'Two-Drink Minimum Massacre (TV-MA Parody)',
    releaseYear: 2026,
    characterName: 'Headliner Comedian & Deep-V Heckler',
    promptScript:
        'Oh, look everybody, the guy in the front row wearing a deep-V neck at 11 PM has an opinion on my set! Sir, did you button your shirt down to your navel on purpose, or did your chest hair file for emancipation on the ride over?! Don\'t whisper to your date like she\'s impressed—she\'s been texting her Uber driver "rescue me" since the appetizer arrived!',
    duetLeadA:
        'Did you button that shirt down to your navel on purpose, sir, or are you auditioning for a budget Magic Mike reboot?!',
    duetLeadB:
        'Hey, this shirt is imported silk—and my date told me it makes my collarbones look dangerous!',
    directorCue:
        'Shield your eyes from the stage spotlight, lock onto a front-row heckler, and obliterate them.',
    emotionalTarget: 'Razor-Sharp Stand-Up Savagery [Tier 3 · 1.35x]',
    improvTwist:
        'TWIST AT 15s: The heckler\'s date stands up, applauds your roast, and moves to a solo VIP table up front!',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'ln_56',
    title: 'Catching Your Best Friend in the VIP Coat Check',
    filmOrSeries: 'Coat Rack B Betrayal (TV-MA Parody)',
    releaseYear: 2026,
    characterName: 'Betrayed Wingman & Coat-Rack Culprit',
    promptScript:
        'Excuse me, I just came back here to grab my leather jacket—WHY THE FUCK ARE YOUR LEGS WRAPPED AROUND MY ARCH-NEMESIS IN COAT RACK B?! You spent forty-five minutes in the car hyping me up about how we were going to ignore him all night, and now there are three coat hangers stuck in your hair! Buy me four shots of reposado and never speak of Coat Rack B again!',
    duetLeadA:
        'You spent forty minutes telling me to block him, and now I find you two tangled inside Coat Rack B?!',
    duetLeadB:
        'In my defense, the lighting back here is incredible and he apologized with very convincing tongue work!',
    directorCue:
        'Part two imaginary fur coats and react to catching your friend red-handed with your sworn nemesis.',
    emotionalTarget: 'Betrayed Hyped-Up Disbelief [Tier 3 · 1.35x]',
    improvTwist:
        'TWIST AT 15s: The coat-check attendant pops up from behind the counter eating popcorn and charges you $5 for the show!',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'ln_57',
    title: 'The Late-Night Talk Show Green Room Mutiny',
    filmOrSeries: 'Seven-Second Delay (TV-MA Parody)',
    releaseYear: 2026,
    characterName: 'Unfiltered Guest & Panicked Segment Producer',
    promptScript:
        'Tell the network censors to warm up their seven-second delay button, because I am not reading these sanitized pre-interview questions! You bumped my segment behind a TikTok influencer who lip-syncs to blender noises, and now you want me to smile and plug a rom-com?! Pour vodka in my talk-show mug and watch what happens when an actor stops caring about PR!',
    duetLeadA:
        'Tell the network censors to warm up the bleep button—I am going out through that curtain with zero filter tonight!',
    duetLeadB:
        'We are already live on the East Coast feed! Smile and wave at the studio audience right fucking now!',
    directorCue:
        'Rip out your IFB earpiece thirty seconds before going live on national television.',
    emotionalTarget: 'Zero-Fucks-Left Broadcast Chaos [Tier 3 · 1.35x]',
    improvTwist:
        'TWIST AT 15s: The curtain pulls back early and you are already live on camera in front of the studio audience!',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'ln_58',
    title: 'The Post-Awards Afterparty Bathroom Stall Gossip',
    filmOrSeries: 'Louboutins Under Stall 1 (TV-MA Parody)',
    releaseYear: 2026,
    characterName: 'Gossiping Nominees at the Vanity Mirror',
    promptScript:
        'Lock the lounge door—did you see the Best Actor winner trying to sneak out of the Chateau Marmont freight elevator with two publicists?! He thanked his spouse onstage with tears in his eyes, and twenty minutes later he was doing body shots off a stunt double by the valet! Wait... why did two silver stilettos just appear under Stall 1?!',
    duetLeadA:
        'Did you see him thank his spouse onstage and then sneak into the freight elevator twenty minutes later?!',
    duetLeadB:
        'Lower your voice, look under Stall 1—those are literally the custom Louboutins we were just talking about!',
    directorCue:
        'Touch up your makeup in the mirror while dishing filthy Hollywood secrets before realizing who is in Stall 1.',
    emotionalTarget: 'Scandalous Champagne Dish-Session [Tier 3 · 1.35x]',
    improvTwist:
        'TWIST AT 15s: The stall door clicks open and the exact A-lister you just roasted steps out to wash their hands next to you!',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'ln_59',
    title: 'Evicting the Squatting Situationship',
    filmOrSeries: 'Squatters\' Rights in Sweatpants (TV-MA Parody)',
    releaseYear: 2026,
    characterName: 'Leaseholder & PS5 Squatter',
    promptScript:
        'You came over for a Friday night hookup three weeks ago and somehow your PlayStation 5 is now plugged into my living room OLED! That is not "quality time," Marcus, that is squatters\' rights in velvet sweatpants while eating all my pistachio gelato! Grab your HDMI cord, put on some real pants, and vacate before I invoice you for Wi-Fi!',
    duetLeadA:
        'You came over for a Friday hookup three weeks ago—why the fuck is your PlayStation plugged into my TV?!',
    duetLeadB:
        'Babe, don\'t unplug it mid-update! And technically I bought paper towels on Tuesday so I\'m a contributing resident!',
    directorCue:
        'Toss imaginary gaming gear into a laundry basket with rhythmic, unstoppable fury.',
    emotionalTarget: 'Ruthless Domestic Eviction [Tier 3 · 1.35x]',
    improvTwist:
        'TWIST AT 15s: A mail carrier knocks and hands you a certified letter showing they already forwarded their mail to your address!',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'ln_60',
    title: 'The Midnight Speakeasy Microphone Drop Finale',
    filmOrSeries: 'Uncensored Encore (TV-MA Parody)',
    releaseYear: 2026,
    characterName: 'Speakeasy Headliner & Velvet-Booth Rival',
    promptScript:
        'Listen up, sinners, saints, and everybody hiding in the velvet booths pretending they have an early meeting tomorrow! We didn\'t sneak past the bouncer at 2 AM to sip sparkling water and play polite PG-13 parlor games! Pour the top-shelf bourbon, lock the speakeasy vault, and let\'s give the casting booth a take they aren\'t allowed to air before midnight!',
    duetLeadA:
        'We didn\'t sneak into this speakeasy at 2 AM to play polite PG-13 parlor games—pour the top-shelf bourbon!',
    duetLeadB:
        'The doors are locked, the cameras are rolling, and the next thirty seconds belong to us—let\'s burn the stage down!',
    directorCue:
        'Own the entire room like the undisputed headliner of an underground 2 AM speakeasy.',
    emotionalTarget: 'Legendary Uncensored Bravado [Tier 3 · 1.35x]',
    improvTwist:
        'TWIST AT 15s: The spotlight turns 24K gold and the entire speakeasy crowd chants for a 5-second unfiltered encore!',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 5,
  ),
];

/// ============================================================================
/// 20 RATED-R / TV-MA SPEAKEASY DARE WHEEL & "LIFE IS IMPROV" SECRET DOSSIERS
/// ============================================================================
const List<String> kTwentyRaunchySpeakeasyWheelDares = <String>[
  'Deliver every line like you are hiding a scandalous 3 AM hookup alibi from the person sitting to your left.',
  'Maintain unbroken bedroom-eyes contact with the camera lens while accusing your co-star of stealing your underwear.',
  'Deliver the monologue as a breathless midnight confession in a stalled VIP penthouse elevator.',
  'Speak with velvet, slow-burn seduction until the final 5 words—then erupt into an unhinged TV-MA roast.',
  'Act as if the person across from you just slipped a hotel room keycard and handcuffs under the tablecloth.',
  'Deliver the scene while biting back a wicked, guilty morning-after smirk after every sentence.',
  'Perform the first 15 seconds like a polite corporate Zoom call while pretending someone is under your desk.',
  'Deliver the script as if you are leaving a frantic 2 AM voice note trying to cancel an accidental thirst-trap.',
  'Read every line like a ruthless VIP bouncer deciding who is hot enough to get past the velvet rope.',
  'Deliver the take as if your ex just walked into the bar wearing the jacket they stole from your apartment.',
  'Channel a shameless walk-of-shame survivor explaining why you are wearing last night\'s formalwear at 9 AM.',
  'Perform the scene in a husky noir whisper as if the bedroom walls are paper-thin and the neighbors are listening.',
  'Act as if you just realized your wireless microphone was left ON inside the dressing room trailer.',
  'Deliver the monologue while pretending to hide behind a tiny decorative houseplant on a penthouse balcony.',
  'Sell the entire scene like an intoxicated best man ripping up the approved speech cards at the open bar.',
  'Perform the take as if you are negotiating a laminated 3-way bedroom NDA with a red pen.',
  'Deliver every sentence like a passionate movie-star rival about to kiss their co-star mid-argument.',
  'Act as if a smart speaker in the next room just started blasting your secret bedroom playlist to your parents.',
  'Deliver the lines like a high-priced crisis publicist covering up a leaked Cabo jacuzzi scandal.',
  'Finish the take with a slow-motion microphone drop and a shameless wink straight into the camera lens.',
];

const List<LifeIsImprovSecretDare> kTwentyRaunchyLifeIsImprovDares = <LifeIsImprovSecretDare>[
  // 1-5: House Party / Bar
  LifeIsImprovSecretDare(
    id: 'lii_party_01',
    setting: LifeIsImprovSetting.housePartyBar,
    dossierTitle: 'The Fake Hookup Alibi',
    undercoverPersona: 'Shameless VIP Party Conspirator',
    openingLineToSayOutLoud:
        'Listen closely and don\'t laugh—if anyone asks where we were for the last twenty minutes, tell them the bathroom lock jammed and my belt buckle broke, got it?',
    midDareEscalation15s:
        'Look at the nearest drink and whisper: "Also, pretend this is ginger ale, my publicist is watching."',
    targetReactionFromRoom:
        'Get someone in the room to nod, play along, or ask what the hell happened.',
    spiceTier: 4,
  ),
  LifeIsImprovSecretDare(
    id: 'lii_party_02',
    setting: LifeIsImprovSetting.housePartyBar,
    dossierTitle: 'The NDA Party Crash',
    undercoverPersona: 'Celebrity Crisis Fixer',
    openingLineToSayOutLoud:
        'Alright, listen closely—before anyone posts a single story tonight, my legal team needs everyone within ten feet to confirm they did NOT see two people in the coat closet.',
    midDareEscalation15s:
        'Nod gravely at the first person who laughs and whisper: "So you\'re the TMZ leak."',
    targetReactionFromRoom:
        'Provoke genuine laughter or someone checking the coat closet.',
    spiceTier: 4,
  ),
  LifeIsImprovSecretDare(
    id: 'lii_party_03',
    setting: LifeIsImprovSetting.housePartyBar,
    dossierTitle: 'The Accidental Thirst-Trap Crisis',
    undercoverPersona: 'Panicked Group-Chat Sinner',
    openingLineToSayOutLoud:
        'Oh fuck, emergency poll for the room: if you accidentally sent a spicy towel mirror pic to the neighborhood HOA chat, do you move out tonight or send a second angle to assert dominance?',
    midDareEscalation15s:
        'Stare at your phone and gasp: "Wait, the HOA president just gave it a heart reaction!"',
    targetReactionFromRoom:
        'Get at least one person in the room to give you serious damage-control advice.',
    spiceTier: 5,
  ),
  LifeIsImprovSecretDare(
    id: 'lii_party_04',
    setting: LifeIsImprovSetting.housePartyBar,
    dossierTitle: 'The Seductive Chore Breakdown',
    undercoverPersona: 'Late-Night Bedroom Narrator',
    openingLineToSayOutLoud:
        'Hold my drink for ten seconds—I need to explain how I parallel-parked outside using the exact vocal tone of an R-rated Cinemax thriller.',
    midDareEscalation15s:
        'Lower your voice an octave and describe turning the steering wheel like a scandalous affair.',
    targetReactionFromRoom:
        'Make someone in the room blush or burst out laughing before the 30s clock expires.',
    spiceTier: 4,
  ),
  LifeIsImprovSecretDare(
    id: 'lii_party_05',
    setting: LifeIsImprovSetting.housePartyBar,
    dossierTitle: 'The Walk-of-Shame Sports Broadcast',
    undercoverPersona: 'Play-by-Play Nightlife Analyst',
    openingLineToSayOutLoud:
        'Ladies and gentlemen, welcome back to the 2 AM broadcast—let\'s review the tape on who in this room is most likely to wake up tomorrow wearing somebody else\'s hoodie.',
    midDareEscalation15s:
        'Point an imaginary microphone at a friend and ask for their halftime stamina report.',
    targetReactionFromRoom:
        'Get the friend to give a post-game interview answer on camera.',
    spiceTier: 4,
  ),

  // 6-10: Public / Out in the Wild
  LifeIsImprovSecretDare(
    id: 'lii_wild_01',
    setting: LifeIsImprovSetting.publicOutInWild,
    dossierTitle: 'The Undercover Cannes Scandal',
    undercoverPersona: 'Incognito A-List Method Star',
    openingLineToSayOutLoud:
        'Please, no flash photography while I\'m off-set—my publicist said the Monaco yacht photos were blurry, so technically that could be anybody\'s ass on page six.',
    midDareEscalation15s:
        'Put on imaginary sunglasses and offer to autograph a napkin for the nearest person.',
    targetReactionFromRoom:
        'Stay in full celebrity-in-hiding character for 25 seconds straight.',
    spiceTier: 4,
  ),
  LifeIsImprovSecretDare(
    id: 'lii_wild_02',
    setting: LifeIsImprovSetting.publicOutInWild,
    dossierTitle: 'The Spy Drop at Table Four',
    undercoverPersona: 'Velvet Noir Intelligence Asset',
    openingLineToSayOutLoud:
        'Take this napkin and don\'t look behind you—if my ex\'s divorce attorney calls, tell him we were at a couples pottery class in Pasadena.',
    midDareEscalation15s:
        'Tap your collar twice and whisper: "The wire is hot, order something strong."',
    targetReactionFromRoom:
        'Have someone nearby pocket the napkin or play along with the alibi.',
    spiceTier: 4,
  ),
  LifeIsImprovSecretDare(
    id: 'lii_wild_03',
    setting: LifeIsImprovSetting.publicOutInWild,
    dossierTitle: 'The Fake Reality-Show Confessional',
    undercoverPersona: 'Reunion Episode Villain',
    openingLineToSayOutLoud:
        'Camera 1, zoom in: nobody at this table knows I\'m about to stir the pot, watch how fast the energy shifts when I bring up last weekend.',
    midDareEscalation15s:
        'Clink your glass dramatically and say: "Cheers to everyone who kept their clothes on this week!"',
    targetReactionFromRoom:
        'Capture the room\'s immediate double-take or laughter.',
    spiceTier: 5,
  ),
  LifeIsImprovSecretDare(
    id: 'lii_wild_04',
    setting: LifeIsImprovSetting.publicOutInWild,
    dossierTitle: 'The Bluetooth HBO Audition',
    undercoverPersona: 'Actor Running Scandalous Lines in Public',
    openingLineToSayOutLoud:
        'Look, Victor, you can keep the penthouse and the Ferrari, just don\'t ask me to give back the silk blindfold before Tuesday!',
    midDareEscalation15s:
        'Pause, point to your ear, and whisper to the room: "Sorry, callback for an HBO pilot, carry on."',
    targetReactionFromRoom:
        'Hold a deadpan professional face while people around you react.',
    spiceTier: 4,
  ),
  LifeIsImprovSecretDare(
    id: 'lii_wild_05',
    setting: LifeIsImprovSetting.publicOutInWild,
    dossierTitle: 'The Velvet Rope Fit Check',
    undercoverPersona: 'Underground Speakeasy Door Bouncer',
    openingLineToSayOutLoud:
        'Alright, line up—before we enter the VIP booth, I\'m auditing everyone\'s outfit on a scale from "Sunday Church" to "3 AM Penthouse Trouble."',
    midDareEscalation15s:
        'Award the highest-rated person in earshot an imaginary golden wristband.',
    targetReactionFromRoom:
        'Get the group to pose or defend their outfit ratings.',
    spiceTier: 4,
  ),

  // 11-15: Late-Night Couch / Partner Dare
  LifeIsImprovSecretDare(
    id: 'lii_couch_01',
    setting: LifeIsImprovSetting.lateNightCouchPartner,
    dossierTitle: 'The 30-Second Bedroom Eye-Lock',
    undercoverPersona: 'Unblinking Seducer',
    openingLineToSayOutLoud:
        'New house rule: we lock eyes from six inches away for the next thirty seconds, and the first person to smirk or look away owes the winner whatever they ask for after this round.',
    midDareEscalation15s:
        'Raise one eyebrow slowly and whisper: "You\'re already cracking, darling."',
    targetReactionFromRoom:
        'Make your partner or co-star break eye contact or blush on camera.',
    spiceTier: 4,
  ),
  LifeIsImprovSecretDare(
    id: 'lii_couch_02',
    setting: LifeIsImprovSetting.lateNightCouchPartner,
    dossierTitle: 'The Ridiculous Roleplay Pitch',
    undercoverPersona: 'Method Intimacy Coordinator',
    openingLineToSayOutLoud:
        'Hear me out—tonight\'s roleplay scenario is "Aggressive IRS Auditor and Billionaire Tax Evader Who Lost the Receipts in the Jacuzzi."',
    midDareEscalation15s:
        'Hand them an imaginary clipboard and demand they explain their "offshore deductions."',
    targetReactionFromRoom:
        'Get your partner or roommate to improvise their character\'s opening excuse back.',
    spiceTier: 5,
  ),
  LifeIsImprovSecretDare(
    id: 'lii_couch_03',
    setting: LifeIsImprovSetting.lateNightCouchPartner,
    dossierTitle: 'The Seductive Snack-Box Reading',
    undercoverPersona: 'Midnight ASMR Siren',
    openingLineToSayOutLoud:
        'Don\'t say a word—I am going to read the nutrition facts on the nearest bottle or wrapper like it\'s the steamiest love letter ever written.',
    midDareEscalation15s:
        'Whisper "zero grams of trans fat" as if revealing a forbidden felony.',
    targetReactionFromRoom:
        'Keep a 100% sultry face while the other person loses their composure.',
    spiceTier: 4,
  ),
  LifeIsImprovSecretDare(
    id: 'lii_couch_04',
    setting: LifeIsImprovSetting.lateNightCouchPartner,
    dossierTitle: 'The Safe-Word Drafting Committee',
    undercoverPersona: 'Bedroom Contract Attorney',
    openingLineToSayOutLoud:
        'We need to officially update our household safe word—and before you vote, "Pumpernickel" and "Danny DeVito" are both on the ballot.',
    midDareEscalation15s:
        'Demand a formal handshake to ratify the new safe word on camera.',
    targetReactionFromRoom:
        'Get your co-star to debate which word is funnier and shake on it.',
    spiceTier: 4,
  ),
  LifeIsImprovSecretDare(
    id: 'lii_couch_05',
    setting: LifeIsImprovSetting.lateNightCouchPartner,
    dossierTitle: 'The Jealous Co-Star Screen Test',
    undercoverPersona: 'Possessive Movie Star Lead',
    openingLineToSayOutLoud:
        'Stop looking at your phone like that—if anyone in this zip code gets your attention after midnight, it better be me in the close-up shot.',
    midDareEscalation15s:
        'Tilt their chin toward the camera lens and say: "Tell the director who your favorite co-star is."',
    targetReactionFromRoom:
        'Finish the take within 3 inches of each other\'s camera frame.',
    spiceTier: 5,
  ),

  // 16-20: Phone Call Bluff
  LifeIsImprovSecretDare(
    id: 'lii_phone_01',
    setting: LifeIsImprovSetting.phoneCallBluff,
    dossierTitle: 'The 2 AM Five-Star Concierge Request',
    undercoverPersona: 'VIP Penthouse Guest in Trouble',
    openingLineToSayOutLoud:
        'Hi, Front Desk? Don\'t ask any questions, just send up three buckets of ice, a locksmith for a pair of novelty handcuffs, and a "Do Not Disturb" sign made of titanium.',
    midDareEscalation15s:
        'Listen for two beats and say: "No, it\'s not an emergency, we\'re actually having a phenomenal time—just hurry!"',
    targetReactionFromRoom:
        'Sell both sides of the frantic hotel call without breaking character.',
    spiceTier: 4,
  ),
  LifeIsImprovSecretDare(
    id: 'lii_phone_02',
    setting: LifeIsImprovSetting.phoneCallBluff,
    dossierTitle: 'The Spicy Voice-Note Retake',
    undercoverPersona: 'Perfectionist Late-Night Flirt',
    openingLineToSayOutLoud:
        'Hey baby, I was just lying here thinking about last night and—fuck, wait, how do I delete that?! Why did my voice crack like a clarinet?! Take two, take two!',
    midDareEscalation15s:
        'Drop immediately back into a silky bedroom purr and then curse again when you realize it auto-sent.',
    targetReactionFromRoom:
        'Switch between angry profanity and sultry seduction at least 3 times.',
    spiceTier: 5,
  ),
  LifeIsImprovSecretDare(
    id: 'lii_phone_03',
    setting: LifeIsImprovSetting.phoneCallBluff,
    dossierTitle: 'The Ibiza Hush-Money Negotiation',
    undercoverPersona: 'Unbothered Scandal Witness',
    openingLineToSayOutLoud:
        'Hello? Oh, look who finally called—if you want me to delete the security footage from the Ibiza cabana, your offer better start with six figures and a jet ski.',
    midDareEscalation15s:
        'Laugh coldly into the phone and say: "Throw in Courtside Lakers tickets and I\'ll forget I ever saw the leopard speedo."',
    targetReactionFromRoom:
        'Deliver a ruthless billionaire shakedown with movie-villain swagger.',
    spiceTier: 5,
  ),
  LifeIsImprovSecretDare(
    id: 'lii_phone_04',
    setting: LifeIsImprovSetting.phoneCallBluff,
    dossierTitle: 'The Morning-After Extraction Coach',
    undercoverPersona: 'Tactical Walk-of-Shame Commander',
    openingLineToSayOutLoud:
        'Stay on the line and move quietly—grab your heels in your left hand, step over the sleeping French bulldog, and do NOT touch the creaky floorboard by the bar!',
    midDareEscalation15s:
        'Stage-whisper: "Abort! Their roommate is making a protein shake in the kitchen—duck behind the island!"',
    targetReactionFromRoom:
        'Direct the imaginary escape like a high-stakes Mission Impossible heist.',
    spiceTier: 4,
  ),
  LifeIsImprovSecretDare(
    id: 'lii_phone_05',
    setting: LifeIsImprovSetting.phoneCallBluff,
    dossierTitle: 'The Avant-Garde Hot-Tub Defense',
    undercoverPersona: 'Unapologetic Indie Auteur',
    openingLineToSayOutLoud:
        'Listen to me, Brenda—that leaked hot-tub video is NOT a scandal, it is an independent European art film shot on 35-millimeter and the lighting was impeccable!',
    midDareEscalation15s:
        'Slam your hand down and shout: "Tell Cannes we\'re submitting it in the Best Cinematography category!"',
    targetReactionFromRoom:
        'Commit 100% to the pretentious Hollywood excuse until the clock hits zero.',
    spiceTier: 5,
  ),
];
