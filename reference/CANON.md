# DMV Simulator --- CANON.md

**Version:** 1.1\
**Status:** CANONICAL\
**Target:** 2D Godot implementation\
**Genre:** Authored Sierra / Quest-for-Glory-style adventure comedy\
**Updated:** September 15, 2026

> **Authority rule:** This document is the canonical authority for the
> 2D Godot version of *DMV Simulator*. When older design notes,
> archaeology, prototypes, AI-GM experiments, visual composites, or
> implementation artifacts conflict with this document, this document
> wins unless a later explicitly canonical document supersedes it.

------------------------------------------------------------------------

## 1. Game Identity

*DMV Simulator* is an authored 2D adventure-comedy designed to feel like
a lost early-1990s Sierra title.

The player goes to the DMV to obtain a driver's license. What begins as
an ordinary bureaucratic wait becomes increasingly strange, absurd,
surreal, mythological, and eventually espionage-inflected. No matter how
large the adventure becomes, the mundane objective remains stubbornly
relevant: the player still needs a driver's license.

Primary inspiration is **Quest for Glory I VGA**, with secondary
influence from *Space Quest*, *Space Quest V*, and some *Monkey Island*
sensibility.

The game is funny because the world commits seriously to ridiculous
circumstances. It should not behave as though it knows it is a joke.

------------------------------------------------------------------------

## 2. Implementation Boundary

This version is a **self-contained authored 2D Godot game**.

It does **not** contain:

-   an AI Game Master;
-   an LLM runtime narrator;
-   procedural story adjudication;
-   a natural-language parser;
-   dynamically generated missions;
-   procedural NPC navigation;
-   an architecture in which an AI invents canonical state, dialogue
    consequences, quests, or permanent mechanics at runtime.

Older AI-GM and text-simulator material is archival design context only.
It may inspire authored content but is not the runtime architecture.

------------------------------------------------------------------------

## 3. Governing Design Principle

**The world forgets. The player remembers.**

Each loop restores the ordinary world toward its authored baseline. The
player's advantage is accumulated understanding: routines, triggers,
relationships, dialogue knowledge, puzzle solutions, timing, shortcuts,
and mechanical mastery.

Progression is therefore primarily **knowledge \> power**.

The player should gradually understand the game better than the world
understands itself.

------------------------------------------------------------------------

## 4. The DMV Is the Constant

The DMV is the game's structural home.

Even when the story expands into hallucination, UnderDMV, fantasy,
espionage, and the License Test, the mundane DMV remains the conceptual
anchor.

The absurdity should grow around bureaucracy rather than replacing it.

------------------------------------------------------------------------

## 5. Mystery Boundary

The game must not completely explain:

-   why the time loop exists;
-   the ultimate significance of Ticket #142;
-   the true identity of the Mastermind;
-   the ontology of UnderDMV;
-   whether every supernatural event is literally supernatural;
-   a unified cosmology explaining all strange events.

Mystery is a feature, not missing exposition.

Not everything is secretly connected. Coincidences, false patterns,
mundane explanations, and unrelated absurdities must remain possible.

------------------------------------------------------------------------

## 6. Tonal Escalation

The broad tonal progression is:

**Mundane → Strange → Absurd → Surreal → Mythological → Espionage →
Existential**

Escalation should be gradual enough that each new layer feels surprising
but retrospectively plausible.

The DMV's deadpan bureaucratic tone persists even as the surrounding
genre changes.

------------------------------------------------------------------------

## 7. Major Phase Order

The canonical macro-structure is:

1.  **Ordinary DMV**
2.  **Increasing Absurdity**
3.  **Hallucination**
4.  **UnderDMV**
5.  **Espionage**
6.  **License Test / Endgame**

These phases may contain optional branches, but this is the governing
progression.

------------------------------------------------------------------------

## 8. Waiting Is Real Gameplay

Waiting at the DMV is always legitimate.

The player may simply wait. The game should not punish them for treating
a waiting room like a waiting room.

However, the environment should continually offer optional interactions,
conversations, observations, minigames, interruptions, and emerging
opportunities.

Time is therefore both atmosphere and authored game structure.

------------------------------------------------------------------------

## 9. Authored Event Model

Core events are authored and deterministic.

Important events should occur because of explicit:

-   clock thresholds;
-   state conditions;
-   prior interactions;
-   inventory conditions;
-   knowledge;
-   relationship state;
-   phase state.

For the core experience, major events are generally guaranteed and
one-time-per-loop unless explicitly designed otherwise.

The game should not rely on random event selection to create its main
narrative.

------------------------------------------------------------------------

## 10. NPC Choreography

NPC behavior follows a **Deathloop-like clockwork philosophy**:
predictable authored routines that the player can learn and exploit.

The implementation model is:

