# G8 Feature Matrix

Every entry below is measured directly against commit `d4976b0`
(`git diff-tree --no-commit-id -r --numstat`, `git diff-tree ...
--name-status`, and import-level dependency extraction against the
commit's own tree via `git archive`) — not inferred from the commit
message, which names only 4 of the 13 slices identified here. Analysis
only; no branch, commit, or push touches this commit or any other.

**Generated code called out explicitly.** Several directories show
huge raw line counts because Drift (`*.g.dart`) and `flutter gen-l10n`
(`app_localizations*.dart`) regenerate thousands of lines from a small
hand-written source. Review size below lists both the raw diff and the
hand-written figure a reviewer would actually read.

---

## Infrastructure / prerequisite slices

### P1 — Reliability layer
| | |
|---|---|
| Purpose | `AppFailure`/`FailureCategory`/`FailureSeverity`, error-mapping, `Logger`/`CrashReporter` interfaces + non-cloud defaults, DI providers |
| Files | `lib/core/error/` (4), `lib/core/logging/` (6), `docs/knowledge/reliability_architecture.md` |
| Dependencies | **None** |
| Review size | 347 hand-written lines, 10 source + 6 test files (`app_failure_test`, `failure_mapper_test`, `console_logger_test`, `logging_providers_test`, `noop_crash_reporter_test`, `repository_boundary_logging_test`) |
| Merge risk | **Lowest in the commit.** Purely additive — zero existing files touched, nothing references it yet |
| Test impact | 6 new test files, all passing in isolation; no existing test's behavior changes |

### P2 — Shared accessibility widgets
| | |
|---|---|
| Purpose | `EmptyStateBanner`, `LoadingState`, `SectionHeader`, `StatCard` — shared UI primitives |
| Files | `lib/shared/widgets/{empty_state_banner,loading_state,section_header,stat_card}.dart` |
| Dependencies | **None** |
| Review size | 232 lines, 4 files + `shared_widgets_a11y_test.dart` |
| Merge risk | **Lowest in the commit**, tied with P1 — purely additive, unused until a feature adopts one |
| Test impact | 1 new test file covering all four widgets |

### P3 — Database schema migration
| | |
|---|---|
| Purpose | New tables/columns backing Flashcards, Lexicon, Learning Journey, and Analytics data |
| Files | `lib/core/database/app_database.dart`, `.../tables/content_tables.dart`, `.../user/user_database.dart`, `.../user/user_tables.dart` (hand-written); `app_database.g.dart`, `user_database.g.dart` (Drift-generated); `assets/database/quran.sqlite` (Modified, +77 KB — well under the CI size gate's 1 MB threshold) |
| Dependencies | **None** — but everything downstream that needs a new table depends on this |
| Review size | **259 hand-written lines** (`app_database.dart` +15, `content_tables.dart` +172, `user_database.dart` +12, `user_tables.dart` +60) vs **8,624 generated lines** in the two `.g.dart` files that should be regenerated via `build_runner`, not hand-reviewed |
| Merge risk | **Highest of the prerequisite slices.** Touches both the content database (group A) and the user database (group B) in the same commit — exactly the kind of change `PROJ-P-002` requires an explicit stop-and-ask review for, not a buried line in a 229-file diff |
| Test impact | `content_database_smoke_test.dart` (Modified) — the schema/version pairing check |

### P4 — Reliability retrofit into existing repositories
| | |
|---|---|
| Purpose | Adopt the P1 pattern into repositories that already shipped before this commit: khatm, learning (scheduler), library (bookmarks), quiz, quran, stats |
| Files | 7 `*_repository_impl.dart`/`*_providers.dart` files (Modified), 7 paired test files (Modified) |
| Dependencies | **P1 only** |
| Review size | +816/−600 lines across 6 already-live features |
| Merge risk | **Medium.** Touches six features already in production use (on `sprint1-my-library`'s timeline) — a regression here is a regression in something users already rely on, not a new surface |
| Test impact | 7 existing test files modified; confirmed via `grep` that `khatm_cycle_repository_impl.dart` and `scheduler_repository_impl.dart` genuinely import `core/error`/`core/logging` — this is a real dependency, not incidental |

### Distributed, not independently mergeable
`lib/l10n/*` (861 hand-authored lines across 3 `.arb` files + 2,349
generated lines in `app_localizations*.dart`), `lib/app/router.dart`
(+99), and `lib/features/home/presentation/home_screen.dart` /
`lib/features/study/presentation/study_screen.dart` (+143 combined) are
touched by nearly every feature below. They cannot be cleanly extracted
as their own slice — each feature PR carries its own l10n keys, its own
route registration, and its own entry-point link. Listed here so the
229-file total is fully accounted for, not silently dropped.

---

## New feature verticals

All eight were checked against each other for cross-imports (relative
imports, verified directly against the commit's tree — no assumption).
**None import each other's siblings that come later in the dependency
order below** — the graph is acyclic.

### F1 — Lexicon
| | |
|---|---|
| Purpose | Word-by-word morphology/lexicon data pipeline and browsing UI |
| Files | `lib/features/lexicon/` (11), `tool/lexicon/` (13 — Python build pipeline + its own tests) |
| Dependencies | P1, P3. No dependency on any other new feature — **the most foundational of the eight** |
| Review size | 779 (lib) + 1,319 (tool) = 2,098 lines, 24 files |
| Merge risk | **Medium.** New data pipeline (Python) alongside new Dart domain/UI — two languages in one review |
| Test impact | `lexicon_entities_test`, `lexicon_repository_contract_test`, `lexicon_repository_impl_test` + the Python tests under `tool/lexicon/tests/` |

### F2 — Flashcards
| | |
|---|---|
| Purpose | Spaced-repetition flashcard decks, smart deck generation |
| Files | `lib/features/flashcards/` (19 — **the largest single feature in the commit**) |
| Dependencies | F1 (Lexicon), `learning` (existing, already on `main`), P1, P2, P3 |
| Review size | 2,293 lines, 19 files |
| Merge risk | **Medium.** Large surface, but self-contained; its only new-feature dependency (Lexicon) is the one directly beneath it in merge order |
| Test impact | `flashcard_filter_test`, `flashcard_repository_test`, `flashcard_tile_test`, `flashcard_ux_test` |

### F3 — Analytics
| | |
|---|---|
| Purpose | Achievements, learning statistics, progress dashboard |
| Files | `lib/features/analytics/` (16) |
| Dependencies | F2 (Flashcards), F1 (Lexicon), `learning`/`search`/`stats` (existing), P2 |
| Review size | 1,741 lines, 16 files |
| Merge risk | **Medium.** Widest existing-feature dependency footprint of the eight (three pre-existing features) |
| Test impact | `achievement_calculator_test`, `achievement_card_test`, `analytics_repository_impl_test`, `goal_card_test`, `performance_insights_selector_test`, `progress_dashboard_screen_test`, `learning_statistics_calculator_test`, `learning_history_calculator_test`, `learning_goal_calculator_test` |

### F4 — AI Tutor
| | |
|---|---|
| Purpose | Contextual study suggestions and insights (later renamed "Study Coach" in RC-1) |
| Files | `lib/features/ai_tutor/` (15) |
| Dependencies | F3 (Analytics), F2 (Flashcards), `search` (existing), P2 |
| Review size | 1,127 lines, 15 files |
| Merge risk | **Medium**, plus a **process flag**: this feature's original labeling was found materially misleading during this engagement's own truthfulness audit (Sprint 36.0) and corrected in a later commit (`8d7dee5`, release group G13). A split-PR reviewer should carry that correction alongside this feature, not ship the pre-correction labeling as if it were final |
| Test impact | `ai_tutor_providers_test`, `ai_tutor_repository_impl_test`, `tutor_header_test`, `tutor_home_screen_test`, `tutor_insight_card_test`, `tutor_insight_generator_test`, `tutor_suggestion_card_test`, `tutor_suggestion_generator_test` |

### F5 — Learning Journey
| | |
|---|---|
| Purpose | Daily learning plan, journey steps/progress |
| Files | `lib/features/learning_journey/` (11) |
| Dependencies | F4 (AI Tutor), `search` (existing), P2 |
| Review size | 724 lines, 11 files |
| Merge risk | **Low-medium.** Straightforward once F4 is in place |
| Test impact | `daily_learning_plan_generator_test`, `journey_header_test`, `journey_progress_card_test`, `journey_step_card_test`, `learning_journey_providers_test`, `learning_journey_repository_impl_test`, `learning_journey_screen_test` |

### F6 — Smart Learning
| | |
|---|---|
| Purpose | Session-strategy recommendations combining several learning signals |
| Files | `lib/features/smart_learning/` (13) |
| Dependencies | F4 (AI Tutor), F5 (Learning Journey), `search` (existing), P2 |
| Review size | 691 lines, 13 files |
| Merge risk | **Low-medium.** Latest in the chain among the "AI Tutor family," so its dependencies are already reviewed by the time it lands |
| Test impact | `smart_deck_selector_test`, `smart_learning_header_test`, `smart_learning_providers_test`, `smart_learning_repository_impl_test`, `smart_learning_screen_test`, `smart_learning_session_generator_test`, `recommendation_card_test`, `session_summary_card_test` |

### F7 — Read Model
| | |
|---|---|
| Purpose | Learning-snapshot aggregation (surfaced on Home) |
| Files | `lib/features/read_model/` (7) |
| Dependencies | F4, F5, F6 — **depends on all three other AI-Tutor-family features**, confirmed by import check |
| Review size | 230 lines, 7 files — smallest of the eight |
| Merge risk | **Low.** Small surface; its risk is entirely in *when* it can merge (last in this family), not in its own content |
| Test impact | `learning_snapshot_generator_test`, `learning_snapshot_providers_test`, `learning_snapshot_repository_impl_test` |

### F8 — Learning Session
| | |
|---|---|
| Purpose | Session controller/screens — appears to enhance an existing surface rather than introduce a wholly new one (its files are Modified, not Added) |
| Files | `lib/features/learning_session/` (4, all Modified) |
| Dependencies | F2 (Flashcards), `learning`/`quiz` (existing) |
| Review size | 64 lines — smallest change of any slice in the commit |
| Merge risk | **Low.** Independent of the F3→F7 "AI Tutor family" chain entirely; can move in parallel |
| Test impact | `learning_session_controller_test`, `learning_session_screen_test`, `review_session_screen_test` (latter two Modified, not new) |

---

## Dependency summary (verified by import extraction, not assumed)

```
P1, P2, P3          — no dependencies, ship in any order, first
P4                   — depends on P1 only
F1 (Lexicon)         — depends on P1, P3
F2 (Flashcards)      — depends on F1, P1, P2, P3
F3 (Analytics)       — depends on F2, F1, P2
F4 (AI Tutor)        — depends on F3, F2, P2
F5 (Learning Journey)— depends on F4, P2
F6 (Smart Learning)  — depends on F4, F5, P2
F7 (Read Model)      — depends on F4, F5, F6
F8 (Learning Session)— depends on F2 only — parallel to F3–F7
```

No cycle exists anywhere in this graph — checked explicitly, not
assumed from the commit message's grouping.
