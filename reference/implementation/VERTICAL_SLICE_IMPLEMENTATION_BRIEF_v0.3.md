# DMV Simulator --- Vertical Slice Implementation Brief v0.3

**Status:** IMPLEMENTATION AUTHORITY\
**Target:** Godot 4.x, authored 2D game\
**Slice target:** approximately 30 minutes\
**Supersedes:** Vertical Slice Implementation Brief v0.2 where this
document differs\
**Read with:** `reference/CANON.md`, `reference/CODEX_README.md`,
`reference/implementation/INSURANCE_GUY_TEST.md`

> This brief defines what the first complete playable vertical slice
> must contain and how completion is judged. `CANON.md` remains
> authoritative for game truth. `CODEX_README.md` governs Codex
> workflow. `INSURANCE_GUY_TEST.md` is the required architecture proof
> before broad slice implementation.

------------------------------------------------------------------------

## 1. Purpose

Build a polished-enough, end-to-end slice that proves the core
experience of *DMV Simulator*:

**ordinary DMV waiting → authored interactions and minigames →
escalating absurdity → Shark crisis → environmental discovery →
hallucination threshold → loop reset → player retains meaningful
progress**

The slice is not a miniature implementation of the whole game. It should
prove the systems and tone needed to build the rest of it.

------------------------------------------------------------------------

## 2. Non-Negotiable Architecture

This is an authored 2D Sierra / Quest-for-Glory-style adventure.

Do not introduce:

-   runtime LLM/AI GM systems;
-   procedural story generation;
-   behavior-tree-driven autonomous NPC lives;
-   random wandering as the basis of choreography;
-   generalized crowd simulation;
-   procedural quests;
-   generalized pathfinding unless the existing project demonstrably
    requires it;
-   new global stats or reputation systems.

Core principle:

> **The world forgets. The player remembers.**

Implementation should favor explicit state, authored schedules, reusable
encounter mechanics, stable IDs, and deterministic consequences.

------------------------------------------------------------------------

## 3. Slice Boundary

The canonical primary chain is:

**Hemorrhoid Prevention → Couples Therapy → Dance-Off → Shark Attack →
Secret Bathroom Closet → Loop Trigger**

Arrival, ticket-taking, exploration, vending-machine interactions,
ordinary NPC conversations, waiting, fast-forward, and ambient DMV
activity surround that chain.

The slice ends after the loop resets and the game demonstrates that the
world has returned to baseline while designated persistent player
progress remains.

Do not continue into UnderDMV or Espionage in this slice.

------------------------------------------------------------------------

## 4. What the Slice Must Prove

The completed slice must demonstrate all of the following in actual
play:

-   fixed-camera 2D DMV exploration;
-   readable eight-direction player movement;
-   collision and interaction;
-   ticket-taking;
-   explicit game time;
-   WAIT / time advancement;
-   fast-forward;
-   deterministic NPC choreography;
-   authored event scheduling;
-   temporary NPC interruptions;
-   dialogue with authored topic/options;
-   reusable minigame interfaces;
-   inventory;
-   persistent Knowledge;
-   at least one Certification;
-   the persistent Prized Snack exception;
-   loop-local state;
-   persistent state;
-   environmental puzzle/clue progression;
-   bathroom/mirror interaction;
-   ordinary-DMV Shark encounter;
-   Sierra-style failure presentation;
-   save/load of current-loop state;
-   canonical loop reset;
-   correct persistence/reset asymmetry;
-   Journal presentation sufficient to expose meaningful
    Knowledge/Certifications;
-   coherent use of approved visual references;
-   audio integration seams, without requiring final SFX.

------------------------------------------------------------------------

## 5. Opening State

A fresh loop begins in the ordinary DMV.

The opening should be stable and learnable.

Core opening population:

-   Deborah at the counter;
-   Security Guard near the entrance;
-   Regular seated;
-   Crossword Lady seated;
-   Insurance Guy on the phone/pacing;
-   appropriate background staff/customers.

The protagonist enters and takes a ticket.

Dan and Sarah may enter shortly after the opening rather than being
present in the first frame.

