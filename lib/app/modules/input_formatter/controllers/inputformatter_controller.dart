import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InputFormatterController extends GetxController {
  final textCtr = TextEditingController();
  final dateCtr = TextEditingController();
  final cardCtr = TextEditingController();
  String get input => textCtr.text;
  String get date => textCtr.text;
  String get card => textCtr.text;
}
