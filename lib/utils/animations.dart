import 'package:flutter/material.dart';

class Animations {
  static Route<void> animatedScreenTransition(Widget screen) {
    return PageRouteBuilder(
      pageBuilder: (context, anim1, anim2) => screen,
      transitionsBuilder: (context, anim1, anim2, child) {
        const begin = Offset(-1.0, 0.0);
        const end = Offset.zero;
        var curve = Curves.ease;
        var curveTween = CurveTween(curve: curve);
        final tween = Tween(begin: begin, end: end).chain(curveTween);
        final offsetAnim = anim1.drive(tween);
        
        return SlideTransition(position: offsetAnim, child: child,);
      },
    );
  }
}
