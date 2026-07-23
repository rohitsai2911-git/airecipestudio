# Poco AI Cooking Companion — Flutter Frontend Design

**Date:** 2026-07-23
**Project:** AI Recipe Studio
**Backend:** FastAPI + Supabase (complete)
**Frontend:** Flutter 3.27.1 / Dart 3.6.0

---

## 1. Architecture

### Pattern: Feature-First Modular

```
lib/
  main.dart                       # App entry, ProviderScope, MaterialApp.router
  core/
    theme/
      app_colors.dart             # All color tokens from DESIGN.md
      app_typography.dart         # TextTheme with exact font sizes/weights
      app_radius.dart             # Shape constants (12px cards, pill buttons, etc.)
      app_shadows.dart            # BoxShadow constants matching CSS
      app_spacing.dart            # Spacing tokens (8px unit, 24px container, etc.)
      app_theme.dart             # ThemeData combining all tokens
    router/
      app_router.dart             # GoRouter config, routes, ShellRoute
      auth_guard.dart            # Redirect logic (session → home, no session → auth)
    api/
      api_client.dart            # HTTP wrapper, JWT interceptor from supabase_flutter
      api_exceptions.dart        # Typed error classes
    design_system/
      widgets/
        poco_app_bar.dart
        recipe_card.dart
        poco_mascot_tip.dart
        poco_bottom_nav.dart
        poco_fab.dart
        tactile_button.dart
        ingredient_chip.dart
        filter_chip.dart
        time_chip.dart
        chat_bubble.dart
        xp_progress_ring.dart
        meal_plan_day.dart
        meal_card.dart
        scanner_viewfinder.dart
        onboarding_step.dart
        difficulty_button.dart
        cuisine_card.dart
        preference_radio.dart
        servings_slider.dart
        shopping_list_item.dart
        achievement_card.dart
        activity_item.dart
    models/
      ingredient.dart
      step.dart
      dish.dart
      recipe_response.dart
      saved_recipe.dart
      chat_message.dart
      chat_reply.dart
      completion_result.dart
      meal_plan_entry.dart
      meal_plan_request.dart
  features/
    auth/
      providers/
        auth_provider.dart        # supabase_flutter session state
        onboarding_provider.dart
      pages/
        splash_page.dart
        onboarding_page.dart
        login_page.dart
        register_page.dart
      widgets/
        auth_form_field.dart
        onboarding_feature_card.dart
    home/
      providers/
        home_provider.dart
        seasonal_provider.dart
      pages/
        home_page.dart
      widgets/
        greeting_section.dart
        hero_recipe_card.dart
        seasonal_scroll.dart
        quick_scan_grid.dart
    ingredient_scanner/
      providers/
        scanner_provider.dart
        ingredient_list_provider.dart
      pages/
        scanner_page.dart
      widgets/
        camera_viewfinder.dart
        ingredient_sheet.dart
    preferences/
      providers/
        preferences_provider.dart
      pages/
        preferences_page.dart
      widgets/
        cuisine_selector.dart
        difficulty_picker.dart
        time_limit_radio.dart
        servings_slider_widget.dart
    recipe_generation/
      providers/
        generation_provider.dart
      pages/
        generation_page.dart
      widgets/
        generation_animation.dart
    recipe_discovery/
      providers/
        discovery_provider.dart
      pages/
        discovery_page.dart
      widgets/
        discovery_card.dart
        asymmetric_hero_card.dart
        filter_chips_row.dart
    recipe_detail/
      providers/
        recipe_detail_provider.dart
      pages/
        recipe_detail_page.dart
      widgets/
        hero_image.dart
        stats_row.dart
        ingredient_list.dart
        step_list.dart
        detail_bottom_bar.dart
    recipe_library/
      providers/
        library_provider.dart
      pages/
        library_page.dart
      widgets/
        library_grid.dart
        library_search_bar.dart
    poco_chat/
      providers/
        chat_provider.dart
      pages/
        chat_page.dart
      widgets/
        chat_bubble.dart
        suggestion_chips.dart
        chat_input_bar.dart
    voice_cooking/
      providers/
        voice_provider.dart
      pages/
        voice_page.dart
      widgets/
        step_display.dart
        voice_controls.dart
    cooking_completion/
      providers/
        completion_provider.dart
      pages/
        completion_page.dart
      widgets/
        xp_animation.dart
        confetti_overlay.dart
    xp_achievements/
      providers/
        xp_provider.dart
      pages/
        xp_page.dart
      widgets/
        progress_ring.dart
        achievement_grid.dart
        activity_feed.dart
    meal_planner/
      providers/
        meal_plan_provider.dart
      pages/
        meal_planner_page.dart
      widgets/
        day_selector.dart
        meal_slot.dart
        smart_suggestions.dart
        shopping_fab.dart
    shopping_list/
      providers/
        shopping_list_provider.dart
      pages/
        shopping_list_page.dart
      widgets/
        category_group.dart
        shopping_list_tile.dart
    profile_settings/
      providers/
        profile_provider.dart
      pages/
        profile_page.dart
      widgets/
        avatar_section.dart
        stats_cards.dart
        settings_list.dart
```

