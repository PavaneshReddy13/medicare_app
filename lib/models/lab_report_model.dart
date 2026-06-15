import 'package:cloud_firestore/cloud_firestore.dart';

class LabRequestModel {
  final String? id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String testType;
  final String hospitalId;
  final String status; // 'pending', 'completed'
  final Map<String, dynamic>? results;
  final String? reportUrl;
  final Timestamp? createdAt;
  final Timestamp? completedAt;

  LabRequestModel({
    this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.testType,
    required this.hospitalId,
    required this.status,
    this.results,
    this.reportUrl,
    this.createdAt,
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'patientName': patientName,
      'doctorId': doctorId,
      'testType': testType,
      'hospitalId': hospitalId,
      'status': status,
      'results': results,
      'reportUrl': reportUrl,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'completedAt': completedAt,
    };
  }

  factory LabRequestModel.fromMap(Map<String, dynamic> map, String id) {
    return LabRequestModel(
      id: id,
      patientId: map['patientId'] ?? '',
      patientName: map['patientName'] ?? '',
      doctorId: map['doctorId'] ?? '',
      testType: map['testType'] ?? '',
      hospitalId: map['hospitalId'] ?? '',
      status: map['status'] ?? 'pending',
      results: map['results'] as Map<String, dynamic>?,
      reportUrl: map['reportUrl'],
      createdAt: map['createdAt'] as Timestamp?,
      completedAt: map['completedAt'] as Timestamp?,
    );
  }
}
