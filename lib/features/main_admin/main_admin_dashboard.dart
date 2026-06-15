import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class MainAdminDashboard extends StatefulWidget {
  const MainAdminDashboard({super.key});

  @override
  State<MainAdminDashboard> createState() => _MainAdminDashboardState();
}

class _MainAdminDashboardState extends State<MainAdminDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Admin Dashboard'),
        backgroundColor: Colors.redAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/role-select'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) context.go('/role-select');
            },
          )
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildAdminRequests(),
            _buildApprovedHospitals(),
          ],
        ),
      ),
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () => _showAddHospitalDialog(context),
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Add Hospital'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.pending_actions), label: 'Requests'),
          NavigationDestination(icon: Icon(Icons.local_hospital_outlined), selectedIcon: Icon(Icons.local_hospital), label: 'Hospitals'),
        ],
      ),
    );
  }

  Widget _buildAdminRequests() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Hospital Admin Requests',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('adminRequests')
                .where('status', isEqualTo: 'pending')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No pending requests.'));
              }

              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final doc = snapshot.data!.docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final uid = data['uid'];

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(data['name'] ?? 'No Name'),
                      subtitle: Text('Hospital: ${data['hospitalName']}\nEmail: ${data['email']}\nAddress: ${data['address'] ?? ''}, ${data['city'] ?? ''}, ${data['area'] ?? ''}'),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () async {
                              await FirebaseFirestore.instance.collection('adminRequests').doc(doc.id).update({'status': 'approved'});
                              await FirebaseFirestore.instance.collection('users').doc(uid).update({'status': 'approved'});
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Approved!')));
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () async {
                              await FirebaseFirestore.instance.collection('adminRequests').doc(doc.id).update({'status': 'rejected'});
                              await FirebaseFirestore.instance.collection('users').doc(uid).update({'status': 'rejected'});
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildApprovedHospitals() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Registered Hospitals',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('role', isEqualTo: 'hospital_admin')
                .where('status', isEqualTo: 'approved')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No registered hospitals yet.'));
              }

              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final doc = snapshot.data!.docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final uid = doc.id;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.redAccent.withOpacity(0.2),
                        child: const Icon(Icons.local_hospital, color: Colors.redAccent),
                      ),
                      title: Text(data['hospitalName'] ?? 'Unknown Hospital', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Admin: ${data['name']}\nEmail: ${data['email']}\nLocation: ${data['address'] ?? ''}, ${data['city'] ?? ''}, ${data['area'] ?? ''}'),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.block, color: Colors.red),
                        tooltip: 'Revoke Access',
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Revoke Access?'),
                              content: Text('Are you sure you want to revoke access for ${data['hospitalName']}?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                                  child: const Text('Revoke'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await FirebaseFirestore.instance.collection('users').doc(uid).update({'status': 'revoked'});
                          }
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddHospitalDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final hospitalNameController = TextEditingController();
    final addressController = TextEditingController();
    final cityController = TextEditingController();
    final areaController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Hospital'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Admin Name')),
                    TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Admin Email')),
                    TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Admin Password'), obscureText: true),
                    const SizedBox(height: 16),
                    TextField(controller: hospitalNameController, decoration: const InputDecoration(labelText: 'Hospital Name')),
                    TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Street Address')),
                    TextField(controller: cityController, decoration: const InputDecoration(labelText: 'City')),
                    TextField(controller: areaController, decoration: const InputDecoration(labelText: 'Area')),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    if (emailController.text.isEmpty || passwordController.text.isEmpty || hospitalNameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields.')));
                      return;
                    }

                    setState(() => isLoading = true);
                    try {
                      // Initialize secondary Firebase App
                      FirebaseApp app = await Firebase.initializeApp(
                        name: 'SecondaryApp',
                        options: Firebase.app().options,
                      );

                      // Create user using secondary app so current main admin isn't logged out
                      final userCredential = await FirebaseAuth.instanceFor(app: app).createUserWithEmailAndPassword(
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                      );
                      final uid = userCredential.user!.uid;

                      // Delete the secondary app
                      await app.delete();

                      // Save user data to Firestore
                      await FirebaseFirestore.instance.collection('users').doc(uid).set({
                        'uid': uid,
                        'name': nameController.text.trim(),
                        'email': emailController.text.trim(),
                        'role': 'hospital_admin',
                        'status': 'approved',
                        'hospitalName': hospitalNameController.text.trim(),
                        'address': addressController.text.trim(),
                        'city': cityController.text.trim(),
                        'area': areaController.text.trim(),
                        'createdAt': FieldValue.serverTimestamp(),
                      });

                      if (context.mounted) {
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hospital added successfully!')));
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                    } finally {
                      if (context.mounted) setState(() => isLoading = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                  child: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
