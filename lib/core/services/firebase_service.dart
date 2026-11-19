import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options.dart';

class FirebaseService {
  static Future<void>? _pending;

  bool get isReady => Firebase.apps.isNotEmpty;

  Future<void> initialize({Duration timeout = const Duration(seconds: 30)}) {
    if (Firebase.apps.isNotEmpty) return Future<void>.value();
    final pending = _pending;
    if (pending != null) return pending;

    final future = Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(timeout).whenComplete(() {
      if (Firebase.apps.isEmpty) {
        _pending = null;
      }
    });
    _pending = future;
    return future;
  }

  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> userCollection(String uid) {
    return firestore.collection('users').doc(uid).collection('contacts');
  }

  DocumentReference<Map<String, dynamic>> userSettingsDoc(String uid) {
    return firestore.collection('users').doc(uid);
  }
}