**Default Routine → Authored Event Override → Phase Modifier**

NPC placement and movement are authored. NPCs do not require generalized
pathfinding or procedural daily-life simulation.

Small ambient variations are acceptable when they do not interfere with
learnable timing, puzzle logic, or player planning.

------------------------------------------------------------------------

## 11. The Sacred Opening

The first approximately 90 seconds of a loop should be especially stable
and memorizable.

The player should quickly develop the feeling:

> I know how this place begins.

That confidence makes later deviations meaningful.

The opening lobby population includes, at minimum:

-   Deborah at the counter;
-   Security Guard near the entrance;
-   The Regular seated;
-   Crossword Lady seated;
-   Insurance Guy pacing/on the phone;
-   appropriate background staff/customers;
-   the protagonist entering and taking a ticket.

Dan and Sarah arrive shortly afterward rather than needing to be present
at the first frame.

------------------------------------------------------------------------

## 12. Stable Lobby Geography

The lobby should have stable, learnable geography:

-   entrance / Security Guard zone;
-   waiting-chair area;
-   service counters;
-   Deborah's station;
-   ticket machine;
-   vending machine;
-   bathroom entrance;
-   open circulation/player space.

Approximate staging may evolve during implementation, but geography
should support readable authored choreography.

------------------------------------------------------------------------

## 13. Increasingly Incorrect Choreography

Later phases should make the familiar lobby feel wrong primarily by
altering established routines.

Examples include:

-   The Regular sitting one chair away from his usual seat;
-   Insurance Guy following a slightly different route;
-   Crossword Lady standing when she is normally seated;
-   Security Guard watching the bathroom;
-   Deborah repeating the same number;
-   the ticket machine producing something impossible.

The principle is:

**Same lobby, increasingly incorrect choreography.**

------------------------------------------------------------------------

## 14. Interruption Architecture

Authored interruptions may temporarily take control of an NPC's routine.

The default rule is that an NPC already controlled by an interruption
does not accept an ordinary second interruption.

Conceptually:

`interruptible_while_active = false`

Re-entry occurs only when the active authored interruption explicitly
permits it or when a higher-priority authored event takes control.

Interruptions may produce loop-local altered state and later authored
consequences.

This is not a generalized social simulation.

------------------------------------------------------------------------

## 15. Insurance Guy as Architecture Proof

Insurance Guy is the first architectural unit test for the NPC routine
system.

Before scaling the routine/interruption architecture across the cast,
implementation should prove that Insurance Guy can support:

-   deterministic routine;
-   authored interruption;
-   temporary altered state;
-   downstream authored consequence;
-   correct save/load restoration;
-   correct loop reset.

Exact save/load should restore meaningful routine progress and temporary
state rather than merely estimating NPC state from the clock.

------------------------------------------------------------------------

## 16. State Layers

Game state is divided conceptually into:

### LoopState

Resets when the loop resets.

Examples:

-   current location;
-   current loop time;
-   temporary inventory;
-   NPC relationship state;
-   temporary flags;
-   event progress;
-   NPC dispositions;
-   temporary physical/emotional conditions.

### PersistentState

Survives loops.

Examples:

-   Knowledge;
-   Certifications;
-   explicitly persistent items;
-   demonstrated competence/accessibility unlocks.

### World Scars

Rare permanent changes to the setting itself.

World Scars should be exceptional and authored, not a general
consequence system.

### Above-Loop State

The driver's license occupies a special conceptual position: acquiring
it represents progression beyond the ordinary loop structure.

------------------------------------------------------------------------

## 17. Core Stats

The canonical core stats are:

-   **Sanity**
-   **Charisma**
-   **Empathy**
-   **Physical Condition**
-   **Honor**

Do not introduce global stats such as Bureaucracy, Suspicion, or DMV
Reputation without an explicit later canon decision.

------------------------------------------------------------------------

## 18. Sanity

Sanity is not simply a health meter.

Lower or altered Sanity may make strange content perceptible or
accessible.

The game may therefore sometimes reward the player for becoming less
conventionally grounded.

Sanity should not become a universal explanation for whether events are
"real."

------------------------------------------------------------------------

## 19. Relationships

NPC relationships use authored states.

Most relationship state resets with the loop unless explicitly
persistent.

What commonly persists is the player's **knowledge of how to build or
alter the relationship efficiently**.

This preserves the core rule: world forgets; player remembers.

------------------------------------------------------------------------

## 20. Knowledge

Knowledge is a major persistent progression system.

Known canonical or reserved Knowledge IDs include:

-   `KNOWS_DETECTIVE_BASICS`
-   `KNOWS_PROPHET_RIDDLE`
-   `KNOWS_TURNING_TECHNIQUE`
-   `cryptography_mastery`
-   `dan_and_sarah_backstory`
-   `mastermind_confronted`
-   `knows_silent_treatment` (implementation naming may be normalized,
    but the concept is canonical)

