import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../../../main.dart';
import '../widgets/display_image.dart';

class CameraScreenView extends StatefulWidget {
  const CameraScreenView({Key? key}) : super(key: key);

  @override
  _CameraScreenViewState createState() => _CameraScreenViewState();
}

class _CameraScreenViewState extends State<CameraScreenView> {
  late CameraController controller;
  int camId = 0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 5.0;
  double _currentZoomLevel = 1.0;

  double _minAvailableExposureOffset = -4.0;
  double _maxAvailableExposureOffset = 4.0;
  double _currentExposureOffset = 0.0;

  void initCamera(int cameraId) {
    controller = CameraController(
      cameras[cameraId],
      ResolutionPreset.max,
    );

    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        controller.getMaxZoomLevel().then((value) => _maxAvailableZoom = value);
        controller.getMinZoomLevel().then((value) => _minAvailableZoom = value);

        controller
            .getMinExposureOffset()
            .then((value) => _minAvailableExposureOffset = value);

        controller
            .getMaxExposureOffset()
            .then((value) => _maxAvailableExposureOffset = value);
      });
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
    if (!controller.value.isInitialized) {
      return Container();
    }
    return MaterialApp(
      home: Stack(
        children: [
          CameraPreview(controller),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              increExposure(),
              zoomCamera(),
              Container(
                alignment: Alignment.bottomCenter,
                height: 100,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              camId == 0
                                  ? {initCamera(1), camId = 1}
                                  : {initCamera(0), camId = 0};
                            });
                          },
                          icon: const Icon(
                            Icons.cameraswitch_outlined,
                            size: 30,
                          ),
                        ),
                        RawMaterialButton(
                          onPressed: () async {
                            await takeImage(context);
                          },
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
            ],
          )
        ],
      ),
    );
  }

  Widget increExposure() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(.5),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _currentExposureOffset.toStringAsFixed(1) + 'x',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    decoration: TextDecoration.none),
              ),
            ),
          ),
          RotatedBox(
            quarterTurns: 3,
            child: SizedBox(
              height: 30,
              child: Slider(
                value: _currentExposureOffset,
                min: _minAvailableExposureOffset,
                max: _maxAvailableExposureOffset,
                activeColor: Colors.white,
                inactiveColor: Colors.white30,
                onChanged: (value) async {
                  setState(() {
                    _currentExposureOffset = value;
                  });
                  await controller.setExposureOffset(value);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> takeImage(BuildContext context) async {
    try {
      await controller.initialize();
      final image = await controller.takePicture();
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DisplayPictureScreen(
            imagePath: image.path,
          ),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  Widget zoomCamera() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Slider(
              value: _currentZoomLevel,
              min: _minAvailableZoom,
              max: _maxAvailableZoom,
              activeColor: Colors.white,
              inactiveColor: Colors.white30,
              onChanged: (value) async {
                setState(() {
                  _currentZoomLevel = value;
                });
                await controller.setZoomLevel(value);
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(.5),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _currentZoomLevel.toStringAsFixed(1) + 'x',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    decoration: TextDecoration.none),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
