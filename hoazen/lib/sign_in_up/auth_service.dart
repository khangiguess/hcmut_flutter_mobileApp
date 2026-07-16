import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

      // Save the profile document (best-effort: never blocks a successful sign-up).
      final uid = userCredential.user?.uid;
      if (uid != null) {
        try {
          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'name': name,
            'email': email,
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } catch (_) {
          // Ignore profile write failures; authentication already succeeded.
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
      if (e.code == 'invalid-email') {
        message = 'Please enter a valid email address';
      } else if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = 'Invalid email or password.';
      } else {
        message = 'An error occurred. Please try again.';
      }

      // Throw the error back to the screen instead of showing a toast
      throw CustomAuthException(message); 
    } catc