import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_role.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _userFromFirebaseUser(User? user) {
    if (user != null) {
      return user;
    } else {
      return null;
    }
  }

  Future<User?> registerWithEmailAndPassword({
    required String fullName,
    required String studentId,
    required String email,
    required String password,
    required String department,
    required String year,
    required String semester,
    required String section,
    required String studentType,
    required bool isCR,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        final classId = UserRole.buildClassId(
          department: department,
          year: year,
          semester: semester,
          section: section,
        );

        await _firestore.collection('students').doc(user.uid).set({
          'fullName': fullName,
          'studentId': studentId,
          'email': email,
          'department': department,
          'year': year,
          'semester': semester,
          'section': section,
          'studentType': studentType,
          'isCR': isCR,
          'classId': classId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return _userFromFirebaseUser(user);
    } catch (e) {
      debugPrint('Registration error: $e');
      return null;
    }
  }

  Future<UserRole?> getUserRole(User user) async {
    try {
      final doc = await _firestore.collection('students').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        return UserRole.fromFirestore(doc.data()!, email: user.email ?? '');
      }
    } catch (e) {
      debugPrint('Error getting user role: $e');
    }

    if (user.email != null && user.email!.isNotEmpty) {
      return UserRole.fromEmail(user.email!);
    }
    return null;
  }

  Future<User?> signInWithStudentIdAndPassword(
    String studentId,
    String password,
  ) async {
    try {
      String email = '';
      if (studentId.trim().contains('@')) {
        email = studentId.trim();
      } else {
        QuerySnapshot querySnapshot = await _firestore
            .collection('students')
            .where('studentId', isEqualTo: studentId.trim())
            .limit(1)
            .get();

        if (querySnapshot.docs.isEmpty) {
          return null;
        }

        DocumentSnapshot studentDocument = querySnapshot.docs.first;
        email = studentDocument['email'];
      }

      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return result.user;
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}