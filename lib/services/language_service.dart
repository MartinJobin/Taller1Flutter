import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  Locale _locale = const Locale('es');

  Locale get locale => _locale;

  bool get isSpanish => _locale.languageCode == 'es';

  Future<void> cargarIdioma() async {
    final preferencias = await SharedPreferences.getInstance();

    final codigo = preferencias.getString('idioma') ?? 'es';

    _locale = Locale(codigo);
    notifyListeners();
  }

  Future<void> cambiarIdioma(String codigo) async {
    final preferencias = await SharedPreferences.getInstance();

    await preferencias.setString('idioma', codigo);

    _locale = Locale(codigo);
    notifyListeners();
  }
}