The first approximately 90 seconds should be especially deterministic.

------------------------------------------------------------------------

## 6. Lobby Geography

The playable lobby must clearly support:

-   entrance/security zone;
-   waiting-chair zone;
-   service-counter/Deborah zone;
-   ticket machine;
-   vending machine;
-   bathroom entrance;
-   open player circulation;
-   space for Dance-Off staging;
-   space for Shark Attack staging.

Use the existing scene as the starting point. Improve it rather than
replacing it wholesale unless required.

Environment/composite visual references control camera, mood, scale, and
staging only when they do not conflict with individual character sheets.

------------------------------------------------------------------------

## 7. Player Movement

Required:

-   X/Y movement;
-   eight-direction presentation;
-   collision;
-   interaction action;
-   no continuous sprite rotation.

The protagonist's canonical individual and movement sheets are the
visual authority.

Movement must feel functional and readable before visual polish is
prioritized.

------------------------------------------------------------------------

## 8. Time

Time is a gameplay system, not just display text.

The slice must support:

-   normal passage of time while the player is free in the DMV;
-   explicit WAIT;
-   fast-forward;
-   authored events keyed to time and state;
-   pausing or controlling the clock during interactions/minigames where
    continued free-running time would break authored behavior.

Exact time scale may be tuned during implementation. Preserve existing
working timing where compatible rather than changing it merely to match
old prototype numbers.

Critical events must not become missable because the player happened to
be inside a dialogue/minigame.

------------------------------------------------------------------------

## 9. Event Scheduling

Use authored event definitions/registry behavior rather than scattered
one-off timer logic where practical.

An event should be able to express, as needed:

-   stable ID;
-   trigger time/window;
-   prerequisites;
-   exclusions;
-   one-time-per-loop status;
-   priority;
-   scene/handler;
-   state changes;
-   rewards;
-   follow-up state.

Useful conceptual priority order:

1.  Critical Story
2.  Mandatory Scheduled
3.  Conditional
4.  Chaotic/Comic
5.  Ambient

The slice does not require a giant generalized event framework. It
requires enough structure that authored events do not fight each other.

------------------------------------------------------------------------

## 10. NPC Routine Model

Use:

**Default Routine → Authored Event Override → Phase Modifier**

NPCs should have deterministic routines appropriate to their role.

Not every NPC needs equal complexity.

Examples:

-   Insurance Guy: pacing/routine architecture proof;
-   Crossword Lady: mostly seated micro-routine;
-   Deborah: counter-centered;
-   Security Guard: entrance/short patrol;
-   Rockstar: authored arrival/wander/sit/event behavior;
-   Shark: authored arrival and encounter choreography.

Do not implement procedural daily-life simulation.

------------------------------------------------------------------------

## 11. Interruption Model

An authored interaction/event may temporarily take control of an NPC.

Default:

``` text
interruptible_while_active = false
```

When an interruption ends, explicit state determines whether the NPC
resumes, branches, or waits for a later event.

Major authored events may override ordinary routines when explicitly
designed to do so.

Insurance Guy must prove this architecture before it is scaled.

------------------------------------------------------------------------

## 12. Insurance Guy Gate

Before broad slice implementation, complete and validate:

`reference/implementation/INSURANCE_GUY_TEST.md`

That proof must demonstrate:

-   deterministic routine;
-   interruption;
-   re-entry protection;
-   temporary loop-local state;
-   later authored consequence;
-   save/load restoration;
-   loop reset;
-   reproducibility.

After that test passes and is reported, the architecture may be applied
carefully to other slice NPCs.

------------------------------------------------------------------------

## 13. Game State

The implementation must maintain a clear distinction among state
lifetimes.

### PersistentState

Survives loop reset.

For the slice, support at minimum the concepts needed for:

-   Knowledge;
-   Certifications;
-   persistent item exceptions;
-   persistent unlocks required by implemented content.

### LoopState

Resets with the loop.

Includes, as applicable:

