# DMV Simulator --- CODEX_README.md

**Purpose:** Operational handoff for Codex\
**Project:** DMV Simulator\
**Engine:** Godot 4.x\
**Current implementation goal:** Architecture proof before
vertical-slice expansion

------------------------------------------------------------------------

## 1. Start Here

This repository contains an existing Godot prototype plus canonical
design and visual/audio reference material for **DMV Simulator**, an
authored 2D Sierra / Quest-for-Glory-style adventure comedy.

Before making substantial changes:

1.  Inspect the existing repository and understand what already works.
2.  Read `reference/CANON.md`.
3.  Read this file completely.
4.  Inspect relevant reference material before implementing content that
    depends on it.
5.  Preserve compatible working code rather than rebuilding the project
    from scratch.

**Do not attempt to implement the full game during the first pass.**

The first pass is an architecture-validation pass.

------------------------------------------------------------------------

## 2. Source-of-Truth Hierarchy

When materials conflict, use this authority order:

1.  `reference/CANON.md`
2.  Explicit current implementation briefs / acceptance criteria
3.  Current architecture and choreography specifications
4.  Canonical individual visual references
5.  Current working implementation, where compatible with the above
6.  Minigame and environment reference images
7.  Older design notes / archaeology
8.  Experimental or explicitly noncanonical material

Do not silently reconcile contradictions by inventing new canon.

If a genuine conflict cannot be resolved from the repository, report it.

------------------------------------------------------------------------

## 3. What This Game Is

DMV Simulator is a **fully authored 2D adventure game**.

Its central design principle is:

> **The world forgets. The player remembers.**

NPC routines, events, puzzles, dialogue consequences, minigames, and
progression are authored and deterministic.

Player progression is primarily knowledge: learning routines, triggers,
relationships, puzzle solutions, timing, and shortcuts across repeated
loops.

The desired implementation philosophy is:

> **Authored content + a small number of reusable systems.**

------------------------------------------------------------------------

## 4. What This Game Is Not

Do not introduce:

-   an AI Game Master;
-   runtime LLM narration;
-   procedural quests;
-   procedural story adjudication;
-   dynamically invented dialogue consequences;
-   generalized NPC life simulation;
-   procedural NPC navigation;
-   new global stats;
-   generalized reputation systems;
-   runtime-generated canon.

Some older project archaeology may contain AI-GM concepts from a
separate experimental direction. Those concepts are **not part of this
Godot implementation**.

------------------------------------------------------------------------

## 5. Current Repository

The repository already contains a working/prototyped Godot project.

Relevant existing areas include:

``` text
project.godot

scenes/
    main.tscn
    player.gd
    regular_npc.gd
    regular_npc.tscn
    waiting_npc.tscn
    hemorrhoid_minigame.tscn

scripts/
    game_state.gd
    hemorrhoid_minigame.gd
    interactable.gd
    main.gd
    npc.gd
    ticket_system.gd
    waiting_event_manager.gd

reference/
    CANON.md
    audio/
    visual/
```

There may also be existing `art/`, `audio/`, `fonts/`, `minigames/`, and
addon directories.

**Inspect before modifying.**

Do not assume filenames imply that a system is correct, obsolete, or
complete. Determine what it currently does.

------------------------------------------------------------------------

## 6. Reference Material vs Runtime Assets

The `reference/` directory describes **what the game should become**.

It is not automatically runtime content.

In particular:

``` text
reference/visual/
```

contains character sheets, sprite construction references, portraits,
minigame mockups, and other design references.

Do **not** import an entire reference sheet into gameplay merely because
it contains sprites.

Runtime-ready assets should ultimately live in production asset
directories such as `art/` / `audio/` or a more organized runtime
structure established during implementation.

Likewise:

``` text
reference/audio/
```

contains source/reference audio. WAV files may be treated as approved
lossless music masters, but runtime integration should remain distinct
from source organization.

------------------------------------------------------------------------

## 7. Visual Authority

For character appearance, use this order:

1.  individual canonical character sheet;
2.  directional/movement sheet;
3.  encounter/minigame reference;
4.  environment or multi-character composite;
5.  experimental/noncanonical image.

**Individual character sheets always outrank composite images for
character identity.**

Do not redesign characters to make conflicting generated images agree.

The directory:

``` text
reference/visual/99_noncanonical/
```

is intentionally noncanonical.

Images there may communicate composition, palette, staging ideas, or
historical experimentation, but they must never override canonical
character or design references.

If an image contains duplicate or incorrectly rendered characters, do
not reproduce those errors.

------------------------------------------------------------------------

## 8. Audio Status

Music references are available or are being added under:

``` text
reference/audio/Music/
```

Sound effects are currently incomplete.

**Missing SFX are not a blocker.**

