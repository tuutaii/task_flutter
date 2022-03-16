import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class TagWidget extends StatelessWidget {
  const TagWidget(this.title, {Key? key}) : super(key: key);
  final String title;
  @override
  Widget build(BuildContext context) {
    return title.text
        .size(8)
        .color(const Color(0xff212862))
        .make()
        .box
        .padding(const EdgeInsets.symmetric(
          vertical: 2,
          horizontal: 7,
        ))
        .white
        .border(color: const Color(0xff212862))
        .make();
  }
}
