import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'authentication.dart';
import 'registerpage.dart';
import 'student_dashboard.dart';
import 'user_role.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String error = '';
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildLoginForm()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF6C5CE7), Color(0xFF5849C2)],
        ),
      ),
      child: Column(
        children: const [
          Icon(Icons.school, size: 60, color: Colors.white),
          SizedBox(height: 12),
          Text(
            'CampusHub',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Stay Connected. Stay Updated.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Student Login',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildIdField(),
              const SizedBox(height: 16),
              _buildPasswordField(),
              const SizedBox(height: 12),
              _buildRememberRow(),
              const SizedBox(height: 24),
              _buildLoginButton(),
              const SizedBox(height: 16),
              _buildRegisterLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIdField() {
    return TextFormField(
      controller: _idController,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your Student ID or Email';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: 'Student ID or Email',
        prefixIcon: const Icon(Icons.person_outline),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
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

  Widget _buildRememberRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value!;
                });
              },
            ),
            const Text('Remember me'),
          ],
        ),
        TextButton(
          onPressed: () {},
          child: const Text('Forgot?'),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C5CE7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text('Login', style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final studentId = _idController.text.trim();
    final password = _passwordController.text;

    dynamic result = await AuthService().signInWithStudentIdAndPassword(
      studentId,
      password,
    );

    if (!mounted) return;

    if (result == null) {
      setState(() {
        error = 'Invalid Student ID or Password';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid Student ID or Password'),
        ),
      );
    } else {
      String email = result.email ?? '';
      if (email.isEmpty && studentId.contains('@')) {
        email = studentId;
      }
      if (email.isEmpty) {
        try {
          final doc = await FirebaseFirestore.instance
              .collection('students')
              .doc(result.uid)
              .get();
          if (doc.exists) {
            email = doc.data()?['email'] ?? '';
          }
        } catch (_) {}
      }

      final userRole = UserRole.fromEmail(email) ??
          UserRole(
            isCR: false,
            department: 'cse',
            year: '2',
            semester: '1',
            section: 'seca',
            email: email,
          );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashBoard(userRole: userRole),
        ),
      );
    }
  }

  Widget _buildRegisterLink() {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RegisterScreen()),
          );
        },
        child: RichText(
          text: const TextSpan(
            style: TextStyle(color: Colors.black87),
            children: [
              TextSpan(text: "Don't have an account? "),
              TextSpan(
                text: 'Register',
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