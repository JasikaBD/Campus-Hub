import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'authentication.dart';
import 'registerpage.dart';
import 'student_dashboard.dart';
import 'routine_home_cr.dart';
import 'user_role.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String error = '';
  // teammate uses student ID field (not email directly)
  final _idController       = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe    = false;
  bool _obscurePassword = true;

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
      child: const Column(
        children: [
          Icon(Icons.school, size: 60, color: Colors.white),
          SizedBox(height: 12),
          Text(
            'CampusHub',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
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
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
      decoration: InputDecoration(
        hintText: 'Student ID',
        prefixIcon: const Icon(Icons.person_outline),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your Student ID' : null,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        hintText: 'Password',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (v) => (v == null || v.isEmpty) ? 'Enter your password' : null,
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
              onChanged: (value) => setState(() => _rememberMe = value!),
            ),
            const Text('Remember me'),
          ],
        ),
        TextButton(onPressed: () {}, child: const Text('Forgot?')),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Login', style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
    );
  }

  // ── Backend login: uses teammate's signInWithStudentIdAndPassword ──
  // After auth succeeds, the returned User.email is parsed with UserRole
  // to determine if the user is a CR or Student → routes accordingly.
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final studentId = _idController.text.trim();
    final password  = _passwordController.text;

    final User? result = await AuthService().signInWithStudentIdAndPassword(
      studentId,
      password,
    );

    if (!mounted) return;

    if (result == null) {
      setState(() => error = 'Invalid Student ID or Password');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid Student ID or Password')),
      );
      return;
    }

    // The stored email encodes role+class: cr.cse.2.1.seca@gmail.com
    final email    = result.email ?? '';
    final userRole = UserRole.fromEmail(email);

    if (userRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Account email format not recognised. '
            'Expected: cr.dept.year.sem.section@gmail.com or student.dept.year.sem.section@gmail.com',
          ),
        ),
      );
      return;
    }

    if (userRole.isCR) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => RoutineHome(userRole: userRole)),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DashBoard(userRole: userRole)),
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
                style: TextStyle(color: Color(0xFF6C5CE7), fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}