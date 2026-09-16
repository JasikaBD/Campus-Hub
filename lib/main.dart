import 'package:flutter/material.dart';
import 'login.dart';

void main(){

  runApp(const MyApp());
}

class MyApp extends StatelessWidget{

  const MyApp({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      theme: ThemeData(
        primaryColor: const Color(0xFF6C5CE7),
        scaffoldBackgroundColor: const Color(0xFF6C5CE7),
      ),
      home: const LoginScreen(),
    );
  }
}