### Data Flow

```
Page → Riverpod Provider/AsyncNotifier → Feature ApiService → ApiClient (JWT) → HTTP → Backend
```

- Pages never call HTTP directly.
- Each feature has its own `api/*.dart` with typed request/response methods.
- Riverpod `AsyncNotifierProvider` handles loading/error/data states.
- `supabase_flutter` SDK manages auth session; `ApiClient` reads JWT from it.
- `GoRouter` with `ShellRoute` for persistent navigation.

---

## 2. Navigation & Routing

### Route Map

```
PUBLIC (outside ShellRoute)
  /                      → Splash → auto-redirect
  /onboarding            → 3-step feature intro
  /login                 → Email/password login
  /register              → Email/password signup

MAIN SHELL (persistent bottom nav / sidebar)
  /home                  → Dashboard tab
  /discover              → Recipe Discovery tab
  /library               → Saved Recipes tab
  /xp                    → XP & Achievements tab
  /profile               → Profile & Settings tab

COOKING FLOW (full-screen, no bottom nav)
  /ingredients           → Manual ingredient entry
  /scan                  → Camera ingredient scanner
  /preferences           → Cuisine, servings, time limit
  /generate              → AI generation loading state
  /recipes/:id           → Recipe detail
  /voice-cooking/:id     → Hands-free voice mode
  /complete/:id          → Completion + XP celebration

AI
  /chat/:sessionId       → Poco AI assistant

PRODUCTIVITY
  /meal-planner          → Weekly calendar
  /shopping-list         → Auto-generated list
```

### Startup Redirect Logic

1. Splash plays → check `supabase_flutter` session
2. No session + first visit → `/onboarding`
3. No session + returning → `/login`
4. Has session → `/home`

### Adaptive Shell

- Mobile (< 768px): `BottomNavigationBar` with 5 tabs
- Tablet (768–1024px): `NavigationRail`
- Desktop (> 1024px): Sidebar navigation
- Same `ShellRoute` delegate — child widget stays, shell swaps.

---

## 3. Data Layer & API Integration

### API Client (`core/api/api_client.dart`)

- Wraps `http` package
- Constructor takes Supabase session token
- Injects `Authorization: Bearer <jwt>` on every request
- Base URL from build config / `.env`
- All responses parsed to typed models
- Errors mapped to domain exceptions

### Feature API Services

| Feature | Service Class | Methods |
|---------|--------------|---------|
| Recipes | `RecipesApi` | `generateRecipes(req)`, `saveRecipe(dish)`, `listRecipes(bookmarked?)`, `getRecipe(id)`, `setBookmark(id, bool)`, `deleteRecipe(id)` |
| Chat | `ChatApi` | `sendMessage(sessionId, message)`, `getHistory(sessionId)` |
| XP | `XpApi` | `completeRecipe(recipeId)` |
| Meal Plans | `MealPlanApi` | `upsertSlot(req)`, `listSlots(start, end)`, `deleteSlot(id)` |

### Models (`core/models/`)

Matching backend Pydantic schemas exactly:

