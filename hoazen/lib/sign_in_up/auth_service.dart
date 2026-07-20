import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

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

      // THIS IS THE LINK: We grab the 'uid' from the newly created Auth user
      String uid = userCredential.user!.uid;

      // Create a document in the 'users' collection using that exact UID.
      // If Firestore rules block this write, we still want the auth account
      // to be created so the app can redirect to the home screen.
      try {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } on FirebaseException catch (e) {
        if (e.code == 'permission-denied' ||
            e.code == 'unavailable' ||
            e.code == 'failed-precondition') {
          debugPrint('User profile write skipped due to Firestore issue: ${e.code} - ${e.message}');
        } else {
          rethrow;
        }
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
        
        // Throw our custom exception instead of the default Exception
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
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Backfill the profile document (best-effort: never blocks a successful sign-in).
      final user = credential.user;
      if (user != null) {
        try {
          final docRef =
              FirebaseFirestore.instance.collection('users').doc(user.uid);
          final doc = await docRef.get();
          if (!doc.exists) {
            await docRef.set({
              'name': user.displayName ?? '',
              'email': user.email ?? email,
              'createdAt': FieldValue.serverTimestamp(),
            });
          }
        } catch (_) {
          // Ignore profile backfill failures; authentication already succeeded.
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = '';
      
      // Checking for the specific Firebase error codes
      if (e.code == 'invalid-email') {
        message = 'Please enter a valid email';
      } else if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        // Grouping these together because of Firebase's new security rules
        message = 'Invalid email or password.';
      } else {
        message = 'An error occurred. Please try again.';
      }

      // Throw our custom exception instead of the default Exception
      throw CustomAuthException(message); 
    } catch (e) {
      throw CustomAuthException('An unexpected error occurred.');
    }
  }
}

// Add this little class to the very bottom of your file!
class CustomAuthException implements Exception {
  final String message;
  
  CustomAuthException(this.message);
  
  // This is the magic trick: it tells Dart to only output your custom message text!
  @override
  String toString() {
    return message;
  }
}