import 'lobby_models_and_realtime.dart';
import '../late_night_raunchy_scenes.dart';
export '../late_night_raunchy_scenes.dart';

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
    emotionalTarget: 'Smoldering Noir Romance & Tension [Tier 3 · 1.35x]',
    improvTwist:
        'TWIST AT 15s: Blow out an imaginary match and deliver the final clause in a breathless whisper.',
    is18Plus: true,
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ...kFiftyNewRatedRSpeakeasyScenes,
];

const List<ScenePrompt> kExpandedEra1970To1999Scenes = [
  ScenePrompt(
    id: 'era70_11',
    category: SceneCategory.era1970To1999,
    title: 'Coffee Is for Closers Only',
    filmOrSeries: 'Brass Leads & Boiler Rooms (1992 Parody)',
    releaseYear: 1992,
    characterName: 'Blake Vance',
    promptScript:
        'Put that decaf espresso mug back on the credenza! Espresso is for closers only! You think the downtown syndicate sent me out in the rain to pat your backs? First prize in this sales contest is a gold convertible; second prize is a set of steak knives; third prize is you pack your desk!',
    duetLeadA:
        'Put that espresso mug down—first prize is a gold convertible, second prize is steak knives, third prize is you pack your desk!',
    duetLeadB:
        'The leads you gave us are five years old, Blake—nobody in this zip code is buying swamp lots over the telephone!',
    directorCue:
        'Tap an imaginary gold wristwatch against the lens with ruthless boardroom swagger and sharp staccato cadence.',
    emotionalTarget: 'Ruthless High-Pressure Bravado',
    improvTwist:
        'TWIST AT 15s: Jingle an imaginary set of luxury car keys inches from the lens and sneer.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'era70_12',
    category: SceneCategory.era1970To1999,
    title: 'Attica on the Sidewalk Bank Run',
    filmOrSeries: 'Heatwave Teller (1975 Parody)',
    releaseYear: 1975,
    characterName: 'Sonny Wortzik-Vane',
    promptScript:
        'Put the bullhorns down and step back behind the police barricades! It is ninety-eight degrees in this vault, the air conditioning broke at noon, and if one cruiser inches toward that revolving door, we are bringing the whole block out to chant with us!',
    duetLeadA:
        'Put the bullhorns down and step back behind the barricades—the air conditioning broke at noon!',
    duetLeadB:
        'Sonny, there are two news helicopters overhead and the pizza delivery guy is asking who\'s tipping him!',
    directorCue:
        'Wipe imaginary sweat from your brow and pace the frame with frantic, sympathetic street energy.',
    emotionalTarget: 'Sweat-Drenched Street Desperation',
    improvTwist:
        'TWIST AT 15s: Wave an imaginary white handkerchief and rally the crowd outside.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'era70_13',
    category: SceneCategory.era1970To1999,
    title: 'Forget It Jake, It Is the Water District',
    filmOrSeries: 'Mulholland Reservoir (1974 Parody)',
    releaseYear: 1974,
    characterName: 'Detective J.J. Gittes-Vane',
    promptScript:
        'You think you know why they are dumping millions of gallons of reservoir water into the ocean at midnight during a drought? Every orange grove in the valley has a silent deed attached to it, and if we ask one more question, our fedoras end up floating in the aqueduct!',
    duetLeadA:
        'Every orange grove in the valley has a silent deed attached to it—stop chasing the reservoir ledger!',
    duetLeadB:
        'I have the county surveyor\'s photographs in my glovebox, J.J., and I\'m not walking away this time!',
    directorCue:
        'Touch the bridge of your nose as if wearing a bandage and speak in a world-weary neo-noir baritone.',
    emotionalTarget: 'Cynical Neo-Noir Fatalism',
    improvTwist:
        'TWIST AT 15s: Glance over your shoulder as if headlights just swept across the alley.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'era70_14',
    category: SceneCategory.era1970To1999,
    title: 'Philly Museum Steps Sunrise Sprint',
    filmOrSeries: 'Southpaw Contender (1976 Parody)',
    releaseYear: 1976,
    characterName: 'Rocco Balboa-Vane',
    promptScript:
        'Nobody in the neighborhood gave me a shot past the third round, Adrian, and maybe I can\'t out-dance the champ on points! All I gotta do is still be standing on my two feet when that fifteenth bell rings so I know I wasn\'t just another bum from the docks!',
    duetLeadA:
        'All I gotta do is still be standing on my two feet when that fifteenth bell rings, Adrian!',
    duetLeadB:
        'Win or lose tonight, Rocco, promise me you\'ll come back through that locker room door in one piece.',
    directorCue:
        'Deliver with humble, bruised sincerity, chin tucked slightly, building to quiet grit.',
    emotionalTarget: 'Underdog Heart & Quiet Determination',
    improvTwist:
        'TWIST AT 15s: Shadow-box two quick jabs toward the camera before softening your expression.',
    durationSeconds: 35,
    difficultyTier: 3,
  ),
  ScenePrompt(
    id: 'era70_15',
    category: SceneCategory.era1970To1999,
    title: 'Saturday Library Detention Manifesto',
    filmOrSeries: 'The Shermer Detention Club (1985 Parody)',
    releaseYear: 1985,
    characterName: 'Bender & Claire',
    promptScript:
        'You think Principal Vernon cares who we actually are once that Monday morning bell rings in the hallway? Down here in the library we\'re a brain, an athlete, a basket case, a princess, and a criminal—and I\'m not pretending we didn\'t just change each other\'s lives!',
    duetLeadA:
        'You think Principal Vernon cares who we actually are once that Monday morning bell rings in the hallway?',
    duetLeadB:
        'If you walk past my locker on Monday without saying hello, I\'ll know everything we said today was a lie.',
    directorCue:
        'Lean back with rebellious 80s teen angst, then let genuine vulnerability crack through.',
    emotionalTarget: 'Rebellious Youth &Raw Vulnerability',
    improvTwist:
        'TWIST AT 15s: Freeze mid-sentence as if the principal just peeked through the library door window.',
    durationSeconds: 30,
    difficultyTier: 3,
  ),
  ScenePrompt(
    id: 'era70_16',
    category: SceneCategory.era1970To1999,
    title: 'Greed Clarifies the Takeover Bid',
    filmOrSeries: 'Ticker Tape Sharks (1987 Parody)',
    releaseYear: 1987,
    characterName: 'Gordon Sterling',
    promptScript:
        'The point is, ladies and gentlemen of the shareholder board, that ambition—for lack of a better word—is the engine that keeps this airline flying! It cuts through the bureaucratic fog and captures the essence of the evolutionary spirit!',
    duetLeadA:
        'Ambition cuts through the bureaucratic fog and captures the essence of the evolutionary spirit!',
    duetLeadB:
        'You\'re not saving the airline, Gordon—you\'re liquidating my father\'s hangar to fund a penthouse in Geneva!',
    directorCue:
        'Snap imaginary suspenders, slick your hair back, and command the room like a corporate emperor.',
    emotionalTarget: 'Predatory Boardroom Charisma',
    improvTwist:
        'TWIST AT 15s: Answer an imaginary brick-sized 1980s cell phone and bark "Buy it all!"',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'era70_17',
    category: SceneCategory.era1970To1999,
    title: 'Diner Pastrami Verdict',
    filmOrSeries: 'When Autumn Met Manhattan (1989 Parody)',
    releaseYear: 1989,
    characterName: 'Sally & Harry',
    promptScript:
        'You honestly believe you can tell the difference between real romance and high-level acting across a deli table?! Watch closely—I can order a pastrami on rye with mustard and sell it so convincingly that every table in this diner asks for what I\'m having!',
    duetLeadA:
        'I can sell a pastrami on rye so convincingly that every table in this diner asks for what I\'m having!',
    duetLeadB:
        'Keep your voice down—the lady at Table Six just dropped her fork and the waiter is staring at us!',
    directorCue:
        'Pivot from breezy conversational banter into over-the-top theatrical bravado, then take a casual bite.',
    emotionalTarget: 'Sparkling Rom-Com Wit & Timing',
    improvTwist:
        'TWIST AT 15s: Immediately drop back to deadpan calm and sip an imaginary water glass.',
    durationSeconds: 30,
    difficultyTier: 3,
  ),
  ScenePrompt(
    id: 'era70_18',
    category: SceneCategory.era1970To1999,
    title: 'Show Me the Contract Incentive',
    filmOrSeries: 'Sports Agent Overtime (1996 Parody)',
    releaseYear: 1996,
    characterName: 'Jerry & Rod',
    promptScript:
        'Look at me on this phone line, Rod—all the other clients walked out with the agency sharks, and you are the one franchise star I am betting my entire career on! Say it with me so the stadium hears it: Show me the franchise contract!',
    duetLeadA:
        'You are the one franchise star I am betting my entire career on—say it with me so the stadium hears it!',
    duetLeadB:
        'Louder, Jerry! Say it from your diaphragm like you love football—show me the franchise contract!',
    directorCue:
        'Build from desperate phone-call pleading into a joyful, jumping celebratory roar.',
    emotionalTarget: 'Desperate Hustle to Euphoric Triumph',
    improvTwist:
        'TWIST AT 15s: Realize the office is watching you through the glass wall and keep shouting anyway.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'era70_19',
    category: SceneCategory.era1970To1999,
    title: 'South Boston Park Bench Breakthrough',
    filmOrSeries: 'Chalkboard Genius (1997 Parody)',
    releaseYear: 1997,
    characterName: 'Dr. Sean Maguire-Vane',
    promptScript:
        'You can recite every textbook in the university library, kid, and solve chalkboard equations the professors took ten years to prove—but if I ask you what the ceiling of the Sistine Chapel actually smells like when you stand underneath it, you\'ve got nothing to say.',
    duetLeadA:
        'You can recite every textbook in the library, kid, but you\'ve never stood outside your own defenses.',
    duetLeadB:
        'Don\'t analyze me from a park bench, Doc—you read one file on my past and think you know my whole story.',
    directorCue:
        'Speak with warm, grounded mentorship, leaning forward gently with quiet emotional gravity.',
    emotionalTarget: 'Empathetic Wisdom & Quiet Gravity',
    improvTwist:
        'TWIST AT 15s: Soften your voice to a gentle whisper: "It is not your fault."',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'era70_20',
    category: SceneCategory.era1970To1999,
    title: 'Red Pill or Blue Velvet Capsule',
    filmOrSeries: 'Mainframe Awakening (1999 Parody)',
    releaseYear: 1999,
    characterName: 'Captain Morpheus-Vane',
    promptScript:
        'This is your final boarding call out of the simulation. Take the cobalt capsule and you wake up at your cubicle desk believing whatever the algorithm feeds you; take the crimson capsule and I show you how deep the fiber-optic rabbit hole actually runs.',
    duetLeadA:
        'Take the crimson capsule and I show you how deep the fiber-optic rabbit hole actually runs.',
    duetLeadB:
        'Wait—before I swallow either one, does the real world still have decent espresso or is it all oat gruel?',
    directorCue:
        'Hold both palms out toward the camera lens at equal height, posture statue-still and voice resonant.',
    emotionalTarget: 'Oracular Cyberpunk Gravitas',
    improvTwist:
        'TWIST AT 15s: Adjust imaginary rimless sunglasses and lean two inches closer to the lens.',
    durationSeconds: 35,
    difficultyTier: 3,
  ),
];