```dart
class Ingredient { String name, quantity, unit }
class Step { int number, instruction }
class Dish { String title, cuisine, imagePromptKey; int cookTimeMinutes, servings; List<Ingredient>; List<Step> }
class RecipeResponse { List<Dish> dishes }
class SavedRecipe { String id, userId; Dish dish; bool bookmarked; String status; DateTime createdAt }
class ChatMessage { String role, content }
class ChatReply { String sessionId, reply }
class CompletionResult { String recipeId; int xp, level, xpAwarded }
class MealPlanEntry { String id, userId, planDate, slot, recipeId; DateTime createdAt }
class MealPlanRequest { String planDate, slot, recipeId }
```

All with `fromJson`/`toJson`. `SavedRecipe.dish` decoded from JSONB inline.

---

## 4. Design System (Pixel-Perfect from Stitch HTML)

### Colors (`core/theme/app_colors.dart`)

```dart
static const surface              = Color(0xFFFCF9F8);
static const surfaceDim           = Color(0xFFDCD9D9);
static const surfaceBright        = Color(0xFFFCF9F8);
static const surfaceContainerLowest = Color(0xFFFFFFFF);
static const surfaceContainerLow  = Color(0xFFF6F3F2);
static const surfaceContainer     = Color(0xFFF0EDED);
static const surfaceContainerHigh = Color(0xFFEAE7E7);
static const surfaceContainerHighest = Color(0xFFE4E2E1);
static const onSurface            = Color(0xFF1B1C1C);
static const onSurfaceVariant     = Color(0xFF594139);
static const inverseSurface       = Color(0xFF303030);
static const inverseOnSurface     = Color(0xFFF3F0F0);
static const outline              = Color(0xFF8D7168);
static const outlineVariant       = Color(0xFFE1BFB5);
static const surfaceTint          = Color(0xFFAB3500);
static const primary              = Color(0xFFAB3500);
static const onPrimary            = Color(0xFFFFFFFF);
static const primaryContainer     = Color(0xFFFF6B35);
static const onPrimaryContainer   = Color(0xFF5F1900);
static const inversePrimary       = Color(0xFFFFB59D);
static const primaryFixed         = Color(0xFFFFDBD0);
static const primaryFixedDim      = Color(0xFFFFB59D);
static const onPrimaryFixed       = Color(0xFF390C00);
static const onPrimaryFixedVariant= Color(0xFF832600);
static const secondary            = Color(0xFF006E1C);
static const onSecondary          = Color(0xFFFFFFFF);
static const secondaryContainer   = Color(0xFF91F78E);
static const onSecondaryContainer = Color(0xFF00731E);
static const secondaryFixed       = Color(0xFF94F990);
static const secondaryFixedDim    = Color(0xFF78DC77);
static const onSecondaryFixed     = Color(0xFF002204);
static const onSecondaryFixedVariant = Color(0xFF005313);
static const tertiary             = Color(0xFF5E5F5C);
static const tertiaryContainer    = Color(0xFF9A9A96);
static const onTertiaryContainer  = Color(0xFF313230);
static const tertiaryFixed        = Color(0xFFE3E2DF);
static const tertiaryFixedDim     = Color(0xFFC7C7C3);
static const onTertiaryFixed      = Color(0xFF1B1C1A);
static const onTertiaryFixedVariant = Color(0xFF464744);
static const background           = Color(0xFFFCF9F8);
static const onBackground         = Color(0xFF1B1C1C);
static const error                = Color(0xFFBA1A1A);
static const onError              = Color(0xFFFFFFFF);
static const errorContainer       = Color(0xFFFFDAD6);
static const onErrorContainer     = Color(0xFF93000A);
static const mascotTipBg          = Color(0xFFFFF7F2);
```

### Typography (`core/theme/app_typography.dart`)

| Token | Size | Height | Spacing | Weight | Family |
|---|---|---|---|---|---|
| display | 48 | 56 | -0.02em | 700 | Plus Jakarta Sans |
| headline-lg | 32 | 40 | -0.01em | 600 | Plus Jakarta Sans |
| headline-lg-mobile | 28 | 36 | -0.01em | 600 | Plus Jakarta Sans |
| headline-md | 24 | 32 | 0 | 600 | Plus Jakarta Sans |
| body-lg | 18 | 28 | 0.01em | 400 | Inter |
| body-md | 16 | 24 | 0 | 400 | Inter |
| label-md | 14 | 20 | 0.05em | 600 | Inter |
| caption | 12 | 16 | 0 | 400 | Inter |

