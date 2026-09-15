# DMV Simulator --- INSURANCE_GUY_TEST.md

**Status:** Implementation test specification\
**Purpose:** First NPC architecture proof for Codex\
**Authority:** Subordinate to `reference/CANON.md` and the current Codex
implementation brief\
**Scope:** Insurance Guy only; ordinary DMV loop

------------------------------------------------------------------------

## 1. Why Insurance Guy Exists in Pass 1

Insurance Guy is the first proof that the DMV can support learnable,
authored NPC choreography without becoming a generalized NPC simulation.

The test should prove this complete lifecycle:

**Authored Routine → Player Interruption → Temporary Loop State →
Authored Consequence → Routine Continues → Save/Load Preserves It → Loop
Reset Erases It**

The goal is not to finish Insurance Guy's eventual full narrative arc.

The goal is to prove the architecture on one deliberately simple NPC
before applying it to Deborah, the Regular, Crossword Lady, Dan and
Sarah, Father and Daughter, Rockstar, Gary, Shark, or later characters.

------------------------------------------------------------------------

## 2. Character Function

Insurance Guy is already in the lobby when the player enters.

He is on the phone with an insurance company and spends much of the
opening DMV period pacing while trapped on hold.

He is useful architecturally because his behavior is:

-   visually obvious;
-   repetitive;
-   spatial;
-   easy for the player to learn;
-   easy to interrupt;
-   capable of resuming;
-   capable of changing later because of an earlier interruption.

His phone call should remain mundane. Do not invent secret plot
importance for him.

------------------------------------------------------------------------

## 3. Baseline Opening State

At the beginning of a fresh loop, Insurance Guy should always begin from
the same authored state.

Required baseline properties:

-   same starting area/position within reasonable implementation
    precision;
-   phone call active;
-   same initial routine state;
-   no interruption active;
-   no interruption-derived temporary flags;
-   no pending interruption consequence;
-   same deterministic route/order of routine stages.

This opening state is part of the stable, learnable DMV choreography.

Do not randomize his starting position, direction, route, or timing.

------------------------------------------------------------------------

## 4. Baseline Routine

Implement a short deterministic pacing routine appropriate to the
existing lobby geometry.

The exact coordinates should be chosen from the actual `main.tscn`, not
invented in this document.

Conceptually, the routine should resemble:

1.  **ON_HOLD_START**\
    Insurance Guy is already on the call and begins/continues waiting.

2.  **PACE_A**\
    Walk to authored pacing point A.

3.  **WAIT_A**\
    Stop briefly. Listen to phone. Optional small idle
    animation/dialogue bark.

4.  **PACE_B**\
    Walk to authored pacing point B.

5.  **WAIT_B**\
    Stop briefly. Listen/react.

6.  **PACE_RETURN**\
    Continue through the authored route.

7.  **LOOP**\
    Repeat according to explicit routine timing/state until an authored
    event changes the routine.

The implementation does not need these exact enum names.

What matters is that the routine is represented by explicit state rather
than random wandering.

------------------------------------------------------------------------

## 5. Timing

Insurance Guy's routine should be deterministic relative to the loop
and/or explicit routine progression.

The player should eventually be able to predict where he will be.

Minor animation timing does not need frame-perfect determinism if it has
no gameplay consequence.

Gameplay-relevant timing and route order must be stable.

------------------------------------------------------------------------

## 6. Player Interruption

Insurance Guy must support at least one ordinary player-triggered
interruption during his baseline routine.

For the architecture proof, a simple conversation/interact action is
sufficient.

When interrupted:

1.  suspend the current default routine coherently;
2.  record the routine state/progress necessary for later continuation;
3.  enter an explicit interruption state;
4.  execute the authored interaction;
5.  set at least one loop-local result/flag;
6.  exit the interruption;
7.  resume or branch into the explicitly authored post-interruption
    routine.

Do not allow the interruption to destroy or silently restart his routine
unless that is the explicit authored consequence.

------------------------------------------------------------------------

## 7. Re-Entrant Interruption Rule

Default behavior while an interruption controls Insurance Guy:

``` text
interruptible_while_active = false
```

Repeated ordinary interaction attempts during the active interruption
should not recursively start another copy of the interaction.

A future major authored event may take control only if that event
explicitly supports overriding the active interruption.

Do not build a large generic priority-AI system solely for this test.

------------------------------------------------------------------------

