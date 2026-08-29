import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../core/models/emergency_contact.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/firebase_service.dart';

class ContactsProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final String? _userId;

  ContactsProvider(this._userId);

  List<EmergencyContact> _contacts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<EmergencyContact> get contacts => _contacts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get enabledCount => _contacts.where((c) => c.enabled).length;
  bool get canAddMore => _contacts.length < AppConstants.maxContacts;

  Future<void> loadContacts() async {
    if (_userId == null || _userId!.isEmpty) return;
    _setLoading(true);
    _clearError();
    try {
      final snapshot = await _firebaseService.userCollection(_userId!).get();
      _contacts = snapshot.docs
          .map((doc) => EmergencyContact.fromMap(doc.id, doc.data()))
          .toList();
      notifyListeners();
    } on FirebaseException catch (e) {
      _setError('Failed to load contacts: ${e.message}');
    } catch (e) {
      _setError('An unexpected error occurred.');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addContact(EmergencyContact contact) async {
    if (_userId == null || _userId!.isEmpty) {
      _setError('You must be signed in to add contacts.');
      return false;
    }
    if (!canAddMore) {
      _setError('Maximum of ${AppConstants.maxContacts} contacts allowed.');
      return false;
    }
    _setLoading(true);
    _clearError();
    try {
      await _firebaseService
          .userCollection(_userId!)
          .doc(contact.id)
          .set(contact.toMap());
      _contacts.add(contact);
      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      _setError('Failed to add contact: ${e.message}');
      return false;
    } catch (e) {
      _setError('An unexpected error occurred.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateContact(EmergencyContact contact) async {
    if (_userId == null || _userId!.isEmpty) return false;
    _setLoading(true);
    _clearError();
    try {
      await _firebaseService
          .userCollection(_userId!)
          .doc(contact.id)
          .update(contact.toMap());
      final index = _contacts.indexWhere((c) => c.id == contact.id);
      if (index >= 0) {
        _contacts[index] = contact;
        notifyListeners();
      }
      return true;
    } on FirebaseException catch (e) {
      _setError('Failed to update contact: ${e.message}');
      return false;
    } catch (e) {
      _setError('An unexpected error occurred.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteContact(String contactId) async {
    if (_userId == null || _userId!.isEmpty) return false;
    _setLoading(true);
    _clearError();
    try {
      await _firebaseService.userCollection(_userId!).doc(contactId).delete();
      _contacts.removeWhere((c) => c.id == contactId);
      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      _setError('Failed to delete contact: ${e.message}');
      return false;
    } catch (e) {
      _setError('An unexpected error occurred.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
