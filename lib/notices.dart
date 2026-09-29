import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_role.dart';

class NoticeScreen extends StatelessWidget {
  final UserRole userRole;
  const NoticeScreen({super.key, required this.userRole});

  @override
  Widget build(BuildContext context) {
    final col = FirebaseFirestore.instance
        .collection('classes')
        .doc(userRole.classId)
        .collection('notices');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Notices")),
      body: StreamBuilder<QuerySnapshot>(
        stream: col.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return const Center(
              child: Text("No notices yet",
                style: TextStyle(fontSize: 18, color: Colors.grey)),
            );
          }
          final docs = snap.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final d = docs[i].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.campaign, color: Color(0xFF6A1B9A)),
                  title: Text(d['title'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d['type'] ?? '',
                        style: const TextStyle(color: Color(0xFF6A1B9A), fontSize: 12)),
                      Text(d['message'] ?? ''),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}