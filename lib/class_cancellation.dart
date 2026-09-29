import 'package:flutter/material.dart';

class ClassCancellation extends StatefulWidget {
  const ClassCancellation({super.key});

  @override
  State<ClassCancellation> createState() => _ClassCancellationState();
}

class _ClassCancellationState extends State<ClassCancellation> {
  final List<String> courses = [
    'Database Systems',
    'Data Structures',
    'Operating Systems',
    'Computer Networks',
  ];

  final List<String> timeSlots = [
    '10:00 AM - 11:30 AM',
    '11:30 AM - 1:00 PM',
    '2:00 PM - 3:30 PM',
    '3:30 PM - 5:00 PM',
  ];

  String? selectedCourse;
  String? selectedTimeSlot;
  DateTime? selectedDate;
  final TextEditingController _reasonController = TextEditingController();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  void _cancelClass() {
    if (selectedCourse == null || selectedDate == null || selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in course, date and time slot.')),
      );
      return;
    }


    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Class cancelled successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [

              const Text(
                'Cancel Class',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),


          const Text('Select Course', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: selectedCourse,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            hint: const Text('Choose a course'),
            items: courses
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (value) => setState(() => selectedCourse = value),
          ),
          const SizedBox(height: 20),


          const Text('Select Date', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 6),
          InkWell(
            onTap: _pickDate,
            child: InputDecorator(
              decoration: const InputDecoration(border: OutlineInputBorder()),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedDate == null
                        ? 'Choose a date'
                        : '${selectedDate!.day} ${_monthName(selectedDate!.month)} ${selectedDate!.year}',
                  ),
                  const Icon(Icons.calendar_today, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),


          const Text('Select Time Slot', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: selectedTimeSlot,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            hint: const Text('Choose a time slot'),
            items: timeSlots
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (value) => setState(() => selectedTimeSlot = value),
          ),
          const SizedBox(height: 20),


          const Text('Reason (Optional)', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 6),
          TextField(
            controller: _reasonController,
            maxLines: 3,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'e.g. Teacher is not available.',
            ),
          ),
          const SizedBox(height: 30),


          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _cancelClass,
              child: const Text(
                'Cancel Class',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}