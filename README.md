# academic_assistant

A Flutter app for ALU students to manage assignments, track their schedule, and monitor attendance. The UI is built with Material Design; data persists across app restarts using shared_preferences and JSON.

## Purpose

- **Assignments:** Create items with title, due date, course name, and optional priority; view a list sorted by due date; mark complete, edit, or remove. This corresponds to creating “tasks” with title, date, and metadata, and displaying them in a list.
- **Schedule:** Create academic sessions (title, date, start/end time, optional location, type: Class, Mastery Session, Study Group, PSL Meeting); view sessions by date; record Present/Absent per session; edit or remove. Sessions are linked to calendar days and shown on the dashboard for “today.”
- **Dashboard:** Shows today’s date and academic week, today’s sessions (linked to the current day), assignments due in the next 7 days (highlighted), attendance percentage, and an “AT RISK” warning when attendance is below 75%.

## Architecture

- **Entry:** `lib/main.dart` – `MaterialApp` with theme; `AuthGate` shows login/signup until authenticated, then shows `AppShell` with the main content.
- **Shell:** `lib/app.dart` – `AppShell` is a `StatefulWidget` that holds the bottom navigation index and the lists of assignments and sessions (single source of truth). It loads data from storage in `initState` and saves after every add/update/remove/toggle. The body is an `IndexedStack`: we show one of three screens (Dashboard, Assignments, Schedule) based on the selected index. Each screen receives copies of the lists and callbacks to mutate; the shell updates state and then persists.
- **Screens (UI):** `lib/screens/` – `dashboard_screen.dart`, `assignments_screen.dart`, `schedule_screen.dart`, plus `login_screen.dart` and `signup_screen.dart`. UI is separated from business logic: screens use `ListView`/`ListTile` for lists, `Padding` for spacing, `AppBar` for structure, and dialogs for add/edit forms.
- **Models (data):** `lib/models/` – `assignment.dart` and `academic_session.dart`. Both have `toJson`/`fromJson` for serialization and `copyWith` for immutable updates.
- **Storage (persistence):** `lib/services/storage_service.dart` defines the interface; `lib/services/shared_preferences_storage.dart` implements it by saving/loading JSON strings under keys. On startup the shell loads assignments and sessions; after each mutation it writes them back so data persists after restart.
- **Theme:** `lib/theme/app_theme.dart` – ALU colors and `ThemeData`; used for consistent Material Design across the app.

## How to run

From the project root:

```bash
flutter pub get
flutter run
```

See `docs/setup.md` for requirements and build commands.

## Assignment criteria mapping

- **Core features (step-by-step):**  
  (a) Creating items with title, date, and metadata – implemented as assignments (title, due date, course, priority) and sessions (title, date, time, type, location).  
  (b) Displaying “today’s” items in a list – dashboard shows today’s sessions and assignments due in the next 7 days.  
  (c) Linking items to calendar days and highlighting – sessions are stored with a date and shown on the dashboard for today; assignments are filtered by due date and shown with “Due today” / “Due tomorrow” badges.  
  (d) No reminder popup in this version; persistence and list/calendar behaviour are covered.

- **Bottom navigation:** Implemented by adding a `BottomNavigationBar` to the `Scaffold` in `app.dart`, defining three screens (Dashboard, Assignments, Schedule), and using `IndexedStack` with `_currentIndex` so the body switches based on the selected tab. The selected index is kept in state and updated in `onTap`.

- **UI (Material Design):** ListView for scrollable lists (assignments, sessions), ListTile-like cards for each entry, Padding for spacing, AppBar for title and structure. Theme and colors are centralized in `app_theme.dart`.

- **Persistence:** (a) Storage method: `SharedPreferencesStorageService` uses the shared_preferences plugin.  
  (b) Saving: assignments and sessions are converted to JSON via `toJson`, encoded as a string, and stored under keys `assignments` and `sessions`.  
  (c) Retrieval at startup: `_loadData()` in `AppShell.initState` calls `loadAssignments()` and `loadSessions()`, which read the strings, decode JSON, and map to `Assignment`/`AcademicSession` with `fromJson`.  
  (d) Data persists after restart because we load in initState and save after every mutation.

More detail is in `docs/architecture.md`, `docs/overview.md`, and `docs/setup.md`.
