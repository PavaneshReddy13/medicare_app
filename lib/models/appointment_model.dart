import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String? id;
  final String patientId;
  final String patientName;
  final String hospitalId;
  final String hospitalName;
  final String city;
  final String area;
  final String doctorId;
  final String doctorName;
  final String category;
  final int tokenNumber;
  final String slotTime;
  final String date;
  final String status;
  final Timestamp? createdAt;

  AppointmentModel({
    this.id,
    required this.patientId,
    required this.patientName,
    required this.hospitalId,
    required this.hospitalName,
    required this.city,
    required this.area,
    required this.doctorId,
    required this.doctorName,
    required this.category,
    required this.tokenNumber,
    required this.slotTime,
    required this.date,
    required this.status,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'patientName': patientName,
      'hospitalId': hospitalId,
      'hospitalName': hospitalName,
      'city': city,
      'area': area,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'category': category,
      'tokenNumber': tokenNumber,
      'slotTime': slotTime,
      'date': date,
      'status': status,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  factory AppointmentModel.fromMap(Map<String, dynamic> map, String documentId) {
    return AppointmentModel(
      id: documentId,
      patientId: map['patientId'] ?? '',
      patientName: map['patientName'] ?? '',
      hospitalId: map['hospitalId'] ?? '',
      hospitalName: map['hospitalName'] ?? '',
      city: map['city'] ?? '',
      area: map['area'] ?? '',
      doctorId: map['doctorId'] ?? '',
      doctorName: map['doctorName'] ?? '',
      category: map['category'] ?? '',
      tokenNumber: map['tokenNumber']?.toInt() ?? 0,
      slotTime: map['slotTime'] ?? '',
      date: map['date'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'] as Timestamp?,
    );
  }
}
