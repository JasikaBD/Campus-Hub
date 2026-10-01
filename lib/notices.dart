import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_role.dart';

class NoticeScreen extends StatefulWidget {
  final UserRole userRole;
  const NoticeScreen({super.key, required this.userRole});

  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Notices"),
        actions: [
          if (widget.userRole.isCR)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _showAddNoticeDialog,
            ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('classes')
            .doc(widget.userRole.classId)
            .collection('notices')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No notices yet",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final title = data['title'] ?? '';
              final message = data['message'] ?? '';
              final type = data['type'] ?? 'General Notice';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              type,
                              style: const TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          if (widget.userRole.isCR)
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red, size: 20),
                              onPressed: () => _deleteNotice(doc.id),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: widget.userRole.isCR
          ? FloatingActionButton.extended(
              onPressed: _showAddNoticeDialog,
              backgroundColor: const Color(0xFF6A1B9A),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text("Post Notice",
                  style: TextStyle(color: Colors.white)),
            )
          : null,
    );
  }

  Future<void> _showAddNoticeDialog() async {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String noticeType = 'Exam Notice';
    final types = [
      'Exam Notice',
      'Class Notice',
      'Assignment Notice',
      'General Notice'
    ];

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Post New Notice"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: noticeType,
                      items: types
                          .map((t) =>
                              DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (v) {
                        setDialogState(() => noticeType = v!);
                      },
                      decoration: const InputDecoration(
                        labelText: "Notice Type",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: "Title",
                        hintText: "e.g. Midterm Schedule",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: messageController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: "Message",
                        hintText: "Write details here...",
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
                    final title = titleController.text.trim();
                    final message = messageController.text.trim();
                    if (title.isEmpty || message.isEmpty) return;

                    await FirebaseFirestore.instance
                        .collection('classes')
                        .doc(widget.userRole.classId)
                        .collection('notices')
                        .add({
                      'type': noticeType,
                      'title': title,
                      'message': message,
                      'createdAt': FieldValue.serverTimestamp(),
                    });

                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text("Post"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteNotice(String docId) async {
    await FirebaseFirestore.instance
        .collection('classes')
        .doc(widget.userRole.classId)
        .collection('notices')
        .doc(docId)
        .delete();
  }
}
