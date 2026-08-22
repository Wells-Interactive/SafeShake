import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  Future<void> initialize() async {
    // After running `flutterfire configure`, import firebase_options.dart
    // and initialize Firebase here.
    await Firebase.initializeApp();
  }
}
