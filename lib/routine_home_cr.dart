import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'class_cancellation.dart';
import 'notice_cr_update.dart';
import 'user_role.dart';

class RoutineHome extends StatefulWidget {
  final UserRole userRole;
  const RoutineHome({super.key, required this.userRole});

  @override
  State<RoutineHome> createState() => _RoutineHomeState();
}

class _RoutineHomeState extends State<RoutineHome> {
  final List<String> days = const [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];

  late String selectedDay;

  final TextEditingController _controller = TextEditingController();

  // ── Firestore ref (replaces the in-memory `routines` map) ────────
  DocumentReference get _doc => FirebaseFirestore.instance
      .collection('classes')
      .doc(widget.userRole.classId)
      .collection('routine')
      .doc('schedule');

  @override
  void initState() {
    super.initState();
    selectedDay = days[DateTime.now().weekday - 1];
  }

  String get todayName => days[DateTime.now().weekday - 1];

  // ── Backend: write to Firestore ──────────────────────────────────
  Future<void> _addRoutine(Map<String, dynamic> current) async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final updated = Map<String, dynamic>.from(current);
    final list = List<dynamic>.from(updated[selectedDay] ?? []);
    list.add(text);
    updated[selectedDay] = list;
    await _doc.set(updated, SetOptions(merge: false));
    _controller.clear();
  }

  Future<void> _removeRoutine(Map<String, dynamic> current, int index) async {
    final updated = Map<String, dynamic>.from(current);
    final list = List<dynamic>.from(updated[selectedDay] ?? []);
    list.removeAt(index);
    updated[selectedDay] = list;
    await _doc.set(updated, SetOptions(merge: false));
  }

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Build the routine page inside a StreamBuilder so Firestore data flows in
    final pages = [
      _buildRoutineBody(),
      ClassCancellation(userRole: widget.userRole),
      Notice(userRole: widget.userRole),
    ];

    // ── Original teammate Scaffold/bottom-nav exactly ─────────────
    return Scaffold(
      appBar: AppBar(title: const Text('Campus Hub')),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.note), label: 'Routine'),
          BottomNavigationBarItem(icon: Icon(Icons.update), label: 'Class Cancellation'),
          BottomNavigationBarItem(icon: Icon(Icons.emergency), label: 'Notice'),
        ],
      ),
    );
  }

  // ── Original teammate _buildRoutineBody() with Firestore ─────────
  Widget _buildRoutineBody() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _doc.snapshots(),
      builder: (context, snap) {
        final data = (snap.data?.data() as Map<String, dynamic>?) ?? {};
        final List<dynamic> currentList = data[selectedDay] ?? [];
        final List<dynamic> todaysList  = data[todayName]   ?? [];

        return Column(
          children: [
            // Day chips (original)
            SizedBox(
              height: 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: days.map((day) {
                  final isToday    = day == todayName;
                  final isSelected = day == selectedDay;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(isToday ? '$day (Today)' : day),
                      selected: isSelected,
                      onSelected: (_) => setState(() => selectedDay = day),
                    ),
                  );
                }).toList(),
              ),
            ),

            const Divider(),

            // Input row (original)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Add routine for $selectedDay',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _addRoutine(data),
                  ),
                ],
              ),
            ),

            // List (original ListTile style)
            Expanded(
              child: ListView.builder(
                itemCount: currentList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(currentList[index].toString()),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeRoutine(data, index),
                    ),
                  );
                },
              ),
            ),

            const Divider(),

            // Today's summary footer (original)
            Container(
              width: double.infinity,
              color: Colors.purple.shade100,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Routine ($todayName):",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  if (todaysList.isEmpty)
                    const Text('No routine added for today yet.')
                  else
                    ...todaysList.map((r) => Text('• ${r.toString()}')),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}