For this first pass:

-   do not generate replacement sound effects;
-   do not spend substantial implementation time on audio polish;
-   do not redesign mechanics around missing audio;
-   create sensible integration points only where naturally required.

Music integration may also remain partial during architecture work.

------------------------------------------------------------------------

# FIRST CODEX PASS

## 9. Objective

The first pass should answer one question:

> **Can the existing prototype support a deterministic, authored NPC
> routine that can be interrupted, enter temporary state, produce an
> authored consequence, save/load correctly, and reset cleanly with the
> loop?**

Use **Insurance Guy** as the proof case.

Do not scale the solution across the full cast until this case works.

------------------------------------------------------------------------

## 10. Step One --- Repository Archaeology

Before implementing Insurance Guy, inspect the existing project.

Determine:

-   current main-scene structure;
-   player movement and interaction architecture;
-   existing NPC base behavior;
-   how `waiting_npc.tscn`, `npc.gd`, and `regular_npc.*` are currently
    used;
-   current `GameState`;
-   current ticket system;
-   current waiting/event manager;
-   current minigame integration;
-   existing loop/reset behavior, if any;
-   current save/load support, if any;
-   autoloads and important project settings;
-   whether useful existing abstractions can support the new
    architecture.

Run the project before making major changes if the environment permits.

Record significant pre-existing errors separately from errors introduced
by the pass.

------------------------------------------------------------------------

## 11. Preserve Before Replacing

Do not perform a broad rewrite merely because a cleaner architecture can
be imagined.

Prefer the smallest coherent extension of the existing project.

Refactor only when the current implementation materially prevents the
required behavior.

Do not build speculative abstractions for future NPCs before Insurance
Guy demonstrates that they are necessary.

------------------------------------------------------------------------

## 12. Deterministic Routine Requirement

Insurance Guy should have a small authored routine that is:

-   deterministic;
-   clock/state driven;
-   inspectable;
-   repeatable after loop reset;
-   stable enough that the player could learn it.

The exact choreography may be provisional during this architecture
proof.

A suitable routine might contain authored stages such as:

-   pacing while on hold;
-   stopping at a consistent location;
-   reacting to the call;
-   resuming or altering the route.

Do not add random wandering.

Do not introduce generalized pathfinding unless an existing project
requirement genuinely demands it.

------------------------------------------------------------------------

## 13. Interruption Requirement

The player or an authored event must be able to interrupt Insurance
Guy's default routine.

The architecture should distinguish:

**Default Routine → Authored Interruption → Resume/Consequence**

An active ordinary interruption should not recursively accept arbitrary
additional interruptions.

Default conceptual behavior:

``` text
interruptible_while_active = false
```

A higher-priority authored event may override this when explicitly
designed to do so.

Do not build a generalized priority AI framework beyond what is needed
to prove this behavior.

------------------------------------------------------------------------

## 14. Temporary State Requirement

The interruption must be capable of producing loop-local temporary
state.

Examples could include:

-   altered disposition;
-   changed current routine stage;
-   a temporary conversation/event flag;
-   a changed next destination;
-   a pending authored consequence.

The exact comic content is less important in Pass 1 than proving that
the state is explicit, inspectable, and deterministic.

Do not invent persistent character lore merely to demonstrate the
system.

------------------------------------------------------------------------

## 15. Authored Consequence Requirement

The interruption should have at least one later observable consequence.

The consequence must arise from explicit state rather than from random
behavior or simulation.

Conceptually:

``` text
player interrupts Insurance Guy
        ↓
temporary state changes
        ↓
routine continues differently
        ↓
later authored consequence occurs
```

The player should be able to understand that their earlier intervention
affected what happened.

------------------------------------------------------------------------

## 16. Save / Load Requirement

Saving during the Insurance Guy sequence and loading that save should
restore a coherent state.

Do not reconstruct his state only from global clock time if doing so
loses meaningful interruption/routine progress.

At minimum, preserve whatever information is necessary to restore:

-   current routine state;
-   meaningful routine progress;
-   active or resolved interruption state;
-   relevant temporary flags;
-   loop time;
-   position where necessary for coherent restoration.

Exact implementation details should follow Godot conventions and the
existing project architecture.

------------------------------------------------------------------------

## 17. Loop Reset Requirement

A loop reset must restore Insurance Guy to his canonical opening-loop
state.

Loop-local interruption state and consequences must reset.

Persistent player knowledge, once that system is relevant, should not be
accidentally erased by a generic state wipe.

For this architecture proof, do not overbuild the complete final
persistent-progression system if it does not yet exist. Establish clean
boundaries so it can be added safely.

------------------------------------------------------------------------

## 18. First-Pass Acceptance Test

The architecture proof is successful when the following can be
demonstrated:

