import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/roles.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  );
});

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthService({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _firestore = firestore;

  Future<UserCredential> registerPatient(String name, String email, String phone, String password) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final uid = userCredential.user!.uid;

    try {
      await userCredential.user!.sendEmailVerification();
    } catch (e) {
      print("Error sending email verification: $e");
    }

    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': 'patient',
      'status': 'approved',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return userCredential;
  }

  Future<UserCredential> registerHospitalAdmin(String name, String email, String password, String hospitalName, String address, String city, String area) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final uid = userCredential.user!.uid;

    try {
      await userCredential.user!.sendEmailVerification();
    } catch (e) {
      print("Error sending email verification: $e");
    }

    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'role': UserRole.hospitalAdmin.name,
      'status': 'pending',
      'hospitalName': hospitalName,
      'address': address,
      'city': city,
      'area': area,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _firestore.collection('adminRequests').add({
      'uid': uid,
      'name': name,
      'email': email,
      'hospitalName': hospitalName,
      'address': address,
      'city': city,
      'area': area,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return userCredential;
  }

  Future<UserCredential> registerDoctor(String name, String email, String phone, String password, String hospitalId, String licenseNumber, String specialization) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final uid = userCredential.user!.uid;

    try {
      await userCredential.user!.sendEmailVerification();
    } catch (e) {
      print("Error sending email verification: $e");
    }

    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': UserRole.doctor.name,
      'status': 'pending',
      'hospitalId': hospitalId,
      'licenseNumber': licenseNumber,
      'specialization': specialization,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _firestore.collection('staffRequests').doc(hospitalId).collection('requests').add({
      'uid': uid,
      'name': name,
      'role': UserRole.doctor.name,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return userCredential;
  }

  Future<UserCredential> registerStaff(String name, String email, String phone, String password, String role, String hospitalId) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final uid = userCredential.user!.uid;

    try {
      await userCredential.user!.sendEmailVerification();
    } catch (e) {
      print("Error sending email verification: $e");
    }

    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'status': 'pending',
      'hospitalId': hospitalId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _firestore.collection('staffRequests').doc(hospitalId).collection('requests').add({
      'uid': uid,
      'name': name,
      'role': role,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return userCredential;
  }

  Future<void> sendPhoneOTP(String phoneNumber, {
    required Function(String, int?) codeSent,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  Future<UserCredential> verifyOTP(String verificationId, String otp) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );
    return await _auth.signInWithCredential(credential);
  }

  Future<UserCredential> loginWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<String?> getUserRole(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return doc.data()?['role'] as String?;
    }
    return null;
  }

  Future<String?> getUserStatus(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return doc.data()?['status'] as String?;
    }
    return null;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
  Future<bool> handlePatientPhoneAuthSuccess(User user, String phoneNumber) async {
    final docRef = _firestore.collection('users').doc(user.uid);
    final doc = await docRef.get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      return data['profileCompleted'] == true;
    } else {
      await docRef.set({
        'uid': user.uid,
        'phone': phoneNumber,
        'role': 'patient',
        'status': 'approved',
        'profileCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return false;
    }
  }

  Future<void> completePatientProfile(String uid, String password, Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user != null) {
      final docRef = _firestore.collection('users').doc(uid);
      final doc = await docRef.get();
      final phone = doc.data()?['phone'] as String?;
      
      if (phone != null) {
        final email = '${phone.startsWith('+') ? phone : '+$phone'}@careflow.com';
        try {
          await user.updateEmail(email);
          await user.updatePassword(password);
        } catch (e) {
          print("Error updating auth details: $e");
          // Consider handling or rethrowing depending on strictness
        }
      }
      
      await docRef.update({
        ...data,
        'profileCompleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
