import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {

  final Widget child;

  const AuthBackground({
    Key? key, 
    required this.child
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          
          _PurpleBox(),
          
          _HeaderIcon(),

          this.child,

        ],
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: 30),
        child: Icon(Icons.person_pin, color: Colors.white, size: 100,),
      ),
    );
  }
}

class _PurpleBox extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    
    final size = MediaQuery.of(context).size;
    
    return Container(
      width: double.infinity,
      height: size.height * 0.4,
      decoration: _purpleBackground(),
      child: Stack(
        children: [
          Positioned(child: _Bubble(radius: 100), top: -40, left: -30),
          Positioned(child: _Bubble(radius: 60), top: 110, left: 40),
          Positioned(child: _Bubble(radius: 120), top: -50, right: -20),
          Positioned(child: _Bubble(radius: 30), top: 70, left: 150),
          Positioned(child: _Bubble(radius: 40), bottom: 40, left: 170),
          Positioned(child: _Bubble(radius: 90), bottom: -30, left: 10),
          Positioned(child: _Bubble(radius: 100), bottom: 100, right: 90),
          Positioned(child: _Bubble(radius: 80), bottom: 10, right: -30),
        ],
      ),
    );
  }

  BoxDecoration _purpleBackground() => BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Color.fromRGBO(63, 63, 156, 1),
        Color.fromRGBO(90, 70, 178, 1)
      ]
    )
  );
}

class _Bubble extends StatelessWidget {
  
  final double radius;

  const _Bubble({
    Key? key,
    required this.radius,   
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: this.radius,
      height: this.radius,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: Color.fromRGBO(255, 255, 255, 0.05)
      ),
    );
  }
}