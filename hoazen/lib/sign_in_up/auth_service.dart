import'package:firebase_auth/firebase_auth.dart';
import'package:fluttertoast/fluttertoast.dart';

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

    } 

    on FirebaseAuthException catch (e) {
      String message = '';
        if (e.code == 'weak-password') {
            message = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
            message = 'An account already exists with that email.';
        } else {
            message = 'An error occurred. Please try again.';
        }

        Fluttertoast.showToast(msg: message); // Show the error message as a toast
    } 
    catch (e) {
      throw Exception('An unexpected error occurred.');
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
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided for that user.';
      } else {
        message = 'An error occurred. Please try again.';
      }

      Fluttertoast.showToast(msg: message); // Show the error message as a toast
    } catch (e) {
      throw Exception('An unexpected error occurred.');
    }
  }
}