# Assessment: the `feat/foundation-runtime` prototype (PR #1)

**Status:** Assessment only. Whether PR #1 is merged, kept parked, or closed is
Usama's decision; this document frames that decision with evidence.

**Scope:** Branch `feat/foundation-runtime` at 773cc39 (6 commits, October 4,
2026), assessed against `docs/ROADMAP-MARK-I-II-III.md` as it stands on main.

## What the branch contains

| File | Lines | Content |
|---|---|---|
| `pyproject.toml` | 18 | Python package `aios` 0.1.0, setuptools, `aios` console script, Apache-2.0 |
| `aios/__init__.py` | 3 | Docstring and version |
| `aios/runtime.py` | 49 | `Event` dataclass and a `Runtime` class: in-process event dispatch |
| `aios/cli.py` | 25 | argparse CLI that emits one event and prints it as JSON |
| `tests/test_runtime.py` | 31 | Three tests covering the event contract |
| `README.md` | 28 | Describes AIOS as "a deliberately small runtime foundation for AI systems" |

The runtime is a deterministic, in-process event bus: handlers register per
event type with `on()`, `emit()` assigns monotonic integer IDs and dispatches
synchronously in registration order, and `events()` reads the stored log back
with type and cursor (`after_id`) filters. The module docstring states the
design constraint directly: AIOS "deliberately does not require a model
provider, network, or database. Adapters can build on the small event/handler
contract." The branch README adds a design boundary: AIOS owns runtime
coordination primitives, while persistent memory/data belongs in AIDB and
economic accounting belongs in TokenCoin.

Verified locally on 2026-11-24: the branch's test suite passes (3 passed,
pytest). The code is small, dependency-free, and does what its tests claim.

## How it relates to the roadmap

**It predates the roadmap.** The branch was written on October 4, 2026, from
the initial commit (merge base a000a46). The roadmap — Gentoo, OpenRC, KDE
Plasma, OpenClaw, the three-generation structure — landed on main on November
24, 2026, seven weeks later. The branch contains no reference to Gentoo,
OpenRC, Plasma, Portage, installers, or operating-system concerns of any kind.

**It embodies a different framing of the project.** The branch defines AIOS as
a Python runtime *library* for agent coordination. The roadmap defines AIOS as
an operating-system *distribution* whose Mark I is a Gentoo-based desktop. The
branch's framing is not a subset or first step of the roadmap's framing; it is
an earlier, different answer to "what is AIOS?"

**It implements no roadmap item.** Mark I's AI layer is decided in the
roadmap: the assistant is integrated into the desktop, and OpenClaw is the
initial AI agent framework. The prototype is not OpenClaw, does not integrate
with it, and does not run on or configure a Gentoo system. Nothing in Mark II
or Mark III calls for an in-process Python event bus either.

**Its one point of contact with the roadmap is an open question.** The
roadmap lists as undecided: "The exact responsibilities and permission model
of the Mark I AI environment, including how desktop actions are authorized."
A small, provider-agnostic event contract is the *kind* of primitive such an
environment could use for coordinating agent actions. But the prototype does
not address the question itself: it has no permission model, no
authorization, and no audit trail beyond an in-memory list — while the
roadmap's cross-generation principles require explicit permissions and
human authorization for consequential actions. As it stands, the prototype is
adjacent to that open question, not an answer to it.

## Merge mechanics

Merging the branch into current main is not clean: `git merge-tree` shows a
content conflict in `README.md` (the branch rewrites the stub README; main has
since replaced it). The code files themselves do not conflict with anything on
main, because main has no Python code. So the obstacle to merging is not
mechanical — it is the framing conflict described above: the branch's README
and package description would put a pre-roadmap definition of AIOS ("runtime
foundation library") at the top of a repository whose roadmap now defines it
as an operating system.

## Options

1. **Merge PR #1 as-is.** Puts working, tested code on main, but imports the
   superseded framing alongside it, requires resolving the README conflict in
   favor of one definition of the project, and lands code that no roadmap
   item calls for.
2. **Merge the code as a clearly-marked prototype area** (for example under a
   `prototypes/` directory, with the roadmap's README kept). Preserves the
   code on main without endorsing its framing; costs a small restructuring
   of the branch first.
3. **Keep the branch parked.** Costs nothing, loses nothing: the branch and
   PR #1 remain available, and the event-contract idea can be revisited when
   the Mark I AI-environment responsibilities are actually designed — the
   first moment it could be judged against a real requirement.
4. **Close PR #1 as superseded.** Defensible on framing grounds — the roadmap
   replaced the branch's definition of the project — but discards nothing
   that cannot be recovered from the branch, and the event-contract idea has
   not yet been evaluated against the AI-environment design question it is
   adjacent to.

## Recommendation

**Keep the branch parked (option 3); do not merge PR #1 in its current form.**
The prototype is competent, tested, and self-contained, but it answers a
question the project no longer asks in that form, and merging it now would
either contradict the roadmap's definition of AIOS or require restructuring
work that only makes sense once the Mark I AI environment has a design to
test it against. When that design work happens, the natural checkpoint is:
adopt the event contract deliberately (option 2), or close PR #1 as
superseded with this assessment as the evidence (option 4). Closing it today
would also be reasonable; parking it is recommended only because the adjacent
roadmap question is still open and the cost of waiting is zero.