-   loop time;
-   current ticket;
-   temporary inventory;
-   temporary flags;
-   NPC relationship/disposition state;
-   event history;
-   routine/interruption state;
-   temporary consequences;
-   current slice progression.

### Event-Local State

Temporary state belonging only to an active dialogue/minigame/event.

Discard or commit it explicitly when the event ends.

### World/Session Coordination

Track current loop/phase/location/time and event scheduling cleanly
enough that systems do not independently invent competing truth.

Do not overbuild future UnderDMV/Espionage state.

------------------------------------------------------------------------

## 14. Controlled State Mutation

State-changing encounters should return or invoke explicit results
rather than allowing arbitrary unrelated scripts to mutate global state
invisibly.

A result may contain, where appropriate:

-   loop flags;
-   persistent Knowledge;
-   Certifications;
-   inventory changes;
-   stat changes;
-   relationship changes;
-   follow-up event eligibility.

The exact API may adapt to the existing repository.

The requirement is traceable, testable state change.

------------------------------------------------------------------------

## 15. Save vs Loop Reset

These are different operations.

### Save/Load

Restores the current loop coherently, including meaningful NPC
routine/interruption/event progress.

Do not rely solely on recomputing NPC state from clock time when player
intervention has altered the loop.

### Loop Reset

Restores authored world baseline while preserving designated
PersistentState.

A reset must not behave like loading an old snapshot.

The completed slice must visibly demonstrate this difference.

------------------------------------------------------------------------

## 16. Ticket System

The player must be able to take a ticket.

The ticket system should integrate with the opening DMV experience and
loop reset.

Do not use the slice to explain Ticket #142.

Any existing working ticket implementation should be preserved/adapted
where compatible.

------------------------------------------------------------------------

## 17. Dialogue

Dialogue is authored.

The slice should support Sierra-like conversational presentation with
character portrait/talking-head treatment where assets permit.

Dialogue must be able to support:

-   topic/options;
-   prerequisites;
-   disabled/hidden options where authored;
-   explicit state consequences;
-   Knowledge checks;
-   relationship/context changes;
-   encounter launch;
-   return to free movement.

Do not introduce a natural-language parser or runtime-generated
dialogue.

------------------------------------------------------------------------

## 18. Journal

The slice needs a simple Journal sufficient to communicate persistent
progression.

Distinguish:

### Knowledge / Facts

Things the player has learned.

### Certifications

Credentials or demonstrated competence.

Do not build the final encyclopedic Journal system.

The UI only needs to make persistence legible and testable.

------------------------------------------------------------------------

## 19. Inventory

Inventory must support:

-   ordinary loop-local items;
-   use of items in authored encounters;
-   the Prized Snack as an explicitly persistent exception.

The player should be able to understand what they currently possess.

Do not invent a metaphysical explanation for why the Prized Snack
persists.

------------------------------------------------------------------------

# VERTICAL-SLICE CONTENT

## 20. Hemorrhoid Prevention

The existing Hemorrhoid Prevention minigame should be preserved/adapted
rather than discarded if it remains compatible.

Its role is to demonstrate an early, mundane-but-absurd DMV activity and
reusable minigame integration.

Completion should produce an explicit result and may award a persistent
Certification according to the existing/canonical design.

It should return cleanly to lobby play.

Do not let later architecture work regress the existing minigame.

------------------------------------------------------------------------

## 21. Downtime Between Major Events

The player should have room to:

-   walk;
-   inspect;
-   talk;
-   use the vending machine;
-   check the Journal;
-   wait;
-   fast-forward;
-   observe NPC routines.

The slice should not feel like five minigames launched back-to-back from
a menu.

The lobby is the connective tissue.

------------------------------------------------------------------------

## 22. Dan and Sarah Arrival

Dan and Sarah enter after the opening baseline has had time to register.

Their argument begins as an apparent vehicle-registration disagreement.

Player interaction can lead into Couples Therapy.

Their approved individual character reference controls identity; later
composite images do not override it.

Canonical visual identity includes East Asian Dan and Sarah, with Dan
bearded.

------------------------------------------------------------------------

## 23. Couples Therapy

