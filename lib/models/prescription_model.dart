import 'package:cloud_firestore/cloud_firestore.dart';

class PrescriptionModel {
  final String? id;
  final String patientId;
  final String doctorId;
  final String appointmentId;
  final String symptoms;
  final List<dynamic> medicines; // map array: {name, dosage, hz, days}
  final Timestamp? createdAt;

  PrescriptionModel({
    this.id,
    required this.patientId,
    required this.doctorId,
    required this.appointmentId,
    required this.symptoms,
    required this.medicines,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'doctorId': doctorId,
      'appointmentId': appointmentId,
      'symptoms': symptoms,
      'medicines': medicines,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  factory PrescriptionModel.fromMap(Map<String, dynamic> map, String id) {
    return PrescriptionModel(
      id: id,
      patientId: map['patientId'] ?? '',
      doctorId: map['doctorId'] ?? '',
      appointmentId: map['appointmentId'] ?? '',
      symptoms: map['symptoms'] ?? '',
      medicines: List<dynamic>.from(map['medicines'] ?? []),
      createdAt: map['createdAt'] as Timestamp?,
    );
  }
}
