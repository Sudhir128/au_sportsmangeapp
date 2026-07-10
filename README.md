# AU Sports Management App

A Flutter app for Anna University students to **create profiles**, **host sports rooms**, and **join games** — similar to TurfTown, built with Flutter and Supabase.

## Features

- User registration, login, and password reset
- Player profile with roll number and contact details
- Create public/private sports rooms (Cricket, Football, Basketball, and more)
- Browse and join open rooms by sport
- View hosted and joined rooms with member list
- Campus announcements and events gallery

## Tech Stack

- Flutter (Android, iOS, Web, Windows)
- Supabase (PostgreSQL + REST API)
- Shared Preferences (session persistence)

## Getting Started

### 1. Restore Supabase (required)

Your old Supabase project is paused. Create a **new Supabase project**, then:

1. Open **SQL Editor** in the Supabase dashboard
2. Run the script in [`supabase/schema.sql`](supabase/schema.sql)
3. Optionally import data from your backup (`db_cluster-09-09-2024@11-15-36.backup`) using `pg_restore` or by copying the `COPY` data for `user`, `room`, and `users_in_rooms` tables
4. Update credentials in [`lib/config/supabase_config.dart`](lib/config/supabase_config.dart):

```dart
static const url = 'https://YOUR_PROJECT.supabase.co';
static const anonKey = 'YOUR_ANON_KEY';
```

### 2. Run the app

```bash
flutter pub get
flutter run
```

For web:

```bash
flutter run -d chrome
```

For Android:

```bash
flutter run -d android
```

## Project Structure

```
lib/
  config/          # Supabase credentials
  services/        # Auth, session, and room logic
  theme/           # App-wide Material theme
  widgets/         # Shared UI components
  pages/           # Screens (login, rooms, events, etc.)
  images/          # App assets
  events/          # Event posters
  announcements/   # Announcement images
supabase/
  schema.sql       # Database setup for new Supabase project
```

## Test Login

After restoring your database backup, you can sign in with any user from the `user` table, for example:

- Email: `sudhirgm128@gmail.com`
- Roll: `2021242020`
- Password: (as stored in your backup)

## Notes

- Authentication uses a custom `user` table (not Supabase Auth). Session is stored locally after login.
- Row Level Security policies in `schema.sql` allow the anon key to read/write — tighten these before production.
- Passwords are stored in plain text in the legacy schema. Consider hashing passwords before going live.
