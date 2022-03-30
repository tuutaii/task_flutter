import 'package:basesource/app/modules/camera_screen/package/camera_picker.dart';
import 'package:flutter/material.dart';

class CameraScreenView extends StatefulWidget {
  const CameraScreenView({Key? key}) : super(key: key);

  @override
  _CameraScreenViewState createState() => _CameraScreenViewState();
}

class _CameraScreenViewState extends State<CameraScreenView> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: SafeArea(
      child: CameraPickerCustom(),
    ));
  }
}
