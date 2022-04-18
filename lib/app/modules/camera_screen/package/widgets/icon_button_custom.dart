import 'package:flutter/material.dart';

class IconButtonCustom extends StatelessWidget {
  const IconButtonCustom({
    Key? key,
    this.iconData,
    this.size,
    this.color,
    this.onTap,
  }) : super(key: key);
  final IconData? iconData;
  final double? size;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: onTap,
        icon: Icon(
          iconData,
          color: color ?? Colors.white,
          size: size ?? 40,
        ));
  }
}
