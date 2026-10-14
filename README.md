# Train / Rest

US-first iOS wellness app: one daily call — **Train / Easy / Rest** — from HealthKit signals, plus an optional Pro injury photo log and calendar.

## Scope (frozen)

- Free forever: Today decision (with HealthKit deny/empty degradation)
- Pro ($4.99 one-time): Log (injury diary) + Calendar timeline
- No social, no accounts, no backend, no training plans, no medical claims
- English only (MVP)

## Milestones

- M0 Shell — three tabs + disclaimer placeholder
- M1 HealthKit + degradation
- M2 Today decision engine
- M3 Injury log (on-device)
- M4 Calendar timeline
- M4.5 StoreKit non-consumable Pro
- M5 TestFlight + privacy labels

## Build

Requires macOS + Xcode 15+ and an Apple Developer team with HealthKit entitlement. This repo is scaffolded so you can open `TrainRest.xcodeproj` (generate locally) or add the `TrainRest` sources to a new App project.

## Non-medical disclaimer (draft)

Train / Rest provides training preference hints only. It does not diagnose, treat, or give medical advice. Pain photos are a personal log, not a clinical record.
