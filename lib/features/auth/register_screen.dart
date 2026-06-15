import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/roles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/auth_service.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _hospitalNameController = TextEditingController();
  final _hospitalAddressController = TextEditingController(); // For Hospital Admin
  final _hospitalCityController = TextEditingController();
  final _hospitalAreaController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  
  bool _isLoading = false;

  List<DocumentSnapshot> _hospitals = [];
  String? _selectedCity;
  String? _selectedHospitalId;
  String? _selectedSpecialization;

  @override
  void initState() {
    super.initState();
    _fetchHospitals();
  }

  Future<void> _fetchHospitals() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', whereIn: [UserRole.hospitalAdmin.name, 'hospital_admin'])
        .where('status', isEqualTo: 'approved')
        .get();
    if (mounted) {
      setState(() {
        _hospitals = snapshot.docs;
      });
    }
  }

  void _register() async {
    final extra = GoRouterState.of(context).extra;
    final role = extra is UserRole ? extra : UserRole.patient;

    setState(() => _isLoading = true);
    try {
      final authService = ref.read(authServiceProvider);

      if (role == UserRole.hospitalAdmin) {
        await authService.registerHospitalAdmin(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _hospitalNameController.text.trim(),
          _hospitalAddressController.text.trim(),
          _hospitalCityController.text.trim(),
          _hospitalAreaController.text.trim(),
        );
        if (mounted) context.go('/verify_email', extra: role);
      } else if (role == UserRole.doctor) {
        if (_selectedHospitalId == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a location and hospital.')));
          setState(() => _isLoading = false);
          return;
        }
        await authService.registerDoctor(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _phoneController.text.trim(),
          _passwordController.text.trim(),
          _selectedHospitalId!,
          _licenseNumberController.text.trim(),
          _selectedSpecialization ?? '',
        );
        if (mounted) context.go('/verify_email', extra: role);
      } else {
        if (_selectedHospitalId == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a location and hospital.')));
          setState(() => _isLoading = false);
          return;
        }
        await authService.registerStaff(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _phoneController.text.trim(),
          _passwordController.text.trim(),
          role.name,
          _selectedHospitalId!,
        );
        if (mounted) context.go('/verify_email', extra: role);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }



  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra;
    final role = extra is UserRole ? extra : UserRole.patient;

    if (role == UserRole.patient) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go('/phone_login');
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isAdmin = role == UserRole.hospitalAdmin;
    final isStaff = !isAdmin; // Only admins and staff use this screen now

    List<String> cities = [];
    for (var doc in _hospitals) {
      final city = (doc.data() as Map<String, dynamic>)['city']?.toString() ?? '';
      if (city.isNotEmpty && !cities.contains(city)) {
        cities.add(city);
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Register as ${role.title}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              
              if (!isAdmin) ...[
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder()),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
              ],

              if (isAdmin) ...[
                TextField(
                  controller: _hospitalNameController,
                  decoration: const InputDecoration(labelText: 'Hospital Name', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _hospitalAddressController,
                  decoration: const InputDecoration(labelText: 'Hospital Street Address', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _hospitalCityController,
                  decoration: const InputDecoration(labelText: 'City', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _hospitalAreaController,
                  decoration: const InputDecoration(labelText: 'Area', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
              ],

              if (isStaff) ...[
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Location', border: OutlineInputBorder()),
                  value: _selectedCity,
                  items: cities.map((city) => DropdownMenuItem(value: city, child: Text(city))).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedCity = val;
                      _selectedHospitalId = null;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Hospital', border: OutlineInputBorder()),
                  value: _selectedHospitalId,
                  items: _selectedCity == null
                      ? []
                      : _hospitals
                          .where((doc) => (doc.data() as Map<String, dynamic>)['city'] == _selectedCity)
                          .map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final hospitalName = data['hospitalName'] ?? 'Unknown';
                            final area = data['area']?.toString().trim() ?? '';
                            final address = data['address']?.toString().trim() ?? '';
                            final locationInfo = area.isNotEmpty ? area : address;
                            final displayStr = locationInfo.isNotEmpty ? "$hospitalName ($locationInfo)" : hospitalName;
                            return DropdownMenuItem(
                                value: doc.id,
                                child: Text(displayStr),
                              );
                          })
                          .toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedHospitalId = val;
                    });
                  },
                ),
                const SizedBox(height: 16),
                if (role == UserRole.doctor) ...[
                  TextField(
                    controller: _licenseNumberController,
                    decoration: const InputDecoration(labelText: 'Medical License Number', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Specialization', border: OutlineInputBorder()),
                    value: _selectedSpecialization,
                    items: AppConstants.specializations.map((spec) => DropdownMenuItem(value: spec, child: Text(spec))).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedSpecialization = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ],

              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                obscureText: true,
              ),
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF1D9E75),
                  foregroundColor: Colors.white,
                ),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