Stable IDs should be preferred in implementation.

------------------------------------------------------------------------

## 21. Certifications

Certifications represent demonstrated competence, credentials, or earned
recognition rather than ordinary factual knowledge.

Known canonical or reserved certifications include:

-   `certified_runner_up`
-   `certified_good_samaritan`
-   `certified_animal_diplomat`
-   `certified_autopilot_operator`
-   `steady_under_pressure`
-   `rockstar_ally_unlocked`
-   `shark_ally_unlocked`

The Journal should distinguish **facts learned** from
**credentials/certifications earned**.

------------------------------------------------------------------------

## 22. Reusable Minigame Families

The authored game should reuse a small vocabulary of mechanics rather
than inventing a bespoke technical framework for every encounter.

Five canonical families are:

1.  **Meter-Fill / Precision**
2.  **Gauge Duel**
3.  **Pattern / Logic**
4.  **Turn-Based Menu Battle**
5.  **Dialogue / Negotiation**

A specific encounter may meaningfully adapt a family, but implementation
should favor reuse.

------------------------------------------------------------------------

## 23. Accessibility

Reflex-heavy minigames must not permanently block progress.

Canonical accessibility concepts include:

-   **Steady Hands**
-   **Autopilot**

Accessibility may widen timing windows, reduce punishment, provide
automatic assistance, or otherwise preserve access to authored content.

`certified_autopilot_operator` may represent demonstrated/earned use
where appropriate.

------------------------------------------------------------------------

## 24. The Vending Machine

The vending machine is a recurring mechanical and comic motif.

It may contain useful, useless, inexplicable, or context-sensitive
items.

Its continued relevance should feel like a mundane machine acquiring
disproportionate importance through repeated loops.

------------------------------------------------------------------------

## 25. The Prized Snack

The **Prized Snack** is canonically persistent.

It survives loops without a fully explained metaphysical justification.

Do not solve or overexplain this contradiction.

Its major known payoff is Shark de-escalation.

------------------------------------------------------------------------

## 26. Rubber Chicken

The Rubber Chicken is loop-local unless later canon explicitly changes
this.

It has a special UnderDMV interaction involving **SMITE(CHICKEN)** and
may intersect with the Flaming Sword / Honor / Paladin path.

Its absurdity should be treated with full mechanical seriousness.

------------------------------------------------------------------------

## 27. Bathroom and Mirror

The bathroom is a recurring hub and threshold location.

The mirror may change based on phase and/or Sanity.

Mirror content may hint, foreshadow, mislead, or expose unusual
information, but the mirror must not become a universal exposition
machine explaining the game's mysteries.

------------------------------------------------------------------------

## 28. The Shark --- Identity

The Shark is a real recurring character within the game's authored
reality.

The Shark is genuinely at the DMV attempting to update its mailing
address.

Its bureaucratic frustration is genuine.

It does not speak conventional human dialogue. Communication occurs
through:

-   physical behavior;
-   gestures;
-   actions;
-   bracketed subtitles where useful.

The Shark is not merely a hallucination punchline or symbolic monster.

------------------------------------------------------------------------

## 29. The Shark --- Canonical Visual Form

The Shark's canonical baseline visual form is an **upright,
humanoid-postured shark**.

It stands and moves inexplicably upright while retaining shark anatomy.

It has **fins only**.

It never has human hands or arms.

The Shark may nevertheless manipulate DMV forms, objects, or other
necessary items with its fins. The game must not explain how this works.

Baseline Shark has no clothing.

A later disguised Shark may use an absurdly flimsy human disguise in the
espionage portion, but the disguise is not the baseline character
design.

------------------------------------------------------------------------

## 30. The Shark --- DMV Arc

The Shark's initial emotional progression is approximately:

**Patient → Confused → Frustrated → Hangry → Furious / Shark Attack**

The player may encounter branching approaches including:

-   fighting;
-   using Shark Repellent;
-   using the Prized Snack.

The Shark is not evil. The conflict emerges from bureaucracy,
frustration, and hunger.

------------------------------------------------------------------------

## 31. Shark Repellent

Aerosolized Shark Repellent may be obtained through the vending-machine
chain.

It is effective only at close range / appropriate timing and outside
water.

It should provide a significant advantage rather than simply functioning
as an instant "win" button.

If the player lacks money on the first relevant vending-machine visit,
an authored NPC interaction may provide enough for one purchase.

The vending machine should also contain at least one useless or comic
option.

------------------------------------------------------------------------

## 32. Prized Snack / Animal Diplomat Route

Using the Prized Snack can de-escalate Shark Attack.

