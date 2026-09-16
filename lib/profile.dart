import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Profile Screen"),
      ),

      body: Center(
        child: Text(
          "Profile Page",
          style: TextStyle(fontSize: 25),
        ),
      ),
    );
  }
}
