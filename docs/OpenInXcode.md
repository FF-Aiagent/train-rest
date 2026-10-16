# Open Train / Rest in Xcode (Mac)

The repo has Swift sources + `project.yml`, but **no checked-in `.xcodeproj`** yet (created on your Mac). Pick **A** (fastest) or **B** (XcodeGen).

## A. New App target, drop in sources (recommended first run)

1. `git clone https://github.com/FF-Aiagent/train-rest.git && cd train-rest`
2. Open **Xcode 15+** → File → New → Project → **App**
   - Product Name: `TrainRest`
   - Team: your Apple Developer team
   - Organization Identifier: e.g. `app.trainrest`
   - Interface: **SwiftUI**, Language: **Swift**
   - Storage: None; uncheck Core Data / Tests if you want minimal
3. Delete the template `ContentView.swift` / `TrainRestApp.swift` Xcode made (keep the target).
4. In Finder, drag the repo folder `TrainRest/` into the Xcode project navigator (copy items if asked; ensure target membership **TrainRest**).
5. Set the target’s **Signing & Capabilities**:
   - Enable **HealthKit**
   - Entitlements file: point to `TrainRest/Resources/TrainRest.entitlements` (or paste the same keys)
6. **Info** usage strings (Target → Info), if not already from `project.yml`:
   - Privacy — Health Share Usage Description:  
     `Train / Rest reads workout, sleep, and heart data to suggest a training preference for today. It does not diagnose or treat conditions.`
   - Privacy — Camera Usage Description:  
     `Take a photo for your personal sore-spot log. Photos stay on this device.`
   - Privacy — Photo Library Usage Description:  
     `Choose a photo for your personal sore-spot log. Photos stay on this device.`
7. Scheme → run on **iPhone Simulator** (HealthKit data will be empty → Easy/degraded call is expected) or a **physical iPhone** with Health data.
8. Optional: Product → Scheme → Edit Scheme → Run → Options → **StoreKit Configuration** (create a `.storekit` file with non-consumable `app.trainrest.pro` at $4.99) to test unlock without ASC.

### What you should see

| Tab | Free user | After Pro unlock |
|-----|-----------|------------------|
| Today | Train / Easy / Rest + reasons + Privacy + Refresh | same (always free) |
| Log | Unlock Pro — price | sore-spot list + add |
| Calendar | Unlock Pro — price | day picker + call + notes |

## B. XcodeGen

```bash
brew install xcodegen
cd train-rest
xcodegen generate
open TrainRest.xcodeproj
```

Then Signing & Capabilities → HealthKit, pick your Team, Run.

## App Store Connect (when ready)

1. Create app **Train / Rest**, primary language English (US), bundle id matching Xcode.
2. In-App Purchase → Non-Consumable → Product ID **`app.trainrest.pro`** → $4.99.
3. Paste copy from `docs/AppStore-US.md`; privacy from `docs/PrivacyNutritionLabels.md`.
4. Archive → Upload → TestFlight internal testing.

## Can’t compile?

- Missing `@main`: only one `TrainRestApp.swift` should be in the target.
- HealthKit link error: add capability + entitlements.
- `PhotosUI` / StoreKit: iOS 17+ deployment target.


## If you see “target does not have an Info.plist”

`main` ships `TrainRest/Info.plist` and `project.yml` sets `GENERATE_INFOPLIST_FILE: NO` + `INFOPLIST_FILE: TrainRest/Info.plist`. Do **not** flip Generate Info.plist File back to Yes.

```bash
git pull
xcodegen generate   # if you use path B
open TrainRest.xcodeproj
```

In Xcode: Build Settings → Info.plist File should be `TrainRest/Info.plist`. Health / Camera / Photos usage strings live in that file.