Mechanic family:

**Dialogue / Negotiation**

Core meters:

-   Openness;
-   Tension.

Moves include:

-   Active Listen;
-   Validate;
-   Reframe;
-   Boundary Set / Confrontation;
-   Silence.

The encounter must support more than one viable path.

The deeper conflict concerns Dan's fear of repeating his father's
failures and his desire to show up reliably for his family.

Sarah helps ground him in present behavior.

Successful resolution should be followed by bureaucracy reasserting
itself.

Relevant result state may include:

-   `dan_fatherhood_fear_resolved`
-   `dan_and_sarah_backstory`

Failure should be soft/retryable within the authored design.

Premature Closure is an important failure condition.

Three consecutive successful Silences may support the special route in
which Dan and Sarah resolve the issue themselves.

------------------------------------------------------------------------

## 24. Rockstar Arrival and Presence

Rockstar arrives through authored lobby choreography.

He:

-   takes a ticket;
-   wanders/sits relatively incognito;
-   should initially read as possibly famous rather than announced
    celebrity;
-   becomes involved in the Dance-Off.

His individual character sheet controls appearance.

Do not establish him as secretly loop-aware.

------------------------------------------------------------------------

## 25. Dance-Off

Mechanic family:

**Gauge Duel**

Requirements:

-   approximately four to five authored rounds;
-   timing-based player input;
-   readable success/performance feedback;
-   Rockstar ultimately wins;
-   player performance still matters;
-   strong performance may award `certified_runner_up`;
-   lobby remains visually/contextually present;
-   bystanders may react;
-   encounter returns cleanly to lobby state.

The Rockstar should move from composed observation toward engagement,
then return rapidly to composure after victory.

The encounter should establish mechanical grammar that can later rhyme
with Faerie Ring, but Faerie Ring itself is outside this slice.

------------------------------------------------------------------------

## 26. Vending Machine

The vending machine must function as both mundane prop and
puzzle/inventory source.

For the slice, it must support the Shark-related item path.

Canonical relevant contents include:

-   aerosolized Shark Repellent;
-   at least one useless/comic item.

The Prized Snack must also be obtainable through the authored slice flow
if it is not already present through an earlier implemented event.

If the player lacks money at the first relevant vending interaction, an
authored NPC may provide enough for one purchase.

Do not make the vending machine a generic shop system unless that is
already useful in the existing implementation.

------------------------------------------------------------------------

## 27. Prized Snack

The slice must demonstrate the Prized Snack's unusual persistence.

Requirements:

-   player can acquire it through the authored flow;
-   it appears in inventory;
-   it can be used in Shark de-escalation;
-   after loop reset, it remains if acquired;
-   ordinary loop-local inventory does not receive the same treatment.

This is one of the slice's clearest demonstrations of asymmetric
persistence.

Do not explain why.

------------------------------------------------------------------------

## 28. Shark Arrival

There is **one ordinary-DMV Shark encounter** in the vertical slice.

The Shark is a genuine DMV customer attempting to update its mailing
address.

It arrives/appears through authored choreography and escalates:

**Patient → Confused → Frustrated → Hangry → Furious / Shark Attack**

The absurdity is played straight.

Canonical visual form:

-   upright;
-   shark anatomy;
-   fins only;
-   no human hands/arms;
-   baseline no clothes;
-   capable of inexplicably manipulating paperwork with fins.

------------------------------------------------------------------------

## 29. Shark Interaction Paths

The ordinary-DMV Shark sequence should support meaningful branching
including:

### Fight

Proceed to Shark Attack normally.

### Shark Repellent

Proceed to Shark Attack with a substantial advantage when used correctly
at close range.

### Prized Snack

Create the de-escalation route.

The slice need not implement every future Shark relationship payoff, but
state should be compatible with later rewards such as:

-   `shark_ally_unlocked`
-   `certified_animal_diplomat`
-   Honor changes.

Do not force those future systems into the slice if doing so requires
speculative architecture.

------------------------------------------------------------------------

## 30. Shark Attack

Preferred implementation:

