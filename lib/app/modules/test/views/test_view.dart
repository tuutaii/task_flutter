import 'package:basesource/app/modules/camera_screen/views/camera_package.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../../../main.dart';

class TestView extends StatefulWidget {
  const TestView({Key? key}) : super(key: key);

  @override
  _TestViewState createState() => _TestViewState();
}

class _TestViewState extends State<TestView> {
  late CameraController controller;
  void initCamera(int cameraId) {
    controller = CameraController(
      cameras[cameraId],
      ResolutionPreset.max,
    );

    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    initCamera(0);
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CameraUIPackage(),
    );
  }
}
