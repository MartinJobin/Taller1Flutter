// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'CINESTREAM';

  @override
  String get loginSubtitle => 'Enjoy your favorite movies';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get loginWithEmail => 'SIGN IN WITH EMAIL';

  @override
  String get continueWithGoogle => 'CONTINUE WITH GOOGLE';

  @override
  String get noAccount => 'Don\'t have an account? ';

  @override
  String get register => 'Sign up';

  @override
  String get selectLanguage => 'Select language';

  @override
  String get spanish => 'Spanish';

  @override
  String get english => 'English';

  @override
  String get language => 'Language';

  @override
  String get enterCredentials => 'Enter your email and password';

  @override
  String get welcome => 'Welcome!';

  @override
  String get invalidEmail => 'The email is not valid';

  @override
  String get invalidCredentials => 'Incorrect email or password';

  @override
  String get networkError => 'Check your internet connection';

  @override
  String get tooManyAttempts => 'Too many attempts. Try again later';

  @override
  String get userDisabled => 'This account is disabled';

  @override
  String get unexpectedError => 'An unexpected error occurred';

  @override
  String get googleError => 'Error signing in with Google';

  @override
  String get search => 'Search';

  @override
  String get scanQr => 'Scan QR code';

  @override
  String get addMovie => 'Add movie';

  @override
  String get profile => 'My profile';

  @override
  String get logout => 'Log out';

  @override
  String get logoutQuestion => 'Do you want to log out?';

  @override
  String get cancel => 'Cancel';

  @override
  String get moviesLoadError => 'Error loading movies';

  @override
  String get noMovies => 'No movies available';

  @override
  String get addFirstMovie => 'Add your first movie to display it in the catalog';

  @override
  String get all => 'All';

  @override
  String get noResults => 'No results found';

  @override
  String get clear => 'Clear';

  @override
  String get back => 'Back';
}
