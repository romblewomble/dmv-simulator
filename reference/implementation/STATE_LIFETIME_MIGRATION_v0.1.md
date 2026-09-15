# DMV Simulator --- State Lifetime Migration Brief v0.1

**Status:** Implementation specification\
**Purpose:** Second bounded Codex architecture pass\
**Prerequisite:** Insurance Guy architecture proof accepted\
**Authority:** Subordinate to `reference/CANON.md` and the current
vertical-slice implementation brief\
**Scope:** State ownership/lifetime migration only

## 1. Objective

Refactor the existing prototype's state model so current and future
state has an explicit lifetime consistent with:

> **The world forgets. The player remembers.**

This is primarily a classification and migration pass, not a content
pass. Audit the legacy `GameState`, classify every meaningful field and
dependency, perform the smallest safe migration, preserve compatible
behavior/saves where reasonable, and make save/reset semantics legible
before more vertical-slice content is added.

## 2. Do Not Build Content

Do not implement or substantially expand Hemorrhoid Prevention lobby
integration, additional NPC routines, Couples Therapy, Dance-Off, Shark
Attack, vending-machine content, bathroom progression, Journal UI, reset
presentation, or new narrative events. Do not use this migration as an
excuse for a broad rewrite.

## 3. Required State Archaeology

Before changing structures, inspect every current `GameState` field and
meaningful read/write site. Classify each as:

-   **PersistentState** --- survives loop reset because it represents
    player-retained progression.
-   **LoopState** --- belongs to the current DMV loop and resets to
    canonical baseline.
-   **Event/Runtime-Local** --- temporary interaction, minigame, UI, or
    runtime state; only explicit results become durable.
-   **Session/Coordination** --- technical state coordinating the
    running game, not canonical progression itself.
-   **Deprecated/Legacy** --- superseded prototype state outside current
    canon.
-   **Unresolved** --- lifetime cannot safely be determined from code
    plus canonical documents.

Do not classify something as persistent merely because the old save
system preserved it.

## 4. Canonical PersistentState

The architecture must support stable persistent categories including:

**Knowledge:** e.g. `KNOWS_DETECTIVE_BASICS`, `KNOWS_PROPHET_RIDDLE`,
`KNOWS_TURNING_TECHNIQUE`, `knows_silent_treatment`,
`cryptography_mastery`, `dan_and_sarah_backstory`,
`mastermind_confronted`.

**Certifications/unlocks:** e.g. `certified_runner_up`,
`certified_good_samaritan`, `certified_animal_diplomat`,
`certified_autopilot_operator`, `steady_under_pressure`,
`rockstar_ally_unlocked`, `shark_ally_unlocked`.

**Persistent item exceptions:** the Prized Snack is canonical. Do not
make all inventory persistent to support it.

Do not implement every future ID now and do not invent persistence for
ambiguous legacy flags.

## 5. Canonical LoopState

LoopState should be capable of representing current-loop information
such as loop time, current ticket, temporary inventory, temporary flags,
NPC dispositions/relationships, event history/progress,
routine/interruption state, pending consequences, current-loop minigame
outcomes, and current location/phase where appropriate.

Insurance Guy's accepted implementation is the first proven example.

## 6. Event-Local State

Temporary encounter values should remain local where possible: active
meters, dialogue selection, transient UI, input locks, combat timing,
etc.

Prefer:

**event owns temporary state → event returns explicit result → durable
state layer applies result**

over arbitrary scripts mutating unrelated global dictionaries.

Do not redesign Hemorrhoid Prevention except for a minimal compatibility
change if required.

## 7. Legacy Stats

Current canonical stats are **Sanity, Charisma, Empathy, Physical
Condition, Honor**. Canon explicitly excludes global Bureaucracy,
Suspicion, and DMV Reputation systems.

For each legacy stat: locate all reads/writes; determine dependencies;
classify it as canonical, deprecated-but-required, or safely removable;
do not reinterpret it as another canonical stat; and do not delete it if
that would cause unrelated regressions. Prefer explicit
deprecation/compatibility handling over speculative remapping.

## 8. Inventory, Flags, Relationships, Minigame Records, World State

**Inventory:** ordinary items are loop-local by default; persistent
items are explicit exceptions.

**Flags:** audit by field/namespace. Stable IDs and explicit ownership
are preferred. Preserve/report ambiguous dependencies rather than
guessing.

**Relationships:** NPC disposition/relationship state ordinarily resets.
Persistent knowledge of how to rebuild a relationship is different from
the relationship itself.

**Minigame records:** distinguish temporary in-progress state,
current-loop result state, and persistent Knowledge/Certification earned
from the encounter. Do not assume previous-loop completion means the
world remembers completion.

**World state:** ordinary changes reset unless explicitly persistent.
World Scars are rare canon; do not classify ordinary legacy flags as
World Scars merely to preserve them.

## 9. Save Schema

