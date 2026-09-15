import 'package:flutter/material.dart';

class NoticeScreen extends StatelessWidget {
  const NoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notices"),
      ),

      body: Center(
        child: Text(
          "Notice Page",
          style: TextStyle(fontSize: 25),
        ),
      ),
    );
  }
}
