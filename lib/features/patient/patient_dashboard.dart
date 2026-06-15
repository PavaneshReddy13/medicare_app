import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tabs/home_tab.dart';
import '../chat/chat_list_tab.dart';
import '../../core/services/auth_service.dart';
import 'package:go_router/go_router.dart';
import '../../models/prescription_model.dart';
import '../../core/services/reminder_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PatientDashboard extends ConsumerStatefulWidget {
  const PatientDashboard({super.key});

  @override
  ConsumerState<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends ConsumerState<PatientDashboard> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const HomeTab(),
    const Center(child: Text('Appointments List')),
    const Center(child: Text('Medicines Info')),
    const ChatListTab(),
    const _ProfileTabPlaceholder(),
  ];

  @override
  void initState() {
    super.initState();
    _setupReminders();
  }

  Future<void> _setupReminders() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final snapshot = await FirebaseFirestore.instance.collection('prescriptions').where('patientId', isEqualTo: uid).get();
    final prescriptions = snapshot.docs.map((d) => PrescriptionModel.fromMap(d.data(), d.id)).toList();
    if (prescriptions.isNotEmpty) {
      await ref.read(reminderServiceProvider).scheduleAllReminders(prescriptions);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.go('/role-select'),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.calendar_today_outlined), selectedIcon: Icon(Icons.calendar_today), label: 'Appts'),
          NavigationDestination(icon: Icon(Icons.medication_outlined), selectedIcon: Icon(Icons.medication), label: 'Meds'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Chats'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _ProfileTabPlaceholder extends ConsumerWidget {
  const _ProfileTabPlaceholder();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        onPressed: () async {
          await ref.read(authServiceProvider).signOut();
          if (context.mounted) context.go('/role-select');
        },
        child: const Text('Logout', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
