# Skinora — Flutter Frontend (Step 1)

AI Powered Skin, Hair & Wellness Companion — Flutter client.

## ✅ What's built in this step
- Project folder structure (`lib/core`, `routes`, `screens`, `widgets`, `models`, `services`)
- `pubspec.yaml` with all required packages (riverpod, go_router, dio, google_fonts, etc.)
- Full theme system: `AppColors` (white + lavender), `AppTextStyles` (Poppins), `AppTheme` (Material 3)
- Reusable widgets: `PrimaryButton`, `SecondaryButton`, `AppTextField`
- Screens: **Splash → Welcome (onboarding) → Login → Signup → Basic Info**
- `go_router` navigation wiring (routes defined, screen-to-screen `TODO`s left for next step)

## 🗂️ Folder structure
```
skinora/
├── pubspec.yaml
├── assets/
│   ├── images/
│   ├── icons/
│   └── fonts/          # add Poppins .ttf files here
└── lib/
    ├── main.dart
    ├── core/
    │   ├── theme/       # app_colors.dart, app_text_styles.dart, app_theme.dart
    │   ├── constants/
    │   └── utils/
    ├── routes/
    │   └── app_routes.dart
    ├── screens/
    │   ├── splash/
    │   ├── onboarding/
    │   ├── auth/        # login, signup, basic_info
    │   ├── assessment/  # next step
    │   └── home/        # next step
    ├── widgets/
    │   └── common/      # app_button.dart, app_text_field.dart
    ├── models/
    └── services/
```

## ▶️ How to run
1. Install Flutter SDK (>= 3.3.0): https://docs.flutter.dev/get-started/install
2. Create a fresh Flutter project shell (this delivers `lib/` + `pubspec.yaml` + `assets/` only):
   ```bash
   flutter create skinora_app
   ```
3. Copy this `lib/`, `pubspec.yaml`, and `assets/` folder into `skinora_app/`, replacing the defaults.
4. Download **Poppins** font files (Regular, Medium, SemiBold, Bold) from Google Fonts and place them in `assets/fonts/`. (Or remove the `fonts:` block in `pubspec.yaml` to rely on `google_fonts` package fetching at runtime — already wired as a fallback via `GoogleFonts.poppins()`.)
5. Install dependencies:
   ```bash
   flutter pub get
   ```
6. Run:
   ```bash
   flutter run
   ```

## 🔜 Next steps (not yet built)
- Skin & Hair Assessment Quiz screens
- AI Analysis Result screen
- Home Dashboard
- Wire up real navigation (replace `TODO` comments with `context.go(...)`)
- Connect to Go backend via `services/` (Dio + AuthService, etc.)

## 🎨 Design tokens
- Primary: `#8B5FBF` (lavender-purple), gradient `#9D6FE0 → #C084E8`
- Background: white / `#FAF8FD`
- Font: Poppins
- Radius scale: 12 / 16 / 20 / 28 / pill
- All tokens centralized in `lib/core/theme/` — change once, reflects everywhere
