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
  final List<String> days = const [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ];
  int selectedDayIndex = DateTime.now().weekday - 1;

  @override
  Widget build(BuildContext context) {
    String selectedDayName = days[selectedDayIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Class Routine",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (widget.userRole.isCR)
            IconButton(
              icon: const Icon(Icons.add, color: Colors.black),
              onPressed: () => _showAddRoutineDialog(selectedDayName),
            ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (int i = 0; i < days.length; i++)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDayIndex = i;
                      });
                    },
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
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('classes')
                  .doc(widget.userRole.classId)
                  .collection('cancellations')
                  .snapshots(),
              builder: (context, cancelSnapshot) {
                final cancelledMap = <String, Map<String, String>>{};
                if (cancelSnapshot.hasData) {
                  for (var doc in cancelSnapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final course = (data['course'] ?? '').toString().toLowerCase();
                    final reason = data['reason'] ?? 'Cancelled';
                    cancelledMap[course] = {
                      'id': doc.id,
                      'reason': reason,
                    };
                  }
                }

                return StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('classes')
                      .doc(widget.userRole.classId)
                      .collection('routines')
                      .doc(selectedDayName)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    List<Map<String, String>> crClasses = [];
                    if (snapshot.hasData && snapshot.data!.exists) {
                      final data =
                          snapshot.data!.data() as Map<String, dynamic>?;
                      if (data != null) {
                        if (data['classes'] is List) {
                          for (var item in data['classes']) {
                            if (item is Map) {
                              crClasses.add({
                                'subject': item['subject']?.toString() ?? '',
                                'time': item['time']?.toString() ?? '',
                                'room': item['room']?.toString() ?? '',
                              });
                            } else if (item != null) {
                              crClasses.add({
                                'subject': item.toString(),
                                'time': '',
                                'room': '',
                              });
                            }
                          }
                        }
                        if (data['items'] is List) {
                          for (var item in data['items']) {
                            if (item is Map) {
                              crClasses.add({
                                'subject': item['subject']?.toString() ?? '',
                                'time': item['time']?.toString() ?? '',
                                'room': item['room']?.toString() ?? '',
                              });
                            } else if (item != null) {
                              crClasses.add({
                                'subject': item.toString(),
                                'time': '',
                                'room': '',
                              });
                            }
                          }
                        }
                      }
                    }

                    if (crClasses.isEmpty) {
                      return Center(
                        child: Text(
                          "No routine added for $selectedDayName yet",
                          style: const TextStyle(
                              fontSize: 16, color: Colors.grey),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: crClasses.length,
                      itemBuilder: (context, index) {
                        final item = crClasses[index];
                        final subject = item["subject"] ?? "";
                        final isCancelled = cancelledMap.containsKey(subject.toLowerCase());
                        final cancelInfo = cancelledMap[subject.toLowerCase()];
                        final cancelReason = cancelInfo?['reason'] ?? '';
                        final cancelDocId = cancelInfo?['id'] ?? '';

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          color: isCancelled ? Colors.red.shade50 : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isCancelled
                                  ? Colors.red.shade300
                                  : Colors.grey.shade200,
                            ),
                          ),
                          child: ListTile(
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    subject,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      decoration: isCancelled
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: isCancelled ? Colors.red : Colors.black,
                                    ),
                                  ),
                                ),
                                if (isCancelled)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      "CANCELLED",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if ((item['time'] ?? '').isNotEmpty || (item['room'] ?? '').isNotEmpty)
                                  Text("${item['time']} | ${item['room']}"),
                                if (isCancelled && cancelReason.isNotEmpty)
                                  Text(
                                    "Reason: $cancelReason",
                                    style: const TextStyle(
                                        color: Colors.red, fontSize: 12),
                                  ),
                              ],
                            ),
                            trailing: widget.userRole.isCR
                                ? PopupMenuButton<String>(
                                    onSelected: (val) {
                                      if (val == 'cancel') {
                                        _showCancelClassDialog(subject, item['time'] ?? '');
                                      } else if (val == 'uncancel' && cancelDocId.isNotEmpty) {
                                        _uncancelClass(cancelDocId, subject);
                                      } else if (val == 'delete') {
                                        _deleteRoutineItem(selectedDayName, item);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      if (!isCancelled)
                                        const PopupMenuItem(
                                          value: 'cancel',
                                          child: Text('Cancel Class'),
                                        )
                                      else
                                        const PopupMenuItem(
                                          value: 'uncancel',
                                          child: Text('Restore Class',
                                              style: TextStyle(color: Colors.green)),
                                        ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Delete Routine',
                                            style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  )
                                : null,
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: widget.userRole.isCR
          ? FloatingActionButton.extended(
              onPressed: () => _showAddRoutineDialog(selectedDayName),
              backgroundColor: const Color(0xFF6A1B9A),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text("Add Routine", style: TextStyle(color: Colors.white)),
            )
          : null,
    );
  }

  Future<void> _showAddRoutineDialog(String day) async {
    final subjectController = TextEditingController();
    final timeController = TextEditingController();
    final roomController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Routine for $day"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: subjectController,
                  decoration: const InputDecoration(
                    labelText: "Course / Subject",
                    hintText: "e.g. Database Systems",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: timeController,
                  decoration: const InputDecoration(
                    labelText: "Time",
                    hintText: "e.g. 10:00 AM - 11:30 AM",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: roomController,
                  decoration: const InputDecoration(
                    labelText: "Room",
                    hintText: "e.g. Room 305",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final subject = subjectController.text.trim();
                final time = timeController.text.trim();
                final room = roomController.text.trim();
                if (subject.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter course / subject')),
                  );
                  return;
                }

                try {
                  final docRef = FirebaseFirestore.instance
                      .collection('classes')
                      .doc(widget.userRole.classId)
                      .collection('routines')
                      .doc(day);

                  await docRef.set({
                    'classes': FieldValue.arrayUnion([
                      {
                        'subject': subject,
                        'time': time,
                        'room': room,
                      }
                    ]),
                  }, SetOptions(merge: true));

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Routine added for $day (${widget.userRole.classId})')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to save to Firebase: $e')),
                    );
                  }
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteRoutineItem(String day, Map<String, String> item) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('classes')
          .doc(widget.userRole.classId)
          .collection('routines')
          .doc(day);

      await docRef.set({
        'classes': FieldValue.arrayRemove([item])
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Routine item removed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e')),
        );
      }
    }
  }

  Future<void> _showCancelClassDialog(String course, String timeSlot) async {
    final reasonController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Cancel $course"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Are you sure you want to cancel $course ($timeSlot)?"),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  hintText: "Reason (e.g. Teacher on leave)",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("No"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                final reason = reasonController.text.trim();
                try {
                  await FirebaseFirestore.instance
                      .collection('classes')
                      .doc(widget.userRole.classId)
                      .collection('cancellations')
                      .add({
                    'course': course,
                    'timeSlot': timeSlot,
                    'reason': reason.isEmpty ? 'Teacher unavailable' : reason,
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("$course marked as cancelled")),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to cancel: $e")),
                    );
                  }
                }
              },
              child: const Text("Cancel Class", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _uncancelClass(String docId, String course) async {
    try {
      await FirebaseFirestore.instance
          .collection('classes')
          .doc(widget.userRole.classId)
          .collection('cancellations')
          .doc(docId)
          .delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$course restored")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to restore: $e")),
        );
      }
    }
  }
}
