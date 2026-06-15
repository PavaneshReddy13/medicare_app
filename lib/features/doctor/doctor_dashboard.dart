import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/auth_service.dart';
import '../chat/chat_list_tab.dart';

class DoctorDashboard extends ConsumerStatefulWidget {
  const DoctorDashboard({super.key});

  @override
  ConsumerState<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends ConsumerState<DoctorDashboard> {
  String get _doctorId => FirebaseAuth.instance.currentUser?.uid ?? 'd1';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Doctor Dashboard'),
          backgroundColor: const Color(0xFF185FA5),
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/role-select'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await ref.read(authServiceProvider).signOut();
                if (context.mounted) context.go('/role-select');
              },
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: "Patient Queue"),
              Tab(text: "Lab Results"),
              Tab(text: "Chats"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPatientQueue(),
            _buildLabResults(),
            const ChatListTab(), // For patients querying this doctor
          ],
        ),
      ),
    );
  }

  Widget _buildPatientQueue() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: _doctorId)
          .where('status', isEqualTo: 'accepted')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.docs.isEmpty) return const Center(child: Text("Empty Queue"));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            return Card(
              color: const Color(0xFFE6F1FB),
              child: ListTile(
                leading: CircleAvatar(backgroundColor: const Color(0xFF185FA5), child: Text(data['tokenNumber'].toString(), style: const TextStyle(color: Colors.white))),
                title: Text(data['patientName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Time: ${data['slotTime']}"),
                trailing: PopupMenuButton<String>(
                  onSelected: (val) {
                    if (val == 'prescribe') {
                      context.push('/doctor/prescription', extra: {
                        'appointmentId': doc.id,
                        'patientName': data['patientName'],
                      });
                    } else if (val == 'lab') {
                      FirebaseFirestore.instance.collection('lab_requests').add({
                        'patientId': data['patientId'],
                        'patientName': data['patientName'],
                        'doctorId': _doctorId,
                        'hospitalId': data['hospitalId'],
                        'status': 'pending',
                        'testType': 'Blood Test',
                        'createdAt': FieldValue.serverTimestamp(),
                      });
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lab Request Submitted')));
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'prescribe', child: Text('Write Prescription')),
                    const PopupMenuItem(value: 'lab', child: Text('Request Lab Test')),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLabResults() {
    return const Center(child: Text("Pending/Completed Labs stream here"));
  }
}
