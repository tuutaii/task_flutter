import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TabWebController extends GetxController {
  final urlCtr = TextEditingController();
  String get url => urlCtr.text;
  bool showLoading = false;
  String data = '';

  late WebViewController webViewController;

  Future<void> loading() async {
    showLoading = true;
    update();
    await Future.delayed(
      const Duration(seconds: 2),
      () => data = 'Data Loaded',
    );
    showLoading = false;
    update();
  }
}
