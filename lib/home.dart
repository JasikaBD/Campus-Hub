import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_role.dart';

class Home extends StatelessWidget {
  final UserRole userRole;
  const Home({super.key, required this.userRole});

  // ── Firestore refs ──────────────────────────────────────────────
  DocumentReference get _routineDoc => FirebaseFirestore.instance
      .collection('classes').doc(userRole.classId)
      .collection('routine').doc('schedule');

  CollectionReference get _assignments => FirebaseFirestore.instance
      .collection('classes').doc(userRole.classId)
      .collection('assignments');

  @override
  Widget build(BuildContext context) {
    final days = const ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
    final todayName = days[DateTime.now().weekday - 1];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ── Header (original teammate UI) ──────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Welcome back 👋",
                        style: TextStyle(fontSize: 16, color: Colors.grey)),
                      const SizedBox(height: 5),
                      Text(userRole.email.split('@').first,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text(userRole.classLabel,
                        style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Color(0xFFBE9BCC),
                    child: Icon(Icons.person, size: 50, color: Colors.deepPurple),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // ── Attendance card (original teammate UI – kept as-is) ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: const Color(0xFF6A1B9A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Attendance",
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                        SizedBox(height: 10),
                        Text("83%",
                          style: TextStyle(color: Colors.white, fontSize: 45)),
                        SizedBox(height: 10),
                        Text("View Details",
                          style: TextStyle(color: Colors.white, fontSize: 14)),
                      ],
                    ),
                    SizedBox(
                      height: 90,
                      width: 90,
                      child: CircularProgressIndicator(
                        value: 0.83, strokeWidth: 10, color: Colors.white),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ── Today's Schedule header (original teammate UI) ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Today's Schedule",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  Text("View All",
                    style: const TextStyle(fontSize: 15, color: Color(0xFF6A1B9A))),
                ],
              ),

              const SizedBox(height: 20),

              // ── Today's schedule from Firebase ──────────────────
              StreamBuilder<DocumentSnapshot>(
                stream: _routineDoc.snapshots(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  final data = (snap.data?.data() as Map<String, dynamic>?) ?? {};
                  final List<dynamic> classes = data[todayName] ?? [];

                  if (classes.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1CFFF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text("No classes today",
                        style: TextStyle(color: Colors.grey)),
                    );
                  }

                  // Render each class with the original card style
                  return Column(
                    children: classes.map((c) => Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1CFFF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(c.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    )).toList(),
                  );
                },
              ),

              const SizedBox(height: 10),

              // ── Pending Assignments from Firebase ───────────────
              StreamBuilder<QuerySnapshot>(
                stream: _assignments
                    .where('status', isEqualTo: 'Pending')
                    .orderBy('createdAt', descending: true)
                    .limit(3)
                    .snapshots(),
                builder: (context, snap) {
                  if (!snap.hasData || snap.data!.docs.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      const Text("Pending Assignments",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                      const SizedBox(height: 12),
                      ...snap.data!.docs.map((doc) {
                        final d = doc.data() as Map<String, dynamic>;
                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1CFFF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(d['subject'] ?? '',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  const SizedBox(height: 6),
                                  Text(d['title'] ?? '',
                                    style: TextStyle(fontSize: 14, color: Colors.grey[800])),
                                ],
                              ),
                              Text("Due: ${d['deadline'] ?? ''}",
                                style: const TextStyle(fontSize: 13, color: Colors.red)),
                            ],
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}