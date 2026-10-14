# Train / Rest

US-first iOS wellness app: one daily call — **Train / Easy / Rest** — from HealthKit signals, plus an optional Pro injury photo log and calendar.

**Repo:** https://github.com/FF-Aiagent/train-rest

## Scope (frozen)

- Free forever: Today decision (with HealthKit deny/empty degradation)
- Pro ($4.99 one-time): Log (injury diary) + Calendar timeline
- No social, no accounts, no backend, no training plans, no medical claims
- English only (MVP)

## Milestones

- [x] M0 Shell — three tabs + disclaimer placeholder
- [x] M1 HealthKit + degradation (source landed; device QA pending)
- [x] M2 Today decision engine (rule-based, deterministic)
- DecisionEngine unit test stubs in TrainRestTests/
- [x] M3 Sore-spot photo log (on-device; Pro-gated)
- [x] M4 Calendar timeline (Pro-gated; reads DailyCallStore + SoreSpotStore)
- [x] M4.5 StoreKit non-consumable Pro (`app.trainrest.pro`) + Restore
- [x] M5 docs: App Store US copy + privacy nutrition draft (TestFlight still needs Mac/ASC)

## Build

Requires macOS + Xcode 15+ and an Apple Developer team with HealthKit capability. Create an iOS App target, add the `TrainRest` sources, enable HealthKit, and point entitlements at `TrainRest/Resources/TrainRest.entitlements`. Or generate with [XcodeGen](https://github.com/yonaskolb/XcodeGen) from `project.yml`.

## Non-medical disclaimer

Train / Rest provides training preference hints only. It does not diagnose, treat, or give medical advice. Pain photos are a personal log, not a clinical record.

## Store / privacy drafts

- [docs/AppStore-US.md](docs/AppStore-US.md)
- [docs/PrivacyNutritionLabels.md](docs/PrivacyNutritionLabels.md)
