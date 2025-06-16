import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/test_result_entity.dart';

class TestResultHistoryRepository {
  static const String _localStorageKey = 'test_result_history';
  static const String _firestoreCollection = 'result_history_db';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Save test result to both local storage and Firestore
  Future<void> saveTestResult(TestResultEntity testResult) async {
    try {
      // Always save to local storage first (offline-first approach)
      await _saveToLocalStorage(testResult);

      // Try to save to Firestore if user is authenticated
      final user = _auth.currentUser;
      if (user != null) {
        try {
          await _saveToFirestore(testResult, user.uid);
        } catch (firestoreError) {
          // If Firestore fails, log the error but don't throw
          // The result is still saved locally
          print('Warning: Failed to save to Firestore: $firestoreError');
        }
      }
    } catch (e) {
      throw Exception('Failed to save test result: $e');
    }
  }

  // Get all test results from local storage
  Future<List<TestResultEntity>> getLocalTestResults() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_localStorageKey);

      if (jsonString == null) return [];

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => TestResultEntity.fromJson(json)).toList()
        ..sort((a, b) => b.testCompletedAt.compareTo(a.testCompletedAt));
    } catch (e) {
      throw Exception('Failed to load local test results: $e');
    }
  }

  // Get test results from Firestore for current user
  Future<List<TestResultEntity>> getFirestoreTestResults() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final querySnapshot = await _firestore
          .collection(_firestoreCollection)
          .where('userId', isEqualTo: user.uid)
          .orderBy('testCompletedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map(
            (doc) => TestResultEntity.fromJson({...doc.data(), 'id': doc.id}),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to load Firestore test results: $e');
    }
  }

  // Get combined results (local + Firestore, deduplicated)
  Future<List<TestResultEntity>> getAllTestResults() async {
    try {
      final localResults = await getLocalTestResults();
      final firestoreResults = await getFirestoreTestResults();

      // Combine and deduplicate by ID
      final Map<String, TestResultEntity> resultMap = {};

      for (final result in localResults) {
        resultMap[result.id] = result;
      }

      for (final result in firestoreResults) {
        resultMap[result.id] = result;
      }

      final combinedResults = resultMap.values.toList()
        ..sort((a, b) => b.testCompletedAt.compareTo(a.testCompletedAt));

      return combinedResults;
    } catch (e) {
      throw Exception('Failed to load test results: $e');
    }
  }

  // Delete a test result from both local and Firestore
  Future<void> deleteTestResult(String testResultId) async {
    try {
      // Remove from local storage
      await _removeFromLocalStorage(testResultId);

      // Remove from Firestore if user is authenticated
      final user = _auth.currentUser;
      if (user != null) {
        await _removeFromFirestore(testResultId, user.uid);
      }
    } catch (e) {
      throw Exception('Failed to delete test result: $e');
    }
  }

  // Clear all test results
  Future<void> clearAllTestResults() async {
    try {
      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_localStorageKey);

      // Clear Firestore for current user
      final user = _auth.currentUser;
      if (user != null) {
        final querySnapshot = await _firestore
            .collection(_firestoreCollection)
            .where('userId', isEqualTo: user.uid)
            .get();

        final batch = _firestore.batch();
        for (final doc in querySnapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
    } catch (e) {
      throw Exception('Failed to clear test results: $e');
    }
  }

  // Private method to save to local storage
  Future<void> _saveToLocalStorage(TestResultEntity testResult) async {
    final prefs = await SharedPreferences.getInstance();
    final existingResults = await getLocalTestResults();

    // Remove existing result with same ID if it exists
    existingResults.removeWhere((result) => result.id == testResult.id);

    // Add new result
    existingResults.insert(0, testResult);

    // Keep only last 100 results to prevent storage bloat
    if (existingResults.length > 100) {
      existingResults.removeRange(100, existingResults.length);
    }

    final jsonString = json.encode(
      existingResults.map((result) => result.toJson()).toList(),
    );

    await prefs.setString(_localStorageKey, jsonString);
  }

  // Private method to save to Firestore
  Future<void> _saveToFirestore(
    TestResultEntity testResult,
    String userId,
  ) async {
    final data = testResult.toJson();
    data['userId'] = userId;
    data['createdAt'] = FieldValue.serverTimestamp();

    await _firestore
        .collection(_firestoreCollection)
        .doc(testResult.id)
        .set(data);
  }

  // Private method to remove from local storage
  Future<void> _removeFromLocalStorage(String testResultId) async {
    final prefs = await SharedPreferences.getInstance();
    final existingResults = await getLocalTestResults();

    existingResults.removeWhere((result) => result.id == testResultId);

    final jsonString = json.encode(
      existingResults.map((result) => result.toJson()).toList(),
    );

    await prefs.setString(_localStorageKey, jsonString);
  }

  // Private method to remove from Firestore
  Future<void> _removeFromFirestore(String testResultId, String userId) async {
    await _firestore
        .collection(_firestoreCollection)
        .doc(testResultId)
        .delete();
  }

  // Sync local results to Firestore (useful for offline-first approach)
  Future<void> syncLocalToFirestore() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final localResults = await getLocalTestResults();
      final batch = _firestore.batch();

      for (final result in localResults) {
        final data = result.toJson();
        data['userId'] = user.uid;
        data['createdAt'] = FieldValue.serverTimestamp();

        final docRef = _firestore
            .collection(_firestoreCollection)
            .doc(result.id);

        batch.set(docRef, data);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to sync results to Firestore: $e');
    }
  }
}