The Shark notices the snack, eats it, calms, and redirects attention
toward its paperwork problem.

This may lead into an Animal Diplomat sequence and can award:

-   `shark_ally_unlocked`
-   `certified_animal_diplomat`
-   Honor

The non-hangry Shark may indicate its forms while Deborah clarifies what
additional paperwork is required.

------------------------------------------------------------------------

## 33. Shark Attack --- Combat Form

The preferred Shark Attack implementation is a **real-time
Quest-for-Glory-inspired gauge/combat duel** in the DMV lobby.

The encounter may include:

-   protagonist Health;
-   protagonist Stamina;
-   Shark Health and/or Aggression;
-   Attack;
-   Dodge;
-   Brace/Block;
-   Item.

The Shark uses authored readable tells, such as:

-   head movement before bite/lunge;
-   fins spreading before sweep;
-   body lean before charge;
-   recovery windows that create attack opportunities.

Stamina should discourage button mashing.

Knowledge of the Shark's patterns should matter across loops.

Shark Repellent and Prized Snack remain meaningful alternate solutions
inside this encounter.

------------------------------------------------------------------------

## 34. Failure and Death Presentation

Failure in dangerous encounters should use a classic Sierra / *Space
Quest* / *Quest for Glory*-style death presentation.

Canonical sequence:

1.  defeat freezes the action;
2.  a bespoke Sierra-style death popup appears;
3.  the popup may visually evoke the place where Restore/Restart/Quit
    options would normally appear;
4.  **there are no Load/Restore buttons**;
5.  after a brief pause, the popup and scene fade;
6.  the game transitions to the canonical loop reset.

The loop itself is the restore system.

Death messages should be bespoke, dry, and encounter-specific.

------------------------------------------------------------------------

## 35. Rockstar --- Identity

The Rockstar is a real person within the game's world.

He should be recognizable as potentially famous without being a direct
depiction of a real celebrity.

Visual inspiration combines:

-   elegant, angular, Pale-White-Duke-era rock-star energy;
-   Nikola-Tesla-in-*The Prestige*-style stillness and inscrutability.

He is age-ambiguous, elegant, slightly rumpled, unusually composed, and
comfortable being strange without advertising that he is strange.

Do not make him an overt parody or give him obvious rock-star costume
clichés.

His coincidences with later events remain unexplained.

------------------------------------------------------------------------

## 36. Rockstar --- DMV Arc

The Rockstar:

1.  enters the DMV;
2.  takes a ticket;
3.  wanders/sits relatively incognito;
4.  becomes involved in the Dance-Off;
5.  later encounters a title/VIN issue;
6.  may become an ally;
7.  may conditionally appear in relation to the Faerie Ring;
8.  may become an UnderDMV companion under appropriate authored
    conditions.

He is not secretly established as loop-aware.

------------------------------------------------------------------------

## 37. Dance-Off

The Dance-Off uses the **Gauge Duel** family.

It is an authored sequence of approximately four to five rounds.

The Rockstar ultimately wins.

Player performance still matters. Strong performance can produce
rewards, including:

-   `certified_runner_up`

The joke is not that player input is meaningless; the joke is that the
player can perform extraordinarily well and still discover that the
quiet stranger is absurdly better.

The lobby remains visible and bystanders may react.

The Rockstar's performance progression should move from composed
observation toward genuine engagement, then return quickly to composure
after victory.

------------------------------------------------------------------------

## 38. Faerie Ring

The Faerie Ring is a separate later **Gauge Duel** encounter.

It deliberately rhymes mechanically with the Dance-Off while
transforming the familiar timing grammar into a surreal context.

The protagonist is normally alone during the primary encounter.

The Rockstar is **not normally present**.

The interface may evolve from a conventional horizontal gauge toward
circular or stranger geometry.

The Faerie Ring encounter guarantees the transition into UnderDMV. It
should flow into that transition rather than ending with a conventional
results screen.

------------------------------------------------------------------------

## 39. Turning Technique

`KNOWS_TURNING_TECHNIQUE` is associated with mastery of the Faerie Ring
and later supports the License Test's 3-Point Turns domain.

Current canonical refinement:

-   exceptional Faerie Ring performance may allow the protagonist to
    discover the technique independently;
-   if `rockstar_ally_unlocked` is present and the player reaches an
    appropriate good-but-not-perfect performance threshold, the Rockstar
    may appear at the end to affirm, clarify, or teach the turning
    technique;
-   Rockstar ally status may therefore lower the effective mastery
    threshold;
-   main progression through the Faerie Ring is **never gated on
    Rockstar ally status**.

This supersedes earlier notes implying that the Rockstar is always
present or is the exclusive source of `KNOWS_TURNING_TECHNIQUE`.

------------------------------------------------------------------------