### Shadows (`core/theme/app_shadows.dart`)

```dart
card           = BoxShadow(0, 10, 30, rgba(45,45,45,0.05))
bottomNav      = BoxShadow(0, -10, 30, rgba(45,45,45,0.05))
onboardingCard = BoxShadow(0, 10, 30, rgba(45,45,45,0.05))
mascotCard     = BoxShadow(0, 20, 50, rgba(171,53,0,0.08))
vibrantButton  = BoxShadow(0, 4, 0, Color(0xFF832600))
voiceNextBtn   = BoxShadow(0, 10, 30, rgba(171,53,0,0.2))
sheet          = BoxShadow(0, -20, 50, rgba(0,0,0,0.1))
glowOrange     = BoxShadow(0, 0, 20, rgba(255,107,53,0.15))
progressGlow   = BoxShadow(0, 0, 15, rgba(255,107,53,0.4))
```

### Radius (`core/theme/app_radius.dart`)

- Cards: 12px
- Buttons: pill (stadium)
- Small elements/chips: 8px
- Feature cards (onboarding): 24px
- Chat bubbles: 16px + 4px asymmetric corner
- Scanner sheet top: 32px
- Bottom nav top: 12px

### Spacing (`core/theme/app_spacing.dart`)

```dart
unit = 8.0; containerPadding = 24.0; gutter = 16.0;
stackSm = 8.0; stackMd = 16.0; stackLg = 32.0; stackXl = 64.0;
```

### Shared Widget Inventory

