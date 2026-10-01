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
  String? year;
  String? semester;
  String? section;
  String? studentType;

  bool _obscurePassword = true;
  bool _isLoading = false;

  String error = '';

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
              const SizedBox(height: 10),
              _buildTextField(
                controller: _fullNameController,
                hint: 'Full Name',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
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
                items: const [
                  'CSE',
                  'EEE',
                  'ME',
                  'CIVIL',
                  'TEXTILE',
                  'IPE',
                  'BBA'
                ],
                onChanged: (value) => setState(() => department = value),
              ),
              const SizedBox(height: 16),
              buildDropDown(
                hint: 'Academic Year',
                icon: Icons.calendar_month_outlined,
                value: year,
                items: const [
                  '1st Year',
                  '2nd Year',
                  '3rd Year',
                  '4th Year'
                ],
                onChanged: (value) => setState(() => year = value),
              ),
              const SizedBox(height: 16),
              buildDropDown(
                hint: 'Semester',
                icon: Icons.calendar_today,
                value: semester,
                items: const [
                  '1st Semester',
                  '2nd Semester'
                ],
                onChanged: (value) => setState(() => semester = value),
              ),
              const SizedBox(height: 16),
              buildDropDown(
                hint: 'Section',
                icon: Icons.groups_outlined,
                value: section,
                items: const [
                  'Section A',
                  'Section B',
                  'Section C',
                  'Section D'
                ],
                onChanged: (value) => setState(() => section = value),
              ),
              const SizedBox(height: 16),
              buildDropDown(
                hint: 'Role (CR or Student)',
                icon: Icons.person_2_outlined,
                value: studentType,
                items: const [
                  'Class Representative (CR)',
                  'Student'
                ],
                onChanged: (value) => setState(() => studentType = value),
              ),
              const SizedBox(height: 16),
              _buildPasswordField(),
              const SizedBox(height: 24),
              _buildRegisterButton(),
              const SizedBox(height: 16),
              _buildLoginLink(),
              if (error.isNotEmpty) ...[
                const SizedBox(height: 12.0),
                Center(
                  child: Text(
                    error,
                    style: const TextStyle(color: Colors.red, fontSize: 14.0),
                  ),
                ),
              ],
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
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,

      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select $hint';
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

      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),

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
        onPressed: _isLoading
            ? null
            : () async {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    _isLoading = true;
                    error = '';
                  });

                  final bool isCR = studentType?.contains('(CR)') ?? false;

                  dynamic result =
                      await AuthService().registerWithEmailAndPassword(
                    fullName: _fullNameController.text.trim(),
                    studentId: _idController.text.trim(),
                    email: _emailController.text.trim(),
                    password: _passwordController.text,
                    department: department!,
                    year: year!,
                    semester: semester!,
                    section: section!,
                    studentType: studentType!,
                    isCR: isCR,
                  );

                  if (!mounted) return;
                  setState(() {
                    _isLoading = false;
                  });

                  if (result == null) {
                    setState(() {
                      error = 'Registration failed. Please check your credentials and try again.';
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Registration successful! Please login.'),
                        backgroundColor: Colors.green,
                      ),
                    );

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
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
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                'Register',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
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
