# App Privacy (nutrition labels) — draft

Align labels with real behavior. No backend → do not mark “collected from this app” for analytics/account data we do not send.

## Data linked to user

None expected (no accounts).

## Data not linked to user / on device

| Type | Used for | Notes |
|------|----------|--------|
| Health & Fitness | App Functionality | HealthKit read: workouts, sleep analysis, HRV, resting heart rate — used only to compute today’s call on device |
| Photos or Videos | App Functionality | Optional sore-spot log photos — stored on device only |
| Purchases | App Functionality | StoreKit non-consumable Pro entitlement |

## Tracking

No tracking. No third-party ads. No analytics SDK in MVP.

## Permissions copy (Info.plist)

- Health Share: already in `project.yml` — non-medical wording
- Camera / Photo Library: personal sore-spot log, stays on device
