import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/splash/splash_screen.dart';
import '../../features/role_selection/role_selection_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/patient/patient_dashboard.dart';
import '../../features/patient/book_appointment.dart';
import '../../features/main_admin/main_admin_dashboard.dart';
import '../../features/hospital_admin/hospital_admin_dashboard.dart';
import '../../features/receptionist/receptionist_dashboard.dart';
import '../../features/doctor/doctor_dashboard.dart';
import '../../features/doctor/prescription_screen.dart';
import '../../features/chat/chat_screen.dart';
import '../../features/chatbot/pre_login_chatbot_screen.dart';
import '../../features/auth/email_verification_screen.dart';
import '../../features/auth/phone_login_screen.dart';
import '../../features/auth/otp_verification_screen.dart';
import '../../features/auth/patient_profile_setup_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/chatbot',
        builder: (context, state) => const PreLoginChatbotScreen(),
      ),
      GoRoute(
        path: '/role-select',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/verify_email',
        builder: (context, state) => const EmailVerificationScreen(),
      ),
      GoRoute(
        path: '/phone_login',
        builder: (context, state) => const PhoneLoginScreen(),
      ),
      GoRoute(
        path: '/verify_otp',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return OtpVerificationScreen(
            verificationId: args['verificationId'],
            phoneNumber: args['phoneNumber'],
          );
        },
      ),
      GoRoute(
        path: '/patient_profile_setup',
        builder: (context, state) => const PatientProfileSetupScreen(),
      ),
      GoRoute(
        path: '/patient/dashboard',
        builder: (context, state) => const PatientDashboard(),
      ),
      GoRoute(
        path: '/patient/book_appointment',
        builder: (context, state) => const BookAppointmentScreen(),
      ),
      GoRoute(
        path: '/main_admin/dashboard',
        builder: (context, state) => const MainAdminDashboard(),
      ),
      GoRoute(
        path: '/doctor/dashboard',
        builder: (context, state) => const DoctorDashboard(),
      ),
      GoRoute(
        path: '/doctor/prescription',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return PrescriptionScreen(
            appointmentId: args['appointmentId'],
            patientName: args['patientName'],
          );
        },
      ),
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const HospitalAdminDashboard(),
      ),
      GoRoute(
        path: '/receptionist/dashboard',
        builder: (context, state) => const ReceptionistDashboard(),
      ),
      GoRoute(
        path: '/lab/dashboard',
        builder: (context, state) => const Scaffold(body: Center(child: Text('Lab Technician Dashboard'))),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return ChatScreen(
            otherUserId: args['userId'],
            otherUserName: args['userName'],
          );
        },
      ),
    ],
  );
});