const List<ScenePrompt> kExpandedEra2000To2026Scenes = [
  ScenePrompt(
    id: 'era00_11',
    category: SceneCategory.era2000To2026,
    title: 'Cerulean Sweater Lecture',
    filmOrSeries: 'Runway Tyrant (2006 Parody)',
    releaseYear: 2006,
    characterName: 'Miranda Priestly-Vane',
    promptScript:
        'Oh, don\'t chuckle as if you are exempt from this magazine\'s editorial decisions! That lumpy sweater you pulled from the clearance bin is not simply blue, it is cerulean—selected for you by the very people in this showroom whom you think you are too intellectual to respect.',
    duetLeadA:
        'That sweater is not simply blue, it is cerulean—selected for you by the people in this very showroom.',
    duetLeadB:
        'I apologize, Miranda—I was just trying to say both belts looked identical on the mannequin.',
    directorCue:
        'Never raise your voice above a devastatingly calm purr; let a single eyebrow arch do the violence.',
    emotionalTarget: 'Icy Haute-Couture Supremacy',
    improvTwist:
        'TWIST AT 15s: Dismissively wave your hand and murmur "That\'s all."',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'era00_12',
    category: SceneCategory.era2000To2026,
    title: 'Call It in the Gas Station Coin Toss',
    filmOrSeries: 'West Texas Coin Flip (2007 Parody)',
    releaseYear: 2007,
    characterName: 'Anton Chigurh-Vane',
    promptScript:
        'What is the most you have ever wagered on a single quarter flip at a desert gas station? This nineteen-fifty-eight coin has traveled twenty-two years across the highway just to land on your counter—call it in the air, friend.',
    duetLeadA:
        'This coin has traveled twenty-two years across the highway just to land on your counter—call it.',
    duetLeadB:
        'I didn\'t put anything up to bet, mister—I\'m just closing the register for the night!',
    directorCue:
        'Keep your eyelids completely unblinking and tilt your head slightly with eerie, monotone calm.',
    emotionalTarget: 'Unblinking Existential Menace',
    improvTwist:
        'TWIST AT 15s:Slap an imaginary coin onto the back of your wrist and stare down at it.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'era00_13',
    category: SceneCategory.era2000To2026,
    title: 'Drop the "The" From the Startup Name',
    filmOrSeries: 'Dorm Room Billionaires (2010 Parody)',
    releaseYear: 2010,
    characterName: 'Mark & Eduardo',
    promptScript:
        'You had one share dilution clause in the contract and you didn\'t even read the signature page before flying back to New York! You want to know why I locked the server room? Because we\'re not building a campus directory anymore—drop the "The," it\'s cleaner!',
    duetLeadA:
        'You had one dilution clause in the contract and you didn\'t even read the signature page!',
    duetLeadB:
        'I was your best friend and your CFO, Mark—I\'m freezing the bank account and hiring litigators tonight!',
    directorCue:
        'Deliver at rapid-fire Aaron Sorkin cadence with zero pauses and robotic intellectual arrogance.',
    emotionalTarget: 'Hyper-Articulate Silicon Valley Betrayal',
    improvTwist:
        'TWIST AT 15s: Glance down at your laptop screen as if refreshing live user counts mid-argument.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'era00_14',
    category: SceneCategory.era2000To2026,
    title: 'Penny Stock Microphone Rally',
    filmOrSeries: 'Stratton Bullhorn (2013 Parody)',
    releaseYear: 2013,
    characterName: 'Jordan Belfort-Vane',
    promptScript:
        'Put the compliance subpoenas in the shredder because I am not vacating this trading floor! They want to send federal auditors to count our commissions? They\'re gonna need a battalion and a wrecking ball to drag me off this desk—pick up the phones and start dialing!',
    duetLeadA:
        'I am not vacating this trading floor—pick up the phones and start dialing!',
    duetLeadB:
        'Jordan, the SEC is in the lobby elevator right now—if you don\'t sign the settlement, we\'re all cooked!',
    directorCue:
        'Beat your chest rhythmically, then erupt into a feral, desk-stomping motivational roar.',
    emotionalTarget: 'Feral Trading-Floor Euphoria',
    improvTwist:
        'TWIST AT 15s: Toss imaginary hundred-dollar bills toward the lens and point at the back row.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'era00_15',
    category: SceneCategory.era2000To2026,
    title: 'Look At Me, I Run the Bridge Now',
    filmOrSeries: 'Freighter Standoff (2013 Parody)',
    releaseYear: 2013,
    characterName: 'Muse & Captain Richard',
    promptScript:
        'Stop staring at the radar console and look directly into my eyes! Nobody is coming over the horizon to rescue this cargo ship before nightfall—look at me, Irish, I am the captain of this bridge now!',
    duetLeadA:
        'Stop staring at the radar console—look at me, I am the captain of this bridge now!',
    duetLeadB:
        'The main engine room is flooded and the crew locked the bulkhead—if we don\'t steer into the current, we capsize!',
    directorCue:
        'Point two fingers toward your own eyes and hold an intense, commanding close-up gaze.',
    emotionalTarget: 'High-Seas Command & Raw Urgency',
    improvTwist:
        'TWIST AT 15s: React as if the ship\'s alarm klaxon just blared across the wheelhouse.',
    durationSeconds: 30,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'era00_16',
    category: SceneCategory.era2000To2026,
    title: 'Tap Your Spoon on the Teacup',
    filmOrSeries: 'Sunken Lawn Party (2017 Parody)',
    releaseYear: 2017,
    characterName: 'Chris & Missy',
    promptScript:
        'Stop tapping that silver spoon against the porcelain teacup! I know what you\'re doing in this parlor, my hands are locked to the armrests of this leather chair, and I am not falling into the floor for your garden party!',
    duetLeadA:
        'Stop tapping that silver spoon against the porcelain teacup—I know what you\'re doing!',
    duetLeadB:
        'Just breathe and listen to the silver ring, Chris—sink into the quiet floor for a moment.',
    directorCue:
        'Keep your head completely immobilized while letting a single tear-stained, wide-eyed panic fill your eyes.',
    emotionalTarget: 'Paralyzed Psychological Terror',
    improvTwist:
        'TWIST AT 15s: Gasp sharply as if you just broke free from hypnosis and grab your car keys.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'era00_17',
    category: SceneCategory.era2000To2026,
    title: 'Basement Stairs Morse Code',
    filmOrSeries: 'Subterranean Villa (2019 Parody)',
    releaseYear: 2019,
    characterName: 'Ki-taek & Moon-gwang',
    promptScript:
        'You mean to tell me there has been a concrete bunker hidden behind the peach preserves shelf for four years?! The wealthy family upstairs thinks the hallway light is a motion sensor, and you\'ve been tapping Morse code with your forehead!',
    duetLeadA:
        'There has been a concrete bunker hidden behind the preserves shelf for four years?!',
    duetLeadB:
        'Don\'t call the police—Wait! The family\'s SUV just pulled into the driveway because the rain washed out their camping trip!',
    directorCue:
        'Pivot from dark-comedy disbelief to sheer scramble panic as footsteps approach overhead.',
    emotionalTarget: 'Virtuoso Genre-Shift Panic',
    improvTwist:
        'TWIST AT 15s: Duck below the bottom third of the camera frame as if hiding under a coffee table.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'era00_18',
    category: SceneCategory.era2000To2026,
    title: 'Mahjong Tiles in the Emerald Lounge',
    filmOrSeries: 'Singapore Heiress (2018 Parody)',
    releaseYear: 2018,
    characterName: 'Rachel & Eleanor',
    promptScript:
        'Look at the bamboo tiles I just discarded across the table, Eleanor! I drew the winning dragon three turns ago, and I handed it to you so your son wouldn\'t have to choose between his family crest and the woman who actually loves him.',
    duetLeadA:
        'I drew the winning mahjong tile three turns ago, and I handed it to you so your son wouldn\'t have to choose.',
    duetLeadB:
        'You may know probability theory, professor, but this family plays for centuries, not semesters.',
    directorCue:
        'Place an imaginary tile down with regal poise, chin lifted and eyes steady with quiet victory.',
    emotionalTarget: 'Regal Poise & Emotional Checkmate',
    improvTwist:
        'TWIST AT 15s: Flash an effortless, gracious smile before standing up from the table.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'era00_19',
    category: SceneCategory.era2000To2026,
    title: 'Fifth Gen Fighter Cockpit Dogfight',
    filmOrSeries: 'Mach Ten Maverick (2022 Parody)',
    releaseYear: 2022,
    characterName: 'Captain Pete & Rooster',
    promptScript:
        'Don\'t look at the instrument panel, kid—it\'s not the plane, it\'s the pilot in the seat! Pull the canopy stick hard left into the canyon wall on my mark, deploy flares, and trust your wingman!',
    duetLeadA:
        'It\'s not the plane, it\'s the pilot in the seat—pull hard left into the canyon on my mark!',
    duetLeadB:
        'Missile lock warning is screaming in my helmet, Mav—if we pull nine Gs right now the wings will shear off!',
    directorCue:
        'Strain your neck and jaw as if fighting 9 Gs of gravitational force in a supersonic cockpit.',
    emotionalTarget: 'Supersonic G-Force Adrenaline',
    improvTwist:
        'TWIST AT 15s: Look up over your shoulder to track an imaginary bandit jet passing overhead.',
    durationSeconds: 30,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'era00_20',
    category: SceneCategory.era2000To2026,
    title: 'Chain Reaction in the Desert Rain',
    filmOrSeries: 'Trinity Stopwatch (2023 Parody)',
    releaseYear: 2023,
    characterName: 'Dr. Julius Vane',
    promptScript:
        'When we pressed that ignition switch in the desert bunker, the equations said there was a near-zero probability of igniting the atmosphere—and now I stare at the ripples on the pond and wonder if the chain reaction already started.',
    duetLeadA:
        'I stare at the ripples on the pond and wonder if the chain reaction already started.',
    duetLeadB:
        'The Senate committee doesn\'t want philosophy, Doctor—they want to know whose side you\'re on.',
    directorCue:
        'Hold a thousand-yard stare directly through the camera lens with haunted, whispered stillness.',
    emotionalTarget: 'Haunted Historical Weight',
    improvTwist:
        'TWIST AT 15s: Squint as if a blinding white flash just illuminated the soundstage.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
];

const List<ScenePrompt> kExpandedAwardsBestActorScenes = [
  ScenePrompt(
    id: 'actor_11',
    category: SceneCategory.awardsBestActor,
    title: 'The Left Foot Canvas Breakthrough',
    filmOrSeries: 'Dublin Studio Brush (1989 Parody)',
    releaseYear: 1989,
    characterName: 'Christy Brown-Vane',
    promptScript:
        'They told my mother to lock the chalk away because a boy who can\'t hold a pencil in his fingers has nothing to say to the world! Look at the word painted across that floorboards—every letter came out of my soul!',
    duetLeadA:
        'Look at the word painted across the floorboards—every letter came out of my soul!',
    duetLeadB:
        'Hold the brush steady, Christy—the gallery owner from Grafton Street is standing in the doorway right now!',
    directorCue:
        'Channel fierce, triumphant defiance through your eyes and jaw with explosive vocal clarity.',
    emotionalTarget: 'Fierce Artistic Triumph',
    improvTwist:
        'TWIST AT 15s: Let out a sudden, joyful laugh of pure relief.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'actor_12',
    category: SceneCategory.awardsBestActor,
    title: 'Hoo-Ah in the Prep School Assembly',
    filmOrSeries: 'Blind Colonel Tango (1992 Parody)',
    releaseYear: 1992,
    characterName: 'Lt. Col. Frank Slade-Vane',
    promptScript:
        'I have stood at many crossroads in my life, Mr. Headmaster, and I always knew which path was the right one—without exception, I never took it, because it was too damn hard! This boy kept his integrity intact, and you will not expel his future today!',
    duetLeadA:
        'This boy kept his integrity intact, and you will not expel his future in this auditorium today!',
    duetLeadB:
        'Colonel Slade, you are out of order—sit down or campus security will escort you from the podium!',
    directorCue:
        'Fix your gaze slightly above the lens with thunderous military posture and gravelly baritone authority.',
    emotionalTarget: 'Thunderous Moral Roar',
    improvTwist:
        'TWIST AT 15s: Slam an imaginary cane onto the floor and bark "Hoo-ah!"',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'actor_13',
    category: SceneCategory.awardsBestActor,
    title: 'Nocturne in the Ruined Conservatory',
    filmOrSeries: 'Warsaw Ivory Keys (2002 Parody)',
    releaseYear: 2002,
    characterName: 'Wladyslaw & The Officer',
    promptScript:
        'My fingers haven\'t touched a tuned grand piano in two winters, Captain, and the frost has stiffened my knuckles—but if you let me sit on that bench for three minutes, the music will tell you who I am.',
    duetLeadA:
        'If you let me sit on that bench for three minutes, the music will tell you who I am.',
    duetLeadB:
        'Play quietly, pianist—my command post is in the next room, and I am listening.',
    directorCue:
        'Shiver visibly from imaginary cold, then let serene dignity wash over your face as your hands hover over keys.',
    emotionalTarget: 'Fragile Dignity & Transcendent Grace',
    improvTwist:
        'TWIST AT 15s: Close your eyes and sway to an imaginary Chopin chord.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'actor_14',
    category: SceneCategory.awardsBestActor,
    title: 'Georgia On the Studio Rhodes',
    filmOrSeries: 'Hit the Road Vinyl (2004 Parody)',
    releaseYear: 2004,
    characterName: 'Ray & Producer Ahmet',
    promptScript:
        'Don\'t tell me the radio stations won\'t play a six-minute gospel rhythm track just because nobody\'s tried it before! Put the tape reel on record, count the horns in on four, and watch the whole country tap their shoes!',
    duetLeadA:
        'Put the tape reel on record, count the horns in on four, and watch the whole country tap their shoes!',
    duetLeadB:
        'We only have four minutes of studio tape left on the spool, Ray—if we miss the bridge, we lose the session!',
    directorCue:
        'Sway side-to-side behind imaginary sunglasses with infectious rhythmic joy and gravel-warm soul.',
    emotionalTarget: 'Infectious Soulful Genius',
    improvTwist:
        'TWIST AT 15s: Snap your fingers on the off-beat and grin wide at the control booth.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'actor_15',
    category: SceneCategory.awardsBestActor,
    title: 'The Royal Microphone Stammer',
    filmOrSeries: 'Broadcast to the Empire (2010 Parody)',
    releaseYear: 2010,
    characterName: 'Bertie & Lionel',
    promptScript:
        'That red BBC indicator lamp is blinking like an executioner\'s eye, Lionel, and forty million listeners are waiting for a steady voice! Don\'t leave the booth—conduct me through the first sentence like an orchestra!',
    duetLeadA:
        'That red indicator lamp is blinking—conduct me through the first sentence like an orchestra!',
    duetLeadB:
        'Forget the forty million people, Your Majesty—just speak the words to me, one breath at a time.',
    directorCue:
        'Show tight jaw and throat tension before exhaling into a resonant, hard-won vocal release.',
    emotionalTarget: 'Vulnerability Conquering Fear',
    improvTwist:
        'TWIST AT 15s: Sing two words of the line melodically to break the vocal block, then finish strong.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'actor_16',
    category: SceneCategory.awardsBestActor,
    title: 'January Thaw on the House Floor',
    filmOrSeries: 'Telegraph & Gavel (2012 Parody)',
    releaseYear: 2012,
    characterName: 'President Abraham & Thaddeus',
    promptScript:
        'A compass, I learned when I was surveying the prairie, will point you true north from where you stand, but it has no advice about the swamps and chasms you must cross on the way! We need two more votes before the gavel falls at sundown!',
    duetLeadA:
        'A compass points true north, but it has no advice about the swamps—we need two more votes by sundown!',
    duetLeadB:
        'If I soften my speech on the floor today, Mr. President, the gallery will think we flinched!',
    directorCue:
        'Adopt a folksy, high-tenor storyteller cadence that suddenly snaps into thunderous executive command.',
    emotionalTarget: 'Folksy Gravity & Historic Command',
    improvTwist:
        'TWIST AT 15s: Slap the table sharply and lean forward with piercing eyes.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'actor_17',
    category: SceneCategory.awardsBestActor,
    title: 'Cashed-Out Rodeo Buyer\'s Club',
    filmOrSeries: 'Smuggled Vials (2013 Parody)',
    releaseYear: 2013,
    characterName: 'Ron Woodroof-Vane',
    promptScript:
        'The hospital board gave me thirty days on a clipboard two years ago, doc, and I\'m still standing here in my boots with a trunk full of life-saving medicine! Sign the customs release or step out of my driveway!',
    duetLeadA:
        'The hospital gave me thirty days two years ago, doc—sign the release or step out of my driveway!',
    duetLeadB:
        'The FDA marshals are parked across the street, Ron—if you open that trunk right now they\'ll seize every box!',
    directorCue:
        'Tip an imaginary cowboy hat back and deliver with wiry, outlaw Texas swagger.',
    emotionalTarget: 'Outlaw Grit & Survival Defiance',
    improvTwist:
        'TWIST AT 15s: Flash a rascal wink and pull a backup manifest from your boot.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'actor_18',
    category: SceneCategory.awardsBestActor,
    title: 'Frozen River Bear-Claw Crawl',
    filmOrSeries: 'Frontier Revenant (2015 Parody)',
    releaseYear: 2015,
    characterName: 'Hugh Glass-Vane',
    promptScript:
        'You left me in a shallow trench under two feet of Dakota snow with an empty canteen and a broken ankle! I crawled two hundred miles across frozen river ice just to look you in the eye when the wind stops blowing.',
    duetLeadA:
        'I crawled two hundred miles across frozen river ice just to look you in the eye.',
    duetLeadB:
        'The blizzard was closing the pass, Glass—nobody could have carried you over that ridge alive!',
    directorCue:
        'Breathe in ragged, frosty rasps and channel primal, elemental endurance.',
    emotionalTarget: 'Primal Elemental Vengeance',
    improvTwist:
        'TWIST AT 15s: Shiver violently and clench your jaw until your voice drops to a lethal growl.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'actor_19',
    category: SceneCategory.awardsBestActor,
    title: 'Harbor Hardware Shovel Grief',
    filmOrSeries: 'Winter Harbor (2016 Parody)',
    releaseYear: 2016,
    characterName: 'Lee & Patrick',
    promptScript:
        'I understand you want to stay on the boat and keep your friends at the high school, kid, and I\'m trying to make the numbers work—I just can\'t beat it. I can\'t stay in this town another winter.',
    duetLeadA:
        'I\'m trying to make the numbers work, kid—I just can\'t beat it. I can\'t stay in this town.',
    duetLeadB:
        'We can rent the spare room above the garage, Uncle Lee—you don\'t have to run back to Boston!',
    directorCue:
        'Avoid direct eye contact at first, speaking in understated, devastatingly quiet New England restraint.',
    emotionalTarget: 'Understated Heartbreak & Restraint',
    improvTwist:
        'TWIST AT 15s: Catch your breath mid-word and look away from the lens to hide the crack in your voice.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'actor_20',
    category: SceneCategory.awardsBestActor,
    title: 'Underground Bunker War Cabinet',
    filmOrSeries: 'Whitehall Blitz (2017 Parody)',
    releaseYear: 2017,
    characterName: 'Prime Minister Winston-Vane',
    promptScript:
        'You ask what our policy is while the map of Europe goes dark? We shall never parley, we shall never negotiate with tyranny from a position of fear—we will defend every street, every harbor, and every hill until the New World steps forth!',
    duetLeadA:
        'We shall never parley—we will defend every street, every harbor, and every hill!',
    duetLeadB:
        'Prime Minister, the fleet at the channel needs an order in ten minutes—are we launching the civilian boats?',
    directorCue:
        'Jut your lower jaw forward, grip imaginary coat lapels, and roll every consonant like distant thunder.',
    emotionalTarget: 'Oratorical Thunder & Iron Resolve',
    improvTwist:
        'TWIST AT 15s: Flash a defiant two-finger victory sign directly into the lens.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
];

const List<ScenePrompt> kExpandedAwardsBestActressScenes = [
  ScenePrompt(
    id: 'actress_11',
    category: SceneCategory.awardsBestActress,
    title: 'Brainerd Diner Coffee Refill',
    filmOrSeries: 'Snowplow Alibi (1996 Parody)',
    releaseYear: 1996,
    characterName: 'Chief Marge Gunderson-Vane',
    promptScript:
        'So you got the tan sedan in the lot, you got three people missing since Tuesday, and all for a little bit of money—there\'s more to life than a suitcase of cash, don\'tcha know, and it\'s a beautiful day in Minnesota!',
    duetLeadA:
        'There\'s more to life than a suitcase of cash, don\'tcha know—and you\'re coming in the squad car.',
    duetLeadB:
        'Chief, my lawyer in Minneapolis said I don\'t have to answer a single question about the dealership!',
    directorCue:
        'Deliver with cheerful, sing-song Midwest warmth while never losing sharp detective authority.',
    emotionalTarget: 'Warm Midwest Decency & Iron Resolve',
    improvTwist:
        'TWIST AT 15s: Tip an imaginary fur-lined police cap and smile politely while reading rights.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'actress_12',
    category: SceneCategory.awardsBestActress,
    title: 'Hexavalent Water Glass Challenge',
    filmOrSeries: 'Desert Filing Cabinet (2000 Parody)',
    releaseYear: 2000,
    characterName: 'Erin & Corporate Counsel',
    promptScript:
        'By the way, that pitcher of water on the conference table was drawn this morning from a well right next to your cooling towers—so go ahead, counselor, take a big refreshing gulp before you tell these families the water is safe!',
    duetLeadA:
        'That pitcher of water came from the well next to your cooling towers—take a big sip, counselor!',
    duetLeadB:
        'Let\'s not get theatrical, Miss Brockovich—we are here to discuss preliminary settlement figures.',
    directorCue:
        'Slide an imaginary glass across the table, cross your arms, and lock eyes with triumphant working-class fire.',
    emotionalTarget: 'Fierce Working-Class Vindication',
    improvTwist:
        'TWIST AT 15s: Arch your eyebrow as the lawyer pushes the glass away and smirk.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'actress_13',
    category: SceneCategory.awardsBestActress,
    title: 'La Vie En Rose Spotlight Curtain',
    filmOrSeries: 'Parisian Sparrow (2007 Parody)',
    releaseYear: 2007,
    characterName: 'Edith & Stage Manager Bruno',
    promptScript:
        'If you cancel tonight\'s Olympia concert because my hands are trembling, Bruno, you may as well lock me in a museum! Give me the black dress, turn the footlights up, and let me sing until the balcony weeps!',
    duetLeadA:
        'Give me the black dress, turn the footlights up, and let me sing until the balcony weeps!',
    duetLeadB:
        'The doctor said one more three-hour encore will wreck your vocal cords, Edith—the crowd is already standing!',
    directorCue:
        'Start frail and hunched, then straighten into incandescent theatrical command as the spotlight hits.',
    emotionalTarget: 'Incandescent Tragic Grandeur',
    improvTwist:
        'TWIST AT 15s: Throw both arms wide to embrace an imaginary sold-out opera house.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'actress_14',
    category: SceneCategory.awardsBestActress,
    title: 'The Black Feather Coda',
    filmOrSeries: 'Mirror Lake Ballet (2010 Parody)',
    releaseYear: 2010,
    characterName: 'Nina & Thomas',
    promptScript:
        'You told me the White Swan only needed technical precision, Thomas, and that I was too timid to let the dark twin out of the mirror! Watch the thirty-two fouettés tonight—I didn\'t just dance the role, I became it.',
    duetLeadA:
        'Watch the thirty-two fouettés tonight, Thomas—I didn\'t just dance the role, I became it.',
    duetLeadB:
        'The curtain goes up on Act Three in ninety seconds, Nina—don\'t lose yourself out there!',
    directorCue:
        'Breathe rapidly after an imaginary dance leap, eyes wide with feverish, perfectionist ecstasy.',
    emotionalTarget: 'Feverish Perfectionist Ecstasy',
    improvTwist:
        'TWIST AT 15s: Whisper "It was perfect" with a haunting, serene smile.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'actress_15',
    category: SceneCategory.awardsBestActress,
    title: 'Park Avenue Stoli Martini Breakdown',
    filmOrSeries: 'San Francisco Socialite (2013 Parody)',
    releaseYear: 2013,
    characterName: 'Jasmine & Ginger',
    promptScript:
        'I am taking an online interior-design course, Ginger, and as soon as my nervous system stops humming like a high-voltage wire, I will be back in Manhattan hosting charity galas—pass me the Stoli with a twist!',
    duetLeadA:
        'As soon as my nervous system stops humming like a wire, I\'ll be back hosting galas in Manhattan!',
    duetLeadB:
        'Jasmine, you flew first-class on a maxed-out card and you\'re talking to yourself at the bus stop!',
    directorCue:
        'Fan your face with a trembling hand while maintaining brittle, upper-crust denial.',
    emotionalTarget: 'Brittle Aristocratic Unraveling',
    improvTwist:
        'TWIST AT 15s: Snap out of a mid-sentence daydream and ask "Wait, who are you calling?"',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'actress_16',
    category: SceneCategory.awardsBestActress,
    title: 'Here\'s to the Dreamers Audition',
    filmOrSeries: 'Griffith Park Twilight (2016 Parody)',
    releaseYear: 2016,
    characterName: 'Mia & Casting Director',
    promptScript:
        'My aunt used to jump into the freezing river in Paris barefoot without looking down—she said even if we look foolish to the people on the bridge, here\'s to the mess we make while we\'re chasing the dream.',
    duetLeadA:
        'Even if we look foolish to the people on the bridge, here\'s to the mess we make chasing the dream.',
    duetLeadB:
        'Don\'t read from the sides, Mia—just tell us the story in your own voice, the room is yours.',
    directorCue:
        'Begin conversational and bare, letting luminous nostalgia and quiet courage fill your voice.',
    emotionalTarget: 'Luminous Bittersweet Nostalgia',
    improvTwist:
        'TWIST AT 15s: Smile softly through glistening eyes as if remembering an old melody.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'actress_17',
    category: SceneCategory.awardsBestActress,
    title: 'Three Highway Signs Outside Town',
    filmOrSeries: 'County Line Billboards (2017 Parody)',
    releaseYear: 2017,
    characterName: 'Mildred & Chief Willoughby',
    promptScript:
        'I rented all three rotting billboards on the old county road for a whole year, Chief, because the weeds were growing over the case file and somebody in this station needs to look up every morning when they drive to work!',
    duetLeadA:
        'I rented all three billboards on the county road so somebody in this station looks up every morning!',
    duetLeadB:
        'Mildred, every deputy on my force has searched that highway—putting my name in ten-foot letters won\'t manufacture a witness!',
    directorCue:
        'Hands on hips, jaw set like granite, delivering dry, unsentimental fury.',
    emotionalTarget: 'Granite Grief & Unyielding Fury',
    improvTwist:
        'TWIST AT 15s: Soften for a fraction of a second before snapping your armor right back into place.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'actress_18',
    category: SceneCategory.awardsBestActress,
    title: 'Seventeen Rabbits in the Queen\'s Bedchamber',
    filmOrSeries: 'Candlelight Court Intrigue (2018 Parody)',
    releaseYear: 2018,
    characterName: 'Queen Anne & Lady Sarah',
    promptScript:
        'Do you think because my legs ache with gout that I am blind to the whispers in the corridor, Sarah?! Play the harpsichord if you wish, or leave the bedchamber—I am still the monarch of this palace!',
    duetLeadA:
        'Do you think I am blind to the whispers in the corridor?! I am still the monarch of this palace!',
    duetLeadB:
        'I am the only person in this court who tells you the truth when your wig is crooked, Anne!',
    directorCue:
        'Oscillate wildly between petulant royal tantrum and heartbreakingly lonely vulnerability.',
    emotionalTarget: 'Tragicomic Royal Volatility',
    improvTwist:
        'TWIST AT 15s: Feign a sudden fainting spell just to test who rushes to your side.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'actress_19',
    category: SceneCategory.awardsBestActress,
    title: 'Metronome Five-Four Berlin Rehearsal',
    filmOrSeries: 'Philharmonic Podium (2022 Parody)',
    releaseYear: 2022,
    characterName: 'Maestro Lydia Vane',
    promptScript:
        'Time is the essential piece of interpretation—you cannot start the Mahler Fifth without my downbeat! Do not blame the first-chair oboe when it is my right hand that controls the clock of this entire concert hall!',
    duetLeadA:
        'You cannot start the symphony without my downbeat—my right hand controls the clock of this hall!',
    duetLeadB:
        'The board of directors already locked your studio office, Maestro—a guest conductor is on the podium.',
    directorCue:
        'Slash the air with an imaginary conductor\'s baton with razor-sharp intellectual dominance.',
    emotionalTarget: 'Imperial Artistic Obsession',
    improvTwist:
        'TWIST AT 15s: Freeze mid-gesture as if hearing a phantom metronome ticking off-screen.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'actress_20',
    category: SceneCategory.awardsBestActress,
    title: 'Googly Eyes in the Laundromat Tax Audit',
    filmOrSeries: 'Omniverse Bagel (2022 Parody)',
    releaseYear: 2022,
    characterName: 'Evelyn & Waymond',
    promptScript:
        'In another universe we owned a glamorous cinema and wore tailored suits, and in this one we are drowning in laundry receipts at the IRS office—yet even with every timeline collapsing, I would still choose to do taxes with you!',
    duetLeadA:
        'Even with every timeline collapsing at once, I would still choose to do laundry and taxes with you!',
    duetLeadB:
        'Please, Evelyn—be kind, especially when we have no idea what is happening in the multiverse!',
    directorCue:
        'Shift from overwhelmed comedic exhaustion to open-hearted, tearful cosmic warmth.',
    emotionalTarget: 'Cosmic Empathy & Joyful Chaos',
    improvTwist:
        'TWIST AT 15s: Stick an imaginary googly eye onto your forehead and beam with pride.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
];

const List<ScenePrompt> kExpandedAwardsBestSupportingActorScenes = [
  ScenePrompt(
    id: 'supp_11',
    category: SceneCategory.awardsBestSupportingActor,
    title: 'Does It Look Like I Am Kidding at the Copacabana?',
    filmOrSeries: 'Bamboo Lounge Wise Guys (1990 Parody)',
    releaseYear: 1990,
    characterName: 'Tommy DeVito-Vane (Supporting Scene-Stealer)',
    promptScript:
        'You said I\'m a riot? Funny how—like a circus clown here to amuse the VIP table?! Tell me what\'s so funny right now before the waiter brings the veal, or wait—am I just busting your chops, Henry?!',
    duetLeadA:
        'Funny how—like a circus clown here to amuse the VIP table?! Tell me what\'s so funny right now!',
    duetLeadB:
        'Come on, Tommy, you know what I meant—the way you told the story about the precinct captain!',
    directorCue:
        'SUPPORTING ACTOR MASTERCLASS: Drop the room temperature to absolute zero with a dead-eyed stare, then explode into uproarious laughter.',
    emotionalTarget: 'Hair-Trigger Supporting Menace & Wit',
    improvTwist:
        'TWIST AT 15s: Slam the table laughing: "I almost had you going, didn\'t I?!"',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'supp_12',
    category: SceneCategory.awardsBestSupportingActor,
    title: 'Check the Barn Loft, Marshal',
    filmOrSeries: 'Runaway Fugitive Train (1993 Parody)',
    releaseYear: 1993,
    characterName: 'Deputy Marshal Samuel Gerard-Vane',
    promptScript:
        'Listen up, ladies and gentlemen: our target did not sprout wings in that drainage tunnel! I want roadblocks on every county bridge, checkpoints at every hospital, every courthouse, every doghouse, and every outhouse in a fifteen-mile radius!',
    duetLeadA:
        'I want checkpoints at every hospital, every courthouse, every doghouse, and every outhouse in fifteen miles!',
    duetLeadB:
        'Marshal, the river current drops sixty feet over that dam—nobody survives that jump!',
    directorCue:
        'SUPPORTING ACTOR MASTERCLASS: Bark rapid-fire tactical orders while chewing imaginary gum with relentless authority.',
    emotionalTarget: 'Relentless Tactical Authority',
    improvTwist:
        'TWIST AT 15s: Point directly at the camera: "I don\'t care—find him!"',
    durationSeconds: 30,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'supp_13',
    category: SceneCategory.awardsBestSupportingActor,
    title: 'Forty Years Before the Parole Stamp',
    filmOrSeries: 'Zihuatanejo Postcard (1994 Parody)',
    releaseYear: 1994,
    characterName: 'Ellis "Red" Boyd-Vane (Supporting Anchor)',
    promptScript:
        'Rehabilitated? That\'s just a politician\'s word so young fellas in suits can wear a badge and check a box! Keep your rubber stamp, sonny—to tell you the truth, I don\'t give a hoot whether you sign that paper or not.',
    duetLeadA:
        'Rehabilitated is just a politician\'s word—keep your rubber stamp, sonny, I\'m done begging.',
    duetLeadB:
        'Forty years is a long time, Ellis—do you feel ready to rejoin society on the outside?',
    directorCue:
        'SUPPORTING ACTOR MASTERCLASS: Sit back with calm, weathered dignity and a wry, unhurried cadence.',
    emotionalTarget: 'Weathered Soulful Honesty',
    improvTwist:
        'TWIST AT 15s: Look up as if surprised when the green APPROVED stamp hits the desk.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'supp_14',
    category: SceneCategory.awardsBestSupportingActor,
    title: 'The Greatest Trick in the Precinct Office',
    filmOrSeries: 'Kobayashi Coffee Mug (1995 Parody)',
    releaseYear: 1995,
    characterName: 'Verbal Kint-Vane (Supporting Chameleon)',
    promptScript:
        'You think a guy like me was calling the shots on that harbor boat, Agent Kujan? The greatest trick the phantom ever pulled was convincing the entire precinct that he was just a nervous clerk reading names off a bulletin board!',
    duetLeadA:
        'The greatest trick the phantom ever pulled was convincing the precinct he was just a nervous clerk!',
    duetLeadB:
        'Wait a second—look at the bottom of that porcelain coffee mug! Guard, stop him at the elevator!',
    directorCue:
        'SUPPORTING ACTOR MASTERCLASS: Begin meek and hunched, then straighten your posture into smooth, chilling confidence.',
    emotionalTarget: 'Chameleon Deception to Ice-Cold Reveal',
    improvTwist:
        'TWIST AT 15s: Drop the nervous stutter completely and flash a razor-thin smile.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'supp_15',
    category: SceneCategory.awardsBestSupportingActor,
    title: 'Wicked Smart Harvard Bar Roast',
    filmOrSeries: 'Cambridge Apple Cart (1997 Parody)',
    releaseYear: 1997,
    characterName: 'Chuckie Sullivan-Vane (Best Supporting Friend)',
    promptScript:
        'You\'re sitting on a winning lottery ticket in that head of yours, Will, and you\'re too scared to cash it in! The best part of my morning is walking up your front steps hoping you\'re gone—not a goodbye, just gone onto bigger things!',
    duetLeadA:
        'The best part of my morning is walking up your steps hoping you finally left for bigger things!',
    duetLeadB:
        'We grew up on the same block, Chuckie—why are you pushing me out of the neighborhood?',
    directorCue:
        'SUPPORTING ACTOR MASTERCLASS: Deliver with blue-collar Boston loyalty and fierce brotherly tough love.',
    emotionalTarget: 'Selfless Brotherly Tough Love',
    improvTwist:
        'TWIST AT 15s: Clap an imaginary shoulder and grin: "How do you like them apples?"',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'supp_16',
    category: SceneCategory.awardsBestSupportingActor,
    title: 'Are You Rushing or Dragging the Downbeat?',
    filmOrSeries: 'Conservatory Cymbal (2014 Parody)',
    releaseYear: 2014,
    characterName: 'Maestro Terence Fletcher-Vane',
    promptScript:
        'Stop the band! Were you rushing or were you dragging on bar seventeen, Neiman?! There are no two words in the English language more harmful to jazz history than "good job"—now count my tempo or pack your drumsticks!',
    duetLeadA:
        'Were you rushing or were you dragging on bar seventeen?! Count my tempo or pack your drumsticks!',
    duetLeadB:
        'I was right on the metronome click, Fletcher—give me the solo again and watch!',
    directorCue:
        'SUPPORTING ACTOR MASTERCLASS: Snap from terrifying whispered precision into a vein-popping tempo count.',
    emotionalTarget: 'Volcanic Conservatory Intensity',
    improvTwist:
        'TWIST AT 15s: Freeze your fist in mid-air to cut the band off on a dime.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'supp_17',
    category: SceneCategory.awardsBestSupportingActor,
    title: 'You Are the Only One Who Sees Me, Juan',
    filmOrSeries: 'Miami Ocean Lesson (2016 Parody)',
    releaseYear: 2016,
    characterName: 'Juan (Supporting Mentor)',
    promptScript:
        'Let your head rest back in the ocean water, Little—I\'ve got you right here in my hands, the waves won\'t pull you under. At some point you gotta decide for yourself who you\'re gonna be, and nobody in this world can make that choice for you.',
    duetLeadA:
        'At some point you gotta decide for yourself who you\'re gonna be—nobody can make that choice for you.',
    duetLeadB:
        'How do I know which way to swim when everyone on the block keeps shouting different names?',
    directorCue:
        'SUPPORTING ACTOR MASTERCLASS: Speak with deep, protective warmth and unhurried coastal stillness.',
    emotionalTarget: 'Protective Grace & Quiet Tenderness',
    improvTwist:
        'TWIST AT 15s: Nod encouragingly and lower your voice to a comforting hush.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'supp_18',
    category: SceneCategory.awardsBestSupportingActor,
    title: 'Eight Whiskey Sours in the Western Trailer',
    filmOrSeries: 'Sunset Stunt Double (2019 Parody)',
    releaseYear: 2019,
    characterName: 'Cliff Booth-Vane (Supporting Stuntman)',
    promptScript:
        'Hey, don\'t cry in front of the stunt crew, Rick—you\'re the leading man on the call sheet! Put on the sunglasses, walk out onto the western street set, and show that nine-year-old method actress why your name is above the title!',
    duetLeadA:
        'Put on the sunglasses, walk out onto the set, and show them why your name is above the title!',
    duetLeadB:
        'I forgot half my monologue in the saloon, Cliff—if I blow Take Three, my career is toast!',
    directorCue:
        'SUPPORTING ACTOR MASTERCLASS: Lean back with effortless, sun-baked Hollywood stuntman cool and a reassuring grin.',
    emotionalTarget: 'Effortless Loyal Stuntman Cool',
    improvTwist:
        'TWIST AT 15s: Slide imaginary aviators onto your nose and give a two-finger salute.',
    durationSeconds: 30,
    difficultyTier: 3,
  ),
  ScenePrompt(
    id: 'supp_19',
    category: SceneCategory.awardsBestSupportingActor,
    title: 'Never Mistake Kindness for Weakness',
    filmOrSeries: 'Fanny Pack Dojo (2022 Parody)',
    releaseYear: 2022,
    characterName: 'Waymond Wang-Vane (Supporting Heart)',
    promptScript:
        'You think because I hand out cookies and put silly stickers on the filing folders that I don\'t see how hard the world is?! When I choose to see the good side of things, that is not naive—it is strategic, and it is how I survive!',
    duetLeadA:
        'When I choose to see the good side of things, that is not naive—it is how we survive!',
    duetLeadB:
        'Waymond, the multiverse auditors are coming up the elevator—how can you still be smiling?!',
    directorCue:
        'SUPPORTING ACTOR MASTERCLASS: Combine gentle, earnest pleading with sudden martial-arts poise.',
    emotionalTarget: 'Radical Kindness & Heroic Heart',
    improvTwist:
        'TWIST AT 15s: Adjust your imaginary tie like a Hong Kong romance lead in the rain.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'supp_20',
    category: SceneCategory.awardsBestSupportingActor,
    title: 'Amateur Hour at the Senate Confirmation',
    filmOrSeries: 'Capitol Dossier (2023 Parody)',
    releaseYear: 2023,
    characterName: 'Chairman Lewis Strauss-Vane (Supporting Antagonist)',
    promptScript:
        'You thought I was just the modest shoe salesman carrying your briefcase into the physics institute?! Every question on that committee prosecutor\'s legal pad was typed in my office at midnight—because amateurs seek the spotlight, while power works in the shadow!',
    duetLeadA:
        'Every question on that prosecutor\'s pad was typed in my office—amateurs seek the spotlight!',
    duetLeadB:
        'Careful, Mr. Chairman—a young senator from Massachusetts just voted against your confirmation!',
    directorCue:
        'SUPPORTING ACTOR MASTERCLASS: Watch your smooth political smile curdle into bitter, vindictive obsession.',
    emotionalTarget: 'Calculated Vindictive Ambition',
    improvTwist:
        'TWIST AT 15s: Straighten your glasses and demand a recount of the Senate roll call.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
];

const List<ScenePrompt> kExpandedAwardsBestVillainScenes = [
  ScenePrompt(
    id: 'villain_11',
    category: SceneCategory.awardsBestVillain,
    title: 'A Census Taker Tried to Test Me',
    filmOrSeries: 'Glass Cellar Consultation (1991 Parody)',
    releaseYear: 1991,
    characterName: 'Dr. Hannibal Vane',
    promptScript:
        'You flew all the way from the academy in a cheap polyester suit hoping I would profile your case for free, Agent Starling? Tell me what the lambs were whispering when you woke up at 3 AM, and I\'ll give you the first clue.',
    duetLeadA:
        'Tell me what the lambs were whispering at 3 AM, Agent, and I\'ll give you the first clue.',
    duetLeadB:
        'Keep your eyes on the questionnaire, Doctor—you\'re behind tempered glass for a reason.',
    directorCue:
        'Stand dead-center in the frame, chin slightly raised, speaking with cultivated, aristocratic stillness.',
    emotionalTarget: 'Aristocratic Psychological Menace',
    improvTwist:
        'TWIST AT 15s: Inhale deeply through your nose as if identifying their perfume through the glass.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'villain_12',
    category: SceneCategory.awardsBestVillain,
    title: 'What\'s in the Cardboard Delivery Box?',
    filmOrSeries: 'Desert Pylon Finale (1995 Parody)',
    releaseYear: 1995,
    characterName: 'John Doe-Vane',
    promptScript:
        'Don\'t listen to the captain, Detective—walk over to the delivery van and see what I scheduled for 7 PM sharp! You thought you were hunting a madman in the rain, when you were actually the final chapter of my masterpiece!',
    duetLeadA:
        'You thought you were hunting a madman, when you were actually the final chapter of my masterpiece!',
    duetLeadB:
        'Keep your hands where I can see them and stay on your knees—don\'t say another word!',
    directorCue:
        'Speak with eerie,serene conviction as if calmly explaining a mathematical proof.',
    emotionalTarget: 'Serene Fanatical Provocation',
    improvTwist:
        'TWIST AT 15s: Tilt your head toward the sky and whisper "Become vengeance."',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'villain_13',
    category: SceneCategory.awardsBestVillain,
    title: 'I Am Your Number One Fan in the Cabin',
    filmOrSeries: 'Blizzard Typewriter (1990 Parody)',
    releaseYear: 1990,
    characterName: 'Annie Wilkes-Vane',
    promptScript:
        'I bought a whole ream of corrasable bond paper in town, Paul, and then I read chapter twelve and realized you let my favorite heroine perish in a cockadoodie carriage wreck! Nobody leaves this guest room until you type a rewrite!',
    duetLeadA:
        'Nobody leaves this snowed-in guest room until you type a proper rewrite of chapter twelve!',
    duetLeadB:
        'The phone lines are down and the roads are plowed, Annie—my publisher in New York is expecting me!',
    directorCue:
        'Snap from sweet, dimpled fangirl glee into terrifying, wide-eyed cabin rage in a single breath.',
    emotionalTarget: 'Whiplash Sweet-to-Terrifying Rage',
    improvTwist:
        'TWIST AT 15s: Clasp your hands over your heart and beam: "Oh Paul, it\'s going to be our best book yet!"',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'villain_14',
    category: SceneCategory.awardsBestVillain,
    title: 'Thumbs Down in the Colosseum Box',
    filmOrSeries: 'Imperial Sand & Marble (2000 Parody)',
    releaseYear: 2000,
    characterName: 'Emperor Commodus-Vane',
    promptScript:
        'Am I not merciful to the senate and the people of Rome?! All I ever asked from my father was one nod of approval, and instead he handed the legion\'s signet ring to a general who refuses to kneel in the arena!',
    duetLeadA:
        'Am I not merciful?! All I ever asked was one nod of approval from the throne!',
    duetLeadB:
        'The crowd in the upper tiers is chanting the gladiator\'s name, Caesar—you cannot silence fifty thousand voices.',
    directorCue:
        'Tremble with wounded imperial pride, extending your thumb slowly in front of the camera.',
    emotionalTarget: 'Wounded Imperial Narcissism',
    improvTwist:
        'TWIST AT 15s: Whisper "Am I not merciful?!" inches from the lens before turning your thumb down.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'villain_15',
    category: SceneCategory.awardsBestVillain,
    title: 'Ten-Year-Old Scotch on the Precinct Roof',
    filmOrSeries: 'Training Day Badge (2001 Parody)',
    releaseYear: 2001,
    characterName: 'Detective Alonzo Harris-Vane',
    promptScript:
        'You think you can lock me in a cell with a rookie report, Jake?! I built the cases on this block, I run this boulevard, and King Kong ain\'t got nothing on my badge!',
    duetLeadA:
        'I built the cases on this block, I run this boulevard, and King Kong ain\'t got nothing on me!',
    duetLeadB:
        'The neighborhood is watching from the balconies, Alonzo, and I\'m taking the evidence bag downtown.',
    directorCue:
        'Spread both arms wide, chest puffed out, projecting explosive alpha swagger and desperation.',
    emotionalTarget: 'Explosive Alpha Defiance',
    improvTwist:
        'TWIST AT 15s: Laugh darkly and tap your chest twice with both hands.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'villain_16',
    category: SceneCategory.awardsBestVillain,
    title: 'Bill the Butcher\'s Five Points Cleaver',
    filmOrSeries: 'Cobblestone Tammany (2002 Parody)',
    releaseYear: 2002,
    characterName: 'William Cutting-Vane',
    promptScript:
        'You see this glass eye staring across the tavern, Amsterdam? I tapped it with a silver spoon the night your father fell in the square, because a true rival deserves to be remembered in iron and blood!',
    duetLeadA:
        'I tapped this glass eye with a silver spoon because a true rival deserves to be remembered!',
    duetLeadB:
        'The bells of the old church are ringing, Bill—the square belongs to the new generation tonight.',
    directorCue:
        'Twirl an imaginary handlebar mustache and speak with operatic 19th-century theatricality.',
    emotionalTarget: 'Operatic Street-Boss Grandeur',
    improvTwist:
        'TWIST AT 15s: Tap the cheekbone below your eye twice and bare your teeth in a grin.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'villain_17',
    category: SceneCategory.awardsBestVillain,
    title: 'Why So Serious at the Mob Bank Table?',
    filmOrSeries: 'Gotham Pencil Trick (2008 Parody)',
    releaseYear: 2008,
    characterName: 'The Painted Anarchist',
    promptScript:
        'You mob bosses had plans, the commissioner had plans, the schemers had spreadsheets to control their little worlds—introduce a tiny drop of anarchy into the equation and suddenly everyone loses their minds!',
    duetLeadA:
        'Introduce a tiny drop of anarchy into the equation and suddenly everyone loses their minds!',
    duetLeadB:
        'Security! Get this guy in the purple suit out of our boardroom before the cops trace the vault!',
    directorCue:
        'Lick the corner of your lip, tilt your head unpredictably, and vary your pitch from high giggle to gravelly drop.',
    emotionalTarget: 'Unpredictable Anarchic Glee',
    improvTwist:
        'TWIST AT 15s: Slam your palm onto the desk: "Ta-da! The pencil is gone!"',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'villain_18',
    category: SceneCategory.awardsBestVillain,
    title: 'A Glass of Fresh Farmhouse Milk',
    filmOrSeries: 'Chateau Strudel (2009 Parody)',
    releaseYear: 2009,
    characterName: 'Colonel Hans Landa-Vane',
    promptScript:
        'Monsieur, your dairy cows produce the finest cream in the province, and your hospitality is impeccable—so before I sign my ledger and depart, let us drop the polite charade and discuss who is hiding beneath your floorboards.',
    duetLeadA:
        'Your hospitality is impeccable—now let us drop the charade and discuss who is beneath the floorboards.',
    duetLeadB:
        'There is nobody on this farm but my daughters, Colonel—you have already inspected the barn.',
    directorCue:
        'Begin with exaggerated, courtly European politeness, then let your smile vanish in a single frame.',
    emotionalTarget: 'Courtly Charm to Ice-Cold Dread',
    improvTwist:
        'TWIST AT 15s: Wait for the cream before taking a bite of imaginary strudel.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'villain_19',
    category: SceneCategory.awardsBestVillain,
    title: 'Wait for the Cream in the Parlor',
    filmOrSeries: 'Candyland Plantation Dinner (2012 Parody)',
    releaseYear: 2012,
    characterName: 'Calvin Candie-Vane',
    promptScript:
        'You came into my dining room wearing valet velvet, drank my finest Kentucky bourbon, and thought you could buy my prized champion for pennies on the dollar?! Bring out the white cake and lock the parlor doors!',
    duetLeadA:
        'You drank my finest bourbon and thought you could hoodwink me in my own parlor?!',
    duetLeadB:
        'Put the hammer down and sign the bill of sale—we came to do business, not make speeches.',
    directorCue:
        'Lean across the table with Southern gothic flamboyance that suddenly erupts into table-pounding fury.',
    emotionalTarget: 'Flamboyant Southern Gothic Fury',
    improvTwist:
        'TWIST AT 15s: Wipe your hand with a silk handkerchief and flash a venomous smile.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'villain_20',
    category: SceneCategory.awardsBestVillain,
    title: 'Ancestral Throne in the Waterfall Arena',
    filmOrSeries: 'Vibranium Crown (2018 Parody)',
    releaseYear: 2018,
    characterName: 'Erik Killmonger-Vane',
    promptScript:
        'You sat behind a holographic cloaking shield in the mountains while the rest of the world burned outside your borders! I didn\'t come here to ask the council for a tour—I came here to claim the throne!',
    duetLeadA:
        'I didn\'t come here to ask the council for a tour—I came here to claim the throne!',
    duetLeadB:
        'A king who rules only through vengeance will burn his own kingdom to ash before sunrise.',
    directorCue:
        'Walk in a slow circle with swaggering righteous heat, chin high and arms spread.',
    emotionalTarget: 'Righteous Fire & Tragic Fury',
    improvTwist:
        'TWIST AT 15s: Look out over an imaginary sunset horizon and soften your voice.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
];

const List<ScenePrompt> kExpandedAwardsEmmyVaultScenes = [
  ScenePrompt(
    id: 'emmy_11',
    category: SceneCategory.awardsEmmyVault,
    title: 'The Ducks Left the Backyard Pool',
    filmOrSeries: 'North Jersey Espresso (1999 Parody)',
    releaseYear: 1999,
    characterName: 'Tony & Dr. Melfi',
    promptScript:
        'Whatever happened to the strong, silent type in this country, Doc?! Nowadays everybody\'s crying on a velvet sofa about their childhood while my waste-management captains are folding under federal subpoenas!',
    duetLeadA:
        'Whatever happened to the strong, silent type, Doc?! My captains are folding under subpoenas!',
    duetLeadB:
        'You\'re not angry about history, Tony—you\'re panicked because the ducks flew out of your pool.',
    directorCue:
        'Breathe heavily through your nose, jabbing an imaginary cigar in the air with Jersey boss frustration.',
    emotionalTarget: 'Conflicted Mob-Boss Vulnerability',
    improvTwist:
        'TWIST AT 15s: Rub your forehead and admit quietly: "I miss those damn ducks."',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'emmy_12',
    category: SceneCategory.awardsEmmyVault,
    title: 'A Man Must Have a Code on the Corner',
    filmOrSeries: 'Baltimore Wiretap (2002 Parody)',
    releaseYear: 2002,
    characterName: 'Omar & Detective Bunk',
    promptScript:
        'You can wave that gold detective badge in my face all afternoon, Bunk, but out on those west-side rowhouses a man has got to have a code—and I never pointed my piece at a taxpayer who wasn\'t in the game.',
    duetLeadA:
        'Out on those rowhouses a man has got to have a code—I never touched a citizen outside the game.',
    duetLeadB:
        'Makes me sick, Omar, how far we done fell from the old neighborhood we grew up in.',
    directorCue:
        'Whistle two notes of "The Farmer in the Dell," then speak with cool, philosophical street poise.',
    emotionalTarget: 'Street-Poet Honor & Cool Poise',
    improvTwist:
        'TWIST AT 15s: Arch a scarred eyebrow and say "Indeed."',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'emmy_13',
    category: SceneCategory.awardsEmmyVault,
    title: 'The Carousel Nostalgia Pitch',
    filmOrSeries: 'Madison Avenue Martini (2007 Parody)',
    releaseYear: 2007,
    characterName: 'Don Draper-Vane',
    promptScript:
        'Technology is a glittering lure, gentlemen, but nostalgia literally means the pain from an old wound! This slide projector is not a spaceship—it is a time machine that takes us backwards to a place where we know we are loved.',
    duetLeadA:
        'This projector is not a spaceship—it is a time machine that takes us back to where we are loved.',
    duetLeadB:
        'Don, the client in the corner is literally wiping tears off his glasses—close the account right now!',
    directorCue:
        'Click an imaginary slide remote every four seconds, voice rich, smoky, and mesmerizing.',
    emotionalTarget: 'Mesmerizing Poetic Melancholy',
    improvTwist:
        'TWIST AT 15s: Pause in silhouette as the imaginary projector beam hits your face.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'emmy_14',
    category: SceneCategory.awardsEmmyVault,
    title: 'Tread Lightly in the Garage',
    filmOrSeries: 'Albuquerque Blue Crystal (2013 Parody)',
    releaseYear: 2013,
    characterName: 'Walter & Hank',
    promptScript:
        'You closed the garage door and found a poetry book in my bathroom, Hank, and now you think you\'re looking at the harmless high-school teacher you used to tease at family barbecues? If that\'s true, if you don\'t know who I am, then tread lightly.',
    duetLeadA:
        'If you truly don\'t know who you are talking to right now, Hank, then I suggest you tread lightly.',
    duetLeadB:
        'I don\'t know who you are anymore, Walt—you\'re the smartest guy I ever met, and you\'re a monster.',
    directorCue:
        'Take off imaginary glasses slowly and drop your voice a full octave into a lethal whisper.',
    emotionalTarget: 'Quiet Domestic Transformation to Menace',
    improvTwist:
        'TWIST AT 15s: Step two inches closer to the lens without blinking.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'emmy_15',
    category: SceneCategory.awardsEmmyVault,
    title: 'I Demand a Trial by Combat in the Throne Room',
    filmOrSeries: 'Iron Crown Tribunal (2014 Parody)',
    releaseYear: 2014,
    characterName: 'Lord Tyrion-Vane',
    promptScript:
        'I did not poison your royal goblet, but I wish that I had! Watching this ungrateful court point fingers at me after I saved your city walls from burning gives me more relief than a thousand lying witnesses!',
    duetLeadA:
        'I did not poison your royal goblet—I am on trial for refusing to bow to hypocrites!',
    duetLeadB:
        'Confess to the High Septon now and my father will let you take the black at the northern wall!',
    directorCue:
        'Wrathful Shakespearean projection, eyes blazing as you glare around an imaginary packed gallery.',
    emotionalTarget: 'Shakespearean Scorn & Righteous Rage',
    improvTwist:
        'TWIST AT 15s: Clench both fists as if chained and roar "I demand a trial by combat!"',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'emmy_16',
    category: SceneCategory.awardsEmmyVault,
    title: 'Chicanery with the Breast-Pocket Battery',
    filmOrSeries: 'Albuquerque Bar Hearing (2017 Parody)',
    releaseYear: 2017,
    characterName: 'Chuck & Jimmy McGill-Vane',
    promptScript:
        'I am not crazy! I know he swapped those address numbers—1216, one year after Magna Carta, as if I could ever make such a mistake! You think a billboard lawyer with a degree from a correspondence school belongs at the bar?!',
    duetLeadA:
        'I am not crazy! I know he swapped those address numbers—one year after Magna Carta!',
    duetLeadB:
        'Reach into your inside suit pocket, Chuck—huell slipped a fully charged cell phone battery in there an hour ago.',
    directorCue:
        'Rant with pedantic legal fury, then freeze in horrified silence as the courtroom goes pin-drop quiet.',
    emotionalTarget: 'Pedantic Fury to Shattered Pride',
    improvTwist:
        'TWIST AT 15s: Pull an imaginary battery from your coat pocket and drop it like hot coal.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'emmy_17',
    category: SceneCategory.awardsEmmyVault,
    title: 'Boar on the Floor in the Hunting Lodge',
    filmOrSeries: 'Waystar Helicopter (2019 Parody)',
    releaseYear: 2019,
    characterName: 'Logan & Kendall Roy-Vane',
    promptScript:
        'You flew to Hungary on my corporate jet, drank my vintage Bordeaux, and one of you executives leaked our takeover bid to the press! Nobody touches their dessert until the mole steps forward—you are not serious people!',
    duetLeadA:
        'One of you leaked our takeover bid to the press—look at me, you are not serious people!',
    duetLeadB:
        'The stock price is up four points, Dad—the board thinks your dinosaur media empire needs a reboot!',
    directorCue:
        'Growl like a billionaire patriarch who owns the oxygen in the room.',
    emotionalTarget: 'Patriarchal Billionaire Contempt',
    improvTwist:
        'TWIST AT 15s: Wave everyone off with disgust and bark "Make your own pile!"',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'emmy_18',
    category: SceneCategory.awardsEmmyVault,
    title: 'Fourth-Wall Kneel in the Confessional',
    filmOrSeries: 'London Guinea Pig Cafe (2019 Parody)',
    releaseYear: 2019,
    characterName: 'Fleabag & The Priest',
    promptScript:
        'I just want someone to tell me what to wear in the morning, what to believe in, and how to stop glancing at the camera every time a conversation gets too honest!Wait—how did you just see me look over there?!',
    duetLeadA:
        'Wait a second—where did you just go when you glanced over at the corner of the room?!',
    duetLeadB:
        'Nowhere, Father—I was just thinking about foxes and gin-in-a-tin!',
    directorCue:
        'Deliver a conspiratorial aside directly to the camera lens, then startle when your co-star catches you.',
    emotionalTarget: 'Witty Fourth-Wall Intimacy & Yearning',
    improvTwist:
        'TWIST AT 15s: Flash a guilty, knowing wink directly at the lens.',
    durationSeconds: 30,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'emmy_19',
    category: SceneCategory.awardsEmmyVault,
    title: 'Every Second Counts on the Expo Line',
    filmOrSeries: 'Chicago Beef Brigade (2022 Parody)',
    releaseYear: 2022,
    characterName: 'Chef Carmy & Sydney',
    promptScript:
        'Hands at the pass right now! Why are there seventy-two pre-order tickets printing off the machine at 10:58 AM when the fennel isn\'t even julienned?! Say "Heard, Chef!" or get off my line!',
    duetLeadA:
        'Why are there seventy-two tickets printing off the machine at 10:58 AM?! Say "Heard, Chef!"',
    duetLeadB:
        'You forgot to turn off the online pre-order toggle on the tablet, Chef—the whole block is outside!',
    directorCue:
        'Chop imaginary herbs at machine-gun speed while your voice climbs into pressure-cooker kitchen panic.',
    emotionalTarget: 'Kitchen Pressure-Cooker Intensity',
    improvTwist:
        'TWIST AT 15s: Take a sharp deep breath, touch your apron, and say "Corner, behind!"',
    durationSeconds: 30,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'emmy_20',
    category: SceneCategory.awardsEmmyVault,
    title: 'Twenty Years in the Strawberry Patch',
    filmOrSeries: 'Cordyceps Highway (2023 Parody)',
    releaseYear: 2023,
    characterName: 'Bill & Frank',
    promptScript:
        'I used to pray for the world to end so I could finally have the town to myself, Frank—and then you fell into my perimeter trap, planted strawberries in the yard, and gave me the only thing worth guarding.',
    duetLeadA:
        'You planted strawberries in the yard and gave me the only thing left in the world worth guarding.',
    duetLeadB:
        'Pour the Beaujolais from the cellar, Bill—today we wear our Sunday suits and eat like kings.',
    directorCue:
        'Let gruff survivalist armor melt into deeply earned, tender devotion.',
    emotionalTarget: 'Gruff Tenderness & Devoted Grace',
    improvTwist:
        'TWIST AT 15s: Laugh softly through tears at the taste of an imaginary fresh strawberry.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
];

const List<ScenePrompt> kExpandedSpecialtyCultClassicsScenes = [
  ScenePrompt(
    id: 'cult_11',
    category: SceneCategory.specialtyCultClassics,
    title: 'That Persian Rug Tied the Living Room Together',
    filmOrSeries: 'Bowling Alley White Russian (1998 Parody)',
    releaseYear: 1998,
    characterName: 'The Dude & Walter',
    promptScript:
        'Look, man, you got the wrong Lebowski—I\'m the Dude, so that\'s what you call me! Your thugs came into my bungalow, ruined a vintage rug that really tied the room together, and spilled my half-and-half!',
    duetLeadA:
        'That rug really tied the bungalow together, man, and this aggression will not stand!',
    duetLeadB:
        'Forget the rug, Dude—we have league playoffs on Wednesday and Smokey stepped over the foul line!',
    directorCue:
        'Slouch in an imaginary bathrobe, swirling a glass of ice with laid-back California indignation.',
    emotionalTarget: 'Zen Slacker Indignation',
    improvTwist:
        'TWIST AT 15s: Shrug Philosophically: "Yeah, well, that\'s just, like, your opinion, man."',
    durationSeconds: 30,
    difficultyTier: 3,
  ),
  ScenePrompt(
    id: 'cult_12',
    category: SceneCategory.specialtyCultClassics,
    title: 'First Rule of the Basement Soap Club',
    filmOrSeries: 'Paper Street Underground (1999 Parody)',
    releaseYear: 1999,
    characterName: 'Tyler Durden-Vane',
    promptScript:
        'Look around this basement—we are working jobs we hate to buy designer Swedish coffee tables we don\'t need! We are the middle children of history, and tonight the first rule of this club is nobody tweets about the basement!',
    duetLeadA:
        'We are working jobs we hate to buy Swedish coffee tables we don\'t need—welcome to the basement!',
    duetLeadB:
        'Wait—if we\'re not allowed to talk about the club, how did forty new guys show up in parking lot B?!',
    directorCue:
        'Point directly at the lens with charismatic underground-prophet swagger and a crooked grin.',
    emotionalTarget: 'Subversive Charismatic Swagger',
    improvTwist:
        'TWIST AT 15s: Point to your own jaw: "Hit me as hard as you can!"',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'cult_13',
    category: SceneCategory.specialtyCultClassics,
    title: 'Why Are You Wearing That Giant Bunny Suit?',
    filmOrSeries: 'Tangent Universe 28 Days (2001 Parody)',
    releaseYear: 2001,
    characterName: 'Donnie & Frank the Rabbit',
    promptScript:
        'A jet engine just fell through my bedroom ceiling from a plane nobody has on radar, and you\'re standing on the golf course in a six-foot silver rabbit costume telling me the world ends in twenty-eight days?!',
    duetLeadA:
        'Why are you wearing that six-foot silver rabbit costume on the golf course at 2 AM?!',
    duetLeadB:
        'Twenty-eight days, six hours, forty-two minutes, and twelve seconds—why are you wearing that human suit?',
    directorCue:
        'Walk forward as if sleepwalking in a trance, blinking into an eerie blue spotlight.',
    emotionalTarget: 'Surreal Sleepwalking Dread',
    improvTwist:
        'TWIST AT 15s: Flash a haunted, knowing half-smile at the ceiling.',
    durationSeconds: 30,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'cult_14',
    category: SceneCategory.specialtyCultClassics,
    title: 'Where Is My Supersuit, Honey?!',
    filmOrSeries: 'Metroville Freeze (2004 Parody)',
    releaseYear: 2004,
    characterName: 'Lucius & Honey',
    promptScript:
        'A giant robot is rolling down Main Street right outside our apartment window, Honey—where is my supersuit?! Don\'t tell me you packed it away before dinner, the city is in danger!',
    duetLeadA:
        'A giant robot is rolling down Main Street—tell me where you put my supersuit, woman!',
    duetLeadB:
        'Your evening is in danger! We have been planning this anniversary dinner for two months, Lucius!',
    directorCue:
        'Fling open imaginary closet doors in frantic, rhythmic back-and-forth domestic comedy.',
    emotionalTarget: 'High-Energy Domestic Superhero Comedy',
    improvTwist:
        'TWIST AT 15s: Freeze mid-pose as if sliding across an icy living-room floor.',
    durationSeconds: 30,
    difficultyTier: 3,
  ),
  ScenePrompt(
    id: 'cult_15',
    category: SceneCategory.specialtyCultClassics,
    title: 'Five-Point Palm Exploding Heart Technique',
    filmOrSeries: 'Yellow Tracksuit Vengeance (2003 Parody)',
    releaseYear: 2003,
    characterName: 'Beatrix & Pai Mei',
    promptScript:
        'You locked me inside a wooden coffin six feet underground with nothing but a flashlight and a three-inch punch! Tell the Crazy Eighty-Eight to clear the restaurant floor, because I came for the top of the list!',
    duetLeadA:
        'You locked me six feet underground with a three-inch punch—now I came for the top of the list!',
    duetLeadB:
        'Wiggle your big toe first, Kiddo—the bride in the yellow tracksuit never leaves a debt unpaid.',
    directorCue:
        'Drop into a sharp martial-arts stance, brushing dust off your shoulder with pulp-cinema intensity.',
    emotionalTarget: 'Stylized Pulp-Action Vengeance',
    improvTwist:
        'TWIST AT 15s: Strike an iconic crane-style finger pose at the camera.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'cult_16',
    category: SceneCategory.specialtyCultClassics,
    title: 'Take Car, Go to Mum\'s, Have a Pint at the Winchester',
    filmOrSeries: 'North London Zombie Pub (2004 Parody)',
    releaseYear: 2004,
    characterName: 'Shaun & Ed',
    promptScript:
        'Alright, here is the master tactical plan: we take the red coupe, we rescue Mum, we pick up Liz, we head down to the Winchester tavern, have a nice cold pint, and wait for this whole apocalypse to blow over!',
    duetLeadA:
        'We head down to the Winchester, have a nice cold pint, and wait for this whole apocalypse to blow over!',
    duetLeadB:
        'Brilliant plan, mate—except the zombies are already in the garden and don\'t throw my vintage vinyl records at them!',
    directorCue:
        'Adjustment an imaginary red necktie with deadpan British optimism while chaos unfolds around you.',
    emotionalTarget: 'Deadpan British Pub Optimism',
    improvTwist:
        'TWIST AT 15s: Raise an imaginary pint glass and wink: "How\'s that for a slice of fried gold?"',
    durationSeconds: 30,
    difficultyTier: 3,
  ),
  ScenePrompt(
    id: 'cult_17',
    category: SceneCategory.specialtyCultClassics,
    title: 'I Did Not Hit Her, Oh Hi Mark!',
    filmOrSeries: 'San Francisco Rooftop Green Screen (2003 Parody)',
    releaseYear: 2003,
    characterName: 'Johnny & Mark',
    promptScript:
        'It is not true, don\'t even ask—it is complete fabrication, I did not do it, I did not! ...Oh, hi Mark! Anyway, how is your weekend going, let\'s toss this football in tuxedos from three feet away!',
    duetLeadA:
        'It is complete fabrication, I did not do it! ...Oh, hi Mark! Let\'s toss the football in tuxedos!',
    duetLeadB:
        'Johnny, why are we wearing rented formalwear on a rooftop at two in the afternoon?',
    directorCue:
        'Drop from melodramatic rage to a completely flat, cheerful "Oh hi Mark!" in zero milliseconds.',
    emotionalTarget: 'Gloriously Bizarre Cult Melodrama',
    improvTwist:
        'TWIST AT 15s: Toss an imaginary water bottle over your shoulder and laugh inexplicably.',
    durationSeconds: 30,
    difficultyTier: 3,
  ),
  ScenePrompt(
    id: 'cult_18',
    category: SceneCategory.specialtyCultClassics,
    title: 'Vote for Pedro at the High School Assembly',
    filmOrSeries: 'Preston Idaho Tater Tots (2004 Parody)',
    releaseYear: 2004,
    characterName: 'Napoleon & Pedro',
    promptScript:
        'Gosh! Nobody in this school has any bowstaff skills or numchuck skills, and if you vote for Pedro today, all of your wildest dreams will come true—now watch this freestyle dance routine!',
    duetLeadA:
        'If you vote for Pedro today, all of your wildest dreams will come true—gosh!',
    duetLeadB:
        'Napoleon, give me some of your tater tots from your cargo pocket before the bell rings.',
    directorCue:
        'Sigh heavily through your mouth with awkward deadpan commitment, then bust two sharp dance moves.',
    emotionalTarget: 'Awkward Deadpan Triumph',
    improvTwist:
        'TWIST AT 15s: Guard your imaginary cargo pocket and snap "Get your own tots!"',
    durationSeconds: 30,
    difficultyTier: 3,
  ),
  ScenePrompt(
    id: 'cult_19',
    category: SceneCategory.specialtyCultClassics,
    title: 'Lobby Concierge Perfume Defense',
    filmOrSeries: 'Alpine Pink Hotel (2014 Parody)',
    releaseYear: 2014,
    characterName: 'Monsieur Gustave & Zero',
    promptScript:
        'Keep your hands off my lobby boy, you uncultured troopers! There are still faint glimmers of civilization left in this Alpine slaughterhouse, and I never check out of a suite without my bottle of L\'Air de Panache!',
    duetLeadA:
        'Keep your hands off my lobby boy—I never depart a suite without my bottle of L\'Air de Panache!',
    duetLeadB:
        'Monsieur Gustave, the cable car is leaving in thirty seconds and the guards have the painting!',
    directorCue:
        'Stand in symmetrical, Wes Anderson posture and deliver rapid, poetic aristocratic wit.',
    emotionalTarget: 'Dapper Symmetrical Wit & Gallantry',
    improvTwist:
        'TWIST AT 15s: Spritz imaginary cologne on both wrists before bolting.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'cult_20',
    category: SceneCategory.specialtyCultClassics,
    title: 'Hark Triton on the Lighthouse Rock',
    filmOrSeries: 'New England Foghorn (2019 Parody)',
    releaseYear: 2019,
    characterName: 'Thomas Wake & Winslow',
    promptScript:
        'Why\'d you spill your beans, lad—and don\'t tell me you weren\'t fond of me lobster! Let Neptune strike ye down with tempest waves if you touch that brass lantern in the top of my tower!',
    duetLeadA:
        'Don\'t tell me you weren\'t fond of me lobster—let Neptune strike ye down with tempest waves!',
    duetLeadB:
        'We\'ve been stranded on this rock for four weeks, old man, and I\'m going up those stairs to see the light!',
    directorCue:
        'Scowl under an imaginary sea-captain cap, roaring in 19th-century maritime cadence.',
    emotionalTarget: 'Tempestuous Maritime Madness',
    improvTwist:
        'TWIST AT 15s: Glare at an imaginary seagull and shout "Bad luck to shoo a gull!"',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
];

const List<ScenePrompt> kExpandedSpecialtyBlockbusterSciFiScenes = [
  ScenePrompt(
    id: 'scifi_11',
    category: SceneCategory.specialtyBlockbusterSciFi,
    title: 'Welcome to the Dinosaur Paddock',
    filmOrSeries: 'Amber Mosquito Island (1993 Parody)',
    releaseYear: 1993,
    characterName: 'Dr. Ian Malcolm & Dr. Grant',
    promptScript:
        'Your genetic engineers were so preoccupied with whether or not they could clone a sixty-ton reptile that they never stopped to ask if they should! Look at the water cup trembling on the dashboard—life finds a way!',
    duetLeadA:
        'Your scientists were so preoccupied with whether they could that they never stopped to ask if they should!',
    duetLeadB:
        'Nobody move a muscle—its vision is based on movement and the perimeter fence just lost power!',
    directorCue:
        'Adjust imaginary black-framed glasses and point at a vibrating water cup on the dashboard.',
    emotionalTarget: 'Chaos-Theory Wit & Sudden Awe',
    improvTwist:
        'TWIST AT 15s: Freeze completely still as a shadow passes over the lens.',
    durationSeconds: 35,
    difficultyTier: 3,
  ),
  ScenePrompt(
    id: 'scifi_12',
    category: SceneCategory.specialtyBlockbusterSciFi,
    title: 'Today We Cancel the Alien Apocalypse',
    filmOrSeries: 'Area 51 Hangar Speech (1996 Parody)',
    releaseYear: 1996,
    characterName: 'President Thomas Whitmore-Vane',
    promptScript:
        'In less than an hour, fighter squadrons from here will join pilots from across the globe in the largest aerial battle in the history of mankind! We will not go quietly into the night—today we celebrate our Independence Day!',
    duetLeadA:
        'We will not go quietly into the night—today we celebrate our Independence Day!',
    duetLeadB:
        'The virus upload is at ninety-eight percent, Mr. President—fire the main payload now!',
    directorCue:
        'Stand on an imaginary truck bed with an imaginary megaphone, building to a stadium-sized crescendo.',
    emotionalTarget: 'Rousing Blockbuster Heroism',
    improvTwist:
        'TWIST AT 15s: Salute the squadron and pull down an imaginary flight helmet visor.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'scifi_13',
    category: SceneCategory.specialtyBlockbusterSciFi,
    title: 'One Does Not Simply Walk Into the Volcano',
    filmOrSeries: 'Council of the Golden Ring (2001 Parody)',
    releaseYear: 2001,
    characterName: 'Boromir & Aragorn',
    promptScript:
        'One does not simply stroll past the black gates of the volcano after breakfast! Its obsidian towers are guarded by more than goblins—there is a lidless fiery eye up there that never blinks!',
    duetLeadA:
        'One does not simply stroll past the obsidian gates—there is a fiery eye up there that never blinks!',
    duetLeadB:
        'You have my sword, my bow, and my axe—we ride at dawn whether the eye blinks or not!',
    directorCue:
        'Touch your thumb and index finger together in the classic meme gesture with solemn fantasy gravitas.',
    emotionalTarget: 'Epic High-Fantasy Gravitas',
    improvTwist:
        'TWIST AT 15s: Draw an imaginary broadsword and pledge your allegiance.',
    durationSeconds: 35,
    difficultyTier: 3,
  ),
  ScenePrompt(
    id: 'scifi_14',
    category: SceneCategory.specialtyBlockbusterSciFi,
    title: 'Why Do We Fall, Master Bruce?',
    filmOrSeries: 'Wayne Manor Bat-Cave (2005 Parody)',
    releaseYear: 2005,
    characterName: 'Alfred & Bruce',
    promptScript:
        'You can armor the suit in kevlar and carbon fiber, Master Bruce, and prowl the rooftops until dawn, but some men aren\'t looking for anything logical like money—some men just want to watch the world burn.',
    duetLeadA:
        'Some men aren\'t looking for anything logical like money—some men just want to watch the world burn.',
    duetLeadB:
        'Then fire up the Bat-computer, Alfred—tonight we become more than a man, we become a symbol.',
    directorCue:
        'Speak in a warm, gravelly Cockney butler cadence with deep paternal concern.',
    emotionalTarget: 'Paternal Gravitas & Warning',
    improvTwist:
        'TWIST AT 15s: Set down an imaginary silver breakfast tray and bow your head.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'scifi_15',
    category: SceneCategory.specialtyBlockbusterSciFi,
    title: 'Spinning Top in the Dream Hotel',
    filmOrSeries: 'Subconscious Paradox (2010 Parody)',
    releaseYear: 2010,
    characterName: 'Cobb & Ariadne',
    promptScript:
        'We are three dream layers deep inside a zero-gravity hotel corridor, Ariadne, and the freight train just crashed through the lobby! Don\'t touch my spinning pewter totem—Wait for the kick on the music cue!',
    duetLeadA:
        'We are three dream layers deep in a zero-gravity corridor—wait for the kick on the music cue!',
    duetLeadB:
        'The projections know we\'re architects, Cobb—if we don\'t wake up before the bridge blows, we drop into Limbo!',
    directorCue:
        'Spin an imaginary top on the desk and stare at it as the room tilts.',
    emotionalTarget: 'Mind-Bending Sci-Fi Urgency',
    improvTwist:
        'TWIST AT 15s: Lean sideways at a 45-degree angle as if gravity just flipped.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'scifi_16',
    category: SceneCategory.specialtyBlockbusterSciFi,
    title: 'Do Not Go Gentle Into the Wormhole',
    filmOrSeries: 'Gargantua Event Horizon (2014 Parody)',
    releaseYear: 2014,
    characterName: 'Cooper & TARS',
    promptScript:
        'One hour on this tidal ocean planet costs us seven years back on Earth, Brand, and my daughter is already my age on the video relay! It\'s not possible to dock with a spinning station at sixty RPM—no, it\'s necessary!',
    duetLeadA:
        'It\'s not possible to dock with a spinning station at sixty RPM—no, it\'s necessary!',
    duetLeadB:
        'Cooper, the airlock clamps are sheared—if you match the station\'s spin manually, you\'ll black out!',
    directorCue:
        'Grip the flight stick with white-knuckle intensity while tears well in your eyes.',
    emotionalTarget: 'Relativistic Heartbreak & Heroism',
    improvTwist:
        'TWIST AT 15s: Tap an imaginary bookshelf from behind to send a message across time.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'scifi_17',
    category: SceneCategory.specialtyBlockbusterSciFi,
    title: 'Witness Me on the Chrome War Rig!',
    filmOrSeries: 'Fury Desert Citadel (2015 Parody)',
    releaseYear: 2015,
    characterName: 'Imperator Furiosa & Nux',
    promptScript:
        'We are not turning this sixteen-wheel tanker back into the dust storm for the Citadel warlord! Open the twin superchargers, haul on the steering wheel, and witness me on the Fury Highway!',
    duetLeadA:
        'Open the twin superchargers, haul on the wheel, and witness me on the Fury Highway!',
    duetLeadB:
        'The guitar player on the bungee rig is still shredding flames behind us—hard right into the canyon!',
    directorCue:
        'Roar over imaginary V8 engines with wild-eyed, high-octane desert intensity.',
    emotionalTarget: 'High-Octane Apocalyptic Ferocity',
    improvTwist:
        'TWIST AT 15s: Point two fingers at your eyes and shout "Witness!"',
    durationSeconds: 30,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'scifi_18',
    category: SceneCategory.specialtyBlockbusterSciFi,
    title: 'Heptapod Ink Circle on the Glass',
    filmOrSeries: 'First Contact Lexicon (2016 Parody)',
    releaseYear: 2016,
    characterName: 'Dr. Louise Banks-Vane',
    promptScript:
        'If you fire on that obsidian shell hovering above the Montana valley, General, you will never understand why they gave us their language! Time is not a straight line—their circular ink sentences mean I already remember the future.',
    duetLeadA:
        'Time is not a straight line, General—their circular sentences mean I already remember the future.',
    duetLeadB:
        'Twelve nations just cut their comms feed, Doctor—you have three minutes to translate "Use Weapon"!',
    directorCue:
        'Place your palm flat against an imaginary glass barrier, eyes luminous with wonder.',
    emotionalTarget: 'Transcendent Linguistic Wonder',
    improvTwist:
        'TWIST AT 15s: Trace a slow circle in the air in front of the camera.',
    durationSeconds: 35,
    difficultyTier: 4,
  ),
  ScenePrompt(
    id: 'scifi_19',
    category: SceneCategory.specialtyBlockbusterSciFi,
    title: 'Baseline Interrogation in the Orange Dust',
    filmOrSeries: 'Replicant Baseline 2049 (2017 Parody)',
    releaseYear: 2017,
    characterName: 'Officer K & Joshi',
    promptScript:
        'Cells interlinked within cells interlinked within one stem! You told me this wooden horse memory was just an implant from the archive, Lieutenant—then why did I find it carved under the furnace in the ruins?!',
    duetLeadA:
        'You told me this memory was an implant—then why did I find the wooden horse carved under the furnace?!',
    duetLeadB:
        'Recite your baseline and bury the case file, K—the world is built on a wall that separates kind.',
    directorCue:
        'Begin in a flat, robotic baseline recitation before letting human anguish crack your composure.',
    emotionalTarget: 'Stoic Android Awakening to Soul',
    improvTwist:
        'TWIST AT 15s: Snap "Interlinked!" three times before your voice breaks.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
  ScenePrompt(
    id: 'scifi_20',
    category: SceneCategory.specialtyBlockbusterSciFi,
    title: 'Fear Is the Mind-Killer in the Sandstorm',
    filmOrSeries: 'Spice Harvester Prophecy (2024 Parody)',
    releaseYear: 2024,
    characterName: 'Paul Muad\'Dib & Chani',
    promptScript:
        'Silence in the council chamber! I have walked the golden path through the spice storm where the Reverend Mothers dare not look—plant the thumper in the dune and lead them to paradise!',
    duetLeadA:
        'I have walked the golden path where the Reverend Mothers dare not look—plant the thumper in the dune!',
    duetLeadB:
        'You swore you wouldn\'t use the southern prophecy on our people, Usul—stay who you were in the desert!',
    directorCue:
        'Project with dual-layered "Voice" resonance, eyes wide as if glowing spice-blue.',
    emotionalTarget: 'Messianic Desert Command',
    improvTwist:
        'TWIST AT 15s: Whisper "Fear is the mind-killer" before raising an imaginary crysknife.',
    durationSeconds: 35,
    difficultyTier: 5,
  ),
];

/// Complete 180-Scene General Catalog partitioned by `SceneCategory` (20 scenes per category: 10 original + 10 expanded).
final Map<SceneCategory, List<ScenePrompt>> kParodyGeneralScenesByCategory = {
  SceneCategory.era1970To1999: <ScenePrompt>[
    ...kEra1970To1999Scenes,
    ...kExpandedEra1970To1999Scenes,
  ],
  SceneCategory.era2000To2026: <ScenePrompt>[
    ...kEra2000To2026Scenes,
    ...kExpandedEra2000To2026Scenes,
  ],
  SceneCategory.awardsBestActor: <ScenePrompt>[
    ...kAwardsBestActorScenes,
    ...kExpandedAwardsBestActorScenes,
  ],
  SceneCategory.awardsBestActress: <ScenePrompt>[
    ...kAwardsBestActressScenes,
    ...kExpandedAwardsBestActressScenes,
  ],
  SceneCategory.awardsBestSupportingActor: <ScenePrompt>[
    ...kAwardsBestSupportingActorScenes,
    ...kExpandedAwardsBestSupportingActorScenes,
  ],
  SceneCategory.awardsBestVillain: <ScenePrompt>[
    ...kAwardsBestVillainScenes,
    ...kExpandedAwardsBestVillainScenes,
  ],
  SceneCategory.awardsEmmyVault: <ScenePrompt>[
    ...kAwardsEmmyVaultScenes,
    ...kExpandedAwardsEmmyVaultScenes,
  ],
  SceneCategory.specialtyCultClassics: <ScenePrompt>[
    ...kSpecialtyCultClassicsScenes,
    ...kExpandedSpecialtyCultClassicsScenes,
  ],
  SceneCategory.specialtyBlockbusterSciFi: <ScenePrompt>[
    ...kSpecialtyBlockbusterSciFiScenes,
    ...kExpandedSpecialtyBlockbusterSciFiScenes,
  ],
};

/// Combined list of all 250 original parody scenes (180 general + 70 18+ After-Hours).
final List<ScenePrompt> kAll100ParodyScenes = <ScenePrompt>[
  ...kEra1970To1999Scenes,
  ...kExpandedEra1970To1999Scenes,
  ...kEra2000To2026Scenes,
  ...kExpandedEra2000To2026Scenes,
  ...kAwardsBestActorScenes,
  ...kExpandedAwardsBestActorScenes,
  ...kAwardsBestActressScenes,
  ...kExpandedAwardsBestActressScenes,
  ...kAwardsBestSupportingActorScenes,
  ...kExpandedAwardsBestSupportingActorScenes,
  ...kAwardsBestVillainScenes,
  ...kExpandedAwardsBestVillainScenes,
  ...kAwardsEmmyVaultScenes,
  ...kExpandedAwardsEmmyVaultScenes,
  ...kSpecialtyCultClassicsScenes,
  ...kExpandedSpecialtyCultClassicsScenes,
  ...kSpecialtyBlockbusterSciFiScenes,
  ...kExpandedSpecialtyBlockbusterSciFiScenes,
  ...kLateNightAfterHoursScenes,
];

/// Dynamic runtime list of custom scenes generated in The Writer's Room (Fixture #13).
final List<ScenePrompt> kWritersRoomCustomScenes = <ScenePrompt>[];

/// Dynamic elastic count of all general scenes (180 base + custom Writer's Room scenes).
int get totalGeneralSceneCount {
  int baseCount = 0;
  for (final list in kParodyGeneralScenesByCategory.values) {
    baseCount += list.length;
  }
  return baseCount + kWritersRoomCustomScenes.length;
}

/// Dynamic elastic count of all catalog scenes (180 general + 70 18+ + custom scenes).
int get totalCatalogSceneCount =>
    kAll100ParodyScenes.length + kWritersRoomCustomScenes.length;

typedef OriginalParodySceneEntry = ScenePrompt;

/// Selects a non-repeating scene of equal genre, difficulty tier, and acting
/// delivery method for Players 2 through 8 in a live multiplayer match so
/// subsequent players NEVER have to perform the exact same scene as Player 1.
/// If [isSupportingActor] is true, selects from the iconic Supporting Actor
/// vault or adapts the scene into a historical Supporting Actor counter-cue.
ScenePrompt selectEqualGenreUnplayedScene({
  required ScenePrompt referenceScene,
  required Set<String> usedSceneIds,
  bool isSupportingActor = false,
  int playerTurnIndex = 1,
}) {
  final Set<String> blockedIds = <String>{
    ...usedSceneIds,
    referenceScene.id,
  };

  List<ScenePrompt> candidatePool;
  if (referenceScene.is18Plus) {
    final targetTier = getSpiceTierForSceneId(referenceScene.id);
    candidatePool = kLateNightAfterHoursScenes
        .where((s) =>
            !blockedIds.contains(s.id) &&
            getSpiceTierForSceneId(s.id) == targetTier)
        .toList();
    if (candidatePool.isEmpty) {
      candidatePool = kLateNightAfterHoursScenes
          .where((s) => !blockedIds.contains(s.id))
          .toList();
    }
  } else if (isSupportingActor) {
    final supportingList = kParodyGeneralScenesByCategory[
            SceneCategory.awardsBestSupportingActor] ??
        kAwardsBestSupportingActorScenes;
    candidatePool =
        supportingList.where((s) => !blockedIds.contains(s.id)).toList();
    if (candidatePool.isEmpty) {
      candidatePool = supportingList;
    }
  } else {
    final categoryList =
        kParodyGeneralScenesByCategory[referenceScene.category] ??
            kEra1970To1999Scenes;
    // Match closest difficulty tier and acting delivery style within the same genre
    candidatePool = categoryList
        .where((s) =>
            !blockedIds.contains(s.id) &&
            (s.difficultyTier - referenceScene.difficultyTier).abs() <= 1)
        .toList();
    if (candidatePool.isEmpty) {
      candidatePool =
          categoryList.where((s) => !blockedIds.contains(s.id)).toList();
    }
    if (candidatePool.isEmpty) {
      candidatePool = kAll100ParodyScenes
          .where((s) => !s.is18Plus && !blockedIds.contains(s.id))
          .toList();
    }
  }

  final ScenePrompt picked = candidatePool.isEmpty
      ? referenceScene
      : candidatePool[playerTurnIndex % candidatePool.length];

  if (isSupportingActor) {
    return adaptSceneForSupportingActor(picked, playerTurnIndex: playerTurnIndex);
  }
  return picked;
}

/// Adapts a scene into an authentic Supporting Actor / Supporting Actress
/// audition cue with historical parody spin and supporting counter-dialogue.
ScenePrompt adaptSceneForSupportingActor(
  ScenePrompt base, {
  int playerTurnIndex = 1,
}) {
  final String supportingScript = base.duetLeadB.trim().isNotEmpty
      ? '${base.duetLeadB} And let the record show: without the supporting anchor in this room, your lead monologue wouldn\'t survive the first cut!'
      : base.promptScript;
  return ScenePrompt(
    id: '${base.id}_supp_turn$playerTurnIndex',
    category: base.category,
    title: '${base.title} [SUPPORTING STEAL]',
    filmOrSeries: '${base.filmOrSeries} · Supporting Counter-Cue',
    releaseYear: base.releaseYear,
    characterName: '${base.characterName} (Supporting Anchor)',
    promptScript: supportingScript,
    duetLeadA: base.duetLeadA,
    duetLeadB: supportingScript,
    directorCue:
        'SUPPORTING ACTOR CALL: Deliver the historical counter-line with scene-stealing reaction beats. ${base.directorCue}',
    emotionalTarget: 'Supporting Scene-Stealer · ${base.emotionalTarget}',
    improvTwist: base.improvTwist,
    is18Plus: base.is18Plus,
    durationSeconds: base.durationSeconds,
    difficultyTier: base.difficultyTier,
  );
}

/// Deterministic 24-Hour Global Challenge ("Cyborg-Director's Daily Cattle Call" — Fixture #3).
class DailyCattleCallChallenge {
  final String utcDateKey;
  final int sceneNumberOf90;
  final ScenePrompt featuredScene;
  final String mandatoryCurveball;
  final Duration timeRemainingUntilReset;

  const DailyCattleCallChallenge({
    required this.utcDateKey,
    this.sceneNumberOf90 = 1,
    required this.featuredScene,
    required this.mandatoryCurveball,
    required this.timeRemainingUntilReset,
  });

  ScenePrompt get scene => featuredScene;
  String get dailyCurveball => mandatoryCurveball;
  String get dateKeyUtc => utcDateKey;
}

const List<String> kDailyCattleCallCurveballs = <String>[
  'Deliver the final 10 seconds as if your microphone is wiretapped by the FBI!',
  'Halfway through, act like you just realized your co-star is your long-lost twin!',
  'Deliver the climax while struggling to hold back tears of sudden betrayal!',
  'Switch to a conspiratorial whisper at the 15-second mark as paparazzi flashbulbs pop!',
  'Act as if you just swallowed a truth serum that forces brutal honesty!',
  'Maintain an unblinking power stare into the camera lens for the final line!',
];

DailyCattleCallChallenge getTodaysDailyCattleCallChallenge([DateTime? now]) {
  final utc = (now ?? DateTime.now()).toUtc();
  final dateKey =
      '${utc.year.toString().padLeft(4, '0')}-${utc.month.toString().padLeft(2, '0')}-${utc.day.toString().padLeft(2, '0')}';
  int hash = 2166136261;
  for (final codeUnit in dateKey.codeUnits) {
    hash ^= codeUnit;
    hash = (hash * 16777619) & 0x7FFFFFFF;
  }
  final generalList = <ScenePrompt>[
    for (final list in kParodyGeneralScenesByCategory.values) ...list,
  ];
  final chosenIndex = hash % generalList.length;
  final chosenScene = generalList[chosenIndex];
  final chosenCurveball =
      kDailyCattleCallCurveballs[(hash ~/ 7) % kDailyCattleCallCurveballs.length];
  final nextReset = DateTime.utc(utc.year, utc.month, utc.day + 1);
  final remaining = nextReset.difference(utc);

  return DailyCattleCallChallenge(
    utcDateKey: dateKey,
    sceneNumberOf90: chosenIndex + 1,
    featuredScene: chosenScene,
    mandatoryCurveball: chosenCurveball,
    timeRemainingUntilReset:
        remaining.isNegative ? const Duration(hours: 24) : remaining,
  );
}

/// Fixture #13 — "The Writer's Room" AI Custom Scene Generator helper.
ScenePrompt buildFallbackWritersRoomScene({
  required String bizarreObject,
  required String occupation,
  required String emotionalState,
}) {
  final cleanObj = bizarreObject.trim().isEmpty
      ? 'a glowing flamingo lamp'
      : bizarreObject.trim();
  final cleanJob = occupation.trim().isEmpty
      ? 'Disgraced Health Inspector'
      : occupation.trim();
  final cleanEmotion = emotionalState.trim().isEmpty
      ? 'Operatic Paranoia'
      : emotionalState.trim();
  final ts = DateTime.now().millisecondsSinceEpoch % 100000;

  return ScenePrompt(
    id: 'writers_room_$ts',
    category: SceneCategory.specialtyCultClassics,
    title: 'The ${cleanObj.split(' ').last.toUpperCase()} Incident',
    filmOrSeries: 'The Writer\'s Room Original',
    releaseYear: 2026,
    characterName: cleanJob,
    promptScript:
        'Look at this $cleanObj sitting on my desk! Do you have any idea what a $cleanJob goes through when the entire city council tries to cover this up? I am not crazy—this $cleanObj is ticking, my badge is on the line, and if you take one step closer I am blowing the whistle on the whole department!',
    duetLeadA:
        'As a veteran $cleanJob, I demand to know why this $cleanObj was hidden inside my evidence locker!',
    duetLeadB:
        'Keep your voice down! If the Commissioner hears you talking about that $cleanObj, neither of us leaves this building employed!',
    directorCue:
        'Grip an imaginary $cleanObj toward the lens while channeling $cleanEmotion',
    emotionalTarget: cleanEmotion,
    improvTwist:
        '15s Curveball: Suddenly realize the $cleanObj is broadcasting your voice live on national television!',
  );
}

/// Fixture #15 (Part A) — 20 Uncensored 18+ Speakeasy "Double-or-Nothing Subtext Dares" (1.25x Spice Multiplier).
const List<String> kSpeakeasySubtextDares = kTwentyRaunchySpeakeasyWheelDares;

/// Fixture #15 (Part B) — "LIFE IS IMPROV" Real-World Secret Dare Settings & Dossiers.
enum LifeIsImprovSetting {
  housePartyBar('House Party / Bar', '🍻', 'Work the room or bartender with a straight face'),
  publicOutInWild('Public / Out in the Wild', '🏙️', 'Blend into a coffee shop, elevator, or street corner'),
  lateNightCouchPartner('Late-Night Couch / Partner Dare', '🛋️', 'Bluff your partner or roommate in real time'),
  phoneCallBluff('Phone Call Bluff', '📞', 'Put a friend on speakerphone and sell the scenario');

  final String label;
  final String emoji;
  final String subtitle;
  const LifeIsImprovSetting(this.label, this.emoji, this.subtitle);
}

class LifeIsImprovSecretDare {
  final String id;
  final LifeIsImprovSetting setting;
  final String dossierTitle;
  final String undercoverPersona;
  final String openingLineToSayOutLoud;
  final String midDareEscalation15s;
  final String targetReactionFromRoom;
  final int spiceTier;

  const LifeIsImprovSecretDare({
    required this.id,
    required this.setting,
    required this.dossierTitle,
    required this.undercoverPersona,
    required this.openingLineToSayOutLoud,
    required this.midDareEscalation15s,
    required this.targetReactionFromRoom,
    this.spiceTier = 3,
  });

  String get escalationAt15s => midDareEscalation15s;

  ScenePrompt toScenePrompt() {
    return ScenePrompt(
      id: id,
      category: SceneCategory.specialtyCultClassics,
      title: 'LIFE IS IMPROV: $dossierTitle',
      filmOrSeries: '18+ Speakeasy · ${setting.label}',
      releaseYear: 2026,
      characterName: undercoverPersona,
      promptScript: openingLineToSayOutLoud,
      duetLeadA: openingLineToSayOutLoud,
      duetLeadB: targetReactionFromRoom,
      directorCue: 'Undercover Persona: $undercoverPersona · Target: $targetReactionFromRoom',
      emotionalTarget: 'Deadpan Real-World Commitment (${setting.label})',
      improvTwist: '15s Escalation: $midDareEscalation15s',
    );
  }
}

const List<LifeIsImprovSecretDare> kLifeIsImprovSecretDares =
    kTwentyRaunchyLifeIsImprovDares;