1.  Start a fresh loop.
2.  Insurance Guy begins in a predictable authored state.
3.  His routine proceeds deterministically.
4.  Trigger the designated interruption.
5.  Insurance Guy enters an explicit temporary altered state.
6.  A later authored consequence occurs because of that state.
7.  Restart/fresh-loop behavior reproduces the original baseline.
8.  Trigger the interruption again.
9.  Save during a meaningful post-interruption state.
10. Change the world state or continue playing.
11. Load the save.
12. Insurance Guy returns to the correct saved
    position/routine/interruption state.
13. Trigger a loop reset.
14. Insurance Guy returns to canonical opening state with loop-local
    state cleared.
15. No major regression is introduced into player movement, interaction,
    tickets, existing NPC behavior, or the existing Hemorrhoid
    Prevention minigame.

If automated tests are practical, add focused tests for state
transitions.

If editor/runtime validation is available, also perform an actual
play/runtime validation.

------------------------------------------------------------------------

## 19. Architecture Quality Bar

The solution should make it reasonably easy to author additional NPC
routines later without requiring a new bespoke engine for each NPC.

However, **do not prematurely generalize**.

A good result is a small, understandable architecture that proves:

-   routine state is explicit;
-   interruption state is explicit;
-   event consequences are explicit;
-   save serialization is explicit;
-   loop reset boundaries are explicit.

Favor readable authored data/state over clever simulation.

------------------------------------------------------------------------

## 20. Do Not Build Yet

Unless required to repair a regression or prove the architecture, do
**not** use Pass 1 to implement:

-   the complete lobby choreography;
-   every NPC;
-   Couples Therapy;
-   Dance-Off;
-   Shark Attack;
-   Faerie Ring;
-   UnderDMV;
-   party combat;
-   Espionage;
-   License Test;
-   full inventory redesign;
-   full Journal UI;
-   final audio implementation;
-   missing SFX;
-   final art pipeline;
-   broad UI polish;
-   a complete save-menu frontend;
-   speculative future systems.

References for these features exist so the architecture can avoid
obviously incompatible decisions---not because they are current
implementation tasks.

------------------------------------------------------------------------

## 21. Do Not Invent Canon

If implementation raises a narrative/design question that is not
answered by `CANON.md` or a current brief:

**do not silently answer it.**

Use a neutral/provisional implementation where possible or report the
question.

Especially do not establish:

-   why the loop exists;
-   who the Mastermind really is;
-   what UnderDMV metaphysically is;
-   hidden loop awareness for an NPC;
-   a universal connection between unrelated events;
-   new permanent progression systems.

------------------------------------------------------------------------

## 22. Existing Visuals During Pass 1

Insurance Guy has dedicated visual reference material.

Use it to understand intended character identity and eventual sprite
presentation.

If no implementation-ready extracted sprite exists yet, do not spend the
architecture pass performing a large manual art-production workflow.

A clearly labeled temporary runtime representation is acceptable when
necessary to prove behavior.

Reference sheets are design authority, not automatically sprite sheets.

------------------------------------------------------------------------

## 23. Stop Conditions

Stop and report rather than improvising if:

-   `CANON.md` conflicts materially with the requested acceptance test;
-   the existing project architecture contains a major constraint that
    makes the planned approach unsafe;
-   a required change would entail a broad rewrite;
-   save/load cannot be implemented coherently without a larger
    architectural decision;
-   the repository does not run before changes and the cause cannot be
    safely isolated;
-   implementation would require inventing canonical story content;
-   an apparent asset conflict cannot be resolved using the authority
    hierarchy.

A useful stop is better than an unauthorized redesign.

------------------------------------------------------------------------

## 24. End-of-Pass Report

When the first pass is complete, provide a concise implementation report
containing:

### Repository findings

What architecture existed before the pass and what was preserved.

### Changes made

Files added/modified and the purpose of each significant change.

### Insurance Guy proof

How the default routine, interruption, temporary state, consequence,
save/load, and loop reset now work.

### Validation

What was actually run/tested and the results.

### Known limitations

Anything provisional, incomplete, or intentionally deferred.

### Design questions

Only unresolved questions that genuinely require human input.

### Recommended next step

What should be implemented next **without implementing it yet**.

------------------------------------------------------------------------

## 25. Definition of Success

Pass 1 is **not** successful because a lot of code was written.

It is successful if the repository emerges with a small, understandable,
tested foundation demonstrating that DMV Simulator's central
authored-loop structure can work.

The desired result is:

> One boring man on a phone follows a predictable routine, the player
> can disrupt it, the world remembers that disruption for the rest of
> the loop, save/load remembers exactly where things were, and the next
> loop forgets.

If that works cleanly, the architecture is ready to begin supporting the
rest of the DMV.
