import 'package:flutter/material.dart';

import 'class_cancellation.dart';
import 'notice_cr_update.dart';

class RoutineHome extends StatefulWidget {
  const RoutineHome({super.key});
  @override
  State<RoutineHome> createState() => _RoutineHomeState();
}

class _RoutineHomeState extends State<RoutineHome> {
  final List<String> days = const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final Map<String, List<String>> routines = {
    'Monday': [],
    'Tuesday': [],
    'Wednesday': [],
    'Thursday': [],
    'Friday': [],
    'Saturday': [],
    'Sunday': [],
  };

  late String selectedDay;

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedDay = days[DateTime.now().weekday - 1];
  }

  String get todayName => days[DateTime.now().weekday - 1];

  void _addRoutine() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      routines[selectedDay]!.add(_controller.text.trim());
      _controller.clear();
    });
  }

  void _removeRoutine(int index) {
    setState(() {
      routines[selectedDay]!.removeAt(index);
    });
  }

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildRoutineBody(),
      const ClassCancellation(),
      const Notice(),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Campus Hub')),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.note), label: 'Routine'),
          BottomNavigationBarItem(
            icon: Icon(Icons.update),
            label: 'Class Cancellation',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.emergency), label: 'Notice'),
        ],
      ),
    );
  }

  Widget _buildRoutineBody() {
    final todaysList = routines[todayName]!;
    return Column(
      children: [
        SizedBox(
          height: 60,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: days.map((day) {
              final isToday = day == todayName;
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
              IconButton(icon: const Icon(Icons.add), onPressed: _addRoutine),
            ],
          ),
        ),

        Expanded(
          child: ListView.builder(
            itemCount: routines[selectedDay]!.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(routines[selectedDay]![index]),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeRoutine(index),
                ),
              );
            },
          ),
        ),

        const Divider(),

        Container(
          width: double.infinity,
          color: Colors.purple.shade100,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today\'s Routine ($todayName):',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              if (todaysList.isEmpty)
                const Text('No routine added for today yet.')
              else
                ...todaysList.map((r) => Text('• $r')),
            ],
          ),
        ),
      ],
    );
  }
}
