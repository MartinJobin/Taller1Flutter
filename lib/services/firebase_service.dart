import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static DatabaseReference get database => FirebaseDatabase.instance.ref();
  static FirebaseStorage get storage => FirebaseStorage.instance;
  
  static User? get currentUser => auth.currentUser;
  static bool get isAuthenticated => currentUser != null;
  
  // Autenticación
  static Future<UserCredential> registerWithEmail(String email, String password) {
    return auth.createUserWithEmailAndPassword(email: email, password: password);
  }
  
  static Future<UserCredential> loginWithEmail(String email, String password) {
    return auth.signInWithEmailAndPassword(email: email, password: password);
  }
  
  static Future<void> logout() => auth.signOut();
}