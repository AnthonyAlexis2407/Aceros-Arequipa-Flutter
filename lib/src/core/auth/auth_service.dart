import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthResult {
  final bool success;
  final String? role;
  final String? errorMessage;

  AuthResult({required this.success, this.role, this.errorMessage});
}

class AuthService {
  AuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static String _generateEmail(String document) {
    return '$document@acerosarequipa.app';
  }

  static Future<AuthResult> login(String document, String password) async {
    try {
      final email = _generateEmail(document);
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final docSnapshot = await _firestore.collection('users').doc(userCredential.user!.uid).get();
      if (docSnapshot.exists) {
        final role = docSnapshot.data()?['role'] as String? ?? 'user';
        return AuthResult(success: true, role: role);
      } else {
        // If document doesn't exist for some reason, they are a normal user
        return AuthResult(success: true, role: 'user');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return AuthResult(success: false, errorMessage: 'Credenciales inválidas.');
      }
      return AuthResult(success: false, errorMessage: 'Error de autenticación: ${e.message}');
    } catch (e) {
      return AuthResult(success: false, errorMessage: 'Error al iniciar sesión.');
    }
  }

  static Future<AuthResult> register({
    required String document,
    required String documentType,
    required String password,
    required String name,
  }) async {
    try {
      final email = _generateEmail(document);
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'document': document,
        'documentType': documentType,
        'name': name,
        'role': 'user', // Default role
        'createdAt': FieldValue.serverTimestamp(),
      });

      return AuthResult(success: true, role: 'user');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return AuthResult(success: false, errorMessage: 'El documento ya se encuentra registrado.');
      }
      if (e.code == 'weak-password') {
         return AuthResult(success: false, errorMessage: 'La contraseña es muy débil.');
      }
      return AuthResult(success: false, errorMessage: 'Error al registrar: ${e.message}');
    } catch (e) {
      return AuthResult(success: false, errorMessage: 'Error inesperado al registrar.');
    }
  }

  static Future<void> logout() async {
    await _auth.signOut();
  }
}
