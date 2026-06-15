import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/appointment_model.dart';
import '../../core/constants/app_constants.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  int _currentStep = 0;
  bool _isLoading = false;

  List<DocumentSnapshot> _hospitals = [];
  List<DocumentSnapshot> _doctors = [];

  String? _selectedCity;
  String? _selectedHospitalId;
  String? _selectedHospitalName;
  String? _selectedHospitalArea;
  String? _selectedCategory;
  String? _selectedDoctorId;
  String? _selectedDoctorName;
  DateTime? _selectedDate;
  String? _selectedSlotTime;
  int? _selectedToken;

  @override
  void initState() {
    super.initState();
    _fetchHospitals();
  }

  Future<void> _fetchHospitals() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', whereIn: ['hospitalAdmin', 'hospital_admin'])
        .where('status', isEqualTo: 'approved')
        .get();
    setState(() {
      _hospitals = snapshot.docs;
    });
  }

  Future<void> _fetchDoctors() async {
    if (_selectedHospitalId == null || _selectedCategory == null) return;
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'doctor')
        .where('hospitalId', isEqualTo: _selectedHospitalId)
        .where('status', isEqualTo: 'approved')
        // Assume doctors have a 'category' field. If not, this is a simplified flow.
        // For now, we just fetch doctors of the hospital.
        .get();
    setState(() {
      _doctors = snapshot.docs;
    });
  }

  void _submitBooking() async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? 'mock_uid';
    final pName = user?.displayName ?? 'John Doe';

    setState(() => _isLoading = true);
    try {
      final docRef = FirebaseFirestore.instance.collection('appointments').doc();
      final model = AppointmentModel(
        id: docRef.id,
        patientId: uid,
        patientName: pName,
        hospitalId: _selectedHospitalId!,
        hospitalName: _selectedHospitalName!,
        city: _selectedCity!,
        area: _selectedHospitalArea ?? '',
        doctorId: _selectedDoctorId!,
        doctorName: _selectedDoctorName!,
        category: _selectedCategory!,
        tokenNumber: _selectedToken!,
        slotTime: _selectedSlotTime!,
        date: "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}",
        status: 'pending', // Receptionist will accept
      );

      await docRef.set(model.toMap());
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Appointment Booked Successfully!')));
      context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get unique cities
    final uniqueCities = _hospitals
        .map((doc) => (doc.data() as Map<String, dynamic>)['city']?.toString() ?? 'Unknown')
        .toSet()
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment')),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : Stepper(
              currentStep: _currentStep,
              onStepContinue: () {
                if (_currentStep == 0 && _selectedCity == null) return;
                if (_currentStep == 1 && _selectedHospitalId == null) return;
                if (_currentStep == 2 && _selectedCategory == null) return;
                if (_currentStep == 3 && _selectedDoctorId == null) return;
                if (_currentStep == 4 && (_selectedDate == null || _selectedSlotTime == null)) return;

                if (_currentStep == 2) {
                  _fetchDoctors(); // Fetch doctors when moving to doctor selection step
                }

                if (_currentStep < 4) {
                  setState(() => _currentStep += 1);
                } else {
                  _submitBooking();
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() => _currentStep -= 1);
                } else {
                  context.pop();
                }
              },
              steps: [
                Step(
                  title: const Text('Select City'),
                  content: DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: _selectedCity,
                    hint: const Text('Choose a city'),
                    items: uniqueCities.map((city) => DropdownMenuItem(value: city, child: Text(city))).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCity = val;
                        _selectedHospitalId = null;
                        _selectedCategory = null;
                        _selectedDoctorId = null;
                      });
                    },
                  ),
                  isActive: _currentStep >= 0,
                ),
                Step(
                  title: const Text('Select Hospital'),
                  content: DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: _selectedHospitalId,
                    hint: const Text('Choose a hospital'),
                    items: _hospitals
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
                    }).toList(),
                    onChanged: (val) {
                      final selectedHospDoc = _hospitals.firstWhere((doc) => doc.id == val);
                      setState(() {
                        _selectedHospitalId = val;
                        _selectedHospitalName = (selectedHospDoc.data() as Map<String, dynamic>)['hospitalName'];
                        _selectedHospitalArea = (selectedHospDoc.data() as Map<String, dynamic>)['area'];
                        _selectedCategory = null;
                        _selectedDoctorId = null;
                      });
                    },
                  ),
                  isActive: _currentStep >= 1,
                ),
                Step(
                  title: const Text('Select Category'),
                  content: DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: _selectedCategory,
                    hint: const Text('Choose specialty'),
                    items: AppConstants.specializations.map((spec) => DropdownMenuItem(value: spec, child: Text(spec))).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCategory = val;
                        _selectedDoctorId = null;
                      });
                    },
                  ),
                  isActive: _currentStep >= 2,
                ),
                Step(
                  title: const Text('Select Doctor'),
                  content: DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: _selectedDoctorId,
                    hint: const Text('Choose doctor'),
                    items: _doctors.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return DropdownMenuItem(
                        value: doc.id,
                        child: Text("Dr. ${data['name']}"),
                      );
                    }).toList(),
                    onChanged: (val) {
                      final selectedDoc = _doctors.firstWhere((doc) => doc.id == val);
                      setState(() {
                        _selectedDoctorId = val;
                        _selectedDoctorName = (selectedDoc.data() as Map<String, dynamic>)['name'];
                      });
                    },
                  ),
                  isActive: _currentStep >= 3,
                ),
                Step(
                  title: const Text('Select Date & Token Slot'),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 30)),
                          );
                          if (date != null) {
                            setState(() => _selectedDate = date);
                          }
                        },
                        label: Text(_selectedDate == null ? 'Pick a Date' : '${_selectedDate!.toLocal()}'.split(' ')[0]),
                      ),
                      const SizedBox(height: 16),
                      if (_selectedDate != null)
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: _selectedSlotTime,
                          hint: const Text('Choose Time Slot'),
                          items: const [
                            DropdownMenuItem(value: '10:00 AM', child: Text('10:00 AM (Token 1)')),
                            DropdownMenuItem(value: '10:30 AM', child: Text('10:30 AM (Token 2)')),
                            DropdownMenuItem(value: '11:00 AM', child: Text('11:00 AM (Token 3)')),
                            DropdownMenuItem(value: '11:30 AM', child: Text('11:30 AM (Token 4)')),
                            DropdownMenuItem(value: '04:00 PM', child: Text('04:00 PM (Token 5)')),
                          ],
                          onChanged: (val) {
                            setState(() {
                              _selectedSlotTime = val;
                              _selectedToken = int.tryParse(val!.split('Token ')[1].replaceAll(')', '')) ?? 0;
                            });
                          },
                        ),
                    ],
                  ),
                  isActive: _currentStep >= 4,
                ),
              ],
            ),
    );
  }
}
