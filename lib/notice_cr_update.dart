import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Notice extends StatefulWidget {
  const Notice({super.key});

  @override
  State<Notice> createState() => _NoticeState();
}

class _NoticeState extends State<Notice> {
  bool _showClassNotice = true;

  Future<void> _openOfficialNotice() async {
    final url = Uri.parse('https://www.aust.edu/notice');
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        actions: [
          TextButton.icon(
            onPressed: () {
              setState(() => _showClassNotice = false);
              _openOfficialNotice();
            },
            icon: const Icon(Icons.public, color: Colors.deepPurple, size: 18),
            label: Text(
              'AUST Notice',
              style: TextStyle(
                color: !_showClassNotice ? Colors.deepPurple : Colors.black,
                fontWeight: !_showClassNotice
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () => setState(() => _showClassNotice = true),
            icon: const Icon(
              Icons.edit_note,
              color: Colors.deepPurple,
              size: 18,
            ),
            label: Text(
              'Class Notice',
              style: TextStyle(
                color: _showClassNotice ? Colors.deepPurple : Colors.black,
                fontWeight: _showClassNotice
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: _showClassNotice
                ? const ClassNoticeForm()
                : const _AustNoticePlaceholder(),
          ),
        ],
      ),
    );
  }
}


class _AustNoticePlaceholder extends StatelessWidget {
  const _AustNoticePlaceholder();

  Future<void> _reopen() async {
    final url = Uri.parse('https://www.aust.edu/notice');
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.public, size: 40, color: Colors.deepPurple),
          const SizedBox(height: 12),
          const Text(
            'AUST official notices open in your browser.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: _reopen, child: const Text('Open again')),
        ],
      ),
    );
  }
}

class ClassNoticeForm extends StatefulWidget {
  const ClassNoticeForm({super.key});

  @override
  State<ClassNoticeForm> createState() => _ClassNoticeFormState();
}

class _ClassNoticeFormState extends State<ClassNoticeForm> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String _noticeType = 'Exam Notice';

  final _types = const [
    'Exam Notice',
    'Class Notice',
    'Assignment Notice',
    'General Notice',
  ];

  void _postNotice() {
    if (_titleController.text.trim().isEmpty ||
        _messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in Title and Message.')),
      );
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Notice posted')));


    setState(() {
      _titleController.clear();
      _messageController.clear();
      _noticeType = 'Exam Notice';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Notice Type', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _noticeType,
          items: _types
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          onChanged: (v) => setState(() => _noticeType = v!),
          decoration: _fieldDecoration(),
        ),

        const SizedBox(height: 18),
        const Text('Title', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 6),
        TextField(
          controller: _titleController,
          decoration: _fieldDecoration(hint: 'e.g. Midterm Exam Schedule'),
        ),

        const SizedBox(height: 18),
        const Text('Message', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 6),
        TextField(
          controller: _messageController,
          maxLines: 4,
          decoration: _fieldDecoration(
            hint: 'Write the notice details here...',
          ),
        ),

        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _postNotice,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            child: const Text(
              'Post Notice',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _fieldDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }
}
