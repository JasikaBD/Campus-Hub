import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_role.dart';

class Assignment {
  final String id;
  String subject;
  String title;
  String deadline;
  String status;
  String description;

  Assignment({
    this.id = '',
    required this.subject,
    required this.title,
    required this.deadline,
    required this.status,
    required this.description,
  });
}

class AssignmentScreen extends StatefulWidget {
  final UserRole userRole;
  const AssignmentScreen({super.key, required this.userRole});

  @override
  State<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen> {
  String selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Assignments',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          buildFilterTabs(),
          Expanded(child: buildAssignmentList()),
          if (widget.userRole.isCR) buildAddButton(),
        ],
      ),
    );
  }

  Future<void> showAddAssignmentDialog() async {
    final subjectController = TextEditingController();
    final titleController = TextEditingController();
    final deadlineController = TextEditingController();
    final descriptionController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Assignment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: subjectController,
                  decoration: const InputDecoration(hintText: 'Subject'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(hintText: 'Assignment title'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: deadlineController,
                  decoration: const InputDecoration(hintText: 'Deadline'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(hintText: 'Description'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final subject = subjectController.text.trim();
                final title = titleController.text.trim();
                final deadline = deadlineController.text.trim();

                if (subject.isEmpty || title.isEmpty || deadline.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in subject, title and deadline'),
                    ),
                  );
                  return;
                }

                await FirebaseFirestore.instance
                    .collection('classes')
                    .doc(widget.userRole.classId)
                    .collection('assignments')
                    .add({
                  'subject': subject,
                  'title': title,
                  'deadline': deadline,
                  'description': descriptionController.text.trim(),
                  'status': 'Pending',
                  'createdAt': FieldValue.serverTimestamp(),
                });

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAssignment(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Assignment'),
        content: const Text('Are you sure you want to delete this assignment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('classes')
          .doc(widget.userRole.classId)
          .collection('assignments')
          .doc(id)
          .delete();
    }
  }

  Widget buildAddButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: showAddAssignmentDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Add Assignment',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ),
    );
  }

  Widget buildFilterTabs() {
    final filters = ['All', 'Pending', 'Submitted'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: filters.map((filter) {
          final isSelected = selectedFilter == filter;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedFilter = filter),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.purple : Colors.grey,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  filter,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget buildAssignmentList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('classes')
          .doc(widget.userRole.classId)
          .collection('assignments')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading assignments: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No Assignment'));
        }

        final assignments = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Assignment(
            id: doc.id,
            subject: data['subject'] ?? '',
            title: data['title'] ?? '',
            deadline: data['deadline'] ?? '',
            status: data['status'] ?? 'Pending',
            description: data['description'] ?? '',
          );
        }).toList();

        final filtered = selectedFilter == 'All'
            ? assignments
            : assignments.where((a) => a.status == selectedFilter).toList();

        if (filtered.isEmpty) {
          return const Center(child: Text('No Assignment'));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final assignment = filtered[index];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AssignmentDetailScreen(
                      assignment: assignment,
                      userRole: widget.userRole,
                    ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            assignment.subject,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            assignment.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            assignment.deadline,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      assignment.status,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                        color: assignment.status == 'Submitted'
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    if (widget.userRole.isCR) ...[
                      const SizedBox(width: 6),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.redAccent, size: 20),
                        onPressed: () => _deleteAssignment(assignment.id),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class AssignmentDetailScreen extends StatefulWidget {
  final Assignment assignment;
  final UserRole userRole;

  const AssignmentDetailScreen({
    super.key,
    required this.assignment,
    required this.userRole,
  });

  @override
  State<AssignmentDetailScreen> createState() => _AssignmentDetailScreenState();
}

class _AssignmentDetailScreenState extends State<AssignmentDetailScreen> {
  late Assignment assignment;

  @override
  void initState() {
    super.initState();
    assignment = widget.assignment;
  }

  Future<void> submitAssignment() async {
    setState(() {
      assignment.status = 'Submitted';
    });

    if (assignment.id.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('classes')
          .doc(widget.userRole.classId)
          .collection('assignments')
          .doc(assignment.id)
          .update({'status': 'Submitted'});
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assignment submitted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Assignment Detail',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          if (widget.userRole.isCR)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Assignment'),
                    content: const Text(
                        'Are you sure you want to delete this assignment?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );

                if (confirm == true && assignment.id.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('classes')
                      .doc(widget.userRole.classId)
                      .collection('assignments')
                      .doc(assignment.id)
                      .delete();
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              assignment.subject,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              assignment.title,
              style: const TextStyle(fontSize: 15, color: Colors.black),
            ),
            const SizedBox(height: 15),
            buildLabel('Deadline'),
            Text(
              assignment.deadline,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 15),
            buildLabel('Description'),
            Text(
              assignment.description.isEmpty
                  ? 'No description provided.'
                  : assignment.description,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 20),
            buildLabel('Status'),
            Text(
              assignment.status,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: assignment.status == 'Submitted'
                    ? Colors.green
                    : Colors.red,
              ),
            ),
            const Spacer(),
            const SizedBox(height: 12),
            if (widget.userRole.isCR)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: submitAssignment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    assignment.status == 'Pending'
                        ? 'Mark as Completed / Submitted'
                        : 'Reopen (Mark as Pending)',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.grey,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
}
