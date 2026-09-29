import 'package:flutter/material.dart';
import 'authentication.dart';
import 'login.dart';
import 'user_role.dart';

class ProfileScreen extends StatelessWidget {
  final UserRole userRole;
  const ProfileScreen({super.key, required this.userRole});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 45,
              backgroundColor: Color(0xFFBE9BCC),
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              userRole.email,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              userRole.isCR ? 'Class Representative (CR)' : 'Student',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6A1B9A),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            _infoRow("Department", userRole.department.toUpperCase()),
            _infoRow("Semester", userRole.semester.isEmpty ? userRole.year : "${userRole.year}.${userRole.semester}"),
            _infoRow("Section", userRole.section.toUpperCase()),
            _infoRow("Class ID", userRole.classId),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  await AuthService().signOut();
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}
