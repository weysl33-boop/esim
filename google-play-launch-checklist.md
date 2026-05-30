# WeAirSim Google Play Launch Checklist

Updated: 2026-05-30

## Current Google / Firebase Setup

- Google account in use: Ourslake, `ourslake2026@gmail.com`
- Google Play Console account used for existing app: `weysl33@yahoo.com`
- Google Play Console status: existing app `WeAirSim` is accessible in Play Console.
- Firebase project: `weairsim-c409d`
- Firebase project number: `925459948173`
- Google Play existing draft app: `WeAirSim`, package `com.weairsim.global`
- Google Play app id path: `developers/7337508722254242941/app/4974101940938149155`
- Android package name: `com.weairsim.global`
- Firebase Android app ID: `1:925459948173:android:229e35a87696499c8ef8c4`
- Web OAuth client: saved locally in `Z:\appS\esim\google-oauth-web-client.local.md`
- Android Firebase config: `Z:\appS\esim\esim-cross-platform-mobile-app-for-international-esim-and-data-purchase\Files\android\app\google-services.json`

## Completed

- Web OAuth client configured for `https://www.weairsim.com`.
- Backend Google login route verified with a Google OAuth redirect.
- Mobile API domain points to `https://www.weairsim.com`.
- Android package changed from vendor default `dev.vlab.esim` to Play Console package `com.weairsim.global`.
- Android app label changed from `Esim` to `WeAirSim`.
- Firebase Android app `WeAirSim Google Play / com.weairsim.global` added.
- Android Firebase options and `google-services.json` updated for project `weairsim-c409d`.
- Play Console dashboard inspected from the logged-in developer account.
- Android upload keystore generated locally.
- Release SHA-1 and SHA-256 fingerprints added to Firebase Android app `com.weairsim.global`.
- Release Android App Bundle generated successfully.
  - AAB path: `G:\weairsim-build\workspace\mobile\build\app\outputs\bundle\release\app-release.aab`
  - AAB size: 96,678,322 bytes (about 92.2 MB)
  - AAB SHA-256: `3448570F543FAE43A6A7B8FBB173FCF95C860CFE545DB98CE67649601F3C6B5E`

## Current Play Console Status

- App: `WeAirSim`
- Package: `com.weairsim.global`
- Update status: not yet submitted for review.
- Production status shown in dashboard: active, 0 active devices, 176 countries/regions.
- Closed testing setup: 2 of 5 tasks completed.
- Open testing setup: 2 of 4 tasks completed.
- Remaining visible release tasks:
  - Select testers for closed testing.
  - Preview and confirm release.
  - Submit release to Google for review.
- Policy center shows a previous issue:
  - Rejection date: 2026-03-22.
  - Policy: Misleading claims / deceptive claims.
  - Appeal reply already sent on 2026-03-23.

## Next Required Before Play Upload

1. Upload the new `.aab` to the existing Play Console app `WeAirSim / com.weairsim.global`.
2. Complete Play Console store requirements:
   - App name: WeAirSim
   - Default language: English or Chinese, final decision needed
   - Short description and full description
   - App icon, feature graphic, phone screenshots
   - Privacy policy URL
   - Data safety form
   - Content rating questionnaire
   - Target audience declaration
   - App access instructions if login is required
   - Payments declaration, because the app sells eSIM/data products
3. Resolve the previous misleading-claims policy issue before production review.
4. Run internal testing on at least one Android device before production submission.

## Operational Notes

- Do not commit `.local.md` secret files.
- Keep release keystore backed up. Losing it can block future updates unless Play App Signing recovery is used.
- Google Play production review should wait until provider API flow, payment flow, email delivery, and refund/support text are verified end-to-end.