Serialized data should explicitly distinguish at least:

``` text
persistent_state
loop_state
```

Technical/session metadata may be separate. Exact Godot representation
is an implementation choice. Do not create competing sources of truth.

## 10. Backward Compatibility

Existing saves use an older schema. Preserve compatibility where
reasonably safe. A migration loader may detect old schema, apply
defaults, map clearly understood values, retain necessary compatibility
fields, and ignore safely obsolete fields.

Do not fabricate persistent progression from ambiguous old data. If
perfect compatibility would substantially complicate the new
architecture, report the tradeoff instead of building a permanent
compatibility maze.

## 11. Save/Load vs Loop Reset

**Save/load** restores PersistentState plus the current LoopState and
serialized scene-object state required for coherent continuation.
Insurance Guy restoration must continue to pass.

**Loop reset** preserves PersistentState, discards/resets LoopState,
clears current-loop NPC/event state, restores opening defaults, and
notifies runtime objects to return to baseline.

Insurance Guy must return to baseline. Existing persistent certification
behavior must survive. The architecture must be capable of representing
a persistent-item exception such as Prized Snack even if it is not yet
wired into gameplay.

## 12. Result Application Seam

Where practical, establish a small explicit way for authored encounters
to commit results. A result may include persistent Knowledge,
Certifications, persistent items, loop flags, loop inventory changes,
relationship changes, or stat changes.

This need not become a universal framework. Extend a compatible existing
result pattern rather than replacing it.

## 13. Debug / Inspection

Make the lifetime boundary easy to inspect during development. A
developer should be able to determine what PersistentState contains,
what LoopState contains, what reset clears, and what reset preserves.
Logs/debugger/tests are sufficient; do not build final player-facing UI.

## 14. Required Legacy-State Classification Report

At completion, report the **pre-migration legacy fields** with:

-   field/category;
-   observed purpose;
-   read/write dependencies;
-   assigned lifetime;
-   migration action;
-   compatibility note;
-   unresolved issue, if any.

This is required so old prototype assumptions do not silently become new
canon.

## 15. Acceptance Tests

The migration passes when all applicable checks succeed:

1.  Project launches.
2.  Player movement remains functional.
3.  Ticket issuance remains functional.
4.  Waiting clock remains functional.
5.  Existing NPC idle behavior remains functional.
6.  Insurance Guy baseline remains deterministic.
7.  Insurance Guy interruption still works.
8.  Insurance Guy consequence still fires once.
9.  Insurance Guy save/load restoration still works.
10. Insurance Guy resets to baseline on loop reset.
11. Persistent certification survives loop reset.
12. A representative LoopState flag does not survive reset.
13. A representative loop-local inventory item does not survive reset.
14. Architecture represents a persistent-item exception independently of
    ordinary inventory.
15. Persistent Knowledge survives reset.
16. NPC relationship/disposition state resets unless explicitly
    exempted.
17. Save/load restores both PersistentState and current LoopState.
18. Older save schema loads safely, or incompatibility is explicitly
    reported and justified.
19. No deprecated legacy stat is silently remapped into current canon.
20. Hemorrhoid Prevention still instantiates/runs at least as well as
    before.
21. No new content is implemented beyond minimal migration/test
    fixtures.
22. `git diff --check` or equivalent cleanliness validation passes.

Use isolated temporary saves rather than overwriting the user's normal
save.

## 16. Stop Conditions

Stop and report rather than guessing if a legacy field materially
affects gameplay but cannot be understood; dependencies imply
incompatible lifetimes; clean migration requires a broad rewrite;
backward compatibility materially conflicts with canon; a field requires
a new persistence design decision; migration would require future
content; or current canon and working code cannot be reconciled without
human choice.

## 17. Out of Scope

Do not remove every legacy artifact for cleanliness, rewrite `GameState`
from scratch unless necessary, create a generalized ECS/state framework,
implement final World Scars, build the Journal, build new minigames,
hook Hemorrhoid Prevention into the lobby, propagate Insurance Guy to
other NPCs, implement reset fades, polish art/audio, or proceed into the
vertical slice.

## 18. Completion Report

Report:

-   **Archaeology:** major legacy state categories and usage.
-   **Classification:** requested legacy-field lifetime mapping.
-   **Migration:** structures changed and why.
-   **Compatibility:** old saves and existing code.
-   **Reset behavior:** exactly what clears and persists.
-   **Validation:** tests/runtime checks performed.
-   **Deprecated state:** what remains temporarily and why.
-   **Unresolved questions:** only human design decisions.
-   **Recommended next step:** without implementing it.

Then **STOP**.

## 19. Definition of Done

This pass is complete when the repository has one understandable answer
to:

> **What belongs to this loop, and what belongs to the player across
> loops?**

It need not be the final state architecture for the entire game. It must
be clean enough that every new vertical-slice feature deliberately
chooses a lifetime rather than inheriting one accidentally.
