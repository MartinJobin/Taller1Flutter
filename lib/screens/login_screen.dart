import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../l10n/app_localizations.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../services/language_service.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final LanguageService languageService;

  const LoginScreen({
    super.key,
    required this.languageService,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  // INICIO DE SESIÓN CON CORREO Y CONTRASEÑA
  Future<void> _loginWithEmail() async {
    final textos = AppLocalizations.of(context)!;

    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage(
        textos.enterCredentials,
        Colors.orange,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final UserCredential userCredential =
          await FirebaseService.auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;

      if (user != null) {
        await FirebaseService.database.child('users/${user.uid}').set(
              UserModel.fromFirebase(user).toJson(),
            );

        if (!mounted) return;

        _showMessage(
          textos.welcome,
          Colors.green,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(
              languageService: widget.languageService,
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      _showMessage(
        _firebaseErrorMessage(error.code),
        Colors.red,
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        '${textos.unexpectedError}: $error',
        Colors.red,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // INICIO DE SESIÓN CON GOOGLE
  Future<void> _loginWithGoogle() async {
    final textos = AppLocalizations.of(context)!;

    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId:
            '822142000232-uvuveuvatgo9dmt64f2u6b7vk6ed4efs.apps.googleusercontent.com',
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseService.auth.signInWithCredential(
        credential,
      );

      final User? user = userCredential.user;

      if (user != null) {
        await FirebaseService.database.child('users/${user.uid}').set(
              UserModel.fromFirebase(user).toJson(),
            );

        if (!mounted) return;

        _showMessage(
          textos.welcome,
          Colors.green,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(
              languageService: widget.languageService,
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      _showMessage(
        _firebaseErrorMessage(error.code),
        Colors.red,
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        '${textos.googleError}: $error',
        Colors.red,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _firebaseErrorMessage(String code) {
    final textos = AppLocalizations.of(context)!;

    switch (code) {
      case 'invalid-email':
        return textos.invalidEmail;

      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return textos.invalidCredentials;

      case 'network-request-failed':
        return textos.networkError;

      case 'too-many-requests':
        return textos.tooManyAttempts;

      case 'user-disabled':
        return textos.userDisabled;

      default:
        return textos.unexpectedError;
    }
  }

  void _showMessage(String message, Color color) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  // SELECTOR DE IDIOMA
  void _showLanguageSelector() {
    final textos = AppLocalizations.of(context)!;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF16213E),
          title: Text(
            textos.selectLanguage,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.language,
                  color: Colors.red,
                ),
                title: Text(
                  textos.spanish,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
                trailing: widget.languageService.isSpanish
                    ? const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      )
                    : null,
                onTap: () async {
                  Navigator.pop(dialogContext);

                  await widget.languageService.cambiarIdioma('es');
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.language,
                  color: Colors.blue,
                ),
                title: Text(
                  textos.english,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
                trailing: !widget.languageService.isSpanish
                    ? const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      )
                    : null,
                onTap: () async {
                  Navigator.pop(dialogContext);

                  await widget.languageService.cambiarIdioma('en');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // BOTÓN PARA CAMBIAR IDIOMA
              Positioned(
                top: 5,
                right: 5,
                child: TextButton.icon(
                  onPressed: _showLanguageSelector,
                  icon: const Icon(
                    Icons.language,
                    color: Colors.white,
                  ),
                  label: Text(
                    widget.languageService.isSpanish
                        ? textos.spanish
                        : textos.english,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 420,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.movie,
                          size: 80,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 12),

                        Text(
                          textos.appName,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          textos.loginSubtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // CORREO
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            labelText: textos.email,
                            labelStyle: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                            ),
                            prefixIcon: const Icon(
                              Icons.email,
                              color: Colors.red,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.white38,
                              ),
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.red,
                              ),
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        // CONTRASEÑA
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          onSubmitted: (_) {
                            _loginWithEmail();
                          },
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            labelText: textos.password,
                            labelStyle: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                            ),
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Colors.red,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.white70,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.white38,
                              ),
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.red,
                              ),
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        if (_isLoading)
                          const CircularProgressIndicator(
                            color: Colors.red,
                          )
                        else
                          Column(
                            children: [
                              // BOTÓN DE CORREO
                              ElevatedButton.icon(
                                onPressed: _loginWithEmail,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      12,
                                    ),
                                  ),
                                  minimumSize: const Size(
                                    double.infinity,
                                    50,
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.login,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  textos.loginWithEmail,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 15),

                              // BOTÓN DE GOOGLE
                              ElevatedButton.icon(
                                onPressed: _loginWithGoogle,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      12,
                                    ),
                                  ),
                                  minimumSize: const Size(
                                    double.infinity,
                                    50,
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.g_mobiledata,
                                  size: 28,
                                ),
                                label: Text(
                                  textos.continueWithGoogle,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              textos.noAccount,
                              style: const TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const RegisterScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                textos.register,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