## 40. Dan and Sarah

Dan and Sarah are an arguing couple whose apparent DMV problem concerns
vehicle registration.

Their deeper conflict is personal.

Dan fears repeating his father's failures. His father forgot, failed to
show up, or otherwise modeled unreliability. Dan wants to show up for
his own family and fears that he will become his father.

Sarah helps ground the conflict in what Dan is actually doing rather
than what he fears becoming.

After meaningful emotional resolution, DMV bureaucracy should
immediately reassert itself.

------------------------------------------------------------------------

## 41. Couples Therapy Minigame

Couples Therapy uses the **Dialogue / Negotiation** family.

Core meters:

-   **Openness** --- generally ratchets upward as genuine progress is
    made;
-   **Tension** --- fluctuates and may rise or fall throughout the
    encounter.

Canonical moves include:

-   Active Listen;
-   Validate;
-   Reframe;
-   Boundary Set / Confrontation;
-   Silence.

Multiple success routes should exist.

Failure states are generally soft and retryable.

**Premature Closure** is an important failure mode: trying to declare
the problem solved before the deeper issue has actually surfaced.

Successful resolution may set:

-   `dan_fatherhood_fear_resolved`
-   `dan_and_sarah_backstory`

------------------------------------------------------------------------

## 42. Silence Route in Couples Therapy

Silence is a legitimate mechanical choice.

Three consecutive successful Silences may allow Dan and Sarah to resolve
the conflict themselves.

The joke is that the protagonist succeeds by finally ceasing to make the
situation worse.

This route should be mechanically real rather than merely an easter egg.

------------------------------------------------------------------------

## 43. Father and Daughter

The Father is a friendly, earnest, highly verbal suburban dad who
constantly attempts conversation.

His teenage Daughter is intelligent, dry, observant, and deliberately
says very little.

Their dynamic should not initially advertise itself as a puzzle.

The Daughter's silence is intentional, not magical.

------------------------------------------------------------------------

## 44. Learning the Silent Treatment

The player should learn the Silence concept explicitly from the Daughter
rather than magically inferring a mechanic.

The intended authored structure is:

1.  Father and Daughter are encountered together;
2.  Father dominates the conversational space;
3.  the player completes a specific objective or creates an opportunity
    that gets Father away;
4.  the player speaks privately with Daughter;
5.  the player asks about her silence;
6.  Daughter explains that she is giving Father the silent treatment;
7.  the player gains persistent knowledge such as
    `knows_silent_treatment`.

Later, Father continues trying to make conversation while Daughter
remains silent.

Eventually he capitulates on an apparently unrelated disagreement,
e.g. agreeing to talk to her mother about the car or allowing the
spring-break trip.

This gives the player an observable demonstration of silence as
leverage/patience rather than presenting it as arbitrary game logic.

The knowledge later has a practical consequence in **Clerksville**.

------------------------------------------------------------------------

## 45. The Regular

The Regular is an ambiguous recurring NPC.

He is not, by default:

-   a quest giver;
-   a prophet;
-   the Mastermind's informant;
-   a standard companion;
-   secretly confirmed as loop-aware.

He should look ordinary and comfortable in the DMV.

**The Regular should never look mysterious on purpose.**

His recurring presence and increasingly strange placement create
ambiguity through context rather than costume or ominous behavior.

His visible ticket is **not Ticket #142** unless a later canon decision
explicitly changes this.

------------------------------------------------------------------------

## 46. Crossword Lady

Crossword Lady is a sharp, self-contained older crossword enthusiast.

She is not a "sweet old lady" archetype and not a secret oracle.

Her crossword routine is highly stable and therefore useful as a
choreography indicator.

A typical idle loop includes reading, thinking, writing, erasing,
staring at a clue, and returning to the puzzle.

Because she is usually seated and absorbed, small
deviations---especially standing or reacting strongly---can signal that
the familiar DMV has become wrong.

------------------------------------------------------------------------

## 47. Gary / False Prophet

Gary begins as an aggressively ordinary, mildly frazzled suburban man.

He becomes the **False Prophet** because he begins finding patterns in
DMV events and eventually decides that he understands them.

His transformation should be made from mundane DMV materials rather than
magical costume changes.

Possible elements include:

-   jacket used as mantle;
-   accordion folder as scripture;
-   NOW SERVING ticket strip as headband;
-   queue belt as sash;
-   clipboard as tablet;
-   visitor sticker.

Gary may notice genuinely strange things. He may occasionally even be
correct.

The game must not visually or narratively confirm that his grand theory
is true.

**Gary does not look like a prophet until Gary decides he is one.**

Gary is distinct from the Order of Now Serving and is not automatically
its leader.

------------------------------------------------------------------------

## 48. Security Guard / Threshold Guardian

