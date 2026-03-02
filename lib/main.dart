import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Style the system UI
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0F0F0F),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const SpeechSyncApp());
}

class SpeechSyncApp extends StatelessWidget {
  const SpeechSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..loadProStatus()..loadSettings(),
      child: MaterialApp(
        title: 'SpeechSync',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        initialRoute: AppRouter.welcome,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
