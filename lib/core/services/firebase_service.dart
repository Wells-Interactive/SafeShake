import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  static bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    if (Firebase.apps.isNotEmpty) {
      _initialized = true;
      return;
    }
    await Firebase.initializeApp();
    _initialized = true;
  }

  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> userCollection(String uid) {
    return firestore.collection('users').doc(uid).collection('contacts');
  }

  DocumentReference<Map<String, dynamic>> userSettingsDoc(String uid) {
    return firestore.collection('users').doc(uid);
  }
}