**real-time Quest-for-Glory-inspired combat/gauge encounter**

Potential combat values:

-   protagonist Health;
-   protagonist Stamina;
-   Shark Health and/or Aggression.

Core actions may include:

-   Attack;
-   Dodge;
-   Brace/Block;
-   Item.

The Shark should use authored readable tells.

Examples:

-   head back → bite/lunge;
-   fins spread → sweep;
-   body lean → charge;
-   recovery → attack opportunity.

Stamina should discourage pure button mashing.

The encounter should reward learned timing/pattern recognition.

------------------------------------------------------------------------

## 31. Shark Repellent Behavior

Repellent should:

-   require appropriate proximity/timing;
-   create meaningful recoil/advantage;
-   reduce Shark pressure/aggression or create longer openings;
-   make the fight substantially easier.

It should not simply skip the encounter like the Prized Snack route.

------------------------------------------------------------------------

## 32. Prized Snack De-escalation

When the player successfully uses the Prized Snack:

1.  Shark notices it;
2.  combat pressure stops;
3.  Shark eats it;
4.  combat UI disappears;
5.  Shark redirects attention toward paperwork;
6.  communication proceeds through behavior/gesture/bracketed subtitle;
7.  Deborah may clarify that additional forms are required.

The encounter should reveal that the Shark is a frustrated/hungry
customer, not a conventional monster.

This route may produce Animal Diplomat/ally-related state where
supported.

------------------------------------------------------------------------

## 33. Shark Defeat / Death Popup

If the protagonist is defeated:

1.  freeze action;
2.  display bespoke Sierra-style death popup;
3.  evoke classic Restore/Restart/Quit presentation;
4.  show **no functional load/restart buttons**;
5.  pause briefly;
6.  fade popup/scene;
7.  execute canonical loop reset.

The loop is the restore system.

At least one Shark-specific dry death message should exist.

------------------------------------------------------------------------

## 34. Post-Shark Lobby

After Shark resolution, the DMV should return toward deadpan normality.

NPC reactions may briefly acknowledge what happened, then routines
reassert themselves.

This tonal snap-back is important.

Do not transform the whole lobby into permanent chaos merely because a
Shark attack occurred.

------------------------------------------------------------------------

## 35. Bathroom / Vending Clue Chain

The latter slice should expose an authored environmental clue chain
involving the vending/bathroom area.

The player should be able to discover access to the **Secret Bathroom
Closet** through explicit clues/state rather than pixel hunting or
random chance.

The chain should reward exploration and observation.

Exact clue text/prop placement may be tuned to the existing lobby and
available assets.

------------------------------------------------------------------------

## 36. Bathroom and Mirror

The bathroom is interactable.

The mirror should support phase/state-dependent authored content.

For the slice, it must establish the bathroom as a place where the
game's reality can become less stable without turning the mirror into an
exposition device.

Mirror content may hint or unsettle.

It must not explain the loop.

------------------------------------------------------------------------

## 37. Secret Bathroom Closet

The Secret Bathroom Closet is the environmental-puzzle culmination of
the slice.

Access should require the authored clue/progression state.

Entering/discovering it moves the slice toward the
hallucination/loop-trigger sequence.

It is not a universal portal and should not explain later cosmology.

------------------------------------------------------------------------

## 38. Hallucination Threshold

The end of the slice should make a clear tonal transition from
increasingly absurd DMV behavior toward hallucination/surreal
instability.

The slice does not need to implement full UnderDMV.

Its job is to prove that the ordinary DMV can convincingly cross a
threshold into something stranger.

Use authored visual/choreographic changes rather than procedural
effects.

------------------------------------------------------------------------

## 39. Loop Trigger

The slice culminates in a deliberate authored loop trigger.

The exact immediate cause may use the established
bathroom/closet/hallucination sequence.

The result must be unmistakable:

-   current loop ends;
-   loop-local world state is discarded/reset;
-   designated PersistentState survives.

------------------------------------------------------------------------

## 40. Canonical Reset Presentation

Baseline:

**fade out → fade in → "WELCOME TO THE DMV. PLEASE TAKE A TICKET."**

