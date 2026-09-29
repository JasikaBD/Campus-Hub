import 'package:campus_hub/login.dart';
//import 'login.dart';
import 'authentication.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _idController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();


  String? department;
  String? semester;
  String? studentType;

  bool _obscurePassword = true;

  String error='';

  @override
  void dispose() {

    _fullNameController.dispose();
    _idController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.deepOrangeAccent,
        foregroundColor: Colors.white,

        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [


              /*
              _buildAvatarPlaceholder(),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _fullNameController,
                hint: 'Full Name',
                icon: Icons.person_outline,
              ),

               */

              const SizedBox(height: 30),
              _buildTextField(
                controller: _idController,
                hint: 'Student ID',
                icon: Icons.badge_outlined,
              ),

              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                hint: 'Email',
                icon: Icons.email_outlined,
              ),


              const SizedBox(height: 16),

              buildDropDown(
                  hint: 'Department',
                  icon: Icons.account_balance_outlined,

                  value: department,

                  items: const['CSE' , 'EEE' , 'ME' , 'CIVIL' , 'TEXTILE' , 'IPE' , 'BBA'],
                  onChanged: (value) => setState(()=> department = value),
              ),




              const SizedBox(height: 16),

              buildDropDown(
                  hint: 'Semester',
                  icon: Icons.calendar_today,
                  value: semester,

                  items: const ['1st' , '2nd' , '3rd' , '4th' , '5th' , '6th' , '7th' , '8th'],
                  onChanged: (value) => setState(() => semester = value ),

              ),


              const SizedBox(height: 16),

              buildDropDown(
                  hint: 'Student Type',
                  icon: Icons.person_2_outlined,
                  value: studentType,
                  items: const ['Admin (CR) ' , 'Normal Student'],
                  onChanged: (value) => setState(()=> studentType = value),
              ),

              const SizedBox(height: 16),
              _buildPasswordField(),

              const SizedBox(height: 24),
              _buildRegisterButton(),

              const SizedBox(height: 16),
              _buildLoginLink(),

              SizedBox(height: 12.0),
              Text(
                error,
                style: TextStyle(color: Colors.red, fontSize: 14.0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /*Widget _buildAvatarPlaceholder() {
    return Center(
      child: CircleAvatar(
        radius: 45,
        backgroundColor: Colors.grey.shade200,
        child: Icon(
          Icons.camera_alt_outlined,
          size: 30,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

   */

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,

      validator: (value){
        if(value==null || value.isEmpty){
          return 'Please enter $hint';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }


  Widget buildDropDown({
    required String hint,
    required IconData icon,
    required String? value,

    required List<String> items,

    required ValueChanged<String?> onChanged,
}){


    return DropdownButtonFormField<String>(

        value : value,
        decoration: InputDecoration(

          hintText: hint,

          prefixIcon: Icon(icon),

          filled:  true,

          fillColor: Colors.grey.shade100,

          border: OutlineInputBorder(

            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),

        ),


        items: items.map((item) => DropdownMenuItem(

            value: item,
            child: Text(item))).toList(),

        onChanged: onChanged,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,

      validator: (value){
        if(value==null || value.isEmpty){
          return 'Please enter your password';
        }
        if(value.length<6){
          return 'Password must be at least 6 characters';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: 'Password',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),

        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () async {
         if(_formKey.currentState!.validate()){
           dynamic result= await AuthService().registerWithEmailAndPassword(

               _fullNameController.text,
               _idController.text,
               _emailController.text,
               _passwordController.text,
           );
           if(result==null){
             setState(() => error = 'Registration failed. Please try again.');
           }else{
             print('Registration successful');

             Navigator.pushReplacement(
                 context,
                 MaterialPageRoute(
                     builder: (context)=> const LoginScreen(),
                 ),
             );
           }
         }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C5CE7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Register',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.pop(context); //back to login page
        },
        child: RichText(
          text: const TextSpan(
            style: TextStyle(color: Colors.black87),
            children: [
              TextSpan(text: 'Already have an account?'),
              TextSpan(
                text: 'Login',
                style: TextStyle(
                  color: Color(0xFF6C5CE7),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
