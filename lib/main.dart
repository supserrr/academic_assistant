import 'package:flutter/material.dart';

import 'app.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'services/shared_preferences_storage.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const AcademicAssistantApp());
}

/// Root widget: shows login/signup or AppShell based on auth state from storage.
class AcademicAssistantApp extends StatelessWidget {
  const AcademicAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Academic Assistant',
      theme: AppTheme.theme,
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  final SharedPreferencesStorageService _storage = SharedPreferencesStorageService();

  bool? _isLoggedIn;
  String? _studentName;
  bool _showSignup = false;

  @override
  void initState() {
    super.initState();
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    final loggedIn = await _storage.getIsLoggedIn();
    final name = await _storage.getStudentName();
    if (mounted) {
      setState(() {
        _isLoggedIn = loggedIn;
        _studentName = name;
      });
    }
  }

  void _onLoginSuccess() {
    _loadAuthState();
  }

  void _onSignupSuccess() {
    _loadAuthState();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_isLoggedIn == true) {
      return AppShell(studentName: _studentName);
    }
    if (_showSignup) {
      return SignupScreen(
        onSignupSuccess: _onSignupSuccess,
        onNavigateToLogin: () => setState(() => _showSignup = false),
        saveCredentials: _storage.saveCredentials,
      );
    }
    return LoginScreen(
      onLoginSuccess: _onLoginSuccess,
      onNavigateToSignup: () => setState(() => _showSignup = true),
      validateLogin: _storage.validateLogin,
    );
  }
}