The Security Guard begins as a mundane, seasoned DMV security
professional.

He is calm, observant, practical, and not presented as an action hero.

His ordinary routine and access-control behavior establish traits that
are later reinterpreted in UnderDMV.

In UnderDMV he becomes **The Threshold Guardian**.

The title may be used explicitly; the tongue-in-cheek directness is
intentional.

The Threshold Guardian encounter should serve as a **tutorial battle for
party combat**.

It is fundamentally a test/access-control encounter rather than a
villainous confrontation.

After the player demonstrates sufficient competence, his attitude may
remain essentially mundane:

> "All right. You can go through."

The fantasy transformation should reinterpret the same character rather
than replacing his personality.

------------------------------------------------------------------------

## 49. Order of Now Serving

The Order of Now Serving is an occult/bureaucratic group that sincerely
believes its doctrine.

Members may accidentally be correct about some things.

They are not omniscient.

Access to some occult material may depend on Sanity.

The game should preserve uncertainty about which parts of their belief
system correspond to reality.

------------------------------------------------------------------------

## 50. False Prophet / Chosen One / Sword

The False Prophet / Chosen One material may intersect with a
Sword-from-the-Stone sequence and a possible Paladin / Flaming Sword
path.

Honor may be relevant.

The magnificence of a fantasy object should contrast with the continued
mundanity of the person interacting with it.

This content remains authored and should not imply that Gary's entire
cosmology is correct.

------------------------------------------------------------------------

## 51. Medical Emergency

The Medical Emergency should be tense and played comparatively straight.

It provides tonal contrast by briefly asking the player to respond to
something that matters without turning the event into a gag.

Successful handling may award:

-   `steady_under_pressure`

That certification can later help with the License Test's Fatigue
Resistance domain.

------------------------------------------------------------------------

## 52. TikTok Scrolling

TikTok Scrolling is an anti-event.

It should remain available as a way to waste time and may frequently
provide nothing useful.

Occasional suspicious details---including apparent references to
"142"---may occur, but such details need not be clues.

The game must preserve the possibility of meaningless coincidence.

------------------------------------------------------------------------

## 53. Municipal Detective

The Municipal Detective material uses an authored deduction framework.

The first major case, **Duplicate Ticket**, teaches detective basics and
can award:

-   `KNOWS_DETECTIVE_BASICS`

Not every mystery has a culprit.

Sometimes the correct solution is recognizing a pattern, process,
accident, or bureaucratic mechanism rather than identifying a villain.

------------------------------------------------------------------------

## 54. UnderDMV

UnderDMV is a genuine fantasy transformation of the game's experience,
not merely the ordinary lobby with fantasy labels pasted over it.

It may support party-based adventure/combat and a distinct sense of time
or traversal.

Its exact metaphysical relationship to the DMV remains unresolved.

Characters from the DMV may appear in transformed/reinterpreted roles
when explicitly authored.

Do not assume every lobby NPC must follow the player into UnderDMV.

------------------------------------------------------------------------

## 55. Undying Auditor

The Undying Auditor is an optional UnderDMV arc associated with Ticket
#142.

The Auditor seeks a verdict rather than simple revenge.

Resolution may create a rare **World Scar**.

The arc must not fully explain Ticket #142 or the loop.

------------------------------------------------------------------------

## 56. Golden Binder

The **Golden Binder** is the canonical bridge from UnderDMV into the
Espionage segment.

It supersedes older "Wrong Envelope" transition concepts where those
conflict.

The transition should proceed through the authored HOME OFFICE / Deborah
/ Golden Binder sequence and into the espionage travel structure.

There is no ordinary return to the normal lobby between UnderDMV and
Espionage.

------------------------------------------------------------------------

## 57. Espionage

The Espionage segment is authored rather than procedurally generated.

Known nodes include:

-   **La Baño**
-   **Vendingrad**
-   **Grand Chaise**
-   **Clerksville**
-   **Fort Lamination**
-   **Cubiclestan**
-   **Redacted Republic**

The structure may use a small static node-map and Journal overlay.

Earlier characters, items, certifications, and knowledge should pay off
through callbacks rather than through a universal reputation system.

Examples include Shark ally benefits in Vendingrad and Silent Treatment
knowledge in Clerksville.

------------------------------------------------------------------------

## 58. The Mastermind

The Mastermind may be confronted.

`mastermind_confronted` may record relevant persistent knowledge/state.

The Mastermind's true identity remains unresolved.

Do not canonize a hidden identity during implementation merely to close
the mystery.

------------------------------------------------------------------------

## 59. License Test

The License Test is the culmination of the absurd journey and returns
the game to its original mundane objective.

Canonical domains include:

### Fatigue Resistance

Uses Meter-Fill / Precision or an extended related mechanic.

