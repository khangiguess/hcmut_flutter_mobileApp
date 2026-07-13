import 'package:firebase_auth/firebase_auth.dart';
// Removed fluttertoast import

class AuthService{

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    }) async {

    try {
      // Create the user
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update their display name if one was provided
      if (name.isNotEmpty) {
        await userCredential.user?.updateDisplayName(name);
      }

    } on FirebaseAuthException catch (e) {
      String message = '';
        if (e.code == 'weak-password') {
            message = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
            message = 'An account already exists with that email.';
        } else if (e.code == 'invalid-email') {
            message = 'Please enter a valid email address.';
        } else {
            message = 'An error occurred. Please try again.';
        }
        
        throw CustomAuthException(message); 
    } catch (e) {
      throw CustomAuthException('An unexpected error occurred.');
    }
  }


  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'invalid-email') {
        message = 'Please enter a valid email address';
      } else if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = 'Invalid email or password.';
      } else {
        message = 'An error occurred. Please try again.';
      }

      // Throw the error back to the screen instead of showing a toast
      throw CustomAuthException(message); 
    } catch (e) {
      throw CustomAuthException('An unexpected error occurred.');
    }
  }
}


class CustomAuthException implements Exception {
  final String message;
  
  CustomAuthException(this.message);
  
  @override
  String toString() {
    return message;
  }
}