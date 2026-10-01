import 'package:flutter/material.dart';
import 'login.dart';
import 'dart:async';


class AppColors{
  static const Color primary = Color(0xFF5B4FE5); //top part of the screen
  static const Color primaryDark = Color(0xFF0B3659); //bottom part of screen
  static const white = Colors.white;
}

class Splash extends StatefulWidget{

  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  int _activeDot = 0;

  Timer?_dotTimer;

  @override

  void initState(){
    super.initState();    //Login after few seconds
    _navigatetologin();



    _dotTimer = Timer.periodic(const Duration(milliseconds: 500), (timer){

      if(!mounted)
        return;

      setState(() {
        _activeDot = (_activeDot + 1)%3;
      });
    });

  }


  @override

  void dispose(){
    _dotTimer?.cancel();
    super.dispose();
  }

  Future<void> _navigatetologin()async{
    await Future.delayed(Duration(milliseconds: 3000), () {});

    if(!mounted)
      return;

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(

      body:  Container(
        width: double.infinity,
        height: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(

            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,

            colors: [AppColors.primary , AppColors.primaryDark],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [

              const Spacer(flex: 3),




              const Icon(
                Icons.school,
                color: Colors.white,
                size: 64,
              ),
              const SizedBox(height: 16),



              const Text(
                'CampusHub',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),

              const SizedBox(height: 6),
              const Text(
                'Stay Connected , Stay Updated',

                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 20),


              //dot

              const Spacer(flex: 3),

              Row(

                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  _dot(active: _activeDot ==0),
                  const SizedBox(width: 4),

                  _dot(active: _activeDot == 1),
                  const SizedBox(width: 4),

                  _dot(active : _activeDot == 2),
                ],
              ),


              const SizedBox(height: 60),

            ],
          ),
        ),
      ),
    );
  }



  Widget _dot(
      {required bool active})
  {
    return AnimatedContainer(

      duration: const Duration(milliseconds: 200),
      width: active ? 20: 6,
      height: 6,

      decoration: BoxDecoration(
        color: active ? Colors.white: Colors.white38,
        borderRadius: BorderRadius.circular(3),
      ),

    );
  }
}





