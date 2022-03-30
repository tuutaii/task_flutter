import 'package:flutter/material.dart';

class ButtonCustom extends StatelessWidget {
  const ButtonCustom({
    Key? key,
    this.icon,
    this.color,
    this.height,
    this.width,
  }) : super(key: key);
  final Widget? icon;
  final Color? color;
  final double? height, width;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width ?? 70,
        height: height ?? 70,
        decoration: BoxDecoration(
          color: color ?? Colors.white,
          borderRadius: BorderRadius.circular(50.0),
        ),
        child: icon);
  }
}
