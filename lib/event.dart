/*import 'package:flutter/material.dart';


enum EventCategory {seminar , workshop , cultural}

class Event{
  final String id;
  final String title;
  final String location;

  final DateTime dateTime;

  final EventCategory category;



  const Event({
    required this.id,
    required this.title,
    required this.location,

    required this.dateTime,

    required this.category,
});


  IconData get icon{

    switch(category){

      case EventCategory.seminar : return Icons.event;

      case EventCategory.workshop : return Icons.computer;

      case EventCategory.cultural : return Icons.emoji_events_outlined;
    }
  }
}



final List<Event> mockEvents = [
  Event(
    id: '1',
    title: 'Flutter Workshop',
    location: 'Lab 3',
    dateTime: DateTime.now(),
    category: EventCategory.workshop,
  ),
];




class EventScreen extends StatefulWidget{


  final List<Event>? events;

  const EventScreen ({super.key , required this.events});


  @override
  State<EventScreen> createState()=> _EventScreenState();
}


class _EventScreenState extends State<EventScreen>{

  late List<Event> events;
  late DateTime visibleMonth;
  late DateTime selectedDate;


  static const weekdayLabels = ['Mon' , 'Tue' , 'Wed' , 'Thu' , 'Fri' , 'Sat' , 'Sun' ];

  static const monthNames = [ 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];


  @override

  void initState(){

    super.initState();

    final incomingEvents = widget.events;

    events = List<Event>.from(
        (incomingEvents != null && incomingEvents.isNotEmpty) ? incomingEvents : mockEvents
    );

    //events = List.from(widget.events.isNotEmpty ? widget.events : mockEvents);



    final now = DateTime.now();     //Default set the current date and month

    visibleMonth = DateTime(now.year , now.month , 1);

    selectedDate = now;
  }



  void goToPreviousMonth(){
    setState(() {
      visibleMonth = DateTime(visibleMonth.year , visibleMonth.month -1 , 1);
    });
  }


  void goToNextMonth(){
    setState(() {
      visibleMonth = DateTime(visibleMonth.year , visibleMonth.month + 1 , 1);
    });
  }



  bool isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  bool hasEventOn(DateTime day) => events.any((e) => isSameDay(e.dateTime, day));


  List<Event> get upcomingEvents{
    final list = events.toList()..sort((a,b) => a.dateTime.compareTo(b.dateTime));

    return list;
  }


  List<DateTime?> buildMonthCells(){
    
    final firstDay = DateTime(visibleMonth.year , visibleMonth.month , 1);
    
    final daysInMonth = DateTime(visibleMonth.year , visibleMonth.month + 1 , 0).day;
    
    final leadingBlanks = firstDay.weekday - 1;


    final cells = <DateTime?>[];
    for (int i = 0; i < leadingBlanks; i++) {
      cells.add(null);
    }
    for (int d = 1; d <= daysInMonth; d++) {
      cells.add(DateTime(visibleMonth.year, visibleMonth.month, d));
    }
    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    return cells;
    
  }
  
  
  void deleteEvent(String id){
    setState(() {
      events.removeWhere((e) => e.id == id);
    });
  }
  
  
  
  
  void showAddEventSheet(DateTime date){
    
    final titileController = TextEditingController();
    final locationController = TextEditingController();
    
    
    EventCategory selectedCategory = EventCategory.seminar;
    
    
    int selectedHour = 10;
    int selectedMinute = 0;
    
    
    showModalBottomSheet(
        context: context, 
        
        isScrollControlled: true,
        
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        
        
        builder: (context) => StatefulBuilder(
            
            builder: (context , setModalState) => Padding(
                
                
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  
                  left: 20,
                  right: 20,
                  
                  top: 20,
                ),
              
              child: Column(
                mainAxisSize:  MainAxisSize.min,
                
                crossAxisAlignment: CrossAxisAlignment.start,
                
                
                children: [
                  Text('Add Event for ${date.day} ${monthNames[date.month - 1]} ${date.year}',
                  
                  style: const TextStyle(fontWeight: FontWeight.bold , fontSize: 18),
                  ),
                  
                  
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: titileController,
                    
                    decoration:  const InputDecoration(
                      labelText: 'Event Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  
                  
                  const SizedBox(height: 16),

                  TextField(
                    controller: locationController,

                    decoration:  const InputDecoration(
                      labelText: 'Location',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  
                  
                  const SizedBox(height: 16),
                  
                  DropdownButtonFormField<EventCategory>(
                      
                    value: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      
                      items: EventCategory.values.map((category){
                        
                        return DropdownMenuItem(
                            
                          value:  category,
                            child: Text(category.name.toUpperCase()),
                        );
                      }).toList(),
                      
                      
                      
                      onChanged: (val) {
                      
                      if(val != null){
                        setModalState(() => selectedCategory = val);
                      }
                      },
                  
                  
                  ),
                  
                  
                  
                  const SizedBox(height: 12),
                  
                  
                  Row(
                    children: [
                      
                      const Text('Time: ' ,style: TextStyle(fontWeight: FontWeight.w500 , fontSize: 15)),
                      
                      const SizedBox(width: 12),
                      
                      Expanded(
                          
                          
                          child: DropdownButtonFormField<int>(
                              
                            value: selectedHour,
                              decoration: const InputDecoration(
                                labelText: 'Hour',
                                border: OutlineInputBorder(),
                                
                                isDense: true,
                              ),
                              
                              items: List.generate(24 , (index) => index).map((hour){
                                
                                final displayHour = hour == 0 ? 12 : (hour>12 ? hour - 12 : hour);
                                
                                final amPm = hour >= 12  ? 'Pm' : 'AM';
                                
                                return DropdownMenuItem(
                                  value : hour,
                                  
                                  child: Text('$displayHour $amPm'),
                                );
                                
                              }).toList(),
                              
                              onChanged: (val) {
                              
                              if(val != null) 
                                setModalState(() => selectedHour = val);
                              
                              
                              },
                          
                          ),
                        
                      ),
                      
                      
                      const SizedBox(width: 12),
                      
                      Expanded(
                          
                          
                          child: DropdownButtonFormField<int>(
                            
                            value: selectedMinute,
                              
                            decoration: const InputDecoration(
                              
                              labelText: 'Minute',
                              
                              border: OutlineInputBorder(),
                              
                              isDense: true,
                            ),
                            
                            items: [0,15,30,45,].map((minute){
                              
                              return DropdownMenuItem(
                                  
                                value: minute,
                                  child: Text(minute.toString().padLeft(2 , '0')),
                              
                              );
                            }).toList(),
                            
                            onChanged: (val){
                              if(val != null)
                                setModalState(()=> selectedMinute = val);
                            },
                          ),
                      
                      
                      ),
                      
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  SizedBox(
                    width: double.infinity,
                    
                    child: ElevatedButton(

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,

                        padding: const EdgeInsets.symmetric(vertical: 14),

                      ),

                        onPressed: (){

                        if(titileController.text.trim().isNotEmpty){
                          setState(() {
                            events.add(
                              Event(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),

                                title:  titileController.text.trim(),

                                dateTime: DateTime(
                                  date.year,
                                  date.month,
                                  date.day,

                                  selectedHour,
                                  selectedMinute,

                                ),


                                location: locationController.text.trim().isEmpty ? 'campus' : locationController.text.trim(),

                                category: selectedCategory,
                              ),
                            );

                            selectedDate = date;
                          });

                          Navigator.pop(context);


                        }
                        },

                        child: const Text(
                          'Save Event', style: TextStyle(color: Colors.white ,fontSize: 16),
                        ),

                    ),
                  ),
                  
                ],
              ),
            ),
        
        ),
    
    );
  }
  


  @override

  Widget build(BuildContext context){

    return Scaffold(

      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.deepOrange,

        elevation: 0,

        centerTitle: true,

        title: const Text('Events',

          style: TextStyle(color: Colors.black , fontWeight: FontWeight.w600 , fontSize: 20),
        ),
      ),


      body: ListView(

        padding: const EdgeInsets.symmetric(horizontal: 16),

        children: [

          buildMonthHeader(),
          const SizedBox(height: 12),

          buildWeekdayRow(),
          const SizedBox(height: 8),

          buildMonthGrid(),
          const SizedBox(height: 24),

          const Text('Upcoming Events' , style: TextStyle(fontSize: 16 , fontWeight: FontWeight.w700),
          ),


          const SizedBox(height: 12),

          if(upcomingEvents.isEmpty)
            const Padding(

                padding: EdgeInsets.symmetric(vertical: 24),

              child: Center(child: Text('No Upcoming Events.')),
            )

          else
            ...upcomingEvents.map(
                (e) => EventTile(
                  event: e,
                  onDelete: () => deleteEvent(e.id),
                ),
            ),

          const SizedBox(height: 16),

        ],
      ),


    );
  }




  Widget buildMonthHeader(){
    return Row(

      mainAxisAlignment:  MainAxisAlignment.spaceBetween,

      children: [
        IconButton(
            onPressed: goToPreviousMonth,
            icon: const Icon(Icons.chevron_left , color: Colors.black),
        ),

        Text(
          '${monthNames [ visibleMonth.month -1]} ${visibleMonth.year}',

          style: const TextStyle(fontWeight: FontWeight.w600 , fontSize: 16),
        ),


        IconButton(
          onPressed: goToNextMonth,
          icon: const Icon(Icons.chevron_right , color: Colors.black),
        ),
      ],
    );
  }


  Widget buildWeekdayRow(){
    return Row(

      children: weekdayLabels.map(
          (label) => Expanded(

              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight:  FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),

          ),
      ).toList(),
    );
  }




  Widget buildMonthGrid() {
    final cells = buildMonthCells();
    final today = DateTime.now();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cells.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 6,
      ),
      itemBuilder: (context, index) {
        final day = cells[index];
        if (day == null) return const SizedBox.shrink();

        final isSelected = isSameDay(day, selectedDate);
        final isCurrentMonth = day.month == visibleMonth.month;
        final isToday = isSameDay(day, today);
        final hasEvent = hasEventOn(day);

        return GestureDetector(
          onTap: () {
            setState(() => selectedDate = day);
            showAddEventSheet(day);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? Colors.blue : Colors.transparent,
                  border: isToday && !isSelected
                      ? Border.all(color: Colors.blue, width: 1)
                      : null,
                ),
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : isCurrentMonth
                        ? Colors.black87
                        : Colors.black26,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13.5,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hasEvent ? Colors.blue : Colors.transparent,
                ),
              ),
            ],
          ),
        );
      },
    );
  }



}




class EventTile extends StatelessWidget{
  final Event event;
  final VoidCallback onDelete;


  const EventTile({required this.event , required this.onDelete});


  String formatDateTime(DateTime d){

    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',];

    final hour12 = d.hour %12 ==0 ? 12 : d.hour %12;

    final ampm = d.hour >= 12 ? 'PM' : 'AM';

    final minute = d.minute.toString().padLeft(2 , '0');

    return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} '  '${d.year} - $hour12:$minute $ampm';


  }


  @override
  Widget build(BuildContext context){

    return Padding(

        padding: const EdgeInsets.only(bottom:  18),

      child: Row(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Container(
            width: 40,
            height: 40,

            decoration: BoxDecoration(

             //color: Colors.withOpacity(0.12),

              borderRadius:  BorderRadius.circular(10),

            ),

            child: Icon(event.icon , color: Colors.blue)
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(

                    event.title,

                  style: const TextStyle(
                    fontWeight:  FontWeight.w600,
                    fontSize: 14,
                  ),


                ),



                const SizedBox(height: 3),

                Text(
                  formatDateTime(event.dateTime),

                  style: const TextStyle(color: Colors.black , fontSize: 13),

                ),


                const SizedBox(height: 2),

                Text(
                  event.location,
                  style: const TextStyle(color: Colors.black38 , fontSize:  12),
                ),
              ],
            ),
          ),


          IconButton(
            icon: const Icon(Icons.delete_outline , color: Colors.red , size : 25),

            onPressed: onDelete,

            tooltip: 'Delete Event',
          ),
        ],
      ),

    );
  }

}


 */
