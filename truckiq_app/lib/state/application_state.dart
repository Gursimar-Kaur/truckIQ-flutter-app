import 'package:flutter/material.dart';
import 'package:truckiq_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
    _loadTheme();
  }
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;
  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  // A simple bool that tracks whether or not a user is logged in
  var _loggedIn = false;
  bool get loggedIn => _loggedIn;

  // Initialize connection to firebase, and configure firebase auth settings/listeners
  Future<void> init() async {
    // This connects us to firebase before starting the app
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Configure ui auth provider to tell it to allow email auth
    FirebaseUIAuth.configureProviders([EmailAuthProvider()]);

    // Whenever the auth user state changes (login or logout)
    // We will notify all listeners of that change
    FirebaseAuth.instance.userChanges().listen((user) {
      // if the user is logged out user will be null
      if (user == null) {
        _loggedIn = false;
      } else {
        _loggedIn = true;
      }

      notifyListeners();
    });
  }
}
