import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'dart:math';

class AnimatedChip extends AnimatedWidget {
  AnimatedChip(
      {Key key,
      this.rotationAnimation,
      Animation<Color>  colorAnimation,
      this.offsetAnimation,
      this.text,
      this.onPressed})
      : super(key: key, listenable: colorAnimation);
  Animation<double> rotationAnimation;
  String text;
  VoidCallback onPressed;
  Animation<Offset> offsetAnimation;

  Widget build(BuildContext context) {
    final Animation<Color> animation = listenable;

    return ActionChip(
      elevation: 6,
      backgroundColor: animation.value,
      avatar: _rotationAvatar(rotationAnimation: rotationAnimation,),
      label: Text(text, style: TextStyle(fontSize: 24, color: Colors.white)),
      onPressed: onPressed,
    );
  }
}

class _rotationAvatar extends AnimatedWidget {
  _rotationAvatar({Key key, Animation<double> rotationAnimation})
      : super(key: key, listenable: rotationAnimation);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;
    return Transform.rotate(
        angle: animation.value,
        child: CircleAvatar(
          radius: 15,
          child: Icon(Icons.swap_horizontal_circle, color: Colors.white,),
          backgroundColor: Colors.transparent,
        ));
  }
}

class _offsetText extends AnimatedWidget {
  _offsetText({Key key, Animation<Offset> offsetAnimation, this.text})
      : super(key: key, listenable: offsetAnimation);
  String text;

  @override
  Widget build(BuildContext context) {
    final Animation<Offset> animation = listenable;
    return Transform.translate(
        offset: animation.value,
        child: Text(text, style: TextStyle(fontSize: 24, color: Colors.white)));
  }
}

class LogoApp extends StatefulWidget {
  _LogoAppState createState() => new _LogoAppState();
}

class _LogoAppState extends State<LogoApp> with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> rotationAnimation;
  Animation<Color> colorAnimation;

  initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    rotationAnimation = Tween(begin: 0.0, end: pi).animate(controller);
    colorAnimation =
        ColorTween(begin: Colors.blue, end: Colors.red).animate(controller);
    controller.forward();
  }

  Widget build(BuildContext context) {
    return Center(
      child: AnimatedChip(
          rotationAnimation: rotationAnimation,
          colorAnimation: colorAnimation,
          text: 'task'),
    );
  }

  dispose() {
    controller.dispose();
    super.dispose();
  }
}
