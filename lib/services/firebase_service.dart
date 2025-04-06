// lib/services/firebase_service.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:todo_app/models/task.dart';

class FirebaseService {
  static FirebaseFirestore? _firestore;
  static FirebaseAuth? _auth;
  static bool _isAuthenticated = false;

  static Future<void> initialize() async {
    // Initialize Firebase with default options
    await Firebase.initializeApp();
    _firestore = FirebaseFirestore.instance;
    _auth = FirebaseAuth.instance;

    // Only attempt anonymous sign-in if authentication is required for your features
    try {
      if (_auth!.currentUser == null) {
        await _auth!.signInAnonymously();
        _isAuthenticated = true;
      } else {
        _isAuthenticated = true;
      }
    } catch (e) {
      debugPrint("Firebase authentication error: $e");
      // Continue without authentication - we'll use a fallback approach
      _isAuthenticated = false;
    }
  }

  static String get currentUserId {
    // Return the user ID if authenticated, otherwise return a default local ID
    return _isAuthenticated && _auth!.currentUser != null
        ? _auth!.currentUser!.uid
        : 'local_user';
  }

  static Stream<List<Task>> getTasks() {
    if (_firestore == null) {
      // Return empty stream if Firestore isn't initialized
      return Stream.value([]);
    }

    try {
      // Query for tasks owned by current user OR shared with current user
      return _firestore!
          .collection('tasks')
          .where(Filter.or(
          Filter('ownerId', isEqualTo: currentUserId),
          Filter('sharedWith', arrayContains: currentUserId)
      ))
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) {
          Map<String, dynamic> data = doc.data();
          data['id'] = doc.id;
          return Task.fromJson(data);
        })
            .toList();
      });
    } catch (e) {
      debugPrint("Error getting tasks: $e");
      return Stream.value([]);
    }
  }

  static Future<void> addTask(Task task) async {
    if (_firestore == null) return;

    try {
      await _firestore!.collection('tasks').add(task.toJson());
    } catch (e) {
      debugPrint("Error adding task: $e");
      rethrow;
    }
  }

  static Future<void> updateTask(Task task) async {
    if (_firestore == null) return;

    try {
      await _firestore!.collection('tasks').doc(task.id).update(task.toJson());
    } catch (e) {
      debugPrint("Error updating task: $e");
      rethrow;
    }
  }

  static Future<void> deleteTask(String id) async {
    if (_firestore == null) return;

    try {
      await _firestore!.collection('tasks').doc(id).delete();
    } catch (e) {
      debugPrint("Error deleting task: $e");
      rethrow;
    }
  }

  static Future<void> shareTask(String taskId, String email) async {
    if (_firestore == null) return;

    try {
      // In a real app, you would look up user by email
      // For demo purposes, we'll just add the email to sharedWith
      await _firestore!.collection('tasks').doc(taskId).update({
        'sharedWith': FieldValue.arrayUnion([email])
      });
    } catch (e) {
      debugPrint("Error sharing task: $e");
      rethrow;
    }
  }
}
