import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double size;
  final ShapeBorder? shape;
  final Color? bgColor;
  final Color? color;
  final List<Widget>? actions;
  final String? title;
  final TextStyle? titleStyle;
  final Widget? leading;

  const CustomAppBar({
    super.key,
    required this.size,
    this.shape,
    this.bgColor,
    this.color,
    this.leading,
    this.title,
    this.titleStyle,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: AppBar(
        shape: shape,
        backgroundColor: bgColor,
        actions: actions,
        leading: leading,
        title: Center(child: Text(title ?? "", style: titleStyle)), // upgrade flutter and dart
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(size);
}
