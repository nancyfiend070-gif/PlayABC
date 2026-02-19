# App Store Submission Checklist – PlayABC

Use this checklist before uploading PlayABC to the App Store. Items marked **Done** are already satisfied in the project; others you must complete in Xcode, App Store Connect, or externally.

---

## 1. Apple Developer & App Store Connect

| Requirement | Status | Notes |
|-------------|--------|--------|
| Apple Developer Program membership | **You** | Active paid membership required. |
| App created in App Store Connect | **You** | Create app with bundle ID `com.playabc.PlayABC`. |
| Bundle ID matches | **Done** | Project uses `com.playabc.PlayABC`. |
| Version & build number | **Done** | MARKETING_VERSION 1.0, CURRENT_PROJECT_VERSION 1. Set build number for each upload. |

---

## 2. Privacy Policy (required)

| Requirement | Status | Notes |
|-------------|--------|--------|
| Privacy policy URL | **You** | **Required.** Host the privacy policy at a public URL (e.g. your website or GitHub Pages). |
| Policy accessible in-app | **Done** | Privacy policy is available via the “Privacy” button on the home screen. |
| Policy in primary language | **You** | Ensure the hosted policy is in English (or your app’s primary language). |
| Enter URL in App Store Connect | **You** | In App Store Connect → Your App → App Information → Privacy Policy URL. |

**Action:** Copy the content from `PlayABC/PRIVACY_POLICY.md` (or the in-app text) to a webpage and use that page’s URL in App Store Connect.

---

## 3. App Privacy (Nutrition Labels)

| Requirement | Status | Notes |
|-------------|--------|--------|
| App Privacy form completed | **You** | In App Store Connect → Your App → App Privacy. |
| Data collection disclosed | **You** | PlayABC **does not collect** personal data, identifiers, or usage data. Select “Data Not Collected” for all categories, or answer the questionnaire accordingly. |
| Third-party SDKs | **Done** | App uses: **Lottie** (animations only, no data collection). No analytics, ads, or social SDKs. |

**Recommendation:** In App Privacy, indicate that no data is collected. If your hosted privacy policy URL is collected when users open the link, that is not “data collection” by the app itself.

---

## 4. Permissions & Info.plist

| Requirement | Status | Notes |
|-------------|--------|--------|
| Microphone | **N/A** | Not used. No `NSMicrophoneUsageDescription` needed. |
| Camera | **N/A** | Not used. No `NSCameraUsageDescription` needed. |
| Photo Library | **N/A** | Not used. No photo usage description needed. |
| Speech Recognition | **N/A** | Only **text-to-speech** (AVSpeechSynthesizer) is used; no speech recognition. No `NSSpeechRecognitionUsageDescription` needed. |
| Other usage descriptions | **Done** | None required for current features. |

The project uses **GENERATE_INFOPLIST_FILE = YES**; no custom Info.plist keys are required for current functionality.

---

## 5. Kids / Age Rating

| Requirement | Status | Notes |
|-------------|--------|--------|
| Age rating questionnaire | **You** | In App Store Connect, complete the age rating questionnaire. For a learning ABC app with no user accounts, ads, or links to social media, expect a low age rating (e.g. 4+). |
| Kids category (optional) | **You** | If you place the app in the **Kids** category: no PII/device data to third parties, no behavioral ads, parental gates for any external links or commerce. PlayABC has no accounts, no ads, and no external links in the main flow; the in-app Privacy view is parent-oriented. |

---

## 6. Build & Technical

| Requirement | Status | Notes |
|-------------|--------|--------|
| Signing & capabilities | **You** | Development team (LHWHZ5LLC) is set. Use automatic signing and ensure the App Store distribution certificate and provisioning profile are valid. |
| Deployment target | **Check** | Project has **IPHONEOS_DEPLOYMENT_TARGET = 26.2**. As of 2025, Apple typically requires iOS 18 SDK; “26.2” may be a typo or a future OS. Consider setting to **17.0** or **18.0** for wider device support unless you intend to target a future OS. |
| Archive & upload | **You** | Product → Archive, then Distribute App → App Store Connect. |
| Sound assets | **You** | Add `tap`, `reward_star`, `reward_celebration`, `background_music` (.mp3) to the target if you want sounds; otherwise the app runs without them. |

---

## 7. App Store Connect Metadata (before first submission)

| Requirement | Status | Notes |
|-------------|--------|--------|
| App name | **You** | e.g. “PlayABC”. |
| Subtitle | **You** | Short tagline (e.g. “Learn letters & play games”). |
| Description | **You** | Clear description of the app for parents. |
| Keywords | **You** | e.g. alphabet, letters, kids, learning, ABC. |
| Screenshots | **You** | Required for each device size (e.g. 6.7", 6.5", 5.5" iPhone; iPad if supported). |
| App icon | **Done** | ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon; ensure Assets.xcassets has an AppIcon set. |
| Category | **You** | e.g. Education (and optionally Kids). |
| Privacy Policy URL | **You** | See section 2. |
| Support URL | **You** | Optional but recommended (e.g. contact or support page). |

---

## 8. Compliance & Legal

| Requirement | Status | Notes |
|-------------|--------|--------|
| Export compliance | **You** | In App Store Connect, answer export compliance. For an app with no encryption beyond what iOS uses by default, “No” or standard exemption usually applies. |
| Content rights | **You** | Confirm you have rights to all content (e.g. Lottie animations, any assets). |
| EU (DSA) | **You** | If distributing in the EU, provide trader status / contact if required. |

---

## Summary – Your actions

1. **Host the privacy policy** at a public URL and **add that URL** in App Store Connect (App Information → Privacy Policy URL).
2. **Complete App Privacy** in App Store Connect (indicate no data collection).
3. **Complete age rating** and choose category (Education / Kids if applicable).
4. **Prepare metadata**: name, description, keywords, **screenshots**, support URL if desired.
5. **Review deployment target** (e.g. set to 17.0 or 18.0 if 26.2 was not intentional).
6. **Archive and upload** the build, then submit for review.

The app codebase already supports **in-app access to the privacy policy** via the Privacy button on the home screen.
