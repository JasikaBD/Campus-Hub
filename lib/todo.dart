import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_role.dart';

class Task {
  String? id;
  String title;
  bool isDone;
  Timestamp? createdAt;

  Task({this.id, required this.title, this.isDone = false, this.createdAt});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isDone': isDone,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  factory Task.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      isDone: data['isDone'] ?? false,
      createdAt: data['createdAt'],
    );
  }
}

class TodoScreen extends StatefulWidget {
  final UserRole userRole;
  const TodoScreen({super.key, required this.userRole});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TextEditingController _controller = TextEditingController();

  // Cache the UID so it doesn't get lost when switching tabs
  late final String? currentUserId;

  @override
  void initState() {
    super.initState();
    // Grab the UID once when the screen loads
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
  }

  // Reference to Firestore collection specific to THIS user: users -> {uid} -> tasks
  CollectionReference? get _tasksRef {
    final uid = currentUserId;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('tasks');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> addTask() async {
    final text = _controller.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter Task')),
      );
      return;
    }

    if (_tasksRef == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: User not logged in')),
      );
      return;
    }

    try {
      // Add task to this user's private collection
      await _tasksRef!.add({
        'title': text,
        'isDone': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _controller.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add task: $e')),
      );
    }
  }

  Future<void> toggleTask(String? taskId, bool currentStatus) async {
    if (taskId == null || _tasksRef == null) return;
    try {
      await _tasksRef!.doc(taskId).update({'isDone': !currentStatus});
    } catch (e) {
      print("Error updating task: $e");
    }
  }

  void confirmDelete(String? taskId, String taskTitle) {
    if (taskId == null || _tasksRef == null) return;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm to Delete'),
          content: Text('"$taskTitle" Want to Delete?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _tasksRef!.doc(taskId).delete();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void openDetail(Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TasksDetailScreen(task: task)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('My Personal Tasks')),
      body: Column(
        children: [
          _buildInputRow(),
          Expanded(child: _buildTaskList()),
        ],
      ),
    );
  }

  Widget _buildInputRow() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Add New Task',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: addTask,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    if (_tasksRef == null) {
      return const Center(child: Text('Please log in to view tasks.'));
    }

    // StreamBuilder automatically syncs real-time updates for this individual user
    return StreamBuilder<QuerySnapshot>(
      stream: _tasksRef!.orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No tasks yet. Enter a task!'));
        }

        final tasks = snapshot.data!.docs
            .map((doc) => Task.fromFirestore(doc))
            .toList();

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];

            return ListTile(
              onTap: () => openDetail(task),
              leading: Checkbox(
                value: task.isDone,
                onChanged: (value) => toggleTask(task.id, task.isDone),
              ),
              title: Text(
                task.title,
                style: TextStyle(
                  decoration: task.isDone ? TextDecoration.lineThrough : null,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => confirmDelete(task.id, task.title),
              ),
            );
          },
        );
      },
    );
  }
}

class TasksDetailScreen extends StatelessWidget {
  final Task task;

  const TasksDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          task.title,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}