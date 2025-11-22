AU Sports Management App

A Flutter-based mobile application designed for managing sports rooms, events, announcements, and user participation within the AU campus environment.
This app allows students to create and join sports rooms, check available rooms, view announcements, register/login securely, and manage events — all in a streamlined UI.

Features
Authentication
User Login & Signup
Password Reset
Secure form validation

Sports Room Management
Create a new sports room
Join existing rooms
View your rooms
Check all available rooms

Announcements & Events
View sports-related announcements
Browse upcoming & past events

Folder Details
1️ announcements/
Contains widgets or models related to sports news and announcements.

2️ events/
Handles event listing, event details, and event UI components.

3️ images/
Stores app assets (PNG/JPG/SVG icons, logos, illustrations).

5️ widgets/
Reusable custom widgets used across the app (buttons, cards, forms, etc.).

6️ main.dart
Entry point of the application, containing providers, route setup, and initialization.

Announcement.dart
Displays all sports-related announcements fetched from the backend or local data.

availablerooms.dart
Shows all sports rooms currently available
Includes backend data fetching

createroom.dart
UI for creating a new sports room
Includes form validation and improved readability

joinroom.dart
Lets users join available rooms

loadpage.dart
Initial loading screen

login.dart
Login page UI
Supabase/Auth service integration

myApp_materialPage.dart
Main MaterialApp widget
Contains theme, routing, and navigation setup

myrooms.dart
Displays rooms created or joined by the user
Shows room info, participants, join status, etc.

Tech Stack
Flutter (Dart)
Supabase
