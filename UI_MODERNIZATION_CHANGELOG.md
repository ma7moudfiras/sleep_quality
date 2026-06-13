# Sleep Quality UI Modernization Patch

## Scope
This patch improves the visual presentation of the Flutter user-facing screens without changing the API contract, backend routes, database schema, or machine-learning logic.

## Updated Flutter Areas
- Modern Material 3 theme with softer surfaces, richer gradients, improved cards, buttons, chips, sliders, snackbars, and navigation.
- Responsive shell:
  - Mobile: bottom NavigationBar with selected labels.
  - Wide screens: NavigationRail and centered content width.
- Shared visual components:
  - `ScreenHeader`
  - `MetricTile`
  - `EnergyBadge`
  - `GradientPanel`
  - `InfoBullet`
  - `ModernEmptyState`
- Log screen:
  - Gradient header.
  - Live metric preview cards.
  - Modern date/time controls.
  - Better mood/activity sliders.
- History screen:
  - Timeline-like cards.
  - Color-coded prediction/energy badges.
  - Feedback buttons with visual energy icons.
- Insights screen:
  - Smart analytics card grid.
  - Recommendation panel.
  - Cleaner weekly report facts.
- Charts screen:
  - Improved chart cards.
  - Colored trends and shaded line areas.
  - Empty-state polish.
- Prediction screen:
  - High-impact prediction panel.
  - Confidence progress bar.
  - Better explanation and tip presentation.
- What-if screen:
  - Scenario builder layout.
  - Modern result card with energy coloring.

## Backend
No backend changes in this patch.

## Notes
Run from `frontend`:

```powershell
flutter clean
flutter pub get
flutter analyze
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8010
```
