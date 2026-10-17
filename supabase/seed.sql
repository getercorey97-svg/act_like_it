-- ============================================================================
-- ACT LIKE IT — PRODUCTION SEED DATA FOR ALL SCENE CATEGORIES
-- File: supabase/seed.sql
-- Target: Automated Supabase GitHub Integration ("Deploy to production")
-- Categories:
--   1. Eras: 1970–1999 (4 scenes)
--   2. Eras: 2000–2026 (4 scenes)
--   3. Awards: Best Actor (4 scenes)
--   4. Awards: Best Actress (4 scenes)
--   5. Awards: Best Supporting Actor (4 scenes)
--   6. Awards: Best Villain (4 scenes)
--   7. Awards: Emmy Vault (4 scenes)
--   8. Specialty: Cult Classics (4 scenes)
--   9. Late-Night After-Hours (5 adult-oriented, high-tension scenes, is_late_night = true)
-- ============================================================================

insert into public.scenes (
  title,
  actor_name,
  character_name,
  script_excerpt,
  target_emotion,
  category,
  is_late_night
) values
  -- ==========================================================================
  -- 1. ERAS: 1970–1999 (4 Scenes)
  -- ==========================================================================
  (
    'The Godfather (1972)',
    'Marlon Brando',
    'Don Vito Corleone',
    E'Why did you go to the police? Why didn''t you come to me first?\nWhat have I ever done to make you treat me so disrespectfully?\nIf you had come to me in friendship, then this scum that ruined your daughter would be suffering this very day.\nAnd if by chance an honest man like yourself should make enemies, then they would become my enemies. And then they would fear you.',
    'Patriarchal Authority & Quiet Menace',
    'Eras: 1970–1999',
    false
  ),
  (
    'Taxi Driver (1976)',
    'Robert De Niro',
    'Travis Bickle',
    E'You talkin'' to me? You talkin'' to me?\nThen who the hell else are you talkin'' to—you talkin'' to me?\nWell, I''m the only one here.\nWho the fuck do you think you''re talking to? Oh, yeah? Okay.',
    'Paranoid Confrontational Intensity',
    'Eras: 1970–1999',
    false
  ),
  (
    'Network (1976)',
    'Peter Finch',
    'Howard Beale',
    E'I don''t have to tell you things are bad. Everybody knows things are bad.\nWe sit watching our TVs while some local newscaster tells us that today we had fifteen homicides and sixty-three violent crimes, as if that''s the way it''s supposed to be!\nI want you to get up right now, go to your windows, open them, and stick your head out and yell:\n"I''m as mad as hell, and I''m not going to take this anymore!"',
    'Prophetic Outrage & Fury',
    'Eras: 1970–1999',
    false
  ),
  (
    'Pulp Fiction (1994)',
    'Samuel L. Jackson',
    'Jules Winnfield',
    E'There''s a passage I got memorized. Ezekiel 25:17.\n"The path of the righteous man is beset on all sides by the inequities of the selfish and the tyranny of evil men.\nBlessed is he who, in the name of charity and good will, shepherds the weak through the valley of the darkness.\nAnd I will strike down upon thee with great vengeance and furious anger those who attempt to poison and destroy My brothers!"',
    'Commanding Righteous Wrath',
    'Eras: 1970–1999',
    false
  ),

  -- ==========================================================================
  -- 2. ERAS: 2000–2026 (4 Scenes)
  -- ==========================================================================
  (
    'The Dark Knight (2008)',
    'Heath Ledger',
    'The Joker',
    E'Wanna know how I got these scars? My father was a drinker... and a fiend.\nAnd one night, he goes off crazier than usual. Mommy gets the kitchen knife to defend herself.\nHe doesn''t like that. Not... one... bit.\nSo, me watching, he takes the knife to her, laughing while he does it. He turns to me, and he says: "Why so serious?"',
    'Unhinged Theatrical Menace',
    'Eras: 2000–2026',
    false
  ),
  (
    'Hidden Figures (2016)',
    'Taraji P. Henson',
    'Katherine Johnson',
    E'There are no colored bathrooms in this building, or any building outside the West Campus, which is half a mile away! Did you know that?\nI have to walk to Timbuktu just to relieve myself! And I can''t use one of the handy bikes. Picture that, Mr. Harrison.\nMy uniform: skirt below the knees, my heels, and a simple string of pearls. Well, I don''t own pearls. Lord knows you don''t pay the colored enough to afford pearls!\nAnd I work like a dog, day and night, living on coffee from a pot none of you wanna touch!',
    'Exhausted Dignity & Righteous Fire',
    'Eras: 2000–2026',
    false
  ),
  (
    'Whiplash (2014)',
    'J.K. Simmons',
    'Terence Fletcher',
    E'There are no two words in the English language more harmful than "good job."\nWere you rushing, or were you dragging? Answer me!\nIf you deliberately sabotage my band, I will gut you like a pig.\nNow—are you a rusher, are you a dragger, or are you gonna be on my fucking time?',
    'Razor-Sharp Psychological Intimidation',
    'Eras: 2000–2026',
    false
  ),
  (
    'Everything Everywhere All at Once (2022)',
    'Ke Huy Quan',
    'Waymond Wang',
    E'You think I''m weak, don''t you? All those years ago, when we first fell in love, your father would say I was too sweet for my own good.\nWhen I choose to see the good side of things, I''m not being naive. It is strategic and necessary. It''s how I''ve learned to survive through everything.\nI know you see yourself as a fighter. Well, I see myself as one too. This is how I fight.\nIn another life, I would have really liked just doing laundry and taxes with you.',
    'Tender Vulnerability & Quiet Strength',
    'Eras: 2000–2026',
    false
  ),

  -- ==========================================================================
  -- 3. AWARDS: BEST ACTOR (4 Scenes)
  -- ==========================================================================
  (
    'There Will Be Blood (2007)',
    'Daniel Day-Lewis',
    'Daniel Plainview',
    E'Drainage! Drainage, Eli, you boy! Drained dry—I''m so sorry.\nHere, if you have a milkshake, and I have a milkshake, and I have a straw.\nThere it is, that''s a straw, you see? Watch it.\nNow, my straw reaches acroooooooss the room and starts to drink your milkshake. I... drink... your... milkshake! I drink it up!',
    'Manic Ruthless Triumph',
    'Awards: Best Actor',
    false
  ),
  (
    'Training Day (2001)',
    'Denzel Washington',
    'Detective Alonzo Harris',
    E'King Kong ain''t got shit on me! You think you can do this to me?!\nI built thisavel! I run this street! You walk around here because I allow you to walk around here!\nYou''re gonna lock me up? Who you gonna put on the frontline when the wolves come knocking?\nI''m the police! I run shit here—you just live here!',
    'Explosive Defiance & Betrayed Ego',
    'Awards: Best Actor',
    false
  ),
  (
    'Scent of a Woman (1992)',
    'Al Pacino',
    'Lt. Col. Frank Slade',
    E'Wait a minute! Wait a minute! I have come to the crossroads in my life.\nI always knew what the right path was. Without exception, I knew.\nBut I never took it. You know why? It was too damn hard.\nNow here''s Charlie. He''s come to the crossroads. He has chosen a path. It''s the right path. It''s a path made of principle—that leads to character. Let him continue on his journey!',
    'Fervent Moral Conviction',
    'Awards: Best Actor',
    false
  ),
  (
    'Oppenheimer (2023)',
    'Cillian Murphy',
    'J. Robert Oppenheimer',
    E'We knew the world would not be the same. A few people laughed, a few people cried. Most people were silent.\nI remembered the line from the Hindu scripture, the Bhagavad Gita.\nVishnu is trying to persuade the Prince that he should do his duty, and to impress him, takes on his multi-armed form and says:\n"Now I am become Death, the destroyer of worlds." I suppose we all thought that, one way or another.',
    'Haunted Existential Dread',
    'Awards: Best Actor',
    false
  ),

  -- ==========================================================================
  -- 4. AWARDS: BEST ACTRESS (4 Scenes)
  -- ==========================================================================
  (
    'The Silence of the Lambs (1991)',
    'Jodie Foster',
    'Clarice Starling',
    E'I woke up early one morning and I heard this strange noise... this screaming. Like the screaming of some kind of child.\nI crept downstairs, outside, to the barn. I was so scared to look inside, Dr. Lecter, because I knew what my uncle was doing.\nThey were slaughtering the spring lambs. And I opened the gate—they wouldn''t run, they just stood there, confused.\nSo I picked up one lamb, and I ran away as fast as I could. I thought if I could save just one... he was so heavy.',
    'Trembling Childhood Trauma & Resolve',
    'Awards: Best Actress',
    false
  ),
  (
    'Misery (1990)',
    'Kathy Bates',
    'Annie Wilkes',
    E'You dirty bird! How could you? She can''t be dead! Misery Chastain cannot be dead!\nWait—I think I see what you''re doing. Oh, Paul, you had me going there for a minute!\nLook at me, Paul. He didn''t get out of the cockadoodie car!\nDo you think I''m an idiot?! You swore to me this novel would be a masterpiece, and instead you murdered her!',
    'Volatile Unstable Obsession',
    'Awards: Best Actress',
    false
  ),
  (
    'Monster (2003)',
    'Charlize Theron',
    'Aileen Wuornos',
    E'You don''t know anything about me! You think you can sum up my whole life on a piece of legal paper?\nEvery single time I tried to do the right thing, the world spat right back in my face!\nI loved you, Selby. Everything I did—every ugly, terrible thing—I did so we could have a roof over our heads and a chance.\nSo go ahead and tell them whatever they want to hear. I''m done apologizing for surviving.',
    'Raw Desperation & Heartbreak',
    'Awards: Best Actress',
    false
  ),
  (
    'Black Swan (2010)',
    'Natalie Portman',
    'Nina Sayers',
    E'You think I''m too fragile? Watch me. Every single day I wake up with bleeding toes and bruised ribs for this company.\nThe White Swan is effortless, yes—because I have lived inside a cage my entire life!\nNow you want the Black Swan? You want me to lose control and let go?\nDon''t look away, Thomas. This role is mine, and nobody is taking it from me. It was perfect.',
    'Feverish Perfectionism & Ecstasy',
    'Awards: Best Actress',
    false
  ),

  -- ==========================================================================
  -- 5. AWARDS: BEST SUPPORTING ACTOR (4 Scenes)
  -- ==========================================================================
  (
    'Good Will Hunting (1997)',
    'Robin Williams',
    'Sean Maguire',
    E'So if I asked you about art, you''d probably give me the skinny on every art book ever written. Michelangelo, you know a lot about him.\nBut I''ll bet you can''t tell me what it smells like in the Sistine Chapel. You''ve never actually stood there and looked up at that beautiful ceiling.\nIf I ask you about love, you''d probably quote me a sonnet. But you''ve never looked at a woman and been totally vulnerable.\nYou''re an orphan, right? Do you think I''d know the first thing about how hard your life has been because I read Oliver Twist?',
    'Grounded Empathy & Quiet Wisdom',
    'Awards: Best Supporting Actor',
    false
  ),
  (
    'Glengarry Glen Ross (1992)',
    'Alec Baldwin',
    'Blake',
    E'Put. That coffee. Down. Coffee''s for closers only. You think I''m fucking with you? I am not fucking with you.\nI''m here from downtown. I''m here from Mitch and Murray. And I''m here on a mission of mercy.\nYou call yourself a salesman, you son of a bitch? A-B-C. A-Always, B-Be, C-Closing. Always be closing!\nSecond prize is a set of steak knives. Third prize is you''re fired. Get the picture?',
    'Ruthless Boardroom Intimidation',
    'Awards: Best Supporting Actor',
    false
  ),
  (
    'Django Unchained (2012)',
    'Christoph Waltz',
    'Dr. King Schultz',
    E'My good man, did you simply get carried away with your dramatic gesture, or are you pointing your weapon at me with lethal intention?\nAllow me to clarify the predicament: within my coat rests a derringer calibrated for immediate discourtesy.\nI am a man of science and commerce, Mr. Candie, yet I find my patience stretched intolerably thin.\nSo I must ask you one final time—shall we conclude this transaction like gentlemen, or shall we make history?',
    'Razor-Wit Politeness & Lethal Calm',
    'Awards: Best Supporting Actor',
    false
  ),
  (
    'The Fighter (2010)',
    'Christian Bale',
    'Dicky Eklund',
    E'Look at me, Micky! That was Sugar Ray Leonard! I knocked him down in front of the whole world, man!\nEveryone in Lowell still talks about that night. You think I forgot how to train you? I taught you every combination you know!\nI know I messed up, okay? I know I let you and Ma down when you needed me in the corner.\nJust give me one more round—let me be your brother again, Mick.',
    'Restless Guilt & Brotherly Pleading',
    'Awards: Best Supporting Actor',
    false
  ),

  -- ==========================================================================
  -- 6. AWARDS: BEST VILLAIN (4 Scenes)
  -- ==========================================================================
  (
    'No Country for Old Men (2007)',
    'Javier Bardem',
    'Anton Chigurh',
    E'What''s the most you ever lost on a coin toss?\nCall it. Yes, you have to call it. I cannot call it for you. It wouldn''t be fair.\nYou need to call it—this coin has been traveling twenty-two years to get here, and now it''s here.\nAnd it''s either heads or tails, and you have to say. Call it, friendo.',
    'Unblinking Cold Fatalism',
    'Awards: Best Villain',
    false
  ),
  (
    'Inglourious Basterds (2009)',
    'Christoph Waltz',
    'Col. Hans Landa',
    E'Monsieur LaPadite, the Germans'' nickname for me is "The Jew Hunter." Precisely because I am able to think like a hawk, whereas my colleagues think like cows.\nNow, if a rat were to scamper through your door right this very minute, would you greet it with a saucer of your delicious milk?\nYou are sheltering enemies of the state underneath your floorboards, are you not?\nPoint out to me the areas where they are hiding... and since I am about to switch back to French, I suggest you listen very carefully.',
    'Chilling Charm & Predatory Precision',
    'Awards: Best Villain',
    false
  ),
  (
    'Wall Street (1987)',
    'Michael Douglas',
    'Gordon Gekko',
    E'The point is, ladies and gentlemen, that greed—for lack of a better word—is good.\nGreed is right. Greed works. Greed clarifies, cuts through, and captures the essence of the evolutionary spirit.\nGreed, in all of its forms—greed for life, for money, for love, knowledge—has marked the upward surge of mankind.\nAnd greed, you mark my words, will not only save Teldar Paper, but that other malfunctioning corporation called the USA.',
    'Seductive Corporate Arrogance',
    'Awards: Best Villain',
    false
  ),
  (
    'A Few Good Men (1992)',
    'Jack Nicholson',
    'Col. Nathan R. Jessep',
    E'Son, we live in a world that has walls, and those walls have to be guarded by men with guns. Who''s gonna do it? You?\nI have a greater responsibility than you can possibly fathom. You weep for Santiago, and you curse the Marines. You have that luxury!\nMy existence, while grotesque and incomprehensible to you, saves lives! You don''t want the truth because deep down in places you don''t talk about at parties, you want me on that wall—you need me on that wall!\nDid I order the Code Red? You''re goddamn right I did!',
    'Volcanic Military Contempt',
    'Awards: Best Villain',
    false
  ),

  -- ==========================================================================
  -- 7. AWARDS: EMMY VAULT (4 Scenes)
  -- ==========================================================================
  (
    'Breaking Bad (2012)',
    'Bryan Cranston',
    'Walter White',
    E'Who are you talking to right now? Who is it you think you see? Do you know how much I make a year?\nEven if I told you, you wouldn''t believe it. Do you know what would happen if I suddenly decided to stop going into work?\nA business big enough that it could be listed on the NASDAQ goes belly up. Disappears! It ceases to exist without me.\nNo, you clearly don''t know who you''re talking to, so let me clue you in. I am not in danger, Skyler. I am the danger. A guy opens his door and gets shot, and you think that of me? No. I am the one who knocks!',
    'Narcissistic Hubris & Cold Authority',
    'Awards: Emmy Vault',
    false
  ),
  (
    'Succession (2023)',
    'Matthew Macfadyen',
    'Tom Wambsgans',
    E'You are broken, Shiv. You don''t like to fail a test, do you?\nI have given you endless approval, and it doesn''t fill you up because you''re broken!\nAnd I think you are incapable of love. And I think you are maybe not a good person to have children.\nYou took my heart and you treated it like a corporate memo—and you''re shocked that I finally stopped bleeding for you?',
    'Venomous Marital Resentment',
    'Awards: Emmy Vault',
    false
  ),
  (
    'The Bear (2022)',
    'Jeremy Allen White',
    'Carmen "Carmy" Berzatto',
    E'Everything was on fire! Every single ticket was printing, the printer wouldn''t stop, and nobody was listening to me!\nI wasn''t even in the room anymore—I was just watching my hands shake over the pass, waiting for the whole kitchen to collapse.\nI thought if I made the food undeniable, then maybe my brother would have let me in the door.\nInstead I''m standing in a walk-in freezer screaming at the people I love because I don''t know how to breathe when things go right.',
    'Breathless Panic & Raw Confession',
    'Awards: Emmy Vault',
    false
  ),
  (
    'The Sopranos (2002)',
    'Edie Falco',
    'Carmela Soprano',
    E'You think I don''t know, Tony? For twenty years I have looked the other way while you paraded your lies through this house!\nI washed your shirts, I raised your children, I smiled at the priest while your blood money paid for the marble countertops!\nDon''t you dare stand at the foot of my bed and act like the victim when one of your girls calls our home!\nGet out! Take your cigars, take your excuses, and get the hell out of my house!',
    'Shattered Composure & Volcanic Rage',
    'Awards: Emmy Vault',
    false
  ),

  -- ==========================================================================
  -- 8. SPECIALTY: CULT CLASSICS (4 Scenes)
  -- ==========================================================================
  (
    'The Rocky Horror Picture Show (1975)',
    'Tim Curry',
    'Dr. Frank-N-Furter',
    E'How do you do, I see you''ve met my faithful handyman.\nHe''s just a little brought down because when you knocked, he thought you were the candyman!\nDon''t get strung out by the way I look. Don''t judge a book by its cover.\nI''m just a sweet transvestite from Transexual, Transylvania—so come up to the lab, and see what''s on the slab! I see you shiver with antici... pation.',
    'Flamboyant Theatrical Seductiveness',
    'Specialty: Cult Classics',
    false
  ),
  (
    'The Big Lebowski (1998)',
    'Jeff Bridges',
    'The Dude',
    E'Let me explain something to you. Um, I am not "Mr. Lebowski." You''re Mr. Lebowski. I''m the Dude.\nSo that''s what you call me. You know, that or, uh, His Dudeness, or, uh, Duder, or El Duderino if you''re not into the whole brevity thing.\nAll the Dude ever wanted was his rug back, man. It really tied the room together!\nLook, this aggression will not stand, man. Yeah, well, you know, that''s just, like, your opinion, man.',
    'Laid-Back Indignant Bewilderment',
    'Specialty: Cult Classics',
    false
  ),
  (
    'Fight Club (1999)',
    'Brad Pitt',
    'Tyler Durden',
    E'Listen up, maggots. You are not special. You are not a beautiful or unique snowflake. You''re the same decaying organic matter as everything else.\nMan, I see in Fight Club the strongest and smartest men who''ve ever lived. I see all this potential, and I see squandering.\nAdvertising has us chasing cars and clothes, working jobs we hate so we can buy shit we don''t need.\nWe''re the middle children of history, man—no purpose or place. The things you own end up owning you. Only after we''ve lost everything are we free to do anything.',
    'Anarchic Charismatic Provocation',
    'Specialty: Cult Classics',
    false
  ),
  (
    'The Princess Bride (1987)',
    'Mandy Patinkin',
    'Inigo Montoya',
    E'Hello. My name is Inigo Montoya. You killed my father. Prepare to die!\nStop saying that! I have spent my entire life searching for the six-fingered man, and now you stand before my blade!\nOffer me money. Yes—power, too, promise me that.\nOffer me anything I ask for... I want my father back, you son of a bitch!',
    'Swashbuckling Vengeance & Passion',
    'Specialty: Cult Classics',
    false
  ),

  -- ==========================================================================
  -- 9. LATE-NIGHT AFTER-HOURS (5 Adult-Oriented, High-Tension Romantic/Dramatic Scenes)
  --    Locked via PostgreSQL RLS: is_late_night = true requires 18+ birth_year
  -- ==========================================================================
  (
    'Eyes Wide Shut (1999)',
    'Nicole Kidman',
    'Alice Harford',
    E'Do you really think you know everything that goes through my head when we''re lying in the dark, Bill?\nLast summer at Cape Cod, there was a naval officer at the next table. He glanced at me for three seconds, and I couldn''t breathe.\nIf he had wanted me—even for one single night—I was ready to give up everything. You, Helena, my whole life.\nAnd yet at the very same moment, you were dearer to me than ever. If you men only knew...',
    'Hypnotic Erotic Candor & Jealousy',
    'Late-Night After-Hours',
    true
  ),
  (
    'Closer (2004)',
    'Clive Owen & Natalie Portman',
    'Larry Gray',
    E'Don''t give me that innocent stare—tell me the truth! You think honesty is just a weapon you pull out when you want to break someone?\nDid you enjoy it? Look me in the eyes and tell me what you whispered to him when the hotel door closed.\nYou want raw, unfiltered passion, Anna, yet the second somebody touches your actual pulse, you bolt for the exit.\nGive it to me—because everyone else falls in love with your fantasy, and I''m the only man in this room who knows what you really are.',
    'Scorching Romantic Obsession & Betrayal',
    'Late-Night After-Hours',
    true
  ),
  (
    'Basic Instinct (1992)',
    'Sharon Stone',
    'Catherine Tramell',
    E'What are you going to do, Nick? Charge me with smoking in an interrogation room?\nYou read every page of my novel before you walked in here, and now you''re terrified that I know exactly how your mind works.\nMaybe I loved him, or maybe I just liked watching a dangerous man lose his nerve between the sheets.\nKeep staring at me like that, Detective, and we both know you won''t make it to the end of this investigation alive.',
    'Seductive Cat-and-Mouse Dominance',
    'Late-Night After-Hours',
    true
  ),
  (
    'Challengers (2024)',
    'Zendaya',
    'Tashi Duncan',
    E'Don''t act like you came up to my hotel room tonight just to talk about your backhand.\nYou two have been orbiting each other for thirteen years, using me as the net so you don''t have to admit what you actually want.\nLook at me—if you step onto that court tomorrow and play like a coward, don''t bother coming back to my bed.\nI don''t want a polite husband or a nostalgic ex-lover. I want to watch two people tear each other apart for one point.',
    'Intoxicating Power Play & Desire',
    'Late-Night After-Hours',
    true
  ),
  (
    'Fatal Attraction (1987)',
    'Glenn Close',
    'Alex Forrest',
    E'You think you can spend an entire weekend tangled in my sheets and then erase me on Monday morning like a business expense?\nI am not going to be ignored, Dan! Do you hear me?\nYou walked into my apartment, you held my face in your hands, and now you''re hiding behind a picket fence like nothing happened.\nI''m part of your life now, whether you lock your front door or not—and we are far from finished.',
    'Feverish Obsessive Passion & Threat',
    'Late-Night After-Hours',
    true
  );
