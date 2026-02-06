# flutter_application_1

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Auth Screens

This project includes simple authentication UI screens:

- Signup screen: [lib/screens/signup_screen.dart](lib/screens/signup_screen.dart)
	- Name, email, and password fields with validation.
	- Persists credentials via a callback and supports loading/error states.
- Signin screen: [lib/screens/login_screen.dart](lib/screens/login_screen.dart)
	- Email and password fields with validation.
	- Navigates to signup and supports loading/error states.
