// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'CINESTREAM';

  @override
  String get loginSubtitle => 'Disfruta tus películas favoritas';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get loginWithEmail => 'INGRESAR CON EMAIL';

  @override
  String get continueWithGoogle => 'CONTINUAR CON GOOGLE';

  @override
  String get noAccount => '¿No tienes cuenta? ';

  @override
  String get register => 'Regístrate';

  @override
  String get selectLanguage => 'Seleccionar idioma';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'English';

  @override
  String get language => 'Idioma';

  @override
  String get enterCredentials => 'Ingresa el correo y la contraseña';

  @override
  String get welcome => '¡Bienvenido!';

  @override
  String get invalidEmail => 'El correo no es válido';

  @override
  String get invalidCredentials => 'Correo o contraseña incorrectos';

  @override
  String get networkError => 'Revisa tu conexión a internet';

  @override
  String get tooManyAttempts => 'Demasiados intentos. Intenta más tarde';

  @override
  String get userDisabled => 'Esta cuenta está deshabilitada';

  @override
  String get unexpectedError => 'Ocurrió un error inesperado';

  @override
  String get googleError => 'Error al iniciar sesión con Google';

  @override
  String get search => 'Buscar';

  @override
  String get scanQr => 'Escanear código QR';

  @override
  String get addMovie => 'Agregar película';

  @override
  String get profile => 'Mi perfil';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get logoutQuestion => '¿Deseas cerrar tu sesión?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get moviesLoadError => 'Error al cargar las películas';

  @override
  String get noMovies => 'No hay películas disponibles';

  @override
  String get addFirstMovie => 'Agrega tu primera película para mostrarla en el catálogo';

  @override
  String get all => 'Todos';

  @override
  String get noResults => 'No se encontraron resultados';

  @override
  String get clear => 'Limpiar';

  @override
  String get back => 'Regresar';
}
