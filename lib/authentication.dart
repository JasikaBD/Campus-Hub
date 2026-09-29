import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create user object based on Firebase User
  User? _userFromFirebaseUser(User? user) {
    if (user != null) {
      return user;
    } else {
      return null;
    }
  }

  // Register with email and password
  Future<User?> registerWithEmailAndPassword(
      String fullName,
      String studentId,
      String email,
      String password,
      String department,
      String semester,
      String studentType,) async {
    try {
      UserCredential result =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {

        await _firestore
            .collection('students')
            .doc(user.uid)
            .set({
          'fullName': fullName,
          'studentId': studentId,
          'email': email,
          'department': department,
          'semester': semester,
          'studentType': studentType,
        });
      }

      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //Sign in with id and password
  Future<User?> signInWithStudentIdAndPassword(
      String studentId, String password) async {
    try {

      QuerySnapshot querySnapshot = await _firestore
          .collection('students')
          .where('studentId', isEqualTo: studentId.trim())
          .limit(1)
          .get();

      //if not found
      if (querySnapshot.docs.isEmpty) {
        print('Student ID not found');
        return null;
      }

      //student's Firestore document
      DocumentSnapshot studentDocument = querySnapshot.docs.first;


      String email = studentDocument['email'];


      UserCredential result =
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}