`steady_under_pressure` may help.

### Road Rules

Uses Pattern / Logic.

`cryptography_mastery` may help.

### 3-Point Turns

Uses Gauge Duel.

`KNOWS_TURNING_TECHNIQUE` may help.

### Parallel Parking

Uses Turn-Based Battle grammar.

Cult / parallel-parking knowledge may help.

### Small Talk Composure

Uses Dialogue / Negotiation.

Prior social encounters may help.

Failure of **any License Test subtest** causes a full loop reset.

------------------------------------------------------------------------

## 60. Callback Taxonomy

Callbacks should be designed deliberately.

Canonical callback categories are:

-   **Explicit** --- directly references a prior event or learned fact;
-   **Cadence** --- repeats timing/rhythm/mechanical expectation;
-   **Structural** --- a later problem uses the logic of an earlier one;
-   **Visual** --- familiar imagery returns in a changed context;
-   **False** --- appears meaningful but is coincidence, noise, or
    misdirection.

Not every callback should become lore.

------------------------------------------------------------------------

## 61. Vertical Slice

The target first vertical slice is approximately **30 minutes**.

Its primary authored chain is:

**Hemorrhoid Prevention → Couples Therapy → Dance-Off → Shark Attack →
Secret Bathroom Closet → Loop Trigger**

The slice should demonstrate:

-   authored NPCs;
-   exploration;
-   game time;
-   deterministic events;
-   dialogue;
-   reusable minigame grammar;
-   inventory;
-   persistent Knowledge;
-   the Prized Snack;
-   state changes;
-   fast-forward / waiting support;
-   bathroom and mirror;
-   loop reset;
-   Sierra-style presentation.

The slice is not expected to implement the full game's later phases.

------------------------------------------------------------------------

## 62. Secret Bathroom Closet

The Secret Bathroom Closet is part of the vertical-slice progression and
is reached through an authored vending/bathroom clue chain.

Its purpose in the slice is to demonstrate environmental puzzle
progression and move the player toward the loop trigger.

It should not become a universal portal explaining every later phase.

------------------------------------------------------------------------

## 63. Canonical Loop Reset Presentation

The baseline loop reset presentation is intentionally simple:

**fade out → fade in → "WELCOME TO THE DMV. PLEASE TAKE A TICKET."**

Exact typography/capitalization may be tuned in presentation, but the
bureaucratic reset message and abrupt return to normality are canonical.

Dangerous-event death popups feed into this same reset rather than
presenting a conventional load-game menu.

------------------------------------------------------------------------

## 64. Save / Inventory / Journal

Save functionality should remain straightforward.

Inventory should clearly distinguish currently held items from
persistent exceptions.

The Journal should distinguish:

-   **Knowledge / learned facts**
-   **Certifications / demonstrated credentials**

Save/load must preserve enough authored NPC and event state to resume
coherently.

------------------------------------------------------------------------

## 65. Visual Direction

Primary visual reference:

**Quest for Glory I VGA**

Secondary references:

-   *Space Quest*
-   *Space Quest V*
-   selected *Monkey Island* sensibility

Desired presentation:

-   2D;
-   fixed camera;
-   approximately 3/4 top-down;
-   colorful but somewhat muted;
-   charming;
-   slightly low-budget in the positive early-PC-adventure sense;
-   expressive and readable;
-   humorous without becoming a modern cartoon;
-   **not true isometric**.

Dialogue should evoke classic Sierra talking-head/dialogue-box
presentation.

------------------------------------------------------------------------

## 66. Movement and Navigation

Player movement is:

-   X/Y;
-   eight-direction;
-   collision-based.

The player character does not rotate continuously.

No generalized pathfinding requirement exists.

NPC placement and movement should remain authored.

------------------------------------------------------------------------

## 67. Character Visual Authority

Individual approved character reference sheets are canonical for
character identity.

When visual references conflict, use this priority:

1.  **Individual canonical character sheets** --- identity, ethnicity,
    age, clothing, hair, body type, props, silhouette.
2.  **Directional/movement sheets** --- sprite orientation, movement
    construction, game-scale appearance.
3.  **Minigame sheets** --- encounter composition, UI language,
    encounter-specific poses.
4.  **Environment/style composites** --- room layout, camera, scale,
    environmental design, approximate staging.
5.  **Experimental/noncanonical images** --- inspiration only.

Composite images must never override individual character sheets.

Do not redesign a character merely to reconcile conflicting generated
images.

------------------------------------------------------------------------

## 68. Known Visual Canon

The following recently established visual decisions are canonical:

-   **Protagonist:** ordinary adult man; tousled dark-brown hair; green
    hoodie/jacket; light T-shirt; blue jeans; sneakers; approved
    individual sheet controls exact appearance.
