import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../../../main.dart';

class CameraScreenView extends StatefulWidget {
  const CameraScreenView({Key? key}) : super(key: key);

  @override
  _CameraScreenViewState createState() => _CameraScreenViewState();
}

class _CameraScreenViewState extends State<CameraScreenView> {
  late CameraController controller;

  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return MaterialApp(
      home: Stack(
        children: [
          CameraPreview(controller),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 100,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.cameraswitch_outlined,
                          size: 30,
                        ),
                      ),
                      RawMaterialButton(
                        onPressed: () {},
                        elevation: 2.0,
                        fillColor: Colors.white,
                        child: const Icon(
                          Icons.photo_camera_outlined,
                          size: 40,
                        ),
                        padding: const EdgeInsets.all(15.0),
                        shape: const CircleBorder(),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.collections_outlined,
                        ),
                      )
                    ]),
              ),
            ),
          )
        ],
      ),
    );
  }
}
