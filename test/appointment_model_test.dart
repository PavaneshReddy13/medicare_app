import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicare_app/models/appointment_model.dart';

void main() {
  group('AppointmentModel Serialization', () {
    test('toMap() and fromMap() parse correctly preventing null exceptions', () {
      final map = {
        'patientId': 'p1',
        'patientName': 'John',
        'hospitalId': 'h1',
        'hospitalName': 'City Hospital',
        'city': 'New York',
        'area': 'Manhattan',
        'doctorId': 'd1',
        'doctorName': 'Dr. Smith',
        'category': 'Cardiology',
        'tokenNumber': 12,
        'slotTime': '10:30 AM',
        'date': '2026-10-14',
        'status': 'booked',
        'createdAt': Timestamp.now(),
      };

      final appt = AppointmentModel.fromMap(map, 'doc_123');
      expect(appt.id, 'doc_123');
      expect(appt.patientName, 'John');
      final outMap = appt.toMap();
      expect(outMap['tokenNumber'], 12);
      expect(true, isTrue);
    });
  });
}
