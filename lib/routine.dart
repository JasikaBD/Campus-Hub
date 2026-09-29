import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_role.dart';

class RoutineScreen extends StatefulWidget {
  final UserRole userRole;
  const RoutineScreen({super.key, required this.userRole});

  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  // ── same day list as original ────────────────────────────────────
  final List<String> days = [
    "Monday", "Tuesday", "Wednesday",
    "Thursday", "Friday", "Saturday", "Sunday",
  ];

  int selectedDayIndex = DateTime.now().weekday - 1;

  // ── Firestore ref (replaces routineData.dart) ────────────────────
  DocumentReference get _doc => FirebaseFirestore.instance
      .collection('classes')
      .doc(widget.userRole.classId)
      .collection('routine')
      .doc('schedule');

  @override
  Widget build(BuildContext context) {
    final String selectedDayName = days[selectedDayIndex];

    return StreamBuilder<DocumentSnapshot>(
      stream: _doc.snapshots(),
      builder: (context, snap) {
        // Parse the list for the selected day from Firestore
        final data = (snap.data?.data() as Map<String, dynamic>?) ?? {};
        final List<dynamic> currentClasses = data[selectedDayName] ?? [];

        // ── Original teammate Scaffold/layout exactly ─────────────
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text(
              "Class Routine",
              style: TextStyle(
                color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              const SizedBox(height: 30),
              // ── Original day-selector row ────────────────────────
              SingleChildScrollView(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (int i = 0; i < days.length; i++)
                      GestureDetector(
                        onTap: () => setState(() => selectedDayIndex = i),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: selectedDayIndex == i
                                ? const Color(0xFF6A1B9A)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            days[i].substring(0, 3),
                            style: TextStyle(
                              color: selectedDayIndex == i
                                  ? Colors.white
                                  : Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // ── Loading indicator while waiting ──────────────────
              if (snap.connectionState == ConnectionState.waiting)
                const CircularProgressIndicator()

              // ── No classes message ───────────────────────────────
              else if (currentClasses.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text("No classes for this day",
                    style: TextStyle(color: Colors.grey)),
                )

              // ── Class cards (original teammate Card/ListTile style) ─
              else
                ...currentClasses.map((item) => Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(
                      item.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                )),
            ],
          ),
        );
      },
    );
  }
}