import 'package:flutter/material.dart';
import 'routineData.dart';

class RoutineScreen extends StatefulWidget {
  const RoutineScreen({super.key});

  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  @override
  final List<String> days = [

    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ];
  int selectedDayIndex = DateTime.now().weekday - 1;
  Widget build(BuildContext context) {
    String selectedDayName = days[selectedDayIndex];

    List<Map<String, String>> currentClasses = routine[selectedDayName] ?? [];
    return Scaffold(
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

      ),



      body: Column(
        children: [
          SizedBox(height: 30,),
          SingleChildScrollView(
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
                      padding: EdgeInsets.all(20),
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
        ],
      ),
    );
  }
}

