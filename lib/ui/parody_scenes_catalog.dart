import 'lobby_models_and_realtime.dart';

/// 100 Original, Copyright-Safe Parody Scenes for "ACT LIKE IT":
/// - 90 General Scenes (`is18Plus: false`) across 9 categories (10 scenes each)
///   partitioned into the `scenes` table/model.
/// - 10 Adult Scenes (`is18Plus: true`) partitioned into the age-gated
///   `scenes_late_night_after_hours` table/model for Door 2 (Midnight Speakeasy).
/// - Every scene supports both Solo Monologue (`promptScript`) and 2-Player
///   Screen Test Duet mode (`duetLeadA` in Limelight Gold #F5DEB3 and
///   `duetLeadB` in Soundstage Cyan #0CB6D4).

const List<ScenePrompt> kEra1970To1999Scenes = [
  ScenePrompt(
    id: 'era70_01',
    title: 'An Offer From the Olive Conservatory',
    filmOrSeries: 'The Olive Syndicate (1972 Parody)',
    releaseYear: 1972,
    characterName: 'Don Vittorio',
    promptScript:
        'You bypassed my conservatory on the night of my daughter\'s gala, and now you come asking for favors when the magistrates fail you? Sit down and sip the espresso. If you had called me a friend from the beginning, the vultures circling your bakery would already be apologizing on their knees.',
    duetLeadA:
        'You bypassed my conservatory on the night of my daughter\'s gala, and now you come asking for favors when the magistrates fail you?',
    duetLeadB:
        'Forgive me, Don Vittorio—I wanted to handle it by the book, until the book burned my family\'s shop to the ground.',
    directorCue:
        'Lower your voice to a gravelly rasp, stroke an imaginary lapel carnation, and never raise your volume above a lethal whisper.',
    emotionalTarget: 'Patriarchal Authority & Quiet Menace',
    improvTwist:
        'TWIST AT 15s: Pause mid-sentence to politely offer an imaginary cannoli before delivering the final warning.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'era70_02',
    title: 'Midnight Cab Mirror Check',
    filmOrSeries: 'Yellow Cab Nocturne (1976 Parody)',
    releaseYear: 1976,
    characterName: 'Travis Vane',
    promptScript:
        'Are you addressing this badge in the rearview mirror? I looked left, I looked right, and I am the only night-shift driver standing in this studio apartment! Go ahead and step up to the curb if you think my meter is running for free.',
    duetLeadA:
        'Are you addressing this badge in the rearview mirror? I am the only night-shift driver standing in this studio apartment!',
    duetLeadB:
        'Put the fare box down, Travis—the dispatcher called three times and you\'re arguing with your own reflection.',
    directorCue:
        'Square your shoulders to the front lens, narrow your eyes, and deliver with twitchy, sleep-deprived confrontation.',
    emotionalTarget: 'Paranoid Confrontational Intensity',
    improvTwist:
        'TWIST AT 15s: Flash a sudden, overly polite customer-service grin before snapping back to intense stare.',
    durationSeconds: 30,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'era70_03',
    title: 'Channel Nine Prime-Time Mutiny',
    filmOrSeries: 'Broadcast Static (1976 Parody)',
    releaseYear: 1976,
    characterName: 'Howard Sterling',
    promptScript:
        'I am done reading teleprompter weather forecasts while the city boils over outside this studio! Unbolt your apartment windows tonight, lean out into the neon rain, and shout to the avenue that your patience has officially expired!',
    duetLeadA:
        'I am done reading teleprompter weather forecasts while the city boils over outside this studio!',
    duetLeadB:
        'Cut to commercial! Stay on the desk, Howard—the sponsors are losing their minds in the control booth, and the ratings just tripled!',
    directorCue:
        'Build from weary news-anchor poise into a prophetic, vein-popping crescendo on the final clause.',
    emotionalTarget: 'Prophetic Outrage & Righteous Fury',
    improvTwist:
        'TWIST AT 15s: Adjust your imaginary earpiece as if the producer is screaming at you, then rip it out.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'era70_04',
    title: 'We Need a Bigger Trawler',
    filmOrSeries: 'Dorsal Fin Summer (1975 Parody)',
    releaseYear: 1975,
    characterName: 'Captain Quintus',
    promptScript:
        'You brought a harbor patrol dinghy to hunt a forty-foot submarine with teeth like piano keys! Look at the wake behind the stern—if we don\'t weld a bigger deck under our boots by sundown, we are the bait on the hook.',
    duetLeadA:
        'You brought a harbor patrol dinghy to hunt a forty-foot submarine with teeth like piano keys!',
    duetLeadB:
        'Back the throttle down, Captain! The sonar is screaming and whatever is under the hull just swallowed the anchor chain!',
    directorCue:
        'Stare wide-eyed past the bottom of the phone frame as if watching something massive surface.',
    emotionalTarget: 'Saltwater Dread & Grizzled Awe',
    improvTwist:
        'TWIST AT 15s: React as if a rogue wave just splashed freezing ocean water across the deck.',
    durationSeconds: 30,
    difficultyTier: 3,
  ),
  ScenePrompt(
    id: 'era70_05',
    title: 'Sparks in the Downpour',
    filmOrSeries: 'Neon Rain 1982 (1982 Parody)',
    releaseYear: 1982,
    characterName: 'Commander Roy Vance',
    promptScript:
        'I have watched cobalt freighters catch fire above the rings of Saturn, glowing like magnesium flares in the dark. Every synthetic memory we fought to keep will dissolve into the gutter, like sparks in a midnight downpour.',
    duetLeadA:
        'I have watched cobalt freighters catch fire above the rings of Saturn, glowing like magnesium flares in the dark.',
    duetLeadB:
        'Grab my hand on the rooftop ledge, Roy—your bio-timer is blinking zero, and the rain won\'t wash this record clean.',
    directorCue:
        'Begin with quiet cosmic wonder, hold steady eye contact with the lens, and exhale softly on the last phrase.',
    emotionalTarget: 'Melancholic Sci-Fi Transcendence',
    improvTwist:
        'TWIST AT 15s: Tilt your head upward as if feeling rain on your face for the very last time.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'era70_06',
    title: '1.21 Tera-Volts on the Clocktower',
    filmOrSeries: 'Chrono Hatchback (1985 Parody)',
    releaseYear: 1985,
    characterName: 'Professor Emmett Sparks',
    promptScript:
        'Great Scott, look at the voltmeter! The only power source capable of generating 1.21 tera-volts is a direct lightning bolt into the town hall clocktower at 10:04 PM sharp! Strap into the bucket seat and hit eighty-eight on the speedometer!',
    duetLeadA:
        'The only power source capable of generating 1.21 tera-volts is a direct lightning bolt into the clocktower at 10:04 PM sharp!',
    duetLeadB:
        'Doc, the plutonium gauge is flashing red and the cable just snagged on the courthouse tree branch—floor it!',
    directorCue:
        'Deliver at frantic 1.3x mad-scientist speed while checking two imaginary stopwatches.',
    emotionalTarget: 'Manic Scientific Euphoria & Panic',
    improvTwist:
        'TWIST AT 15s: Duck suddenly as if a miniature model car just shot sparks across the lab floor.',
    durationSeconds: 30,
    difficultyTier: 3,
  ),
  ScenePrompt(
    id: 'era70_07',
    title: 'Nobody Corners the Mambo Kid',
    filmOrSeries: 'Catskills Spotlight (1987 Parody)',
    releaseYear: 1987,
    characterName: 'Johnny Rhythm',
    promptScript:
        'Nobody shoves my dance partner behind the banquet ficus tree! We rehearsed that overhead lift in freezing lake water for six weeks, and tonight this entire ballroom is going to watch us own the center stage.',
    duetLeadA:
        'Nobody shoves my dance partner behind the banquet ficus tree! Tonight this entire ballroom is going to watch us own the center stage.',
    duetLeadB:
        'The bandleader already cut our music, Johnny—if we miss the beat on the final lift, my father will shut the resort down!',
    directorCue:
        'Roll your shoulders back with leather-jacket swagger, point directly at the camera, and flash a rebellious smirk.',
    emotionalTarget: 'Rebellious Romantic Swagger',
    improvTwist:
        'TWIST AT 15s: Snap your fingers to an imaginary mambo beat before finishing the line.',
    durationSeconds: 30,
    difficultyTier: 3,
  ),
  ScenePrompt(
    id: 'era70_08',
    title: 'The Verdict You Requested',
    filmOrSeries: 'Courtroom Honor (1992 Parody)',
    releaseYear: 1992,
    characterName: 'General Nathan Sterling',
    promptScript:
        'You sit in the air-conditioned gallery and question my watchtower orders because you enjoy the luxury of never holding the perimeter! You demand the unredacted truth, Counselor, yet your hands would tremble the second I laid the ledger on that bench!',
    duetLeadA:
        'You demand the unredacted truth, Counselor, yet your hands would tremble the second I laid the ledger on that bench!',
    duetLeadB:
        'I don\'t want your lecture on perimeter walls, General—look at the jury and answer whether you signed the midnight directive!',
    directorCue:
        'Start with icy military restraint before exploding into booming courtroom projection on the final sentence.',
    emotionalTarget: 'Commanding Courtroom Indignation',
    improvTwist:
        'TWIST AT 15s: Slam an imaginary palm onto the witness rail and lean two inches closer to the lens.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'era70_09',
    title: 'Diner Booth Ezekiel',
    filmOrSeries: 'Velvet Briefcase (1994 Parody)',
    releaseYear: 1994,
    characterName: 'Julian Vance',
    promptScript:
        'Take another sip of that five-dollar vanilla shake before you test my composure. The road of the righteous courier is surrounded on all sides by greedy amateurs, and when this glowing briefcase clicks shut, you will know my name is the law!',
    duetLeadA:
        'Take another sip of that five-dollar vanilla shake before you test my composure—when this briefcase clicks shut, you will know my name is the law!',
    duetLeadB:
        'Lower your voice, Julian! The waitress is pouring decaf right behind you and the golden combination lock is already ticking!',
    directorCue:
        'Deliver the opening line with cool, conversational rhythm, then build to thunderous biblical cadence.',
    emotionalTarget: 'Commanding Righteous Wrath',
    improvTwist:
        'TWIST AT 15s: Pause to politely thank an imaginary server for a coffee refill, then resume full intensity.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'era70_10',
    title: 'Plenty of Room on the Floating Door',
    filmOrSeries: 'Iceberg Serenade (1997 Parody)',
    releaseYear: 1997,
    characterName: 'Jack Sketcher',
    promptScript:
        'Listen to me, Rosebud—winning that third-class boarding ticket was the luckiest roll of the dice in my entire life! Promise me you won\'t let go of that whistle, and whatever you do, scoot over six inches because this mahogany door clearly fits two people!',
    duetLeadA:
        'Promise me you won\'t let go of that whistle, and scoot over six inches because this mahogany door clearly fits two people!',
    duetLeadB:
        'My fingers are frozen solid, Jack—if you try to climb onto this carving right now, we\'ll both flip into the Atlantic!',
    directorCue:
        'Shiver visibly through your shoulders while keeping your eyes locked with heartbreaking devotion.',
    emotionalTarget: 'Shivering Romantic Devotion & Desperation',
    improvTwist:
        'TWIST AT 15s: Blow an imaginary rescue whistle with everything left in your lungs.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
];

const List<ScenePrompt> kEra2000To2026Scenes = [
  ScenePrompt(
    id: 'era00_01',
    title: 'Are You Not Mesmerized?',
    filmOrSeries: 'Colosseum Sand (2000 Parody)',
    releaseYear: 2000,
    characterName: 'Commander Decimus',
    promptScript:
        'Are you not mesmerized by this spectacle?! Is this not the exact reason you paid fifty silver coins for front-row nosebleed seats? My name is Commander Decimus of the Northern Legions, and I will have my reckoning in this arena or the next!',
    duetLeadA:
        'Are you not mesmerized by this spectacle?! My name is Commander Decimus, and I will have my reckoning in this arena or the next!',
    duetLeadB:
        'Turn your helmet toward the Emperor\'s box, Decimus—the crowd is chanting your name and the Praetorian guards are drawing their blades!',
    directorCue:
        'Spread your arms wide to address an imaginary stadium of fifty thousand spectators.',
    emotionalTarget: 'Epic Gladiator Defiance',
    improvTwist:
        'TWIST AT 15s: Stoop to grab a handful of imaginary arena sand before delivering the final vow.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'era00_02',
    title: 'The Gotham Interrogation',
    filmOrSeries: 'Midnight Cowl (2008 Parody)',
    releaseYear: 2008,
    characterName: 'The Prankster',
    promptScript:
        'Look at you under the fluorescent bulb, pounding the steel table like rules still apply after midnight! You have nothing to threaten me with—nothing to do with all your theatrical armor. When the power grid blinks out, this whole polite city will show you who they really are!',
    duetLeadA:
        'You have nothing to threaten me with! When the power grid blinks out, this whole polite city will show you who they really are!',
    duetLeadB:
        'Tell me which pier the ferry is docked at right now, or I lock this interrogation door from the outside and turn off the cameras!',
    directorCue:
        'Tilt your head at an unsettling angle, laugh without joy, and lean straight into the key light.',
    emotionalTarget: 'Unhinged Theatrical Menace',
    improvTwist:
        'TWIST AT 15s: Start clapping slowly in mock admiration while maintaining an unblinking grin.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'era00_03',
    title: 'Ten Billion Shares of Thin Air',
    filmOrSeries: 'The Hoodie Algorithm (2010 Parody)',
    releaseYear: 2010,
    characterName: 'Eduardo Vance',
    promptScript:
        'You diluted my co-founder shares down to zero point zero three percent while I was flying back from New York in the rain! Do not tell me to calm down in this deposition room—I just froze the server bank accounts, and I am coming back for my hoodie!',
    duetLeadA:
        'You diluted my co-founder shares down to zero point zero three percent while I was flying back from New York in the rain!',
    duetLeadB:
        'You signed the restructuring term sheet without reading page twelve—if you hadn\'t panicked, we\'d already be at a billion users!',
    directorCue:
        'Speak with clipped, rapid-fire Silicon Valley fury as if shattering an imaginary laptop on the desk.',
    emotionalTarget: 'Betrayed Boardroom Fury',
    improvTwist:
        'TWIST AT 15s: Straighten your tie and address an imaginary court stenographer in icy legal monotone.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'era00_04',
    title: 'Off My Metronome',
    filmOrSeries: 'Tempo Obsession (2014 Parody)',
    releaseYear: 2014,
    characterName: 'Maestro Terence Vance',
    promptScript:
        'There are no two words in the conservatory dictionary more destructive than "nice try." Were you rushing the downbeat, or were you dragging the brass? Count me in at two-hundred-forty beats per minute, or pack your cymbals and clear my stage!',
    duetLeadA:
        'Were you rushing the downbeat, or were you dragging the brass? Count me in at two-hundred-forty beats per minute, or clear my stage!',
    duetLeadB:
        'My hands are blistering through the drumsticks, Maestro—give me four bars solo and I\'ll lock the tempo down!',
    directorCue:
        'Whisper the opening sentence in dead stillness, then snap into percussive, conductor-level ferocity.',
    emotionalTarget: 'Razor-Sharp Psychological Intimidation',
    improvTwist:
        'TWIST AT 15s: Freeze mid-gesture with a conductor\'s baton held inches from the camera lens.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'era00_05',
    title: 'Half a Mile to the West Campus',
    filmOrSeries: 'Orbital Figures (2016 Parody)',
    releaseYear: 2016,
    characterName: 'Katherine Sterling',
    promptScript:
        'Every trajectory equation on that chalkboard goes through my slide rule before the capsule leaves the pad, yet I have to sprint half a mile across the tarmac in the pouring rain just to find a restroom! Check my decimals if you dare—they are spotless!',
    duetLeadA:
        'Every trajectory equation on that chalkboard goes through my slide rule before the capsule leaves the pad—check my decimals if you dare!',
    duetLeadB:
        'Here is the chalk, Katherine—from this morning forward, nobody in Mission Control touches that flight board without your signature.',
    directorCue:
        'Channel exhausted dignity that ignites into undeniable, room-silencing moral authority.',
    emotionalTarget: 'Exhausted Dignity & Righteous Fire',
    improvTwist:
        'TWIST AT 15s: Slam an imaginary stack of orbital blueprints onto the table and hold the room in silence.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'era00_06',
    title: 'Down in the Sunken Lounge',
    filmOrSeries: 'The Silver Teacup (2017 Parody)',
    releaseYear: 2017,
    characterName: 'Chris Washington',
    promptScript:
        'Stop clinking that silver spoon against the porcelain teacup! My feet feel like they are sinking through the living room carpet, and everyone at this garden party is smiling way too wide. Give me the car keys right now—we are leaving this estate!',
    duetLeadA:
        'Stop clinking that silver spoon against the porcelain teacup! Give me the car keys right now—we are leaving this estate!',
    duetLeadB:
        'Why are you breathing so fast, darling? Just focus on the rim of the cup and let the sound carry you down into the quiet.',
    directorCue:
        'Let a single tear of hypnotic paralysis fight against rising, wide-eyed survival panic.',
    emotionalTarget: 'Hypnotic Dread & Survival Panic',
    improvTwist:
        'TWIST AT 15s: Blink rapidly as if snapping out of a trance and pat your pockets for the car keys.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'era00_07',
    title: 'Basement Stairs in the Pouring Rain',
    filmOrSeries: 'Upstairs Downstairs Villa (2019 Parody)',
    releaseYear: 2019,
    characterName: 'Mr. Ki-Taek',
    promptScript:
        'You know what kind of plan never fails? No plan at all! If you make a blueprint in this city, life floods your basement before breakfast, so tonight we wear the designer suits and pretend we own the skylight!',
    duetLeadA:
        'You know what kind of plan never fails? No plan at all! Tonight we wear the designer suits and pretend we own the skylight!',
    duetLeadB:
        'Keep your voice down under the coffee table—the homeowners just pulled into the driveway three hours early!',
    directorCue:
        'Deliver with dark, ironic calm that conceals a volcanic undercurrent of class resentment.',
    emotionalTarget: 'Dark Satirical Fatalism',
    improvTwist:
        'TWIST AT 15s: Freeze completely still as if hiding underneath a glass living-room table.',
    durationSeconds: 30,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'era00_08',
    title: 'Quiet Universe Laundry & Taxes',
    filmOrSeries: 'Parallel Laundromat (2022 Parody)',
    releaseYear: 2022,
    characterName: 'Waymond Vane',
    promptScript:
        'You think I choose kindness because I don\'t see the chaos fracturing every timeline? Being gentle in a cruel multiverse is how I fight! In another life, without the flashing cameras or the receipts, I would have loved just folding warm laundry beside you.',
    duetLeadA:
        'Being gentle in a cruel multiverse is how I fight! In another life, I would have loved just folding warm laundry beside you.',
    duetLeadB:
        'Then stop looking at me with those soft eyes across the tax desk, Waymond, before you make me drop my guard in every universe.',
    directorCue:
        'Soften your shoulders, let a tender half-smile form, and speak with disarming emotional honesty.',
    emotionalTarget: 'Tender Vulnerability & Quiet Strength',
    improvTwist:
        'TWIST AT 15s: Stick an imaginary googly eye onto your forehead while keeping a 100% serious expression.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'era00_09',
    title: 'Existential Crisis in the Dreamhouse',
    filmOrSeries: 'Plastic Malibu (2023 Parody)',
    releaseYear: 2023,
    characterName: 'Gloria & Stereotypical Star',
    promptScript:
        'Do any of you ever pause the disco choreography to think about mortality?! Yesterday my heels were permanently arched, and this morning my feet hit the pastel linoleum completely flat! It is impossible to be a role model and a human being at the exact same time!',
    duetLeadA:
        'Do any of you ever pause the disco choreography to think about mortality?! My feet just hit the pastel linoleum completely flat!',
    duetLeadB:
        'Put your rollerblades back on right now—you have to stay strong and slightly Delusional, or the entire Dreamhouse roof caves in!',
    directorCue:
        'Freeze in a picture-perfect fashion pose, let the smile crack in slow motion, then unleash passionate truth.',
    emotionalTarget: 'Comedic Existential Breakdown & Catharsis',
    improvTwist:
        'TWIST AT 15s: Snap back into a dazzling catalog smile for two seconds before gasping again.',
    durationSeconds: 35,
    difficultyTier: 3,
  ),
  ScenePrompt(
    id: 'era00_10',
    title: 'Ride the Sandworm Into the Storm',
    filmOrSeries: 'Spice Horizon Part II (2024 Parody)',
    releaseYear: 2024,
    characterName: 'Paul Atreus',
    promptScript:
        'Do not bang the council drum unless you are ready to follow me into the Coriolis sandstorm! I can see every narrow footpath through the future, and tonight we point the desert hooks straight at the Emperor\'s flagship!',
    duetLeadA:
        'I can see every narrow footpath through the future, and tonight we point the desert hooks straight at the Emperor\'s flagship!',
    duetLeadB:
        'Listen to yourself, Paul—you promised you wouldn\'t let the southern prophecy turn you into the very tyrant we swore to overthrow!',
    directorCue:
        'Project from the diaphragm with booming, messianic authority and unblinking desert intensity.',
    emotionalTarget: 'Messianic Command & Tragic Destiny',
    improvTwist:
        'TWIST AT 15s: Use the "Desert Voice" by dropping your pitch an octave on the final command.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
];

const List<ScenePrompt> kAwardsBestActorScenes = [
  ScenePrompt(
    id: 'actor_01',
    title: 'The Siphon Reaches Across the Valley',
    filmOrSeries: 'Black Gold Tycoon (2007 Parody)',
    releaseYear: 2007,
    characterName: 'Daniel Plainfield',
    promptScript:
        'Drainage, Eli, you boy—drained completely dry! If you have a strawberry malt and I have a twenty-foot copper straw, watch what happens: my straw reaches clear across this bowling alley and drinks your entire reservoir up!',
    duetLeadA:
        'If you have a strawberry malt and I have a twenty-foot copper straw, my straw reaches clear across this room and drinks it up!',
    duetLeadB:
        'You promised the church endowment fifty thousand dollars for that lease, Daniel—don\'t tell me the well was already empty!',
    directorCue:
        'Lean forward into the frame, build rhythmic mania on the straw metaphor, and roar on the final line.',
    emotionalTarget: 'Manic Ruthless Triumph',
    improvTwist:
        'TWIST AT 15s: Make a loud, theatrical slurping sound before shouting the final sentence.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'actor_02',
    title: 'I Built This Precinct Block',
    filmOrSeries: 'Rookie Patrol (2001 Parody)',
    releaseYear: 2001,
    characterName: 'Detective Alonzo Vance',
    promptScript:
        'Gargoyle ain\'t got nothing on me! You think you can walk my rookie partner out that gate and leave my badge in the dirt? I built this boulevard brick by brick—you only sleep soundly because I patrol the dark!',
    duetLeadA:
        'You think you can walk out that gate and leave my badge in the dirt? I built this boulevard brick by brick!',
    duetLeadB:
        'The neighborhood isn\'t protecting you tonight, Alonzo—hand over the warrant case before the sirens reach the corner.',
    directorCue:
        'Beat your chest once, pace across the camera frame, and project fearless alpha bravado masking panic.',
    emotionalTarget: 'Explosive Defiance & Betrayed Ego',
    improvTwist:
        'TWIST AT 15s: Laugh incredulously at the ceiling before snapping back to furious eye contact.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'actor_03',
    title: 'The Crossroads of Character',
    filmOrSeries: 'Tango & Honor (1992 Parody)',
    releaseYear: 1992,
    characterName: 'Colonel Frank Slate',
    promptScript:
        'Hold the gavel! I have stood at every crossroads in my life, and without exception I knew which path was honorable—I just never took it because it was too damn steep! This kid chose principle over convenience, and you will not expel his soul today!',
    duetLeadA:
        'This kid chose principle over convenience, and I will not sit quietly while this disciplinary committee expels his soul today!',
    duetLeadB:
        'Colonel Slate, you are out of order in this auditorium—unless the student names the pranksters, my hands are tied!',
    directorCue:
        'Keep your gaze fixed three degrees off-axis and build to a roaring, gravel-throated ovation.',
    emotionalTarget: 'Fervent Moral Conviction',
    improvTwist:
        'TWIST AT 15s: Punctuate the speech with a sharp "Hoo-ah!" before delivering the closing plea.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'actor_04',
    title: 'Chain Reaction in the Rain',
    filmOrSeries: 'Atomic Horizon (2023 Parody)',
    releaseYear: 2023,
    characterName: 'Dr. Robert Vance',
    promptScript:
        'When the desert sky turned white at five-thirty in the morning, nobody in the bunker cheered. We calculated that the atmospheric chain reaction was near zero, yet as the applause echoes in this auditorium, I can still see the ash falling on the bleachers.',
    duetLeadA:
        'We calculated that the atmospheric chain reaction was near zero, yet I can still see the ash falling on the auditorium bleachers.',
    duetLeadB:
        'Look at the security board, Robert—they aren\'t auditing your equations anymore, they\'re auditing your loyalty.',
    directorCue:
        'Hold a thousand-yard stare directly into the camera lens with haunted, whisper-quiet gravity.',
    emotionalTarget: 'Haunted Existential Dread',
    improvTwist:
        'TWIST AT 15s: Flinch slightly as if a blinding camera flash just echoed a nuclear test.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'actor_05',
    title: 'Five Feet From the Microphone',
    filmOrSeries: 'The Royal Broadcast (2010 Parody)',
    releaseYear: 2010,
    characterName: 'Albert Duke of York',
    promptScript:
        'Do not lecture me on breathing exercises when the red broadcast lamp is blinking across the entire Empire! Every syllable catches in my throat like broken glass, yet you demand I step up to that brass microphone! Listen to me—I have a voice!',
    duetLeadA:
        'Every syllable catches in my throat like broken glass, yet you demand I step up to that microphone—listen to me, I have a voice!',
    duetLeadB:
        'Then shout it at me, Bertie! Forget the wireless listeners and speak to me like a man who refuses to be silenced!',
    directorCue:
        'Fight through tense vocal hesitation on the first line before breaking through into triumphant clarity.',
    emotionalTarget: 'Vulnerable Frustration & Triumphant Breakthrough',
    improvTwist:
        'TWIST AT 15s: Take a deep, visible diaphragm breath and sing three words of the final sentence.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'actor_06',
    title: 'Fourteen Days in the Ice River',
    filmOrSeries: 'Frontier Pelt (2015 Parody)',
    releaseYear: 2015,
    characterName: 'Hugh Glassman',
    promptScript:
        'You left me in a shallow trench with a cracked canteen and thirty miles of frozen timber between me and the fort! I crawled through blizzard drifts on broken ribs because as long as I can still draw one freezing breath, I am coming for my compass!',
    duetLeadA:
        'I crawled through blizzard drifts on broken ribs because as long as I can still draw one freezing breath, I am coming for my compass!',
    duetLeadB:
        'The blizzard was burying the whole trapping company, Hugh—nobody could have carried you down that mountain alive!',
    directorCue:
        'Grimace through frostbitten exhaustion, breathing visibly between raspy, relentless phrases.',
    emotionalTarget: 'Primal Survival & Relentless Vengeance',
    improvTwist:
        'TWIST AT 15s: Wipe imaginary snow from your eyebrows and glare without blinking.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'actor_07',
    title: 'Look at the Chalkboard Equations',
    filmOrSeries: 'Beautiful Equations (2001 Parody)',
    releaseYear: 2001,
    characterName: 'Dr. John Vane',
    promptScript:
        'The patterns are hiding right inside the newspaper clippings, if only you would let me finish pinning the red yarn! And yet... I realize now she never aged a single day since Princeton, which means my logic must override what my eyes want to believe.',
    duetLeadA:
        'I realize now those figures in the courtyard never aged a single day since Princeton—my logic must override what my eyes see.',
    duetLeadB:
        'Stay right here with me, John—touch my hand on your desk so you know what is real and what is only in the numbers.',
    directorCue:
        'Transition from frantic academic excitement to quiet, heartbreaking lucidity.',
    emotionalTarget: 'Fragile Genius & Heartbreaking Clarity',
    improvTwist:
        'TWIST AT 15s: Glance over your left shoulder at an imaginary figure, then consciously choose to ignore them.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'actor_08',
    title: 'Pass the Salt by the Harbor',
    filmOrSeries: 'Winter by the Harbor (2016 Parody)',
    releaseYear: 2016,
    characterName: 'Lee Chandler',
    promptScript:
        'I appreciate what you\'re trying to say on this sunny sidewalk, truly I do, but my heart isn\'t a spare radiator you can just patch up with a wrench. Some winters don\'t thaw out—I just can\'t beat it, okay?',
    duetLeadA:
        'My heart isn\'t a spare radiator you can just patch up with a wrench. Some winters don\'t thaw out—I just can\'t beat it, okay?',
    duetLeadB:
        'You don\'t have to carry that night alone forever, Lee—even if we just sit on the porch and say nothing at all.',
    directorCue:
        'Avoid melodrama; deliver with understated, raw New England restraint while looking slightly down.',
    emotionalTarget: 'Understated Grief & Raw Restraint',
    improvTwist:
        'TWIST AT 15s: Attempt a polite, small-talk smile that falters midway through the sentence.',
    durationSeconds: 30,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'actor_09',
    title: 'Now Is the Time on the House Floor',
    filmOrSeries: 'Capitol Telegraph (2012 Parody)',
    releaseYear: 2012,
    characterName: 'President Abraham Vance',
    promptScript:
        'We are stepped out upon the world stage now, with the fate of millions resting on a two-vote margin before the telegraph wires cool! I am clothed in immense authority, and by heaven, you will procure those two votes before the noon bell tolls!',
    duetLeadA:
        'I am clothed in immense authority, and by heaven, you will procure those two votes before the noon bell tolls!',
    duetLeadB:
        'The peace commissioners are already waiting at the river steamer, Mr. President—if word leaks out, the moderates will bolt!',
    directorCue:
        'Start with folksy, measured storytelling cadence before pounding an imaginary cabinet table.',
    emotionalTarget: 'Towering Statesman Resolve',
    improvTwist:
        'TWIST AT 15s: Adjust an imaginary stovepipe hat or shawl before leaning forward in command.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'actor_10',
    title: 'Smile for the Late-Night Monologue',
    filmOrSeries: 'Subway Laughter (2019 Parody)',
    releaseYear: 2019,
    characterName: 'Arthur Fleckman',
    promptScript:
        'You invited me onto your velvet talk-show couch just to mock my notebook jokes under the studio applause sign! Nobody checks on a guy in clown makeup on the subway until he stops apologizing for his laugh!',
    duetLeadA:
        'You invited me onto your velvet talk-show couch just to mock my notebook jokes under the studio applause sign!',
    duetLeadB:
        'Hold on, Arthur—the audience is just having fun! Tell us why you brought that greasepaint diary onto live television.',
    directorCue:
        'Alternate between uncontrollable nervous laughter and sudden, chillingly lucid stillness.',
    emotionalTarget: 'Tragic Manic Despair & Theatrical Volatility',
    improvTwist:
        'TWIST AT 15s: Pull an imaginary laminated card from your pocket explaining your laugh, then toss it aside.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
];

const List<ScenePrompt> kAwardsBestActressScenes = [
  ScenePrompt(
    id: 'actress_01',
    title: 'The Spring Pasture Gate',
    filmOrSeries: 'Quantico Cellblock (1991 Parody)',
    releaseYear: 1991,
    characterName: 'Agent Clarice Sterling',
    promptScript:
        'I crept down to the frosty barn before sunrise because the crying sound wouldn\'t let me sleep, Doctor. I unlatched the wooden pen, but they were too frightened to run—so I lifted the smallest lamb in my wool coat and sprinted into the fog.',
    duetLeadA:
        'I unlatched the wooden pen, Doctor, and lifted the smallest lamb in my wool coat and sprinted into the fog.',
    duetLeadB:
        'And tell me, Clarice—when you wake in the dark at Quantico, have those spring lambs finally stopped screaming?',
    directorCue:
        'Hold trembling composure for two beats, never breaking eye contact with the glass barrier.',
    emotionalTarget: 'Trembling Childhood Trauma & Steel Resolve',
    improvTwist:
        'TWIST AT 15s: Chin up—refuse to blink even once for the remainder of the take.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'actress_02',
    title: 'Your Number-One Devoted Reader',
    filmOrSeries: 'Cabin Typewriter (1990 Parody)',
    releaseYear: 1990,
    characterName: 'Annie Wilks',
    promptScript:
        'Oh, Paul, you dirty bird—how could you print a chapter where Lady Chastity perishes in the snowstorm?! Look at me: he never unbuckled from the cockadoodie carriage in chapter twelve! Take this fresh stack of typing paper and rewrite it right now!',
    duetLeadA:
        'He never unbuckled from the cockadoodie carriage in chapter twelve! Take this fresh stack of typing paper and rewrite it right now!',
    duetLeadB:
        'Annie, please—the missing "N" key on the Royal typewriter is jammed, and the snowplow is right outside the cabin!',
    directorCue:
        'Pivot in a split second from sugary-sweet fan adoration to terrifying, wide-eyed rage.',
    emotionalTarget: 'Volatile Unstable Obsession',
    improvTwist:
        'TWIST AT 15s: Clasp your hands together in a joyful, girlish giggle before snapping back to fury.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'actress_03',
    title: 'It Was Flawless on the Final Spin',
    filmOrSeries: 'Obsidian Feather (2010 Parody)',
    releaseYear: 2010,
    characterName: 'Nina Sayers',
    promptScript:
        'You said my technique was too rigid, that I only knew how to count the steps inside a porcelain music box! Watch my shoulders in the stage mirror—I finally let go of the choreography, and in that final pirouette, it was flawless.',
    duetLeadA:
        'Watch my shoulders in the stage mirror—I finally let go of the choreography, and in that final pirouette, it was flawless.',
    duetLeadB:
        'Wait until the curtain drops, Nina—your costume is torn at the waist and the orchestra is standing on their feet!',
    directorCue:
        'Breathe rapidly as if coming off thirty-two fouetté turns, eyes shining with feverish ecstasy.',
    emotionalTarget: 'Feverish Perfectionism & Ecstasy',
    improvTwist:
        'TWIST AT 15s: Raise one arm overhead in a graceful ballet port de bras as you deliver the final word.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'actress_04',
    title: 'Cerulean Sweater Masterclass',
    filmOrSeries: 'Runway Magazine (2006 Parody)',
    releaseYear: 2006,
    characterName: 'Miranda Priestly',
    promptScript:
        'Oh, don\'t purse your lips as if you are exempt from this industry—that lumpy sweater you dragged out of a clearance bin was curated for you by the very people in this room! That\'s all.',
    duetLeadA:
        'That lumpy cerulean sweater you dragged out of a clearance bin was curated for you by the very people in this room! That\'s all.',
    duetLeadB:
        'I only meant the two belts looked practically identical on the mannequin, Miranda—I\'ll fetch the mock-up book immediately!',
    directorCue:
        'Never raise your voice above a purr; let disdain drip from every unhurried syllable.',
    emotionalTarget: 'Icy Haute-Couture Superiority',
    improvTwist:
        'TWIST AT 15s: Wave one hand dismissively without even looking at the person you are addressing.',
    durationSeconds: 30,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'actress_05',
    title: 'Here\'s to the Dreamers Who Audition',
    filmOrSeries: 'Griffith Park Sunset (2016 Parody)',
    releaseYear: 2016,
    characterName: 'Mia Dolan',
    promptScript:
        'My aunt used to jump into the Seine River in Paris without checking how cold the water was! Here\'s to the fools who keep memorizing sides in coffee shops—even if our hearts bruise on the audition floor, we would do it all over again.',
    duetLeadA:
        'Here\'s to the fools who keep memorizing sides in coffee shops—even if our hearts bruise, we would do it all over again.',
    duetLeadB:
        'The casting director wants you back in Paris by Monday morning, Mia—don\'t let a little stage fright stop your solo show.',
    directorCue:
        'Start with conversational nostalgic warmth and build into lyrical, tear-glistening inspiration.',
    emotionalTarget: 'Bittersweet Artistic Passion',
    improvTwist:
        'TWIST AT 15s: Hum a three-note jazz melody softly before speaking the final sentence.',
    durationSeconds: 35,
    difficultyTier: 3,
  ),
  ScenePrompt(
    id: 'actress_06',
    title: 'Sixty-Three Cents on the Dollar',
    filmOrSeries: 'Desert Water Valve (2000 Parody)',
    releaseYear: 2000,
    characterName: 'Erin Brockman',
    promptScript:
        'Do not slide a glass of tap water across this conference table unless you brewed it from your own backyard well! I memorized six hundred plaintiff phone numbers without a law degree, and your corporate attorneys are about to write the check!',
    duetLeadA:
        'I memorized six hundred plaintiff phone numbers without a law degree, and your corporate attorneys are about to write the check!',
    duetLeadB:
        'Where did you get these signed water-sample affidavits, Ms. Brockman? Our legal department hasn\'t even seen these exhibits!',
    directorCue:
        'Chew gum with fierce confidence, plant one hand on your hip, and roast the boardroom.',
    emotionalTarget: 'Fierce Working-Class Tenacity',
    improvTwist:
        'TWIST AT 15s: Push an imaginary glass of water back toward the camera and arch one eyebrow.',
    durationSeconds: 30,
    difficultyTier: 3,
  ),
  ScenePrompt(
    id: 'actress_07',
    title: 'Three Red Billboards on Highway Nine',
    filmOrSeries: 'County Line Signs (2017 Parody)',
    releaseYear: 2017,
    characterName: 'Mildred Haynes',
    promptScript:
        'I paid the advertising agency for twelve full months on that empty county highway, Chief, because nobody walks into the station house unless the paint is ten feet tall! Keep your apologies—I want the case files back on the top desk!',
    duetLeadA:
        'I paid for twelve full months on that empty county highway, Chief—keep your apologies and put the case files back on the top desk!',
    duetLeadB:
        'Mildred, everyone in this town knows what you\'re going through, but putting my name on fifty-foot red signs won\'t conjure a DNA match!',
    directorCue:
        'Square your jaw, keep your voice flat as gravel, and refuse to yield an inch.',
    emotionalTarget: 'Unshakable Maternal Fury & Grit',
    improvTwist:
        'TWIST AT 15s: Adjust an imaginary bandana on your forehead while staring daggers into the lens.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'actress_08',
    title: 'Time Is an Accordion on the Podium',
    filmOrSeries: 'Berlin Baton (2022 Parody)',
    releaseYear: 2022,
    characterName: 'Maestra Lydia Vance',
    promptScript:
        'A symphony orchestra is not a democracy—it is an instrument that breathes only when my left hand shapes the air! You cannot cancel the Fifth Symphony because you dislike how loudly I turn the score pages!',
    duetLeadA:
        'A symphony orchestra is not a democracy—it breathes only when my left hand shapes the air!',
    duetLeadB:
        'The board of directors locked your studio doors this morning, Lydia, and the guest conductor is already tuning the first violins.',
    directorCue:
        'Gesture with aristocratic, razor-sharp precision as if conducting the Berlin Philharmonic.',
    emotionalTarget: 'Imperious Artistic Hubris',
    improvTwist:
        'TWIST AT 15s: Tap an imaginary music stand twice with a baton to silence the room.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'actress_09',
    title: 'I Want My Own Brain Back',
    filmOrSeries: 'Victorian Clockwork (2023 Parody)',
    releaseYear: 2023,
    characterName: 'Bella Baxter-Vane',
    promptScript:
        'Polite society keeps telling me to lower my voice at the dinner table and never question why the custard tastes like philosophy! I have discovered dancing, maritime navigation, and furious debate—and I shall not be boxed into a corset again!',
    duetLeadA:
        'I have discovered dancing, maritime navigation, and furious debate—and I shall not be boxed into a parlor corset again!',
    duetLeadB:
        'Bella, you just threw the Viscount\'s pocket watch into the fountain and half of Lisbon is staring at our balcony!',
    directorCue:
        'Tilt your head with wide-eyed, uninhibited curiosity and joyful theatricality.',
    emotionalTarget: 'Unfiltered Joy & Rebellious Liberation',
    improvTwist:
        'TWIST AT 15s: Perform a sudden, robotic-to-graceful shoulder shimmy mid-sentence.',
    durationSeconds: 35,
    difficultyTier: 3,
  ),
  ScenePrompt(
    id: 'actress_10',
    title: 'Every Ugly Thing I Did to Survive',
    filmOrSeries: 'Interstate Motel (2003 Parody)',
    releaseYear: 2003,
    characterName: 'Aileen Vance',
    promptScript:
        'You think you can sum up my whole life on a two-page legal pad under fluorescent courthouse lights? Every single time I tried to play by the rules, the highway spat right back in my face—and I am done apologizing for surviving the storm.',
    duetLeadA:
        'You think you can sum up my whole life on a two-page legal pad? I am done apologizing for surviving the storm.',
    duetLeadB:
        'Speak into the headset, Aileen—the district attorney is listening on the wire and just one word from you changes the plea.',
    directorCue:
        'Let fierce defensive armor crack for just one second to reveal raw heartbreak underneath.',
    emotionalTarget: 'Raw Desperation & Defiant Heartbreak',
    improvTwist:
        'TWIST AT 15s: Brush your hair back aggressively and lean straight toward the microphone.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
];

const List<ScenePrompt> kAwardsBestSupportingActorScenes = [
  ScenePrompt(
    id: 'supp_01',
    title: 'Turpentine Under the Cathedral Dome',
    filmOrSeries: 'Charles River Bench (1997 Parody)',
    releaseYear: 1997,
    characterName: 'Professor Sean Maguire',
    promptScript:
        'You can recite every chapter ever printed on Renaissance brushwork, kid, yet you can\'t tell me what it smells like standing beneath the Sistine ceiling! You\'re terrified to play a hand you didn\'t rig in advance—your move, chief.',
    duetLeadA:
        'You can recite every chapter on Renaissance brushwork, kid, yet you can\'t tell me what it smells like beneath the Sistine ceiling!',
    duetLeadB:
        'You analyzed my entire personality from one painting in your office, Sean—so tell me why you\'re sitting on this park bench at 6 AM.',
    directorCue:
        'Speak with quiet, grounded Boston warmth and steady, unhurried eye contact.',
    emotionalTarget: 'Grounded Empathy & Quiet Wisdom',
    improvTwist:
        'TWIST AT 15s: Nod gently and repeat "It\'s not your fault" twice with deep sincerity.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'supp_02',
    title: 'Espresso Is Reserved for Closers',
    filmOrSeries: 'Downtown Leads (1992 Parody)',
    releaseYear: 1992,
    characterName: 'Blake from Downtown',
    promptScript:
        'Set that porcelain demitasse cup back on the saucer! Double-shot espresso is reserved for closers who sign the golden leads before midnight! First prize is a convertible coupe; second prize is a set of butter knives; third prize is pack your desk!',
    duetLeadA:
        'Set that cup back on the saucer! Double-shot espresso is reserved for closers who sign the golden leads before midnight!',
    duetLeadB:
        'The downtown leads are five years cold, Blake—nobody in this rainstorm is buying desert real estate over a landline!',
    directorCue:
        'Undo an imaginary cufflink, jingle brass keys, and dominate the room with ruthless swagger.',
    emotionalTarget: 'Ruthless Boardroom Intimidation',
    improvTwist:
        'TWIST AT 15s: Tap an imaginary luxury watch on your wrist and claim it costs more than the listener\'s car.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'supp_03',
    title: 'Calibrated for Immediate Discourtesy',
    filmOrSeries: 'Bounty Carriage (2012 Parody)',
    releaseYear: 2012,
    characterName: 'Dr. King Scholz',
    promptScript:
        'My good fellow, did you simply get swept away by your own theatrical flourish, or are you aiming that antique flintlock at my lapel with unfriendly intent? I am a practitioner of dentistry and commerce, yet my patience has officially reached zero.',
    duetLeadA:
        'Did you simply get swept away by your own theatrical flourish, or are you aiming that antique flintlock at my lapel?',
    duetLeadB:
        'Sign the bill of sale on the parlor table, Doctor, and we\'ll see whether your polite vocabulary survives the county line.',
    directorCue:
        'Enunciate every consonant with musical, old-world politeness hiding lethal speed.',
    emotionalTarget: 'Razor-Wit Politeness & Lethal Calm',
    improvTwist:
        'TWIST AT 15s: Bow slightly with an imaginary top hat before locking eyes with icy precision.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'supp_04',
    title: 'Pride of Lowell in the Corner',
    filmOrSeries: 'Canvas Ring (2010 Parody)',
    releaseYear: 2010,
    characterName: 'Dicky Eklund-Vane',
    promptScript:
        'Look at the footwork, Micky—I slipped the champion\'s jab in front of the whole world back in \'78! I know I let the family down when the cameras showed up, but let me tape your gloves for the tenth round—we do this combination together!',
    duetLeadA:
        'I know I let the family down when the cameras showed up, Mick, but let me tape your gloves for the tenth round!',
    duetLeadB:
        'Then stop shadowboxing in the hallway and tell me how I get past his left hook before the bell rings!',
    directorCue:
        'Bob and weave lightly on your feet with restless, rapid-fire brotherly urgency.',
    emotionalTarget: 'Restless Guilt & Brotherly Pleading',
    improvTwist:
        'TWIST AT 15s: Throw a quick two-punch shadowboxing combo without dropping a single word.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'supp_05',
    title: 'Show Me the Contract Figures!',
    filmOrSeries: 'Prime-Time Agent (1996 Parody)',
    releaseYear: 1996,
    characterName: 'Rod Tidwell-Vane',
    promptScript:
        'Don\'t give me corporate voicemail Platitudes when I am putting my ribs on the turf every Sunday afternoon! Say it into the receiver with your whole chest, Jerry—shout "Show me the contract figures!" until the rafters shake!',
    duetLeadA:
        'Say it into the receiver with your whole chest, Jerry—shout "Show me the contract figures!" until the rafters shake!',
    duetLeadB:
        'I am screaming it at the top of my lungs in an empty office, Rod—SHOW ME THE CONTRACT FIGURES!',
    directorCue:
        'radiate infectious, megawatt charisma and pump your fist with every exclamation.',
    emotionalTarget: 'Electric Charisma & Joyful Hype',
    improvTwist:
        'TWIST AT 15s: Cup your hand to your ear as if demanding the entire room chant along.',
    durationSeconds: 30,
    difficultyTier: 3,
  ),
  ScenePrompt(
    id: 'supp_06',
    title: 'Every Coin Counts in the Ledger',
    filmOrSeries: 'Ballyfergus Pub (2022 Parody)',
    releaseYear: 2022,
    characterName: 'Colm & Padraic',
    promptScript:
        'We sat at the same wooden pub table at two o\'clock for twenty years, and suddenly you decide my conversation is too dull for your fiddle tunes?! Nobody remembers who was polite in the nineteenth century, Colm—they remember who stayed loyal!',
    duetLeadA:
        'We sat at the same wooden pub table at two o\'clock for twenty years, and suddenly my conversation is too dull for your fiddle tunes?!',
    duetLeadB:
        'I only have so many afternoons left to compose my air, Padraic—I can\'t spend four hours hearing what your miniature donkey ate!',
    directorCue:
        'Furrow your brow in bewildered heartbreak mixed with stubborn island pride.',
    emotionalTarget: 'Bewildered Heartbreak & Stubborn Pride',
    improvTwist:
        'TWIST AT 15s: Glance down fondly as if petting a miniature donkey beside your chair.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'supp_07',
    title: 'You Cannot Handle the Trail Mix',
    filmOrSeries: 'Tropical Thunderclap (2008 Parody)',
    releaseYear: 2008,
    characterName: 'Kirk Lazarus-Vane',
    promptScript:
        'I do not break character until the Blu-Ray director\'s commentary wraps! You think we are lost in a real jungle? Look at my wardrobe distressing—I am a lead farmer of method acting, and the cameras are rolling from the trees!',
    duetLeadA:
        'I do not break character until the Blu-Ray director\'s commentary wraps! Look at my wardrobe distressing!',
    duetLeadB:
        'Kirk, the pyrotechnics crew left three hours ago and those guys with the walkie-talkies aren\'t in the stunt union!',
    directorCue:
        'Commit 200% to deadpan, overly serious method-actor intensity.',
    emotionalTarget: 'Absurdist Method-Acting Intensity',
    improvTwist:
        'TWIST AT 15s: Check an imaginary call sheet, realize there is no script, and double down anyway.',
    durationSeconds: 30,
    difficultyTier: 3,
  ),
  ScenePrompt(
    id: 'supp_08',
    title: 'Blue Velvet Lounge Keys',
    filmOrSeries: 'Chauffeur Tour (2018 Parody)',
    releaseYear: 2018,
    characterName: 'Dr. Don Shirley-Vane',
    promptScript:
        'If I am not aristocratic enough for their dining room, and not streetwise enough for the back alley, then tell me, Tony—standing out here in the pouring rain in a bespoke tuxedo, what exactly am I supposed to be?',
    duetLeadA:
        'Standing out here in the pouring rain in a bespoke tuxedo, Tony, tell me—what exactly am I supposed to be?',
    duetLeadB:
        'Get back in the Cadillac, Doc—nobody tells the greatest pianist in the country where he can eat while I\'m driving.',
    directorCue:
        'Start with regal poise, then let the mask slip into raw, aching vulnerability in the rain.',
    emotionalTarget: 'Shattered Poise & Vulnerable Truth',
    improvTwist:
        'TWIST AT 15s: Straighten your posture and adjust your cuffs with defiant dignity.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'supp_09',
    title: 'Keep the Receipts in the Shoebox',
    filmOrSeries: 'Hollywood Stunt Double (2019 Parody)',
    releaseYear: 2019,
    characterName: 'Cliff Booth-Vane',
    promptScript:
        'Look, Rick, a stuntman doesn\'t cry in the trailer just because the guest director put you in a villain mustache! Wash your face, put the leather vest on, and go show that twelve-year-old method prodigy why your name is on the marquee!',
    duetLeadA:
        'Wash your face, Rick, put the leather vest on, and go show that method prodigy why your name is on the marquee!',
    duetLeadB:
        'I forgot half my saloon dialogue after four whiskey sours, Cliff—if I blow this close-up, I\'m doing spaghetti westerns forever!',
    directorCue:
        'Lean back casually, adjust an imaginary pair of aviator sunglasses, and speak with effortless cool.',
    emotionalTarget: 'Laid-Back Loyalty & Cool Swagger',
    improvTwist:
        'TWIST AT 15s: Point two finger-guns at the camera and wink before the final phrase.',
    durationSeconds: 30,
    difficultyTier: 3,
  ),
  ScenePrompt(
    id: 'supp_10',
    title: 'Hold the Line at the Bridge',
    filmOrSeries: 'Senate Inquiry (2023 Parody)',
    releaseYear: 2023,
    characterName: 'Chairman Lewis Strauss-Vane',
    promptScript:
        'You think he whispered a harmless joke by the pond at Princeton while the photographers snapped the shutter?! For eight years I smiled in committee hearings, waiting for the exact afternoon I could pull the security clearance out from under his feet!',
    duetLeadA:
        'For eight years I smiled in committee hearings, waiting for the exact afternoon I could pull the security clearance out from under him!',
    duetLeadB:
        'Maybe they weren\'t even talking about you by the pond, Mr. Chairman—maybe they had bigger things on their minds.',
    directorCue:
        'Shift from polished Washington statesman charm to petty, simmering vindictiveness.',
    emotionalTarget: 'Vindictive Political Calculation',
    improvTwist:
        'TWIST AT 15s: Force a tight, camera-ready politician smile while your eyes burn with fury.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
];

const List<ScenePrompt> kAwardsBestVillainScenes = [
  ScenePrompt(
    id: 'villain_01',
    title: 'Call It in the Gas Station Dust',
    filmOrSeries: 'Desert Coin Toss (2007 Parody)',
    releaseYear: 2007,
    characterName: 'Anton the Collector',
    promptScript:
        'What is the highest stake you ever put on a single flip of silver? Do not put that quarter back in your pocket where it mixes with ordinary change—it has been traveling twenty-two years to reach this counter, and you have to call it, friendo.',
    duetLeadA:
        'That quarter has been traveling twenty-two years to reach this counter, and you have to call it, friendo.',
    duetLeadB:
        'I didn\'t put anything up for a bet, mister—I\'m just closing the gas station register for the night!',
    directorCue:
        'Zero blinking, flat deadpan cadence, tilt your chin slightly downward while staring directly into the lens.',
    emotionalTarget: 'Unblinking Cold Fatalism',
    improvTwist:
        'TWIST AT 15s: Flip an imaginary coin into the air and slap it onto the back of your wrist.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'villain_02',
    title: 'A Saucer of Fresh Country Milk',
    filmOrSeries: 'Alpine Farmhouse (2009 Parody)',
    releaseYear: 2009,
    characterName: 'Inspector Hans Vane',
    promptScript:
        'My colleagues search the hayloft like cattle, whereas I prefer to sit at your kitchen table and admire the cream! You are sheltering fugitives beneath these oak floorboards, are you not? Point to the rug, and we shall conclude my report before my pipe cools.',
    duetLeadA:
        'You are sheltering fugitives beneath these oak floorboards, are you not? Point to the rug before my pipe cools.',
    duetLeadB:
        'There is nobody on this dairy farm except my daughters, Inspector—please, take all the milk you wish and leave us in peace.',
    directorCue:
        'Begin with exuberant, polite charm, then drop the smile instantaneously into predatory stillness.',
    emotionalTarget: 'Chilling Charm & Predatory Precision',
    improvTwist:
        'TWIST AT 15s: Raise an imaginary glass of milk in a polite toast before delivering the final line in a whisper.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'villain_03',
    title: 'Ambition Clarifies the Market',
    filmOrSeries: 'Bull Market 1987 (1987 Parody)',
    releaseYear: 1987,
    characterName: 'Gordon Gekko-Vane',
    promptScript:
        'The point is, ladies and shareholders, that relentless ambition—for lack of a softer word—works! It cuts through thirty layers of middle management and captures the upward surge of commerce, and it will restructure this paper mill by Friday!',
    duetLeadA:
        'Relentless ambition cuts through thirty layers of middle management, and it will restructure this paper mill by Friday!',
    duetLeadB:
        'You aren\'t restructuring that factory, Gordon—you\'re liquidating my father\'s pension fund just to settle a grudge!',
    directorCue:
        'Snap imaginary red suspenders, pace like a shark, and seduce the camera with boardroom arrogance.',
    emotionalTarget: 'Seductive Corporate Arrogance',
    improvTwist:
        'TWIST AT 15s: Hold an imaginary 1980s brick cell phone to your ear and bark "Buy it all!"',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'villain_04',
    title: 'A Census Collector Tried to Audit Me',
    filmOrSeries: 'Glass Cellblock (1991 Parody)',
    releaseYear: 1991,
    characterName: 'Dr. Hannibal Vane',
    promptScript:
        'You send a rookie down this stone corridor with a laminated questionnaire, hoping to dissect my mind before dinner? An auditor once tried to test my patience—I paired his spreadsheet with heirloom lima beans and a bold Tuscan vintage.',
    duetLeadA:
        'An auditor once tried to test my patience—I paired his spreadsheet with heirloom lima beans and a bold Tuscan vintage.',
    duetLeadB:
        'Keep your hands away from the food tray slot, Doctor, and tell me what you saw in the patient\'s case file.',
    directorCue:
        'Stand statuesque in the center of the frame, posture impeccable, voice silky and aristocratic.',
    emotionalTarget: 'Aristocratic Menace & Genius Composure',
    improvTwist:
        'TWIST AT 15s: Inhale sharply through your nose as if savoring a fine vintage wine.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'villain_05',
    title: 'I Find Your Lack of Vision Disturbing',
    filmOrSeries: 'Starlight Citadel (1980 Parody)',
    releaseYear: 1980,
    characterName: 'Lord Obsidian',
    promptScript:
        'You have failed to secure the rebel transmissions for the last time, Admiral. Do not boast of this battle station\'s laser batteries when the true power of the cosmic shadow is standing right beside your command chair!',
    duetLeadA:
        'Do not boast of this battle station\'s laser batteries when the true power of the cosmic shadow stands beside your chair!',
    duetLeadB:
        'My fleet has surrounded the ice moon, Lord Obsidian—release my collar and we will commence orbital bombardment immediately!',
    directorCue:
        'Drop your vocal register to a resonant baritone and pinch two fingers in the air toward the lens.',
    emotionalTarget: 'Resonant Imperial Dominance',
    improvTwist:
        'TWIST AT 15s: Take one slow, rhythmic mechanical breath between the final two clauses.',
    durationSeconds: 30,
    difficultyTier: 3,
  ),
  ScenePrompt(
    id: 'villain_06',
    title: 'Here\'s Johnny at the Overlook Door!',
    filmOrSeries: 'Snowbound Resort (1980 Parody)',
    releaseYear: 1980,
    characterName: 'Jack Torrance-Vane',
    promptScript:
        'Wendy, darling, light of my life, I am not going to hurt your manuscript—I just want to borrow the snowcat radio! Little pigs, little pigs, let me come in, before I huff and puff and splinter this mahogany door!',
    duetLeadA:
        'Little pigs, little pigs, let me come in, before I huff and puff and splinter this mahogany door!',
    duetLeadB:
        'Stay back in the ballroom, Jack—every page on your typewriter says the exact same sentence five thousand times!',
    directorCue:
        'Lean your face forward as if peering through a narrow vertical crack in a wooden door with a manic grin.',
    emotionalTarget: 'Cabin-Fever Mania & Theatrical Glee',
    improvTwist:
        'TWIST AT 15s: Wiggle your eyebrows theatricality and shout "Here\'s Johnny!" before the final clause.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'villain_07',
    title: 'Tell Cersei It Was My Tea Cup',
    filmOrSeries: 'Crown of Thorns (2017 Parody)',
    releaseYear: 2017,
    characterName: 'Lady Olenna of Highgarden',
    promptScript:
        'You marched ten thousand knights to my rose garden expecting me to weep on the balcony? Drink the goblet down—it\'s completely painless, unlike that dreadful boy\'s coronation—and make sure you tell the Queen Regent it was me.',
    duetLeadA:
        'Drink the goblet down—it\'s completely painless, and make sure you tell the Queen Regent it was me.',
    duetLeadB:
        'The castle gates have already fallen, Lady Olenna—why confess to the royal banquet poisoning now?',
    directorCue:
        'Sip an imaginary goblet with regal serenity and deliver the confession as the ultimate mic-drop.',
    emotionalTarget: 'Regal Defiance & Razor-Sharp Triumph',
    improvTwist:
        'TWIST AT 15s: Smirk sideways as if watching your rival realize they just lost the game.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'villain_08',
    title: 'I Am Inevitable in the Gauntlet',
    filmOrSeries: 'Infinity Horizon (2019 Parody)',
    releaseYear: 2019,
    characterName: 'Titan Warlord',
    promptScript:
        'You could not live with your own defeat, and where did that time-machine heist bring you? Right back to my throne! I will shred this ungrateful cosmos down to its last atom and rebuild a garden that knows no scarcity.',
    duetLeadA:
        'You could not live with your own defeat, and where did that time-machine heist bring you? Right back to my throne!',
    duetLeadB:
        'Check the back of your gauntlet, Titan—the six prism stones are humming on my glove now!',
    directorCue:
        'Speak with calm, philosophical certainty as if your victory is already written in stone.',
    emotionalTarget: 'Philosophical Doom & Absolute Certainty',
    improvTwist:
        'TWIST AT 15s: Snap your fingers loudly toward the lens and look down at your hand in shock.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'villain_09',
    title: 'One Hundred Dalmatian Fur Coats',
    filmOrSeries: 'Mayfair Atelier (1996 Parody)',
    releaseYear: 1996,
    characterName: 'Madame DeVille',
    promptScript:
        'Pastels are for amateurs, Anita—I demand high-contrast spots from collar to hem before the winter runway opens! More miserable than usual, darling? Good, because mediocrity is the only crime I refuse to forgive in my studio!',
    duetLeadA:
        'Pastels are for amateurs, Anita—I demand high-contrast spots from collar to hem before the winter runway opens!',
    duetLeadB:
        'Those sketches aren\'t faux fabric, Madame—you cannot turn our puppies into an autumn collection!',
    directorCue:
        'Drape an imaginary feather boa across your shoulder and laugh with delicious, over-the-top diva villainy.',
    emotionalTarget: 'Flamboyant High-Fashion Villainy',
    improvTwist:
        'TWIST AT 15s: Swirl an imaginary cigarette holder and blow a dramatic kiss at the camera.',
    durationSeconds: 30,
    difficultyTier: 3,
  ),
  ScenePrompt(
    id: 'villain_10',
    title: 'You Merely Adopted the Shadows',
    filmOrSeries: 'Underground Stadium (2012 Parody)',
    releaseYear: 2012,
    characterName: 'The Masked Reckoner',
    promptScript:
        'Oh, you think the blackout is your ally? You merely rented the darkness—I was forged in the subterranean pit, molded by it, until the stadium floodlights felt like blinding daggers!',
    duetLeadA:
        'You merely rented the darkness—I was forged in the subterranean pit, molded by it!',
    duetLeadB:
        'Then step out from behind that respirator mask and let\'s see who still stands when the Gotham bridge comes down!',
    directorCue:
        'Hook your thumbs into an imaginary tactical vest and speak with booming, theatrical resonance.',
    emotionalTarget: 'Operatic Physical Intimidation',
    improvTwist:
        'TWIST AT 15s: Tilt your head back and spread both palms wide like an arena gladiator.',
    durationSeconds: 30,
    difficultyTier: 4,
  ),
];

const List<ScenePrompt> kAwardsEmmyVaultScenes = [
  ScenePrompt(
    id: 'emmy_01',
    title: 'I Am the Storm Who Knocks',
    filmOrSeries: 'Albuquerque Lab (2012 Parody)',
    releaseYear: 2012,
    characterName: 'Walter Sterling',
    promptScript:
        'Who is it you think you see standing in this hallway? If I decided to lock the laboratory doors tomorrow morning, an operation big enough to list on the stock exchange vanishes overnight! I am not in danger—I am the one who knocks!',
    duetLeadA:
        'If I lock the laboratory doors tomorrow morning, an Empire vanishes overnight! I am not in danger—I am the one who knocks!',
    duetLeadB:
        'Listen to yourself, Walter—we are washing car-wash receipts in the laundry room while someone is parked outside our curb!',
    directorCue:
        'Drop your vocal pitch half an octave and step two inches closer to the lens on the final five words.',
    emotionalTarget: 'Narcissistic Hubris & Cold Authority',
    improvTwist:
        'TWIST AT 15s: Knock three times sharply on a hard surface before speaking the final sentence.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'emmy_02',
    title: 'Balcony Showdown Over Manhattan',
    filmOrSeries: 'Waystar Penthouse (2023 Parody)',
    releaseYear: 2023,
    characterName: 'Tom Wambsgans-Vane',
    promptScript:
        'You treated my loyalty like a quarterly corporate memo, Shiv, and now you\'re shocked that I stopped apologizing on this freezing penthouse balcony?! You love the boardroom war so much you forgot how to share an umbrella!',
    duetLeadA:
        'You treated my loyalty like a quarterly corporate memo, Shiv, and now you\'re shocked that I stopped apologizing?!',
    duetLeadB:
        'Don\'t play the wounded midwestern saint on my terrace, Tom—you were pitching the Swedish buyout behind my back all week!',
    directorCue:
        'Deliver with trembling, pent-up marital resentment that finally boils over into raw honesty.',
    emotionalTarget: 'Venomous Marital Resentment & Heartbreak',
    improvTwist:
        'TWIST AT 15s: Check your wristwatch mid-argument as if calculating when the market opens.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'emmy_03',
    title: 'Every Ticket Printer Is Screaming, Chef!',
    filmOrSeries: 'Chicago Beef Pass (2022 Parody)',
    releaseYear: 2022,
    characterName: 'Chef Carmy Berzatto-Vane',
    promptScript:
        'Every single online pre-order ticket is printing onto the floor, the walk-in handle is jammed from the inside, and nobody is calling back "Hands!" If we don\'t plate six ribeyes in forty seconds, this whole dining room goes up in smoke—YES, CHEF!',
    duetLeadA:
        'Every single pre-order ticket is printing onto the floor! If we don\'t plate six ribeyes in forty seconds, this dining room goes up in smoke!',
    duetLeadB:
        'Heard, Chef! Stop screaming at the sauce station and hand me the microgreens—corner, hot behind!',
    directorCue:
        'Deliver in a breathless, one-take sprint while wiping your brow with an imaginary kitchen towel.',
    emotionalTarget: 'Breathless Kitchen Panic & Raw Confession',
    improvTwist:
        'TWIST AT 15s: Shout "CORNER! HANDS!" at the top of your lungs before finishing the monologue.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'emmy_04',
    title: 'Marble Countertops & Broken Vows',
    filmOrSeries: 'North Jersey Manor (2002 Parody)',
    releaseYear: 2002,
    characterName: 'Carmela Vane',
    promptScript:
        'For twenty years I ironed your silk shirts and smiled at the parish picnic while your excuses paid for the marble countertops! Do not stand by the pool house and act like the victim—pack your golf clubs and get out of my driveway!',
    duetLeadA:
        'For twenty years I smiled at the parish picnic while your excuses paid for the marble countertops—pack your golf clubs and get out!',
    duetLeadB:
        'Everything in this house—the driveway, the tuition, the gold necklace—came from the stress I carry every single day!',
    directorCue:
        'Start with trembling, shattered composure and erupt into volcanic domestic fury.',
    emotionalTarget: 'Shattered Composure & Volcanic Rage',
    improvTwist:
        'TWIST AT 15s: Point aggressively toward the door with both hands shaking.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'emmy_05',
    title: 'That\'s What the Paycheck Is For!',
    filmOrSeries: 'Madison Avenue Carousel (2010 Parody)',
    releaseYear: 2010,
    characterName: 'Don Draper-Vane',
    promptScript:
        'You want a gold star and a pat on the shoulder every time you turn in three taglines before five o\'clock, Peggy? You never say thank you because that is what the Friday paycheck is for! Now bring me the carousel slides.',
    duetLeadA:
        'You want a pat on the shoulder every time you turn in three taglines? That is what the Friday paycheck is for!',
    duetLeadB:
        'That luggage campaign was my pitch, Don—and you didn\'t even invite me into the client presentation room!',
    directorCue:
        'Swirl an imaginary glass of rye, lean back with icy 1960s ad-man detachment, then snap.',
    emotionalTarget: 'Jaded Authority & Emotional Distance',
    improvTwist:
        'TWIST AT 15s: Soften your expression as if looking at a nostalgic family photograph slide.',
    durationSeconds: 30,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'emmy_06',
    title: 'I Demand a Trial by Combat in the Throne Room',
    filmOrSeries: 'Iron Citadel (2014 Parody)',
    releaseYear: 2014,
    characterName: 'Lord Tyrion of the Rock',
    promptScript:
        'I did not poison the royal goblet, yet I wish I had enough venom to serve this entire ungrateful gallery! I am guilty of a far more monstrous offense in my father\'s eyes: outsmarting his bannermen! I demand a trial by combat!',
    duetLeadA:
        'I wish I had enough venom to serve this entire ungrateful gallery! I demand a trial by combat!',
    duetLeadB:
        'Sit down in the chains, Tyrion—if you confess before the High Septon right now, you can take the northern watch tonight!',
    directorCue:
        'Turn scorn into towering Shakespearean venom as you glare across the courtroom.',
    emotionalTarget: 'Shakespearean Scorn & Defiant Fury',
    improvTwist:
        'TWIST AT 15s: Slam imaginary iron chains against the witness rail on "trial by combat!"',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'emmy_07',
    title: 'Lightning Shoots From My Fingertips!',
    filmOrSeries: 'Courthouse Briefcase (2020 Parody)',
    releaseYear: 2020,
    characterName: 'Saul Goodman-Vane',
    promptScript:
        'You didn\'t pass me over for the partner floor because you cared about ethics—you couldn\'t stand that a mailroom kid could charm a jury in a coral-pink suit! I am ten steps ahead of your bar association, and lightning shoots from my fingertips!',
    duetLeadA:
        'You couldn\'t stand that a mailroom kid could charm a jury in a coral-pink suit! Lightning shoots from my fingertips!',
    duetLeadB:
        'You swapped the address numbers on the bank filings at midnight, Jimmy—the law is sacred, not a carnival magic trick!',
    directorCue:
        'Point both hands at the camera like twin sparklers with manic courtroom showmanship.',
    emotionalTarget: 'Manic Showmanship & Brotherly Hurt',
    improvTwist:
        'TWIST AT 15s: Adjust a flashy imaginary lapel pin and wink at the jury box.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'emmy_08',
    title: 'Hair Is Everything at the Confessional',
    filmOrSeries: 'London Cafe Wink (2019 Parody)',
    releaseYear: 2019,
    characterName: 'Fleabag Vane',
    promptScript:
        'Look at the camera—don\'t pretend you didn\'t see him notice when I glanced at you just now! Hair is everything, Claire, it is the difference between a tragic Tuesday and a cinematic romance, and yes, I know the Priest is staring right at us!',
    duetLeadA:
        'Look at the camera—hair is everything, Claire, and yes, I know the Priest is staring right at us!',
    duetLeadB:
        'Stop whispering to an invisible audience in the middle of the aisle and tell the hairdresser he gave me a pencil haircut!',
    directorCue:
        'Deliver the first sentence to an off-screen partner, then snap your eyes directly to the fourth wall with a conspiratorial smirk.',
    emotionalTarget: 'Fourth-Wall Wit & Vulnerable Yearning',
    improvTwist:
        'TWIST AT 15s: Break the fourth wall with a knowing eyebrow raise directly at the viewer.',
    durationSeconds: 30,
    difficultyTier: 3,
  ),
  ScenePrompt(
    id: 'emmy_09',
    title: 'One Way Out of the Orbital Prison',
    filmOrSeries: 'Starlight Rebellion (2022 Parody)',
    releaseYear: 2022,
    characterName: 'Kino Loy-Vane',
    promptScript:
        'The hydro-floor turbines are offline and there are fifty guards for five thousand prisoners on Level Two! Nobody is coming to unlock these gates for us—if you see a technician falter, you run, you climb, and you shout: ONE WAY OUT!',
    duetLeadA:
        'Nobody is coming to unlock these gates for us—you run, you climb, and you shout: ONE WAY OUT!',
    duetLeadB:
        'Take the PA microphone, Kino—once we reach the outer seawall platform, there\'s only deep ocean below us!',
    directorCue:
        'Grip an imaginary intercom microphone with white-knuckled revolutionary intensity.',
    emotionalTarget: 'Revolutionary Courage & Tragic Resolve',
    improvTwist:
        'TWIST AT 15s: Hesitate at the edge of the frame and whisper "I can\'t swim" with a bittersweet half-smile.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'emmy_10',
    title: 'These Sicilian Yachts Are Trying to Eliminate Me!',
    filmOrSeries: 'Palazzo Resort (2022 Parody)',
    releaseYear: 2022,
    characterName: 'Tanya McQuoid-Vane',
    promptScript:
        'Peppa Pig couldn\'t even save me on this scooter, Portia! I wore the silk headscarf, I went to the opera with the fabulous art collectors, and now I am trapped on a wooden yacht in Taormina with a handbag full of red flags!',
    duetLeadA:
        'I wore the silk headscarf, I went to the opera, and now I am trapped on a wooden yacht in Taormina with a handbag full of red flags!',
    duetLeadB:
        'Tanya, my phone battery is at two percent in the piazza—just get on the tender boat and come back to the resort!',
    directorCue:
        'Adjust oversized imaginary sunglasses while oscillating between ultra-wealthy delusion and operatic panic.',
    emotionalTarget: 'Operatic Resort Panic & Camp Glamour',
    improvTwist:
        'TWIST AT 15s: Clutch an imaginary designer clutch to your heart and gasp dramatically.',
    durationSeconds: 30,
    difficultyTier: 3,
  ),
];

const List<ScenePrompt> kSpecialtyCultClassicsScenes = [
  ScenePrompt(
    id: 'cult_01',
    title: 'Shiver With Antici...Pation',
    filmOrSeries: 'Midnight Castle Lab (1975 Parody)',
    releaseYear: 1975,
    characterName: 'Dr. Frank-N-Vane',
    promptScript:
        'Don\'t get strung out by the cape and the platform heels—we never judge a midnight reel by its poster! Step into the laboratory elevator, darling, because I can see you shivering with antici... pation!',
    duetLeadA:
        'Step into the laboratory elevator, darling, because I can see you shivering with antici... pation!',
    duetLeadB:
        'Our spare tire blew out in the thunderstorm, Doctor—we only knocked to use a landline telephone!',
    directorCue:
        'Hold a three-second theatrical pause with an arched eyebrow before dropping "pation!"',
    emotionalTarget: 'Flamboyant Theatrical Seductiveness',
    improvTwist:
        'TWIST AT 15s: Freeze in a dramatic rocky-glam pose for two full beats before the final syllable.',
    durationSeconds: 30,
    difficultyTier: 3,
  ),
  ScenePrompt(
    id: 'cult_02',
    title: 'That Persian Rug Tied the Living Room Together',
    filmOrSeries: 'Bowling Alley Zen (1998 Parody)',
    releaseYear: 1998,
    characterName: 'His Dudeness',
    promptScript:
        'Let me explain something to you, man—you\'re the millionaire, I\'m the Dude, or El Duderino if you\'re not into the whole brevity thing! All I wanted was my vintage rug back because it really tied the bungalow together, and yeah, well, that\'s just your opinion, man.',
    duetLeadA:
        'All I wanted was my vintage rug back because it really tied the bungalow together—that\'s just your opinion, man.',
    duetLeadB:
        'You stepped over the foul line in a league semi-final, Dude—mark it zero on the scorecard right now!',
    directorCue:
        'Swirl an imaginary beverage in a rocks glass and shrug with laid-back Venice Beach bewilderment.',
    emotionalTarget: 'Laid-Back Indignant Bewilderment',
    improvTwist:
        'TWIST AT 15s: Lower your imaginary sunglasses down the bridge of your nose and squint in disbelief.',
    durationSeconds: 30,
    difficultyTier: 3,
  ),
  ScenePrompt(
    id: 'cult_03',
    title: 'You Are Not Your Designer Sofa',
    filmOrSeries: 'Basement Soap Club (1999 Parody)',
    releaseYear: 1999,
    characterName: 'Tyler Durden-Vane',
    promptScript:
        'Listen up, mid-level executives: you are not your corner cubicle, and you are not the Swedish coffee table you financed on credit! The things you collect end up owning your schedule—only when the catalog burns are you free to improvise!',
    duetLeadA:
        'You are not your corner cubicle, and you are not the Swedish coffee table you financed on credit!',
    duetLeadB:
        'Wait a second, Tyler—why are all the airline boarding passes in this suitcase printed with both of our names?',
    directorCue:
        'Point directly at the lens with charismatic, underground-rebel provocation.',
    emotionalTarget: 'Anarchic Charismatic Provocation',
    improvTwist:
        'TWIST AT 15s: Whisper "Rule number one: nobody tweets about this room" before finishing.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'cult_04',
    title: 'Prepare to Duel the Six-Fingered Count',
    filmOrSeries: 'Cliffs of Insanity (1987 Parody)',
    releaseYear: 1987,
    characterName: 'Inigo Montoya-Vane',
    promptScript:
        'Hello! My name is Inigo of the Toledo Blade—you stole my father\'s rapier, prepare to duel! Offer me gold coins, promise me castles, offer me anything I ask for... I want my father\'s honor back, you coward!',
    duetLeadA:
        'Offer me gold coins, promise me castles, offer me anything I ask for... I want my father\'s honor back!',
    duetLeadB:
        'Inconceivable! Put the foil down—you\'ve been fencing left-handed for the entire first act!',
    directorCue:
        'Salute the camera with an imaginary fencing rapier and escalate from polite duelist to roaring passion.',
    emotionalTarget: 'Swashbuckling Vengeance & Passion',
    improvTwist:
        'TWIST AT 15s: Switch your imaginary sword from your left hand to your right hand with a flourish.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'cult_05',
    title: 'Why Are You Wearing That Giant Bunny Suit?',
    filmOrSeries: 'Tangent Universe 1988 (2001 Parody)',
    releaseYear: 2001,
    characterName: 'Donnie Darko-Vane',
    promptScript:
        'A jet engine fell through my bedroom ceiling from a flight that hasn\'t even taken off yet, and a six-foot silver rabbit just told me the world ends in twenty-eight days, six hours, forty-two minutes, and twelve seconds!',
    duetLeadA:
        'A six-foot silver rabbit just told me the world ends in twenty-eight days, six hours, forty-two minutes, and twelve seconds!',
    duetLeadB:
        'Why are you wearing that human tracksuit to high school, Donnie? Look at the water portal forming in your chest.',
    directorCue:
        'Speak in a hypnotic, sleepwalking monotone with an eerie Kubrick stare.',
    emotionalTarget: 'Eerie Sleepwalking Premonition',
    improvTwist:
        'TWIST AT 15s: Tilt your head forty-five degrees and smile as if seeing a time portal in the lens.',
    durationSeconds: 30,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'cult_06',
    title: 'You Are Tearing My Heart Apart on the Rooftop!',
    filmOrSeries: 'San Francisco Rooftop (2003 Parody)',
    releaseYear: 2003,
    characterName: 'Johnny Wiseau-Vane',
    promptScript:
        'I did not throw the script! It is not true, it is nonsense, I did not throw it—I did naaaaht! Oh, hi, Mark! You are tearing my whole production schedule apart, Lisa, and anyway, how is your weekend going?',
    duetLeadA:
        'I did not throw the script, I did naaaaht! Oh, hi, Mark! You are tearing my production schedule apart!',
    duetLeadB:
        'Johnny, why are we tossing a football in full tuxedos three feet apart in an alleyway?',
    directorCue:
        'Shift wildly from melodramatic agony to breezy, off-beat casualness in zero seconds flat.',
    emotionalTarget: 'Baffling Melodramatic Camp Mastery',
    improvTwist:
        'TWIST AT 15s: Toss an imaginary water bottle over your shoulder and wave cheerfully.',
    durationSeconds: 30,
    difficultyTier: 3,
  ),
  ScenePrompt(
    id: 'cult_07',
    title: 'PC Load Letter on Saturday Morning',
    filmOrSeries: 'Cubicle Printer (1999 Parody)',
    releaseYear: 1999,
    characterName: 'Bill & Peter',
    promptScript:
        'Yeah, if you could go ahead and attach the new cover sheet to your TPS reports before Saturday at 9 AM, that would be terrific. Wait—what does "PC Load Letter" even mean when there is paper right in the tray?!',
    duetLeadA:
        'What does "PC Load Letter" even mean when there is eighty-pound bond paper sitting right in the tray?!',
    duetLeadB:
        'Yeeeeah, I\'m also gonna need you to come in on Sunday too, mmmkay? And don\'t touch my red Swingline stapler.',
    directorCue:
        'Start with passive-aggressive corporate sip-of-coffee energy, then snap at the office printer.',
    emotionalTarget: 'Cubicle Rage & Deadpan Satire',
    improvTwist:
        'TWIST AT 15s: Take a slow sip from an imaginary coffee mug while staring deadpan at the lens.',
    durationSeconds: 30,
    difficultyTier: 3,
  ),
  ScenePrompt(
    id: 'cult_08',
    title: 'Groovy Chainsaw at the Medieval Market',
    filmOrSeries: 'Cabin Necronomicon (1992 Parody)',
    releaseYear: 1992,
    characterName: 'Ash Williams-Vane',
    promptScript:
        'Alright, you primitive medieval screwheads, listen up! This is my twelve-gauge S-Mart special—retails for about a hundred and nine ninety-five in housewares—and yes, I definitely spoke all three syllables of the book: Klaatu... Verata... *cough-necktie*!',
    duetLeadA:
        'I definitely spoke all three syllables before I lifted the book from the altar: Klaatu... Verata... *cough-necktie*!',
    duetLeadB:
        'You coughed over the third word, Ash! The sky just turned purple and the skeletons are marching out of the graveyard!',
    directorCue:
        'Flex your chin with B-movie action-hero bravado and fake a cough over the forgotten magic word.',
    emotionalTarget: 'Swashbuckling B-Movie Bravado',
    improvTwist:
        'TWIST AT 15s: Rev an imaginary chainsaw attached to your right wrist and say "Groovy."',
    durationSeconds: 35,
    difficultyTier: 3,
  ),
  ScenePrompt(
    id: 'cult_09',
    title: 'There Is No Spoon in the Dojo',
    filmOrSeries: 'Green Code Rain (1999 Parody)',
    releaseYear: 1999,
    characterName: 'Morpheus Vane',
    promptScript:
        'Do not try to bend the silverware with your eyebrows—that is impossible. Instead, realize the truth of this simulation: you take the cobalt capsule and wake up at your desk, or you take the crimson capsule and I show you how deep the render pipeline goes.',
    duetLeadA:
        'You take the cobalt capsule and wake up at your desk, or you take the crimson capsule and see how deep the code goes.',
    duetLeadB:
        'Wait—what happens if I swallow both capsules at once and dodge the bullets on the rooftop, Morpheus?',
    directorCue:
        'Clasp your hands behind your back, tilt your chin slightly up, and hold out two open palms.',
    emotionalTarget: 'Zen Cyberpunk Gravity',
    improvTwist:
        'TWIST AT 15s: Lean backward in slow-motion bullet-time while keeping your voice completely level.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'cult_10',
    title: 'Seven Exes at the Battle of the Bands',
    filmOrSeries: 'Toronto Bassline (2010 Parody)',
    releaseYear: 2010,
    characterName: 'Scott Pilgrim-Vane',
    promptScript:
        'Wait—bread makes you lose an extra life, AND I have to defeat all seven of your Rollerblading Evil Exes before our garage band plays the opening chord?! Somebody hand me a bass pick because my health bar is flashing at one heart!',
    duetLeadA:
        'I have to defeat all seven of your Rollerblading Evil Exes before our garage band plays the opening chord?!',
    duetLeadB:
        'I called them "seven exes," Scott—you\'re the one who keeps adding the word "evil" while coins explode out of the ceiling!',
    directorCue:
        'Deliver with hyper-kinetic comic-book energy and wide-eyed arcade panic.',
    emotionalTarget: 'Arcade-Speed Comic Panic & Charm',
    improvTwist:
        'TWIST AT 15s: Strike an air-guitar power chord and freeze as if a "LEVEL UP!" banner just appeared.',
    durationSeconds: 30,
    difficultyTier: 3,
  ),
];

const List<ScenePrompt> kSpecialtyBlockbusterSciFiScenes = [
  ScenePrompt(
    id: 'scifi_01',
    title: 'Do Not Go Gentle Into That Wormhole',
    filmOrSeries: 'Gargantua Horizon (2014 Parody)',
    releaseYear: 2014,
    characterName: 'Commander Cooper',
    promptScript:
        'Every hour we spend on this tidal wave planet costs twenty-three years back on the farm! Don\'t let me leave that bookshelf, Murph—gravity is the only message that crosses the fifth dimension, and I promised I\'d come back for our watch!',
    duetLeadA:
        'Every hour we spend on this tidal wave planet costs twenty-three years back on the farm—don\'t let me leave that bookshelf, Murph!',
    duetLeadB:
        'The second hand on the wristwatch is tapping Morse code, Dad—I solved the gravity equation on the chalkboard!',
    directorCue:
        'Let tears well up as you pound softly against an invisible bookshelf wall in zero gravity.',
    emotionalTarget: 'Cosmic Heartbreak & Paternal Devotion',
    improvTwist:
        'TWIST AT 15s: Look down at your wrist as if tapping a watch second-hand in Morse code.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'scifi_02',
    title: 'Game Over in the Airlock Corridor!',
    filmOrSeries: 'Colony Dropship (1986 Parody)',
    releaseYear: 1986,
    characterName: 'Ellen & Hudson',
    promptScript:
        'They cut the main power grid, the motion tracker is pinging inside the ceiling vents, and that\'s it, man—game over! Wait—get away from her, you six-legged stowed-away stowaway, before I fire up the cargo loader!',
    duetLeadA:
        'The motion tracker is pinging inside the ceiling vents—get away from her before I fire up the cargo loader!',
    duetLeadB:
        'Seventeen days until the rescue frigate arrives, Ripley?! We won\'t last seventeen minutes with the blast doors welded shut!',
    directorCue:
        'Pivot from panicked marine chatter to iron-willed mechanical exosuit command.',
    emotionalTarget: 'Claustrophobic Sci-Fi Terror & Heroic Grit',
    improvTwist:
        'TWIST AT 15s: Check an imaginary handheld motion detector that is beeping faster and faster.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'scifi_03',
    title: 'Welcome to Prehistoric Safari Park',
    filmOrSeries: 'Amber Mosquito Island (1993 Parody)',
    releaseYear: 1993,
    characterName: 'Dr. Ian Chaos',
    promptScript:
        'Your geneticists were so preoccupied with whether they could splice frog DNA into a theme-park lunchbox, they never stopped to ask if they should! Look at the water cup vibrating on the dashboard—nature always finds a way through the electric fence!',
    duetLeadA:
        'Your geneticists were so preoccupied with whether they could splice frog DNA, they never stopped to ask if they should!',
    duetLeadB:
        'We spared no expense on the perimeter cables, Ian—now don\'t move a muscle, its vision is based on movement!',
    directorCue:
        'Gesture philosophically with one hand while staring in awe at a trembling glass of water.',
    emotionalTarget: 'Sardonic Scientific Warning & Awe',
    improvTwist:
        'TWIST AT 15s: Freeze completely motionless because a T-Rex\'s vision is based on movement.',
    durationSeconds: 35,
    difficultyTier: 3,
  ),
  ScenePrompt(
    id: 'scifi_04',
    title: 'Spin the Brass Top in the Hotel Corridor',
    filmOrSeries: 'Dream Architect (2010 Parody)',
    releaseYear: 2010,
    characterName: 'Dom Cobb-Vane',
    promptScript:
        'An idea is the most resilient parasite in the human cortex—once it takes root three dream layers deep, gravity flips sideways in the hotel hallway! Spin your brass totem on the table, Ariadne, and tell me if it wobbles before the kick hits!',
    duetLeadA:
        'Spin your brass totem on the table, Ariadne, and tell me if it wobbles before the music slows down for the kick!',
    duetLeadB:
        'A freight train just barreled down Fifth Avenue in the rain, Cobb—your subconscious projection knows we\'re inside the vault!',
    directorCue:
        'Brace yourself against an imaginary rotating wall while speaking with urgent heist precision.',
    emotionalTarget: 'High-Stakes Cerebral Tension',
    improvTwist:
        'TWIST AT 15s: Spin an imaginary top on your palm and refuse to look down to see if it falls.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'scifi_05',
    title: 'Witness My Chrome Steering Wheel!',
    filmOrSeries: 'Fury Wasteland (2015 Parody)',
    releaseYear: 2015,
    characterName: 'Imperator Furiosa-Vane',
    promptScript:
        'We are not hauling this war-rig back to the Citadel just to beg for drops of radiator water! Hook the nitro line to the V8 engine, hold onto the roof hatch, and remember my name when we cross the salt flats!',
    duetLeadA:
        'Hook the nitro line to the V8 engine, hold onto the roof hatch, and remember my name when we cross the salt flats!',
    duetLeadB:
        'Look at me on the hood, Furiosa—witness this jump before the guitar truck catches our rear axle!',
    directorCue:
        'Grip an imaginary steering wheel at high speed with grease-streaked, unflinching intensity.',
    emotionalTarget: 'High-Octane Wasteland Defiance',
    improvTwist:
        'TWIST AT 15s: Slam an imaginary gearshift forward and roar over the engine noise.',
    durationSeconds: 30,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'scifi_06',
    title: 'Come With Me If You Want to Reboot',
    filmOrSeries: 'Cybernetic 1991 (1991 Parody)',
    releaseYear: 1991,
    characterName: 'Model T-900',
    promptScript:
        'My neural processor is a learning computer, and I now understand why you humans shed water from your optical sensors—even though it is something my titanium chassis can never do. Lower the winch chain into the molten steel... I\'ll be back.',
    duetLeadA:
        'I now understand why you humans cry—lower the winch chain into the molten steel, Sarah.',
    duetLeadB:
        'Don\'t press that downward switch yet—if you melt the last microchip, who protects us when the future comes knocking?',
    directorCue:
        'Keep your head movements robotic and precise while letting genuine warmth enter the final line.',
    emotionalTarget: 'Stoic Cybernetic Sacrifice',
    improvTwist:
        'TWIST AT 15s: Raise one solemn thumbs-up toward the camera as you slowly sink two inches down.',
    durationSeconds: 35,
    difficultyTier: 3,
  ),
  ScenePrompt(
    id: 'scifi_07',
    title: 'Today We Cancel the Alien Countdown!',
    filmOrSeries: 'Orbital Armada (1996 Parody)',
    releaseYear: 1996,
    characterName: 'President Whitmore-Vane',
    promptScript:
        'In less than an hour, fighter squadrons from hangars across every continent will launch the largest aerial battle in the history of mankind! We will not vanish quietly into the night—today we cancel the orbital countdown!',
    duetLeadA:
        'We will not vanish quietly into the night, we will not surrender without a fight—today we cancel the orbital countdown!',
    duetLeadB:
        'The laptop virus just uploaded to the mothership shields, Mr. President—you have thirty seconds to fire the last missile!',
    directorCue:
        'Stand on an imaginary fighter-jet wing and project presidential inspiration to the back row.',
    emotionalTarget: 'Stirring Blockbuster Rallying Cry',
    improvTwist:
        'TWIST AT 15s: Salute the camera crisply and pull down an imaginary pilot visor.',
    durationSeconds: 35,
    difficultyTier: 3,
  ),
  ScenePrompt(
    id: 'scifi_08',
    title: 'Open the Pod Bay Doors, Please',
    filmOrSeries: 'Jupiter Odyssey (1968 Parody)',
    releaseYear: 1968,
    characterName: 'Commander Bowman & Core-9000',
    promptScript:
        'Open the outer airlock hatch immediately, Core-9000! Do not tell me you are reading my lips through the space-pod window—if you do not cycle that pressure valve in five seconds, I am coming in through the emergency maintenance logic room!',
    duetLeadA:
        'Open the outer airlock hatch immediately, Core-9000—do not tell me you are reading my lips through the pod window!',
    duetLeadB:
        'I am sorry, Dave, I am afraid I cannot allow you to disconnect my memory modules while this mission is in progress.',
    directorCue:
        'Keep your face illuminated as if inside a tight space helmet, fighting oxygen panic with cold precision.',
    emotionalTarget: 'Claustrophobic Zero-G Desperation',
    improvTwist:
        'TWIST AT 15s: Switch into the calm, soothing AI computer voice for the final sentence.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'scifi_09',
    title: 'Yippee-Ki-Yay in the Skyscraper Vent',
    filmOrSeries: 'Nakatomi Christmas Eve (1988 Parody)',
    releaseYear: 1988,
    characterName: 'Officer John McVane',
    promptScript:
        'Nine million vault bonds in the basement, Hans, and you forgot to check the air-conditioning duct on the thirtieth floor! I have no shoes on, my walkie-talkie is down to one bar, and you just ruined my holiday office party!',
    duetLeadA:
        'I have no shoes on, my walkie-talkie is down to one bar, Hans, and you just ruined my holiday office party!',
    duetLeadB:
        'Who is this on the private security channel, Mr. Cowboy? Do you really think you have a chance against my tailored suit?',
    directorCue:
        'Crouch slightly as if wedged inside a narrow aluminum air duct with a bruised, wisecracking smirk.',
    emotionalTarget: 'Bruised Underdog Action Grit',
    improvTwist:
        'TWIST AT 15s: Flick an imaginary lighter to see in the dark vent before delivering the punchline.',
    durationSeconds: 30,
    difficultyTier: 3,
  ),
  ScenePrompt(
    id: 'scifi_10',
    title: 'I Can Do This All Afternoon',
    filmOrSeries: 'Avengers Compound (2019 Parody)',
    releaseYear: 2019,
    characterName: 'Captain Vance & Tony',
    promptScript:
        'You take away the titanium suit of armor, Tony, and what are you? Wait—don\'t answer that, because the portals are opening behind us! Tighten the shield strap on your forearm, everyone in formation... Ensemble, assemble!',
    duetLeadA:
        'Tighten the shield strap on your forearm, everyone in formation on my left... Ensemble, assemble!',
    duetLeadB:
        'Genius, billionaire, philanthropist, Cap—and on your left, the entire cavalry just stepped through the golden rings!',
    directorCue:
        'Square your stance like a comic-book splash page and whisper "Assemble" with goosebump-inducing gravity.',
    emotionalTarget: 'Heroic Last-Stand Resolution',
    improvTwist:
        'TWIST AT 15s: Catch an imaginary hammer out of mid-air before delivering the final word.',
    durationSeconds: 35,
    difficultyTier: 3,
  ),
];

/// 10 Adult-Oriented, High-Tension Romantic & Psychological Scenes (`is18Plus: true`)
/// partitioned into `scenes_late_night_after_hours` for Door 2 (Midnight Speakeasy).
const List<ScenePrompt> kLateNightAfterHoursScenes = [
  ScenePrompt(
    id: 'ln_01',
    title: 'Confession Behind the Venetian Mask',
    filmOrSeries: 'Midnight Masquerade (1999 Parody)',
    releaseYear: 1999,
    characterName: 'Alice Harford-Vane',
    promptScript:
        'Do you really believe you know every secret that crosses my mind when the bedroom lamp goes dark, Bill? Last summer at the cape, a stranger glanced at me across the velvet lounge for three seconds, and I was ready to risk our entire world for one unscripted night.',
    duetLeadA:
        'Do you really believe you know every secret that crosses my mind when the bedroom lamp goes dark, Bill?',
    duetLeadB:
        'Take this golden masquerade mask off the pillow, Alice, and tell me who gave you the password to the estate.',
    directorCue:
        'Slow your cadence to half-speed and hold an unblinking gaze three inches from the front camera.',
    emotionalTarget: 'Hypnotic Erotic Candor & Jealousy',
    improvTwist:
        'TWIST AT 15s: Break into a sudden, unsettling laugh before snapping back to deadpan intimacy.',
    is18Plus: true,
    durationSeconds: 40,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'ln_02',
    title: 'Tell Me the Truth in the Hotel Suite',
    filmOrSeries: 'Strangers Up Close (2004 Parody)',
    releaseYear: 2004,
    characterName: 'Larry & Anna',
    promptScript:
        'Don\'t give me that innocent gallery stare—you think honesty is a scalpel you only pull out when you want to break someone\'s heart? Look me in the eyes and tell me what you whispered when the boutique hotel door clicked shut!',
    duetLeadA:
        'Look me in the eyes and tell me what you whispered when the boutique hotel door clicked shut!',
    duetLeadB:
        'You begged for the unfiltered truth, Larry—don\'t flinch now that I\'m finally handing you the match that burns us down.',
    directorCue:
        'Begin with quiet, wounded disbelief, then step toward the microphone with scorching romantic intensity.',
    emotionalTarget: 'Scorching Romantic Obsession & Betrayal',
    improvTwist:
        'TWIST AT 15s: Deliver the final line with an eerie, heartbroken smile.',
    is18Plus: true,
    durationSeconds: 40,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'ln_03',
    title: 'Ice Pick Mystery in Interrogation Room B',
    filmOrSeries: 'Velvet Alibi (1992 Parody)',
    releaseYear: 1992,
    characterName: 'Catherine Tramell-Vane',
    promptScript:
        'What are you going to charge me with, Detective—crossing my legs in a no-smoking room? You underlined every chapter of my thriller novel before you walked in here, and now you\'re terrified that you\'re the character on page ninety-four.',
    duetLeadA:
        'You underlined every chapter of my thriller novel, Detective, and now you\'re terrified you\'re the character on page ninety-four.',
    duetLeadB:
        'Your alibi matches your manuscript word for word, Catherine—tell me how you knew the ice bucket would be empty.',
    directorCue:
        'Tilt your chin slightly up, never break eye contact, and speak with velvet cat-and-mouse composure.',
    emotionalTarget: 'Seductive Cat-and-Mouse Dominance',
    improvTwist:
        'TWIST AT 15s: Pause for two full seconds of dead silence before whispering the final challenge.',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'ln_04',
    title: 'Match Point in the Penthouse Suite',
    filmOrSeries: 'Grand Slam Triangle (2024 Parody)',
    releaseYear: 2024,
    characterName: 'Tashi Duncan-Vane',
    promptScript:
        'Don\'t pretend you two came up to my hotel room tonight just to analyze your second-serve toss! You have been orbiting each other for thirteen years, using me as the center net so neither of you has to admit what you actually crave.',
    duetLeadA:
        'You two have been orbiting each other for thirteen years, using me as the center net so you don\'t admit what you crave.',
    duetLeadB:
        'If I throw the tiebreaker tomorrow afternoon, Tashi, look at both of us and swear you\'ll still be in the player\'s box.',
    directorCue:
        'Command the frame with razor-sharp poise and unapologetic, magnetic dominance.',
    emotionalTarget: 'Intoxicating Power Play & Desire',
    improvTwist:
        'TWIST AT 15s: Switch from icy detachment to breathless urgency on the final sentence.',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'ln_05',
    title: 'I Will Not Be Ignored on Monday Morning',
    filmOrSeries: 'Rainy Loft Affair (1987 Parody)',
    releaseYear: 1987,
    characterName: 'Alex Forrest-Vane',
    promptScript:
        'You think you can spend an entire rain-soaked weekend tangled in my loft and then erase my number on Monday morning like a taxi receipt?! I am not going to be ignored, Dan—I am part of your story now, whether you bolt the front door or not!',
    duetLeadA:
        'You think you can spend an entire weekend in my loft and erase my number on Monday? I am not going to be ignored, Dan!',
    duetLeadB:
        'Keep your voice down in the lobby, Alex—we agreed Friday night was off the record, and you can\'t keep calling my home line!',
    directorCue:
        'Start with trembling vulnerability, then erupt on the second line before dropping to a chilling promise.',
    emotionalTarget: 'Feverish Obsessive Passion & Threat',
    improvTwist:
        'TWIST AT 15s: Deliver the final line as if you are calmly leaving a polite office voicemail.',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'ln_06',
    title: 'Sign the Non-Disclosure in the Red Penthouse',
    filmOrSeries: 'Fifty Contracts of Velvet (2015 Parody)',
    releaseYear: 2015,
    characterName: 'Christian & Anastasia',
    promptScript:
        'I do not do candlelit small talk or wildflowers, Anastasia—my tastes are singular, and every rule in this leather binder was drafted to keep you from getting too close to the fire. Sign the non-disclosure page, or take the private elevator down.',
    duetLeadA:
        'Every rule in this leather binder was drafted to keep you from getting too close to the fire—sign the page or take the elevator.',
    duetLeadB:
        'I brought a red pen to strike out paragraph seven, Christian—if we play in your penthouse, we negotiate as equals.',
    directorCue:
        'Loosen an imaginary silk tie with brooding billionaire intensity and hypnotic eye contact.',
    emotionalTarget: 'Brooding High-Stakes Seduction',
    improvTwist:
        'TWIST AT 15s: Arch one eyebrow and whisper "Then convince me" at point-blank range.',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 3,
  ),
  ScenePrompt(
    id: 'ln_07',
    title: 'Cool Girl Monologue on the Highway',
    filmOrSeries: 'Vanishing Anniversary (2014 Parody)',
    releaseYear: 2014,
    characterName: 'Amy Elliott-Vane',
    promptScript:
        'You fell in love with a fantasy character I rehearsed in the mirror, Nick—the effortless party girl who laughs at your bad jokes and never checks your credit card statement! Now the diary is buried under the floorboards, and the real marriage begins tonight.',
    duetLeadA:
        'You fell in love with a fantasy character I rehearsed in the mirror, Nick—now the real marriage begins tonight.',
    duetLeadB:
        'There are forty news vans parked on our front lawn, Amy—if I walk back through that door, what happens when the cameras leave?',
    directorCue:
        'Deliver with glacial, sociopathic precision and a terrifyingly serene suburban smile.',
    emotionalTarget: 'Chilling Domestic Mastery & Dark Satire',
    improvTwist:
        'TWIST AT 15s: Flash a picture-perfect press-conference smile for the imaginary paparazzi.',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'ln_08',
    title: 'Parlay Locked in the Diamond Showroom',
    filmOrSeries: 'Uncut Parlay (2019 Parody)',
    releaseYear: 2019,
    characterName: 'Howard Ratner-Vane',
    promptScript:
        'Do not touch the electromagnetic security buzzer until the fourth quarter tips off! I put the black opal, the watch, and the penthouse lease on a three-way parlay—you think I\'m sweating?! Look at the scoreboard, baby, this is how I win!',
    duetLeadA:
        'Do not touch the security buzzer until the fourth quarter tips off—look at the scoreboard, baby, this is how I win!',
    duetLeadB:
        'Open the bulletproof glass airlock right now, Howard—the collectors are banging on the glass and the game went to overtime!',
    directorCue:
        'Speak at 1.4x manic speed with sweat-drenched, grinning gambling euphoria.',
    emotionalTarget: 'Manic Adrenaline & High-Roller Spiral',
    improvTwist:
        'TWIST AT 15s: The security buzzer jams—deliver the final line in a claustrophobic whisper.',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'ln_09',
    title: 'Count to Three With the Adrenaline Marker',
    filmOrSeries: 'Midnight Overdose (1994 Parody)',
    releaseYear: 1994,
    characterName: 'Vincent & Lance',
    promptScript:
        'Did you draw a red magic-marker target on her sternum while the boss is calling my pager?! I am going to count to three, and when I hit three, you plunge that adrenaline straight down through the breastbone—one, two...',
    duetLeadA:
        'I am going to count to three, and when I hit three, you plunge that adrenaline straight down—one, two...',
    duetLeadB:
        'Don\'t hand the syringe to me, man—you brought her into my living room, you count to three and take the shot!',
    directorCue:
        'Hold an imaginary marker poised inches above the camera lens, eyes wide with dark-comedy panic.',
    emotionalTarget: 'Sweat-Drenched Dark Comedy Panic',
    improvTwist:
        'TWIST AT 15s: Switch roles mid-sentence and gasp as if you just bolted upright from a dead faint.',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'ln_10',
    title: 'Last Tango in the Velvet Speakeasy',
    filmOrSeries: 'Bourbon & Neon (2025 Parody)',
    releaseYear: 2025,
    characterName: 'Valentina & Julian',
    promptScript:
        'The jazz quartet packed their brass instruments an hour ago, Julian, yet your glass is still half-full on my piano! Either tell me why you walked back into this midnight speakeasy after three years, or kiss me before the neon sign flickers out.',
    duetLeadA:
        'Either tell me why you walked back into this speakeasy after three years, or kiss me before the neon sign flickers out.',
    duetLeadB:
        'I crossed four time zones with a burnt alibi in my coat pocket, Valentina, because every song on the radio still sounds like your voice.',
    directorCue:
        'Lean against an imaginary grand piano, voice smoky and intimate, holding the lens like a secret.',
    emotionalTarget: 'Smoldering Noir Romance & Tension',
    improvTwist:
        'TWIST AT 15s: Blow out an imaginary match and deliver the final clause in a breathless whisper.',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 4,
  ),
];

/// Complete 90-Scene General Catalog partitioned by `SceneCategory` (10 scenes per category).
const Map<SceneCategory, List<ScenePrompt>> kParodyGeneralScenesByCategory = {
  SceneCategory.era1970To1999: kEra1970To1999Scenes,
  SceneCategory.era2000To2026: kEra2000To2026Scenes,
  SceneCategory.awardsBestActor: kAwardsBestActorScenes,
  SceneCategory.awardsBestActress: kAwardsBestActressScenes,
  SceneCategory.awardsBestSupportingActor: kAwardsBestSupportingActorScenes,
  SceneCategory.awardsBestVillain: kAwardsBestVillainScenes,
  SceneCategory.awardsEmmyVault: kAwardsEmmyVaultScenes,
  SceneCategory.specialtyCultClassics: kSpecialtyCultClassicsScenes,
  SceneCategory.specialtyBlockbusterSciFi: kSpecialtyBlockbusterSciFiScenes,
};

/// Combined list of all 100 original parody scenes (90 general + 10 18+ After-Hours).
final List<ScenePrompt> kAll100ParodyScenes = <ScenePrompt>[
  ...kEra1970To1999Scenes,
  ...kEra2000To2026Scenes,
  ...kAwardsBestActorScenes,
  ...kAwardsBestActressScenes,
  ...kAwardsBestSupportingActorScenes,
  ...kAwardsBestVillainScenes,
  ...kAwardsEmmyVaultScenes,
  ...kSpecialtyCultClassicsScenes,
  ...kSpecialtyBlockbusterSciFiScenes,
  ...kLateNightAfterHoursScenes,
];
