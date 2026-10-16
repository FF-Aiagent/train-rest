# Train / Rest

US-first iOS wellness app: one daily call — **Train / Easy / Rest** — from HealthKit, plus optional Pro sore-spot photo log and calendar.

**Repo:** https://github.com/FF-Aiagent/train-rest  
**Latest on `main`:** M0–M5 source + ASC/privacy docs.

## Scope (frozen)

- **Free forever:** Today’s Train / Easy / Rest (with HealthKit deny/empty degradation)
- **Pro ($4.99 one-time):** Log (sore-spot diary) + Calendar — product id `app.trainrest.pro`
- No social, no accounts, no backend, no training plans, no medical claims
- English only (MVP)

## Open on your Mac (start here)

Step-by-step: **[docs/OpenInXcode.md](docs/OpenInXcode.md)**

Short version:

```bash
git clone https://github.com/FF-Aiagent/train-rest.git
cd train-rest
# Then Xcode → New App → drag in TrainRest/ sources → enable HealthKit → Run
# Or: brew install xcodegen && xcodegen generate && open TrainRest.xcodeproj
```

You need **macOS + Xcode 15+** and an Apple Developer team. This Linux bot can push Swift; it cannot build the iOS Simulator for you.

## Milestones

- [x] M0 Shell — three tabs + disclaimer
- [x] M1 HealthKit + degradation
- [x] M2 Decision engine (deterministic) + `TrainRestTests/`
- [x] M3 Sore-spot photo log (Pro-gated)
- [x] M4 Calendar timeline (Pro-gated)
- [x] M4.5 StoreKit Pro + Restore
- [x] M5 ASC/privacy **docs** + in-app Privacy screen (TestFlight still needs your Mac/ASC)

## Docs

- [docs/OpenInXcode.md](docs/OpenInXcode.md) — clone → Xcode → run
- [docs/SmokeAndScreens.md](docs/SmokeAndScreens.md) — Mac smoke ticks + four Critiquito shots
- [docs/AppStore-US.md](docs/AppStore-US.md) — US listing draft
- [docs/PrivacyNutritionLabels.md](docs/PrivacyNutritionLabels.md) — privacy labels
- [StoreKit.storekit.md](StoreKit.storekit.md) — IAP product id

## Non-medical disclaimer

Train / Rest provides training preference hints only. It does not diagnose, treat, or give medical advice. Sore-spot photos are a personal log, not a clinical record.
