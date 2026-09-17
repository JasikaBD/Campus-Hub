import 'package:flutter/material.dart';


class Assignment {

  String subject;
  String title;
  String deadline;
  String status;
  String description;


  Assignment({                //named parameter
    required this.subject,
    required this.title,
    required this.deadline,
    required this.status,
    required this.description,
});



}




class AssignmentScreen extends StatefulWidget{

  const AssignmentScreen({super.key});


  @override

  State<AssignmentScreen> createState()=> _AssignmentScreenState();
}



class _AssignmentScreenState extends State<AssignmentScreen>{

  String selectedFilter = 'All';

  final List<Assignment> assignments = [];

  List<Assignment> get filteredAssignments{
    if(selectedFilter == 'All')
      return assignments;

    return assignments.where((a) => a.status == selectedFilter).toList();
  }


  @override

  Widget build(BuildContext context){
    return Scaffold(

      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,

        iconTheme: const IconThemeData(color: Colors.black),

        title: const Text('Assignments' ,

          style: TextStyle(color: Colors.black , fontWeight: FontWeight.bold),
        ),

        centerTitle: true,
      ),



      body : Column(

        children: [
          
          buildFilterTabs(),
          
          Expanded(child: buildAssignmentList()),
          
          buildAddButton(),
          
        ],
      ),




    );
  }



  //this part was copied

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
              onPressed: () {
                final subject = subjectController.text.trim();
                final title = titleController.text.trim();
                final deadline = deadlineController.text.trim();

                if (subject.isEmpty || title.isEmpty || deadline.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in subject, title and deadline')),
                  );
                  return;
                }

                setState(() {
                  assignments.add(Assignment(
                    subject: subject,
                    title: title,
                    deadline: deadline,
                    status: 'Pending',
                    description: descriptionController.text.trim(),

                  ));
                });
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
  
  
  Widget buildAddButton(){
    
    return Padding(
        padding: const EdgeInsets.all(16),
      
       child: SizedBox(
         width: double.infinity,
         
         height: 50,
         
         child: ElevatedButton(

             onPressed: showAddAssignmentDialog,

             style: ElevatedButton.styleFrom(
               backgroundColor: Colors.purple,

               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
             ),
             child: const Text('Add Assignment' ,

                 style: TextStyle(color: Colors.white , fontSize: 18),
             ),

         ),
       ),
    
    );
  }



  Widget buildFilterTabs(){

    final filters = ['All' , 'Pending' , 'Submitted'];

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
                  color: isSelected ?  Colors.purple : Colors.grey,
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


  Widget buildAssignmentList(){

    final assignments = filteredAssignments;

    if(assignments.isEmpty){
      return const Center (child: Text('No Assignment'));
    }



    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),

      itemCount: assignments.length,

      itemBuilder: (context , index){
        final assignment = assignments[index];

        return GestureDetector(

          onTap: (){

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AssignmentDetailScreen(assignment: assignment),
              ),
            );
          },
          

          child: Container(

            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            
            decoration: BoxDecoration(
              color: Colors.grey,
              
              borderRadius: BorderRadius.circular(15),

              border: Border.all(color: Colors.grey),
            ),


            child: Container(

              margin: const EdgeInsets.only(bottom: 12),

              padding: const EdgeInsets.all(14),

              decoration: BoxDecoration(

                color: Colors.grey,

                borderRadius: BorderRadius.circular(14),

                border: Border.all(color : Colors.grey),
              ),

              child: Row(

                children: [
                  Expanded(
                      child: Column(

                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(

                            assignment.subject,
                            style: const TextStyle(fontSize: 15 , fontWeight: FontWeight.bold),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            assignment.title,
                            style: const TextStyle(fontSize: 15 , fontWeight: FontWeight.bold),

                          ),

                          const SizedBox(height: 5),


                          Text(

                            assignment.deadline,
                            style: const TextStyle(fontWeight: FontWeight.bold , fontSize: 15),
                          ),

                        ],
                      ),
                  ),

                  Text(
                    assignment.status,

                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,

                      color: assignment.status == 'Submitted' ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),



            ),
          ),
        );
      }
    );
  }

}



class AssignmentDetailScreen extends StatefulWidget{

  final Assignment assignment;

  const AssignmentDetailScreen({super.key , required this.assignment});


  @override
  State<AssignmentDetailScreen> createState()=> _AssignmentDetailScreenState();
}



class _AssignmentDetailScreenState extends State<AssignmentDetailScreen>{

  late Assignment assignment;


  @override

  void initState(){

    super.initState();

    assignment = widget.assignment;
  }




  void submitAssignment() {

    setState(() {
      assignment.status = 'Submitted';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Assignment submitted')),
    );
  }






  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,

        //iconTheme: const IconThemeData(color: Colors.black),

        title: const Text(
          'Assignment Detail',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),

        centerTitle: true,

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
              style: TextStyle(fontSize: 15, color: Colors.black),
            ),

            const SizedBox(height: 15),

            buildLabel('Deadline'),

            Text(
                assignment.deadline,
                style: const TextStyle(fontSize: 15)
            ),

            const SizedBox(height: 15),

            buildLabel('Description'),
            Text(
              assignment.description,
              style: const TextStyle(fontSize: 15),
            ),

            const SizedBox(height: 20),

            buildLabel('Status'),
            Text(
              assignment.status,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.normal,
                color: assignment.status == 'Submitted' ? Colors.green : Colors.red,
              ),

            ),


            const Spacer(),

            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: assignment.status == 'Pending' ? submitAssignment : null,

                style: ElevatedButton.styleFrom(

                  backgroundColor: Colors.purple,

                  disabledBackgroundColor: Colors.grey,

                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),

                child: Text(
                  assignment.status == 'Pending' ? 'Submit Assignment' : 'Already Submitted',
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
        style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.normal),
      ),
    );
  }

}

