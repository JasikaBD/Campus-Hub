import 'package:flutter/material.dart';
import 'home.dart';
import 'routine.dart';
import 'notices.dart';
import 'todo.dart';
import 'profile.dart';
import 'user_role.dart';
//import 'event.dart';


class DashBoard extends StatefulWidget {
  final UserRole userRole;
  const DashBoard({super.key, required this.userRole});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  int selectedIndex = 0;



  late final List<Widget> screens;


  //late final List<Event> dashboardEvents;   //new add


  @override
  void initState() {
    super.initState();




    //dashboardEvents = List.from(mockEvents);    //new add

    screens = [
      Home(userRole: widget.userRole),
      RoutineScreen(userRole: widget.userRole),
      NoticeScreen(userRole: widget.userRole),
      const TodoScreen(),
     // EventScreen(events: dashboardEvents),       //new add
      ProfileScreen(userRole: widget.userRole),
    ];
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.userRole.isCR
              ? "CR Dashboard"
              : "Student Dashboard",
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: screens[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF6A1B9A),
        unselectedItemColor: const Color(0xFFD06BDA),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: "Routine",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: "Notices",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.task), label: "Tasks"),

         // BottomNavigationBarItem(icon: Icon(Icons.event), label: "Events"),    //event navigator

          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
