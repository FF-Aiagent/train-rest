# Smoke checklist + Critiquito screenshots (Mac)

For FF after simulator already ran once. Tip on `main` should be at or after `07b4f91` (Info.plist).

## Smoke (tick in order)

1. `git pull` on Mac Mini → open via [OpenInXcode.md](OpenInXcode.md) path A or B.
2. Signing: your Team selected; HealthKit capability on; `TrainRest/Info.plist` is the Info.plist File (not GENERATE).
3. **Simulator**: Today tab shows Train / Easy / Rest (empty Health → Easy / degraded is OK) + reasons + Privacy + Refresh.
4. **Simulator**: Log and Calendar show Unlock Pro at `$4.99` when locked; after StoreKit config unlock, Log add + Calendar day picker work.
5. **Restore**: buy once, kill app, Restore Purchases still unlocks.
6. **Physical iPhone** (when ready): grant Health read; call should reflect real workout/sleep/HRV or clear missing-data reasons. Camera/Photos only when adding a sore-spot photo.
7. No crash on cold start, tab switch, deny Health, or cancel photo picker.

## Four screenshots for Critiquito

Capture on iPhone simulator (or device), English UI, no debug overlays. Upload the four files in chat and ask Jarvis to hand them to Critiquito.

1. **Today** — full Today tab with a call (Train / Easy / Rest) and short reasons visible.
2. **Log locked** — Log tab with Unlock Pro / price (free-user state).
3. **Log unlocked** — sore-spot list or add flow after Pro unlock (StoreKit config OK).
4. **Calendar unlocked** — day picker + a past call / notes after Pro unlock.

## After smoke (ASC, still Mac)

IAP product `app.trainrest.pro` non-consumable $4.99 in App Store Connect; paste [AppStore-US.md](AppStore-US.md) + [PrivacyNutritionLabels.md](PrivacyNutritionLabels.md). Archive → TestFlight when Health on device looks right.

## Fake Health (Debug / Simulator only)

Release builds never include this path (`#if DEBUG`). On a Debug simulator build you can force Today states without a device or paid Developer account:

**Launch args** (preferred for UITests / automation):

```
-FakeHealth train|easy|rest|insufficient|notGranted|denied
```

**In-app:** Today toolbar → **Fake Health** → pick a scenario (writes `UserDefaults` key `debug.fakeHealth`). Choose **Off** to use real HealthKit again.

**UITest:** `SmokeShotsUITests.testFakeHealthVerdictShots` writes PNGs to `/tmp/trainrest-smoke/` (`10-today-train` … `14-today-not-granted`).

