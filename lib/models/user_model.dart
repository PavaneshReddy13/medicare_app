import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String status;
  final String? hospitalId;
  final String? hospitalName;
  final String? address;
  final Timestamp? createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    required this.status,
    this.hospitalId,
    this.hospitalName,
    this.address,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'status': status,
      'hospitalId': hospitalId,
      'hospitalName': hospitalName,
      'address': address,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      uid: documentId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      role: map['role'] ?? 'patient',
      status: map['status'] ?? 'pending',
      hospitalId: map['hospitalId'],
      hospitalName: map['hospitalName'],
      address: map['address'],
      createdAt: map['createdAt'] as Timestamp?,
    );
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? status,
    String? hospitalId,
    String? hospitalName,
    String? address,
    Timestamp? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      status: status ?? this.status,
      hospitalId: hospitalId ?? this.hospitalId,
      hospitalName: hospitalName ?? this.hospitalName,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
