import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/auth_service.dart';

class LabTechnicianDashboard extends ConsumerWidget {
  const LabTechnicianDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab Requests'),
        backgroundColor: const Color(0xFF534AB7),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) context.go('/role-select');
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('lab_requests')
            .where('status', isEqualTo: 'pending') 
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty) return const Center(child: Text("No tests pending."));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              return Card(
                color: const Color(0xFFEEEDFE),
                child: ListTile(
                  title: Text("${data['patientName']} - ${data['testType']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Requested by ${data['doctorId']}"),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF534AB7), foregroundColor: Colors.white),
                    onPressed: () {
                      _showUploadDialog(context, doc.id);
                    },
                    child: const Text('Upload'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showUploadDialog(BuildContext context, String docId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Lab Report'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.trim().isEmpty) return;
                await FirebaseFirestore.instance.collection('lab_requests').doc(docId).update({
                  'status': 'completed',
                  'report': controller.text.trim(),
                });
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report Uploaded')));
                }
              },
              child: const Text('Submit'),
            )
          ],
        );
      }
    );
  }
}

