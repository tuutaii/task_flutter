import 'package:flutter/material.dart';

class IconButtonCustom extends StatelessWidget {
  const IconButtonCustom({
    Key? key,
    this.iconData,
    this.size,
    this.color,
    this.ontap,
  }) : super(key: key);
  final IconData? iconData;
  final double? size;
  final Color? color;
  final VoidCallback? ontap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: ontap,
        icon: Icon(
          iconData,
          color: color ?? Colors.white,
          size: size ?? 30,
        ));
  }
}