| Widget | File | Description |
|--------|------|-------------|
| `PocoAppBar` | `core/design_system/widgets/poco_app_bar.dart` | Sticky header: avatar + Poco branding + notification bell |
| `PocoGlassAppBar` | Same file | Blurred variant for recipe detail |
| `RecipeCard` | `recipe_card.dart` | 280px min, h-48 image, time chip top-right, title + desc |
| `DiscoveryCard` | `recipe_card.dart` | h-64 image, star rating, match %, time + difficulty |
| `PocoMascotTip` | `poco_mascot_tip.dart` | #FFF7F2 bg, white circle avatar, "Poco's Pro-Tip" + text |
| `PocoBottomNav` | `poco_bottom_nav.dart` | 5 tabs, FILL=1 active, primary color |
| `PocoFab` | `poco_fab.dart` | 64px circle, primary, bolt icon, bottom-24 right-6 |
| `TactileButton` | `tactile_button.dart` | 2px bottom border #832600, translateY(2) on press |
| `IngredientChip` | `ingredient_chip.dart` | primary/10 bg, primary border, close icon |
| `FilterChip` | `filter_chip.dart` | active=primary-container, inactive=surface-container |
| `TimeChip` | `time_chip.dart` | white/90 bg, blurred, text-[12px], top-right position |
| `ChatBubbleAi` | `chat_bubble.dart` | surface-container-lowest bg, 4px bottom-left |
| `ChatBubbleUser` | `chat_bubble.dart` | primary bg, 4px bottom-right |
| `XpProgressRing` | `xp_progress_ring.dart` | SVG ring with offset dasharray |
| `MealPlanDay` | `meal_plan_day.dart` | 64x80 rounded-xl, active=primary-fixed + dot indicator |
| `MealCard` | `meal_card.dart` | h-32 image, swap button on hover, title + kcal |
| `ScannerViewfinder` | `scanner_viewfinder.dart` | Camera overlay + scan line + AI bounding boxes |
| `OnboardingStep` | `onboarding_step.dart` | Animated slide transitions |
| `DifficultyButton` | `difficulty_button.dart` | Pill, active=border-2 primary |
| `CuisineCard` | `cuisine_card.dart` | Icon + label, active=border-primary + #FFF7F2 |
| `PreferenceRadio` | `preference_radio.dart` | Card-style radio |
| `ServingsSlider` | `servings_slider.dart` | Custom thumb (28px, #ab3500), 4px white border |
| `ShoppingListTile` | `shopping_list_tile.dart` | Checkbox + name + quantity |
| `AchievementCard` | `achievement_card.dart` | Bento grid, colored icon circle |
| `ActivityItem` | `activity_item.dart` | Icon + title + XP + timestamp |

---

## 5. Feature Breakdown

### 5.1 Splash & Authentication (`features/auth/`)

- **Splash:** Poco logo + tagline, 2.5s fade → redirect
- **Onboarding:** 3 steps (Welcome → AI Scanning → Voice Cooking) with slide transitions, step indicator
- **Login:** Email/password form, validation, supabase auth
- **Register:** Email/password + name, supabase signup
- **Success Modal:** "You're all set!" with mascot pro-tip
- **States:** splash animation, step transitions, form validation, loading spinner, auth error
- **API:** `supabase_flutter` — `signInWithPassword()`, `signUp()`

### 5.2 Home Dashboard (`features/home/`)

- Greeting with time-of-day variant + chef name
- Hero card with AI-recommended recipe, mascot illustration, "Start Cooking" button
- Seasonal Discoveries: horizontal scroll (snap, 280px cards, hover scale)
- Quick Scanned Recipes: 2-column bento grid (scan card + filter tiles)
- Mascot Pro-Tip box
- FAB (bolt icon)
- Bottom nav (Home active)
- **States:** skeleton loading, recommendations loaded, empty
- **API:** `GET /recipes?bookmarked=` for recent picks

### 5.3 Ingredient Scanner (`features/ingredient_scanner/`)

- Camera viewfinder with animated scan line (`#ff6b35` glow, 3s loop)
- AI bounding boxes with pulsing border
- Bottom sheet: drag handle, manual input (bottom-border, focus→primary glow), ingredient chips, "Generate Recipes" button (primary + shine effect)
- **States:** camera loading, ingredients detected, manual input, sheet collapsed/expanded
- **API:** `POST /recipes/generate` with base64 image + typed ingredients

### 5.4 Preferences & Cuisine (`features/preferences/`)

- Cuisine cards: icon + label, active = primary border + #FFF7F2 bg
- Difficulty pills: Beginner/Intermediate/Advanced
- Time limit radio cards: Under 15m / 30m / 60m / No limit
- Servings slider: 1–20, custom thumb 28px, #ab3500
- **States:** selection tracking, validation
- **API:** Passes selections to `POST /recipes/generate`

### 5.5 AI Recipe Generation (`features/recipe_generation/`)

- Full-screen mascot + animated progress bars
- `box-shadow: 0 20px 50px rgba(171,53,0,0.08)` on mascot card
- **States:** generating (progress), success (auto-navigate to discovery), error (retry)
- **API:** `POST /recipes/generate`

### 5.6 Recipe Discovery (`features/recipe_discovery/`)

- Filter chips row (All Recipes, Quick Bites, Low Carb...)
- Grid: discovery cards (h-64 image, rating, match %, time, difficulty)
- Asymmetric hero card (Chef's Choice): 3/5 image + 2/5 content
- "Generate New" FAB
- Desktop: sidebar layout with filters
- **States:** loading grid, populated, empty
- **API:** Displays `RecipeResponse.dishes` from generation

### 5.7 Recipe Detail (`features/recipe_detail/`)

- Hero image with glass header (blur 8px, `rgba(252,249,248,0.8)`)
- Stats row: time, servings, difficulty, nutrition
- Tag pills: High Fiber, Vegan
- Ingredient list with servings rescaling
- Steps with numbered cards
- AI Pro-Tip box
- Bottom bar: "Start Cooking" + bookmark + share
- **States:** loading, loaded, rescaling
- **API:** `GET /recipes/{id}`, `PATCH /recipes/{id}/bookmark`

### 5.8 Recipe Library (`features/recipe_library/`)

- Search bar (bottom-border style, search icon)
- Filter chips
- Asymmetric grid (16:9 featured, square for rest)
- Bookmark icon
- **States:** loading, populated, empty, search results
- **API:** `GET /recipes`, `DELETE /recipes/{id}`

### 5.9 Poco AI Assistant (`features/poco_chat/`)

- Header: mascot avatar, "Poco AI", green "Ready to help" dot
- Welcome card centered
- Chat bubbles: AI = surface-container-lowest, user = primary, 4px asymmetric corners
- Suggestion chips row
- Bottom input bar: add_circle + text input + send button
- **States:** loading history, streaming reply, error
- **API:** `POST /chat`, `GET /chat/{sessionId}`

### 5.10 Voice Cooking Mode (`features/voice_cooking/`)

- Header: "Voice Mode" label + settings gear
- Current step: large step number, title, description
- Two-button layout: Repeat (surface-container-highest) + Next (primary + shadow)
- Recipe summary card
- Pro-Tip positioned above nav
- **States:** listening, speaking, paused, completed
- **API:** Reads recipe steps from saved recipe; `speech_to_text` package

### 5.11 Cooking Completion & XP (`features/cooking_completion/`)

- Animated progress bar (primary-container + glow)
- Confetti: 5 colors (`#ff6b35`, `#ab3500`, `#ffdbd0`, `#006e1c`, `#78dc77`)
- XP earned + level progress card
- Social share buttons
- "Back to Home"
- **States:** animating, done
- **API:** `POST /completions`

### 5.12 XP & Achievements (`features/xp_achievements/`)

- SVG progress ring: stroke-dasharray on surface-variant bg, primary arc
- Level display
- Bento grid: achievement cards (rounded-2xl, colored circles per rarity)
- Activity feed: icon + title + XP + timestamp
- **States:** loading, populated
- **API:** `POST /completions` returns XP/level

### 5.13 Meal Planner (`features/meal_planner/`)

- Horizontal day selector: 64x80 rounded-xl, active = primary-fixed + `#ab3500` dot
- Meal slots: Breakfast/Lunch/Dinner/Snack with recipe cards (h-32, swap on hover)
- Empty slot: dashed border + add button
- Smart suggestions: blurred cards with "Uses 4 of your items"
- Shopping cart FAB with hover tooltip
- **States:** week loaded, empty slots, suggestions loading
- **API:** `GET /meal-plans`, `POST /meal-plans`, `DELETE /meal-plans/{id}`

### 5.14 Shopping List (`features/shopping_list/`)

- Items grouped by category
- Each: checkbox + name + quantity, strikethrough when checked
- **States:** loading, populated, empty, all checked
- **API:** Aggregated from meal plan entries

### 5.15 Profile & Settings (`features/profile_settings/`)

- Avatar (large circle) + name + level
- Stats cards: recipes cooked, total time, XP
- Settings: Dietary Preferences, Meal Planning, Notifications → toggles (primary checked, surface-variant unchecked)
- Theme toggle (light/dark)
- Logout
- **States:** loading, editing
- **API:** `supabase_flutter` profiles table

---

## 6. Packages

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.0
  go_router: ^14.0.0
  supabase_flutter: ^2.5.0
  http: ^1.2.0
  image_picker: ^1.0.0
  speech_to_text: ^6.6.0
  google_fonts: ^6.1.0
  intl: ^0.19.0
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  riverpod_generator: ^2.4.0
  build_runner: ^2.4.0
```

---

## 7. Missing Assets / Unclear Interactions

### Identified Gaps

- **Mascot illustrations:** Stitch uses `lh3.googleusercontent.com/aida-public/...` URLs for the red panda. Need final SVG/PNG assets bundled in `assets/images/`.
- **Food photography:** All Stitch screens use placeholder Google-hosted URLs. Need actual food images for recipe cards.
- **Confetti animation:** Described visually in Stitch but no code implementation — needs custom `confetti` widget or `confetti` package.
- **Camera integration:** Stitch shows camera UI with viewfinder + scan line — actual camera access needs `image_picker` or `camera` package, plus permission handling.
- **Speech-to-text on desktop:** `speech_to_text` package may have limited desktop support — fallback to keyboard input for desktop.
- **Notification bell:** Tapped in Stitch but no notification screen exists — could open profile settings or a future notifications page.
- **Theme toggle:** Shown in Profile — needs `DynamicTheme` Riverpod provider + dark mode variant of all colors.

---

## 8. Responsive Adaptation

- **Mobile (< 768px):** Single column, 24px margins, bottom nav bar
- **Tablet (768–1024px):** Two-column grid, NavigationRail
- **Desktop (> 1024px):** Multi-column, fixed sidebar 320px, 12-column grid
- Cooking flow: always full-screen regardless of device
- Recipe detail: side-by-side ingredients + steps on desktop
- Meal planner: horizontal day selector + multi-column grid on desktop
