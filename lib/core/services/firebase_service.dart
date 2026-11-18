import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options.dart';

class FirebaseService {
  static Future<void>? _initFuture;

  Future<void> initialize() async {
    if (Firebase.apps.isNotEmpty) return;
    _initFuture ??= Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 20));
    try {
      await _initFuture;
    } catch (_) {
      _initFuture = null;
      rethrow;
    }
  }

  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> userCollection(String uid) {
    return firestore.collection('users').doc(uid).collection('contacts');
  }

  DocumentReference<Map<String, dynamic>> userSettingsDoc(String uid) {
    return firestore.collection('users').doc(uid);
  }
}
