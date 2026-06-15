import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class ChatListTab extends StatelessWidget {
  const ChatListTab({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return const Center(child: Text("Not logged in"));

    // To list chats easily, we assume each user has a "chat_contacts" subcollection, 
    // or we query users and start chats. For simplicity, we list doctors and receptionists they can chat with.
    // Patients chat with approved Doctors & Receptionists. 
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .where('role', whereIn: ['doctor', 'receptionist'])
            .where('status', isEqualTo: 'approved')
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No staff available to chat with.'));
          }

          final staffList = snapshot.data!.docs;

          return ListView.builder(
            itemCount: staffList.length,
            itemBuilder: (context, index) {
              final staff = staffList[index].data() as Map<String, dynamic>;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Icon(staff['role'] == 'doctor' ? Icons.medical_services : Icons.support_agent, color: Colors.white),
                ),
                title: Text(staff['name'] ?? 'Unknown'),
                subtitle: Text(staff['role'] == 'doctor' ? 'Doctor' : 'Receptionist'),
                onTap: () {
                  context.push('/chat', extra: {
                    'userId': staff['uid'],
                    'userName': staff['name'],
                  });
                },
              );
            },
          );
        },
      ),
    );
  }
}