The new loop should visually resemble the familiar opening.

This is where deterministic choreography earns its payoff: NPCs are back
where the player knows they "belong."

------------------------------------------------------------------------

## 41. Persistence Demonstration After Reset

After the slice resets, the player must be able to verify at least:

-   ordinary loop-local state is gone;
-   NPCs do not remember;
-   the lobby has returned to baseline;
-   persistent Knowledge/Certification earned during the slice remains;
-   the Prized Snack remains if acquired.

This verification is part of the slice, not merely an internal test.

------------------------------------------------------------------------

# PRESENTATION

## 42. Visual Direction

Use approved visual references under:

``` text
reference/visual/
```

Authority:

1.  individual character sheets;
2.  movement/directional sheets;
3.  minigame references;
4.  environment/composite references;
5.  noncanonical experiments.

Primary style target is Quest for Glory I VGA: readable small sprites,
fixed 3/4-ish top-down camera, colorful but muted, expressive portraits,
early-PC-adventure charm.

Do not treat generated reference-sheet borders, labels, or example
layouts as runtime assets.

------------------------------------------------------------------------

## 43. Character Asset Scope

Do not require identical animation coverage for every NPC.

Prioritize according to role:

-   protagonist: strongest movement coverage;
-   Insurance Guy: enough locomotion to prove routine architecture;
-   Deborah: counter/dialogue emphasis;
-   Crossword Lady: seated/micro-animation emphasis;
-   Rockstar: ordinary locomotion plus Dance-Off poses;
-   Shark: upright locomotion/interaction/combat;
-   other slice characters: only the authored poses/movement their slice
    role requires.

Avoid building a universal animation set merely for symmetry.

------------------------------------------------------------------------

## 44. Audio

Approved music WAV references may be integrated where practical.

Current music references include tracks for:

-   main menu;
-   lobby;
-   Couples Therapy;
-   Dance-Off;
-   Faerie Ring;
-   Shark Battle.

Faerie Ring is outside this slice and its track need not be used here.

SFX are incomplete.

Missing SFX do not block slice completion during architecture/content
implementation. Use clean audio hooks and defer final SFX polish.

Do not generate substitute audio without instruction.

------------------------------------------------------------------------

## 45. UI

The slice needs functional, coherent UI for:

-   interaction/dialogue;
-   time/ticket where applicable;
-   inventory;
-   Journal;
-   minigames;
-   Sierra death popup.

UI should evoke the game's classic-adventure identity without requiring
pixel-perfect reproduction of any commercial game.

Function and consistency outrank decorative polish in the implementation
pass.

------------------------------------------------------------------------

## 46. Debug Tools

Provide lightweight development visibility where useful.

Useful values/actions include:

-   current loop time;
-   current phase;
-   active/pending event;
-   key LoopState flags;
-   key PersistentState flags;
-   NPC routine state;
-   interruption state;
-   force time forward;
-   trigger/reset loop;
-   inspect inventory/Knowledge/Certifications.

Debug tooling must be separable from player-facing UI.

------------------------------------------------------------------------

# IMPLEMENTATION ORDER

## 47. Required Sequence

Codex should not attack the entire slice in parallel.

Recommended/required progression:

### Pass 1 --- Archaeology

Inspect and run existing repository. Identify current architecture and
regressions.

### Pass 2 --- Foundation Proof

Complete `INSURANCE_GUY_TEST.md`.

Validate and report.

### Pass 3 --- Core Slice Infrastructure

Only after the proof is accepted/authorized, establish the minimal
reusable time/event/state/dialogue/minigame seams required by the slice.

### Pass 4 --- Ordinary Lobby Content

Build opening choreography, conversations, waiting/fast-forward,
vending, Dan/Sarah and Rockstar staging.

### Pass 5 --- Encounter Chain

Integrate Hemorrhoid Prevention, Couples Therapy, Dance-Off, Shark
Attack.

### Pass 6 --- Environmental Endgame

Bathroom/mirror, clue chain, Secret Bathroom Closet, hallucination
threshold, loop trigger.

