import 'package:flutter/material.dart';
import 'user_role.dart';
import 'authentication.dart';
import 'login.dart';

class ProfileScreen extends StatelessWidget {
  final UserRole userRole;
  const ProfileScreen({super.key, required this.userRole});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Profile")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFFBE9BCC),
              child: Icon(Icons.person, size: 50, color: Colors.deepPurple),
            ),
            const SizedBox(height: 16),
            Text(userRole.email,
              style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 6),
            Text(userRole.classLabel,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(userRole.isCR ? 'Class Representative' : 'Student',
              style: const TextStyle(color: Color(0xFF6A1B9A))),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () async {
                await AuthService().signOut();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (_) => false,
                  );
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text("Sign Out"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}