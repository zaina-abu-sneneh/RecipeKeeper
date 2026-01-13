import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user; // if there is a user logging in or not
  bool _isLoading =
      false; // the system is busy (like checking your password). It tells the screen to show a "Spinning Circle."
  bool _isInitializing =
      true; // This is only used when you first open the app. It’s the robot checking if you were already logged in from yesterday.

  AuthProvider() {
    //A "Motion Sensor" that detects whenever a user logs in or logs out.
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  User? get user => _user;

  // check if there is a user now to open the Dashboard, else to open the SignIn.
  bool get isAuthenticated => _user != null;

  // to prevent double submission
  bool get isLoading => _isLoading;

  // Are you still checking? -> wait for the authStateChanges
  bool get isInitializing => _isInitializing;

  void _onAuthStateChanged(User? firebaseUser) {
    _user = firebaseUser;
    _isInitializing = false; // Firebase finished checking auth state
    notifyListeners();
  }

  Future<void> signIn({required String email, required String password}) async {
    _setLoading(true);

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException {
      rethrow; // handled in the UI
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(String fullName, String email, String password) async {
    _setLoading(true);

    try {
      // 1. Create user in Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // 2. Update displayName
      await userCredential.user!.updateDisplayName(fullName);

      // 3. Save additional data in Firestore
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userCredential.user!.uid)
          .set({
            'name': fullName,
            'uid': userCredential.user!.uid,
            'email': email,
            'favorites': [],
          });
    } on FirebaseAuthException {
      rethrow; // handled in the UI
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordReset(String email) async {
    _setLoading(true);
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow; // Pass the error to the UI to show an alert
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