## 8. Temporary Loop State

The player interruption must produce explicit loop-local state.

The implementation should be able to answer questions such as:

-   Has the player interrupted Insurance Guy this loop?
-   Is an interruption currently active?
-   What routine state was suspended?
-   Has the post-interruption consequence occurred?
-   Is a consequence pending?
-   What routine should execute next?

Exact variable/class names are implementation decisions.

This state belongs to the current loop.

It must not become persistent player knowledge merely because it exists.

------------------------------------------------------------------------

## 9. Authored Consequence

At least one later observable behavior must differ because the player
interrupted Insurance Guy earlier.

Keep the proof deliberately small.

A valid consequence could be a changed later stop, bark, route segment,
phone reaction, or other obvious authored behavior.

Requirements:

-   it occurs because of explicit interruption state;
-   it is deterministic;
-   it is visible enough to verify in play;
-   it does not require new lore;
-   it does not require another major NPC;
-   it occurs during the same loop;
-   it resets on the next loop.

The consequence should prove causality, not narrative complexity.

------------------------------------------------------------------------

## 10. Return to Routine

After the interruption and its consequences, Insurance Guy should return
to an authored routine state.

"Return" does not necessarily mean pretending nothing happened.

The post-interruption routine may differ from baseline if explicit state
says it should.

The important distinction is:

**the authored routine owns ordinary behavior; the interruption
temporarily overrides it; state determines what follows.**

------------------------------------------------------------------------

## 11. Major Event Compatibility

The architecture should leave room for a later major lobby event---such
as Shark arrival---to take control of NPC choreography.

Pass 1 does not need to implement Shark arrival.

Do not hard-code Insurance Guy in a way that makes authored event
overrides impossible.

Likewise, do not build the entire future event system merely to prove
that this seam exists.

------------------------------------------------------------------------

## 12. Save / Load Test

Save/load must restore the current loop, not reconstruct a generic
version of it.

Create a testable state after Insurance Guy has been interrupted but
before all resulting behavior has completed.

Save there.

After loading, restore enough information for the scene to continue
coherently, including as applicable:

-   Insurance Guy position;
-   current routine state;
-   routine progress/destination;
-   interruption active/resolved state;
-   interruption-derived flags;
-   pending/completed consequence state;
-   loop clock;
-   any other state strictly necessary for coherent continuation.

A load must not cause Insurance Guy to:

-   teleport back to baseline without reason;
-   replay a completed interruption;
-   lose a pending consequence;
-   duplicate the consequence;
-   infer the wrong state solely from clock time.

------------------------------------------------------------------------

## 13. Loop Reset Test

A loop reset is different from loading a save.

On loop reset, Insurance Guy must return to the canonical fresh-loop
baseline:

-   baseline position;
-   baseline phone state;
-   baseline routine state;
-   no active interruption;
-   no interruption-derived loop flags;
-   no pending consequence;
-   no memory of the prior loop.

This demonstrates:

> **The world forgets. The player remembers.**

Do not accidentally wipe persistent player systems merely because
Insurance Guy's LoopState resets.

------------------------------------------------------------------------

## 14. Fresh-Loop Reproducibility

Run the opening more than once without interruption.

Insurance Guy should reproduce the same meaningful choreography.

Then interrupt him in the same way on separate loops.

The same authored result should occur.

This is a feature, not insufficient variation.

------------------------------------------------------------------------

## 15. Required Manual Acceptance Sequence

The test passes only when the following sequence can be demonstrated:

1.  Launch/start a fresh loop.
2.  Observe Insurance Guy begin from canonical baseline.
3.  Allow the routine to proceed without intervention.
4.  Confirm its route/order is deterministic.
5.  Restart/reset and confirm the baseline reproduces.
6.  Trigger the designated player interruption.
7.  Confirm Insurance Guy enters explicit interruption state.
8.  Attempt an ordinary re-interruption while active and confirm no
    duplicate/re-entrant interaction occurs.
9.  Complete the interruption.
10. Confirm explicit loop-local state records its result.
11. Observe the later authored consequence.
12. Confirm the routine then continues in the correct authored state.
13. Repeat from a fresh loop and verify reproducibility.
14. Interrupt again and save during a meaningful
    post-interruption/pending-consequence state.
15. Continue long enough to make the current world visibly different.
16. Load the save.
17. Confirm position, routine progress, interruption state, relevant
    flags, loop time, and consequence state restore coherently.
