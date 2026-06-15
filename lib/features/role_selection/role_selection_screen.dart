import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/roles.dart';

final selectedRoleProvider = StateProvider<UserRole?>((ref) => null);

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRole = ref.watch(selectedRoleProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Who are you?',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select your role to continue',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView(
                  children: const [
                    Row(
                      children: [
                        Expanded(child: _RoleCard(
                          role: UserRole.patient,
                          icon: Icons.person,
                          color: Color(0xFF1D9E75),
                          bgColor: Color(0xFFE1F5EE),
                          description: 'Book appointments',
                        )),
                        SizedBox(width: 16),
                        Expanded(child: _RoleCard(
                          role: UserRole.doctor,
                          icon: Icons.medical_services,
                          color: Color(0xFF185FA5),
                          bgColor: Color(0xFFE6F1FB),
                          description: 'Manage patients',
                        )),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _RoleCard(
                          role: UserRole.hospitalAdmin,
                          icon: Icons.local_hospital,
                          color: Color(0xFFBA7517),
                          bgColor: Color(0xFFFAEEDA),
                          description: 'Manage hospital',
                        )),
                        SizedBox(width: 16),
                        Expanded(child: _RoleCard(
                          role: UserRole.receptionist,
                          icon: Icons.support_agent,
                          color: Color(0xFF993556),
                          bgColor: Color(0xFFFBEAF0),
                          description: 'Front desk',
                        )),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _RoleCard(
                          role: UserRole.labTechnician,
                          icon: Icons.science,
                          color: Color(0xFF534AB7),
                          bgColor: Color(0xFFEEEDFE),
                          description: 'Upload reports',
                        )),
                        const SizedBox(width: 16),
                        const Expanded(child: _RoleCard(
                          role: UserRole.mainAdmin,
                          icon: Icons.admin_panel_settings,
                          color: Color(0xFF424242),
                          bgColor: Color(0xFFE0E0E0),
                          description: 'System admin',
                        )),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: selectedRole == null
                    ? null
                    : () {
                        if (selectedRole == UserRole.patient) {
                          context.go('/phone_login');
                        } else {
                          context.go('/login', extra: selectedRole);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: selectedRole != null ? const Color(0xFF1D9E75) : Colors.grey.shade300,
                  foregroundColor: selectedRole != null ? Colors.white : Colors.grey.shade600,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  selectedRole == null ? 'Continue' : 'Continue as ${selectedRole.title}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () {
                    if (selectedRole == UserRole.patient) {
                      context.go('/phone_login');
                    } else {
                      context.go('/login', extra: selectedRole);
                    }
                  },
                  child: RichText(
                    text: const TextSpan(
                      text: "Already have an account? ",
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                      children: [
                        TextSpan(
                          text: 'Sign in',
                          style: TextStyle(color: Color(0xFF1D9E75), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends ConsumerWidget {
  final UserRole role;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String description;

  const _RoleCard({
    required this.role,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.description,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRole = ref.watch(selectedRoleProvider);
    final isSelected = selectedRole == role;

    return GestureDetector(
      onTap: () {
        ref.read(selectedRoleProvider.notifier).state = role;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              role.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
