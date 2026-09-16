import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget{
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}


class _RegisterScreenState extends State<RegisterScreen>{

  final _fullNameController = TextEditingController();
  final _idController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();


  bool _obscurePassword = true;


  @override
  void dispose(){   //for clean the memory

    _fullNameController.dispose();
    _idController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: const Color(0xFF6C5CE7),
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatarPlaceholder(),
            const SizedBox(height: 24),
            _buildTextField(
              controller: _fullNameController,
              hint : 'Full Name',
              icon : Icons.person_outline,
            ),

            const SizedBox(height: 16),
            _buildTextField(
              controller: _idController,
              hint : 'Student ID',
              icon: Icons.badge_outlined,
            ),


            const SizedBox(height: 16),
            _buildTextField(
              controller : _emailController,
              hint : 'Email',
              icon: Icons.email_outlined,
            ),

            const SizedBox(height: 16),
            _buildPasswordField(),

            const SizedBox(height: 24),
            _buildRegisterButton(),

            const SizedBox(height: 16),
            _buildLoginLink(),
          ],
        ),
      ),
    );
  }


  Widget _buildAvatarPlaceholder(){
    return Center(
      child: CircleAvatar(
        radius: 45,
        backgroundColor: Colors.grey.shade200,
        child: Icon(Icons.camera_alt_outlined, size: 30 ,color : Colors.grey.shade600),
      ),
    );
  }


  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  } ){

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText : hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey.shade100,
        border:OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }



  Widget _buildPasswordField(){
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        hintText: 'Password',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility_off: Icons.visibility),
          onPressed: (){
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


  Widget _buildRegisterButton(){
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: (){
          print('Name: ${_fullNameController.text}');
          print('Id: ${_idController.text}');
          print('E-mail: ${_emailController.text}');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C5CE7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text('Register' ,style : TextStyle(fontSize: 16, color: Colors.black)),
      ),
    );
  }



  Widget _buildLoginLink(){
    return Center(
      child: TextButton(
        onPressed: (){
          Navigator.pop(context);   //back to login page
        },
        child: RichText(
          text: const TextSpan(
            style: TextStyle(color: Colors.black87),
            children: [
              TextSpan(text: 'Already have an account?'),
              TextSpan(
                text: 'Login',
                style: TextStyle(color: Color(0xFF6C5CE7), fontWeight:  FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