### Pass 7 --- Persistence/Reset Validation

Run complete slice across save/load and loop reset.

### Pass 8 --- Presentation/Polish

Visual/audio/UI cleanup only after the end-to-end slice works.

Codex should stop/report at explicitly requested checkpoints rather than
assuming permission to advance through every pass.

------------------------------------------------------------------------

# ACCEPTANCE TESTS

## 48. Core Runtime Acceptance

The slice must pass the following:

1.  Project launches without new blocking errors.
2.  Player can move in eight directions and collide appropriately.
3.  Player can interact with core lobby objects/NPCs.
4.  Player can take a ticket.
5.  Time advances predictably.
6.  WAIT works.
7.  Fast-forward works without breaking mandatory authored events.
8.  Entering dialogue/minigames does not cause critical events to be
    silently missed.
9.  Opening NPC choreography reproduces across fresh loops.
10. Insurance Guy architecture proof remains functional after full-slice
    integration.

------------------------------------------------------------------------

## 49. State Acceptance

11. LoopState and PersistentState are distinguishable in code and
    behavior.
12. A loop-local item/flag disappears on reset.
13. Persistent Knowledge survives reset.
14. A Certification survives reset.
15. Prized Snack survives reset.
16. NPC temporary/interruption state resets.
17. Save/load restores current-loop authored state rather than merely
    restarting/recomputing it.
18. Loading does not duplicate completed/pending event consequences.

------------------------------------------------------------------------

## 50. Content Acceptance

19. Hemorrhoid Prevention can be entered, completed, and exited cleanly.
20. Dan and Sarah can lead into Couples Therapy.
21. Couples Therapy has functional Openness/Tension logic and multiple
    meaningful choices.
22. Premature Closure can fail/soft-fail as authored.
23. Silence route is representable and three successful consecutive
    Silences can produce its authored payoff.
24. Rockstar arrives through authored choreography.
25. Dance-Off uses Gauge Duel grammar.
26. Rockstar ultimately wins while player performance still affects
    result/reward.
27. Shark appears as one authored ordinary-DMV encounter.
28. Shark visual/behavior logic does not require human hands/arms.
29. Shark Attack is playable as a real-time authored-tell encounter.
30. Shark Repellent creates a meaningful combat advantage.
31. Prized Snack can de-escalate the Shark.
32. Shark defeat produces Sierra-style death popup and automatic loop
    reset.
33. Post-Shark lobby can return toward deadpan routine.

------------------------------------------------------------------------

## 51. Environmental / End Acceptance

34. Vending machine supports required slice item interactions.
35. Bathroom is accessible/interactable.
36. Mirror can present authored state/phase-dependent content.
37. Player can discover the Secret Bathroom Closet through an authored
    clue chain.
38. End sequence reaches a clear hallucination/instability threshold.
39. Loop trigger executes.
40. Reset returns lobby/NPCs to recognizable canonical opening state.
41. Player can visibly verify retained persistent progress after reset.

------------------------------------------------------------------------

## 52. Regression Acceptance

42. Existing ticket functionality is not needlessly broken.
43. Existing Hemorrhoid Prevention implementation is preserved/adapted
    where compatible.
44. Player movement/interactions remain stable through encounter
    integrations.
45. No minigame leaves the player trapped in incorrect UI/input state.
46. No major event fires twice unless explicitly authored.
47. No mandatory event becomes permanently missable because another
    event was active.
48. Loop reset does not accidentally erase persistent progression.
49. Save/load does not accidentally convert loop-local state into
    persistent state.
50. Noncanonical visual composites do not override approved individual
    character identity.

------------------------------------------------------------------------

# DEFINITION OF DONE

## 53. Vertical Slice Completion Criteria

The vertical slice is complete when a tester can, without editor
intervention:

