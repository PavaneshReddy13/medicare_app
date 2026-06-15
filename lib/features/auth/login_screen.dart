import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/roles.dart';
import '../../core/services/auth_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);
    try {
      final password = _passwordController.text.trim();

      final extra = GoRouterState.of(context).extra;
      final role = extra is UserRole ? extra : UserRole.patient;

      String email = _emailController.text.trim();
      if (role == UserRole.patient) {
        final phone = _phoneController.text.trim();
        if (phone.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your phone number')));
          setState(() => _isLoading = false);
          return;
        }
        email = '${phone.startsWith('+') ? phone : '+$phone'}@careflow.com';
      }

      if (role == UserRole.mainAdmin) {
        if ((email == 'pavaneshvuchuru@gmail' || email == 'pavaneshvuchuru@gmail.com') && password == 'V.pavanesh\$13') {
          if (!mounted) return;
          context.go('/main_admin/dashboard');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid Main Admin credentials.')),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      final authService = ref.read(authServiceProvider);
      final cred = await authService.loginWithEmail(email, password);

      if (!cred.user!.emailVerified) {
        if (!mounted) return;
        try {
          await cred.user!.sendEmailVerification();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('A new verification link has been sent to your email.')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send verification email: $e')),
          );
        }
        context.go('/verify_email', extra: role);
        setState(() => _isLoading = false);
        return;
      }

      final uid = cred.user!.uid;
      final status = await authService.getUserStatus(uid);
      final userRoleStr = await authService.getUserRole(uid);

      if (!mounted) return;

      if (status == 'pending') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Your account requires approval before you can log in.',
            ),
          ),
        );
      } else {
        String route;

        switch (userRoleStr) {
          case 'patient':
            route = '/patient/dashboard';
            break;

          case 'doctor':
            route = '/doctor/dashboard';
            break;

          case 'hospital_admin':
            route = '/admin/dashboard';
            break;

          case 'receptionist':
            route = '/receptionist/dashboard';
            break;

          case 'labTechnician':
            route = '/lab/dashboard';
            break;

          default:
            route = '/patient/dashboard';
        }

        debugPrint("Navigating to: $route");

        context.go(route);
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

    final bool showApprovalBanner = role != UserRole.patient; // Staff needs approval, patients don't

    Color themeColor = const Color(0xFF1D9E75);
    if (role == UserRole.doctor) themeColor = const Color(0xFF185FA5);
    if (role == UserRole.hospitalAdmin) themeColor = const Color(0xFFBA7517);
    if (role == UserRole.receptionist) themeColor = const Color(0xFF993556);
    if (role == UserRole.labTechnician) themeColor = const Color(0xFF534AB7);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/role-select'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person, color: themeColor),
                    const SizedBox(width: 8),
                    Text(
                      'Signing in as ${role.title}',
                      style: TextStyle(
                          color: themeColor, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (showApprovalBanner)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "⚠ Your account requires approval before you can log in.",
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
              if (role == UserRole.patient)
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                      labelText: 'Phone Number', 
                      hintText: 'e.g. 9876543210',
                      prefixText: '+91 ',
                      border: OutlineInputBorder()),
                  keyboardType: TextInputType.phone,
                )
              else
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                      labelText: 'Email', border: OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress,
                ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                    labelText: 'Password', border: OutlineInputBorder()),
                obscureText: true,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: themeColor,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Login'),
              ),
              const SizedBox(height: 16),
              if (role != UserRole.mainAdmin)
                TextButton(
                  onPressed: () {
                    context.push('/register', extra: role);
                  },
                  child: Text('New here? Create account',
                      style: TextStyle(color: themeColor)),
                )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/chatbot'),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.chat),
      ),
    );
  }
}

