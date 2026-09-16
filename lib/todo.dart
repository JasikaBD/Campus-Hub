import 'package:flutter/material.dart';

class Task {
  String title;
  bool isDone;

  Task(this.title, {this.isDone = false});
}

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final List<Task> _tasks = []; // dynamic array
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void addTask() {

    final text = _controller.text;

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter Task')),
      );
      return;
    }

    setState(() {
      _tasks.add(Task(text));
      _controller.clear();
    });
  }

  void toggleTask(int index) {
    setState(() {
      _tasks[index].isDone = !_tasks[index].isDone;
    });
  }

  void confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm to Delete'),
          content: Text('"${_tasks[index].title}" Want to Delete?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _tasks.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void openDetail(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TasksDetailScreen(task: _tasks[index])),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('My To-Do List')),
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
    if (_tasks.isEmpty) {
      return const Center(
        child: Text('Enter a task'),
      );
    }

    return ListView.builder(
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        final task = _tasks[index];

        return ListTile(
          onTap: () => openDetail(index),
          leading: Checkbox(
            value: task.isDone,
            onChanged: (value) => toggleTask(index),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.isDone ? TextDecoration.lineThrough : null,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => confirmDelete(index),
          ),
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


