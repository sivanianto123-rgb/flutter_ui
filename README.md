# Daily Flutter UI Screens

A running collection of Flutter (and the occasional web) UI screens I design
and build for practice — pixel-perfect layouts, animation practice, and
Figma-to-Flutter implementation.

**Live gallery:** https://sivanianto123-rgb.github.io/flutter_ui/

## How the gallery works

There's no build step. `index.html` reads this repo's structure live via the
GitHub API and turns every project folder into a card, so adding a new one
is just:

1. Create a new folder at the repo root (or inside `daily_screens/`) with a
   normal `flutter create` scaffold — anything with a `pubspec.yaml` is
   picked up automatically.
2. Optional but recommended: drop a screenshot of the running screen
   directly in that folder's root (e.g. `screenshot.png`, or whatever
   DevTools names it) — the gallery uses the first image file it finds
   sitting directly in the project root as the card's thumbnail. Without
   one, the card falls back to a plain color tile.
3. Commit and push to `main`. The gallery updates automatically — nothing
   else to run or redeploy.

`reading_app/` (the Coreillustrio phonics-app drafts) is intentionally
excluded from the public gallery — that project has its own case study on
the [portfolio site](https://sivanianto123-rgb.github.io/flutter_protfolio/).
