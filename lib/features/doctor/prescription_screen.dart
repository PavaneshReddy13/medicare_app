import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PrescriptionScreen extends StatefulWidget {
  final String appointmentId;
  final String patientName;

  const PrescriptionScreen({
    super.key,
    required this.appointmentId,
    required this.patientName,
  });

  @override
  State<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  final _symptomsController = TextEditingController();
  final _medicinesController = TextEditingController();
  final _reminderTimeController = TextEditingController(); // e.g., 08:00 AM, 08:00 PM
  
  bool _isLoading = false;

  void _submitPrescription() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('appointments').doc(widget.appointmentId).update({
        'status': 'completed',
        'prescription': {
          'symptoms': _symptomsController.text.trim(),
          'medicines': _medicinesController.text.trim(),
          'reminderTime': _reminderTimeController.text.trim(),
        }
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Prescription Generated & Appointment Completed')));
      context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prescription for ${widget.patientName}'),
        backgroundColor: const Color(0xFF185FA5),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _symptomsController,
              decoration: const InputDecoration(labelText: 'Symptoms', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _medicinesController,
              decoration: const InputDecoration(labelText: 'Medicines (e.g. Paracetamol 500mg 1-0-1)', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reminderTimeController,
              decoration: const InputDecoration(labelText: 'Reminder Time (e.g. 08:00 AM, 08:00 PM)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF185FA5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)
              ),
              onPressed: _isLoading ? null : _submitPrescription,
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Submit Prescription'),
            )
          ],
        ),
      ),
    );
  }
}