1.  start a fresh ordinary DMV loop;
2.  enter/take a ticket and explore;
3.  observe predictable NPC routines;
4.  wait or fast-forward without breaking the event sequence;
5.  interact with NPCs and environment;
6.  complete Hemorrhoid Prevention;
7.  encounter Dan and Sarah and play Couples Therapy;
8.  encounter Rockstar and play Dance-Off;
9.  obtain/use relevant vending/inventory items;
10. encounter the upright Shark;
11. resolve Shark Attack through at least the normal combat route and
    support the Repellent and Prized Snack branches;
12. experience correct failure/reset behavior if defeated;
13. continue after successful Shark resolution;
14. solve the bathroom/vending clue progression;
15. reach the Secret Bathroom Closet;
16. cross the hallucination threshold;
17. trigger the loop reset;
18. return to the recognizable opening DMV state;
19. verify that ordinary world/NPC state forgot the loop;
20. verify that designated player Knowledge/Certification and the Prized
    Snack persist;
21. save and load during the slice without corrupting authored NPC/event
    progress;
22. complete the above without a blocking error or manual state repair.

The slice should feel like one continuous small adventure, not a
disconnected systems demo.

------------------------------------------------------------------------

## 54. Technical Definition of Done

In addition to the playable criteria:

-   state ownership is understandable;
-   major events have stable IDs;
-   NPC routine/interruption behavior is explicit;
-   reusable minigame seams exist;
-   event/minigame results mutate state deliberately;
-   loop reset has a clear API/path;
-   save/load has a clear API/path;
-   persistent and loop-local data are not conflated;
-   temporary debug support exists where needed;
-   major new code is documented enough for a later Codex pass to
    inspect;
-   no runtime AI/procedural narrative dependency exists;
-   no unresolved design mystery has been accidentally canonized.

------------------------------------------------------------------------

## 55. Art/Audio Definition of Done

The slice does **not** require final production polish.

It does require:

-   coherent use of canonical character identity;
-   no knowingly incorrect composite-derived character redesigns;
-   readable gameplay-scale character representation;
-   functional minigame UI;
-   coherent lobby/environment presentation;
-   music integration where ready or clean hooks where deferred;
-   no blocking dependency on missing SFX.

Placeholder/runtime-derived assets are acceptable only when clearly
provisional and when the canonical reference remains unambiguous.

------------------------------------------------------------------------

## 56. Out of Scope for v0.3 Slice

Do not require completion of:

-   full hallucination phase;
-   Faerie Ring;
-   UnderDMV;
-   Threshold Guardian battle;
-   party system;
-   Cult questline;
-   False Prophet full arc;
-   Municipal Detective full arc;
-   Medical Emergency unless separately added to slice scope;
-   Espionage;
-   Golden Binder;
-   Undying Auditor;
-   License Test;
-   endgame/endings;
-   final Mastermind content;
-   complete cast choreography outside what the slice requires;
-   final SFX library;
-   final art replacement for every placeholder.

These systems should influence architecture only where `CANON.md`
explicitly requires compatibility.

------------------------------------------------------------------------

## 57. Stop / Report Rules

Codex must stop and report rather than silently expanding scope when:

-   implementation conflicts with `CANON.md`;
-   the existing repository requires a broad rewrite;
-   a requested system cannot be added safely without a larger
    architecture decision;
-   save/load or reset semantics are ambiguous;
-   required content would force invention of unresolved canon;
-   a canonical asset/reference conflict cannot be resolved through the
    authority hierarchy;
-   the project has a pre-existing blocking failure that cannot be
    isolated;
-   an implementation checkpoint explicitly says STOP AND REPORT.

A report should contain:

-   repository findings;
-   changes made;
-   files changed;
-   runtime/tests performed;
-   acceptance criteria passed/failed;
-   regressions;
-   provisional elements;
-   unresolved design questions;
-   recommended next implementation step.

------------------------------------------------------------------------

## 58. Final Standard

The vertical slice succeeds if it proves the game's central promise in
miniature:

The player enters an ordinary, learnable DMV. Waiting reveals routines.
Intervening changes this loop. Absurd encounters emerge from the same
bureaucratic space. Mechanics recur with authored consequences. The
situation becomes impossible. The loop ends. The DMV returns to normal.

But the player does not.

> **The world forgets. The player remembers.**
