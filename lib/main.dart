import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'screens/login_screen.dart';
import 'services/language_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final LanguageService languageService = LanguageService();

  await languageService.cargarIdioma();

  runApp(
    MyApp(
      languageService: languageService,
    ),
  );
}

class MyApp extends StatefulWidget {
  final LanguageService languageService;

  const MyApp({
    super.key,
    required this.languageService,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    widget.languageService.addListener(_actualizarIdioma);
  }

  void _actualizarIdioma() {
    setState(() {});
  }

  @override
  void dispose() {
    widget.languageService.removeListener(_actualizarIdioma);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CINESTREAM',

      locale: widget.languageService.locale,

      localizationsDelegates:
          AppLocalizations.localizationsDelegates,

      supportedLocales:
          AppLocalizations.supportedLocales,

      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.dark,
        ),
      ),

      home: LoginScreen(
        languageService: widget.languageService,
      ),
    );
  }
}