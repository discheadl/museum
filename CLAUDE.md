# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A museum/gallery exhibition app — Flutter frontend + Node.js Express backend. UI text and comments are in Spanish.

## Commands

### Flutter (frontend)

```bash
flutter pub get                  # Install dependencies
flutter analyze                  # Lint
flutter test                     # Run all tests
flutter test test/widget_test.dart  # Run a single test file

# Run with API URL (required)
flutter run --dart-define=MUSEUM_API_BASE_URL=http://localhost:4000

# Android emulator uses a different loopback address
flutter run --dart-define=MUSEUM_API_BASE_URL=http://10.0.2.2:4000
```

### Node.js API (backend)

```bash
cd api
npm install
npm run dev    # Development with file watching
npm start      # Production
```

The API runs on port 4000 by default (override with `PORT` env var).

## Architecture

### Flutter frontend (`lib/`)

Follows a **Repository pattern** with dependency injection at the root:

- **`app/museum_app.dart`** — Root widget; constructs and injects the `MuseumRepository` implementation into the widget tree.
- **`services/museum_repository.dart`** — Abstract interface; swap implementations for testing (`DemoMuseumRepository`) vs. production (`MuseumApiService`).
- **`services/museum_api_service.dart`** — HTTP client; selects base URL based on platform (Android: `10.0.2.2`, others: `localhost`) unless `MUSEUM_API_BASE_URL` is set at compile time.
- **`models/museum_models.dart`** — `MuseumRoom`, `MuseumExhibit`, `MuseumMediaType` (image | video).
- **`features/home/`** — Room carousel (`HomeScreen` + `RoomCard`).
- **`features/room/`** — Exhibit detail view (`RoomScreen` + `ExhibitThumbnail`).
- **`widgets/museum_art_panel.dart`** — Reusable media panel handling both image and video (`video_player`).
- **`data/demo_museum.dart`** — In-memory stub used in widget tests.

The app is locked to **landscape orientation** (set in `main.dart`).

### Node.js API (`api/`)

Simple Express app (ES Modules):

- **`src/server.js`** — Entry point; registers CORS, static `/media/` serving, and routes.
- **`src/data/museum-data.js`** — Hardcoded museum rooms and exhibits data.
- `GET /api/rooms` — Returns all rooms with nested exhibits.
- `GET /api/health` — Health check.
- Static media is served from `api/public/media/`.

### Theme

`MuseumTheme` uses Material Design 3 with seed color `#7F5539` (wood brown), background `#F3EEE6` (cream), and text `#1F1B16` (dark brown).