-   **Dan and Sarah:** both East Asian; Dan has a beard; approved final
    pair sheet controls exact appearance.
-   **Shark:** upright, fin-only form described above.
-   **Security Guard:** seasoned late-middle-aged
    municipal/private-security look; later Threshold Guardian is
    recognizably the same person.
-   **Father and Daughter:** father is verbally animated and
    conventionally suburban; daughter is visually understated, dry, and
    minimally reactive.
-   **Crossword Lady:** older, glasses, crossword and pencil, stable
    seated silhouette.
-   **Rockstar:** elegant, angular, plausibly-famous-but-deniable; no
    direct real-person likeness.
-   **Regular:** ordinary older man whose design does not intentionally
    signal mystery.
-   **Gary:** ordinary checked-shirt-and-khakis figure before
    self-created False Prophet transformation.

Approved individual sheets outrank prose where minor rendering details
differ.

------------------------------------------------------------------------

## 69. Audio Direction and Asset Status

Music and sound should support the Sierra-era adventure identity without
requiring literal hardware emulation.

Approved music references may be stored as lossless WAV masters.

Current implementation may proceed while SFX are incomplete.

Missing SFX must **not** block architectural or vertical-slice
implementation. Do not generate substitute SFX or redesign mechanics
around their absence unless explicitly requested.

Runtime audio integration and compression may be handled separately from
source/reference masters.

------------------------------------------------------------------------

## 70. Content Status Vocabulary

Design material should use explicit status labels where useful:

-   **CANON**
-   **PROVISIONAL**
-   **OPEN**
-   **DEFERRED**
-   **CUT**
-   **ARCHIVAL**

Only CANON material should silently constrain implementation.

PROVISIONAL material may be used as a working direction but should not
override canon.

OPEN questions should remain open rather than being solved by
implementation convenience.

------------------------------------------------------------------------

## 71. Forbidden Spontaneous Canon

Implementation must not spontaneously establish:

-   the Mastermind's true identity;
-   the metaphysics of the loop;
-   the ontology of UnderDMV;
-   secret loop-awareness for NPCs;
-   a hidden explanation connecting every strange event;
-   new global stats;
-   procedural story systems;
-   generalized reputation systems;
-   permanent mechanics not authorized by design;
-   a universal explanation for Prized Snack persistence;
-   conventional human hands/arms for the Shark.

If implementation appears to require one of these, stop and surface the
design question rather than inventing an answer.

------------------------------------------------------------------------

## 72. Deprecated / Superseded Concepts

The following should not control current implementation when encountered
in older documents:

-   AI-GM / runtime LLM architecture for the 2D Godot game;
-   procedural narrative adjudication;
-   rigid four-ending architecture;
-   "Wrong Envelope" as the primary UnderDMV → Espionage bridge;
-   Rockstar always appearing in the Faerie Ring encounter;
-   Rockstar being the exclusive possible source of Turning Technique;
-   generic procedural NPC navigation;
-   any visual composite that contradicts an approved individual
    character sheet.

Older material may remain useful as archaeology or inspiration.

------------------------------------------------------------------------

## 73. Implementation Philosophy

Build the game from **authored content plus a small number of reusable
systems**.

Prefer:

-   stable IDs;
-   explicit state;
-   event registries;
-   deterministic NPC routines;
-   authored interruption controllers;
-   reusable minigame families;
-   explicit dialogue prerequisites;
-   explicit rewards;
-   explicit callbacks;
-   testable state transitions;
-   exact-enough save restoration.

Avoid creating generalized simulation systems merely because they might
theoretically support future content.

Prove systems on a small authored case before scaling them across the
cast.

------------------------------------------------------------------------

## 74. Codex / Implementation Discipline

When an implementation agent encounters ambiguity:

1.  inspect this document;
2.  inspect the relevant implementation/design brief;
3.  inspect the approved individual visual reference where applicable;
4.  preserve existing working architecture where compatible;
5.  make the smallest change necessary;
6.  do not invent canon to solve a technical problem;
7.  surface genuine design conflicts for human decision.

The first architecture pass should prioritize repository archaeology and
the Insurance Guy routine/interruption proof rather than attempting to
build the entire vertical slice at once.

Audio polish and incomplete SFX are not blockers for that pass.

------------------------------------------------------------------------

## 75. Final Governing Principle

*DMV Simulator* is not about becoming powerful enough to conquer a
bizarre world.

It is about becoming familiar enough with a bizarre world to navigate
it.

The DMV repeats. People repeat. Systems repeat. The player notices.

Knowledge turns inconvenience into opportunity, absurdity into pattern,
and repetition into mastery---without requiring the game to explain why
any of it is happening.

**The player should gradually understand the game better than the world
understands itself.**