18. Confirm continuing from the loaded save produces the consequence
    exactly once.
19. Trigger a loop reset.
20. Confirm Insurance Guy returns to baseline with all Insurance-Guy
    loop-local interruption state cleared.
21. Confirm no major regression to player movement, interaction, ticket
    behavior, existing NPC behavior, or Hemorrhoid Prevention.

------------------------------------------------------------------------

## 16. Focused Automated Tests

If the existing project supports practical automated or scripted
testing, prefer focused tests for:

-   baseline state initialization;
-   deterministic routine transition order;
-   interruption lock/re-entry rejection;
-   interruption result state;
-   consequence eligibility;
-   consequence fires once;
-   serialization/deserialization of Insurance Guy loop state;
-   loop reset clearing loop-local Insurance Guy state.

Do not build a large test framework if one does not exist and doing so
would exceed the scope of Pass 1.

Manual runtime validation is still required where possible.

------------------------------------------------------------------------

## 17. Debug Visibility

During Pass 1, it is acceptable---and useful---to expose lightweight
debug information that makes the architecture inspectable.

Useful debug values include:

``` text
loop_time
insurance_routine_state
insurance_interruption_active
insurance_interrupted_this_loop
insurance_consequence_pending
insurance_consequence_completed
```

Debug UI/logging should be easy to remove or disable.

Do not turn temporary debugging into player-facing final UI.

------------------------------------------------------------------------

## 18. Art Requirement for This Test

Canonical Insurance Guy visual references exist under:

``` text
reference/visual/01_characters/
```

Use them as identity authority.

If those sheets are not already separated into implementation-ready
sprite files, do not let sprite extraction/art cleanup consume the
architecture pass.

A temporary runtime representation is acceptable if clearly treated as
temporary.

Do not redraw or redesign Insurance Guy from a composite lobby image.

------------------------------------------------------------------------

## 19. Audio Requirement for This Test

No SFX are required for acceptance.

Music integration is not required for acceptance.

Do not block the architecture proof on audio.

------------------------------------------------------------------------

## 20. Out of Scope

Do not use this test to implement:

-   the full Insurance Guy story;
-   generalized autonomous NPC simulation;
-   random wandering;
-   full-cast choreography;
-   Dan and Sarah;
-   Dance-Off;
-   Shark Attack;
-   the bathroom puzzle;
-   UnderDMV;
-   persistent Knowledge UI;
-   final save-menu presentation;
-   final art or audio polish.

Those come after the architecture proof.

------------------------------------------------------------------------

## 21. Stop and Report Conditions

Stop rather than broadening scope if:

-   the existing NPC architecture cannot support the test without a
    major rewrite;
-   save/load requires a project-wide state-model decision not already
    authorized;
-   the existing prototype fails before changes in a way that prevents
    meaningful validation;
-   implementing the consequence would require inventing character
    canon;
-   a required reference contradicts `CANON.md`;
-   the smallest viable solution would materially alter unrelated
    working systems.

Report the conflict, affected files/systems, and the smallest decision
needed from the user.

------------------------------------------------------------------------

## 22. Completion Report

At completion, report:

1.  what existing architecture was found;
2.  what was preserved;
3.  files added or modified;
4.  Insurance Guy's implemented routine states;
5.  interruption behavior;
6.  temporary state produced;
7.  authored consequence;
8.  save/load behavior;
9.  loop-reset behavior;
10. tests/runtime checks actually performed;
11. any known limitations;
12. any unresolved design questions.

Then **stop**.

Do not automatically proceed to porting the remaining NPC cast.

------------------------------------------------------------------------

## 23. Definition of Done

Insurance Guy is done for Pass 1 when:

-   his opening routine is deterministic and learnable;
-   the player can interrupt it;
-   ordinary re-entrant interruption is prevented;
-   interruption produces explicit loop-local state;
-   that state causes a later deterministic authored consequence;
-   his routine continues coherently afterward;
-   save/load restores the exact-enough current-loop state;
-   loop reset restores canonical baseline;
-   repeated loops reproduce the same behavior;
-   existing core prototype functionality remains intact;
-   implementation is understandable enough to serve as the pattern for
    the next authored NPC;
-   Codex reports results and stops.

The architecture is successful when it proves the game's central state
philosophy with the smallest useful example:

> **The player changes this loop. The save remembers this loop. The next
> loop does not.**
