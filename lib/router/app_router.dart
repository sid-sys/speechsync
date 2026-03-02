import 'package:flutter/material.dart';
import '../screens/welcome/welcome_screen.dart';
import '../screens/shell/main_shell.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/pricing/pricing_page.dart';
import '../screens/notes/note_detail_screen.dart';
import '../models/note_model.dart';

class AppRouter {
  static const String welcome = '/';
  static const String home = '/home';
  static const String history = '/history';
  static const String profile = '/profile';
  static const String pricing = '/pricing';
  static const String noteDetail = '/note-detail';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const MainShell(initialIndex: 0));
      case history:
        return MaterialPageRoute(builder: (_) => const MainShell(initialIndex: 1));
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case pricing:
        return MaterialPageRoute(builder: (_) => const PricingPage());
      case noteDetail:
        final note = settings.arguments as NoteModel;
        return MaterialPageRoute(builder: (_) => NoteDetailScreen(note: note));
      default:
        return null;
    }
  }
}
