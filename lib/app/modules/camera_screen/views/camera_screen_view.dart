import 'dart:io';

import 'package:basesource/app/modules/camera_screen/widgets/display_video.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../../../../main.dart';
import '../widgets/display_image.dart';

class CameraScreenView extends StatefulWidget {
  const CameraScreenView({Key? key}) : super(key: key);

  @override
  _CameraScreenViewState createState() => _CameraScreenViewState();
}

class _CameraScreenViewState extends State<CameraScreenView>
    with TickerProviderStateMixin {
  late CameraController controller;
  VideoPlayerController? videoController;
  int camId = 0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 5.0;
  double _currentZoomLevel = 1.0;
  double _baseZoomLevel = 1.0;

  double _minAvailableExposureOffset = -4.0;
  double _maxAvailableExposureOffset = 4.0;
  double _currentExposureOffset = 0.0;

  late AnimationController _focusModeControlRowAnimationController;
  late Animation<double> _focusModeControlRowAnimation;

  var tabIndex = 0;

  FlashMode? _currentFlash;

  bool _isVideoCameraSelected = false;
  bool _isRecordingInProgress = false;

  XFile? imageFile;
  XFile? videoFile;

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

        _currentFlash = controller.value.flashMode;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    initCamera(0);

    _focusModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _focusModeControlRowAnimation = CurvedAnimation(
      parent: _focusModeControlRowAnimationController,
      curve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    videoController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Stack(
        children: [
          CameraPreview(
            controller,
            child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              return GestureDetector(
                onScaleStart: (detail) {
                  _currentZoomLevel = _baseZoomLevel;
                },
                onScaleUpdate: handleScale,
                onTapDown: (TapDownDetails details) =>
                    onViewFinderTap(details, constraints),
              );
            }),
          ),
          _isRecordingInProgress
              ? const Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    'Recording ...',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        decoration: TextDecoration.none),
                  ),
                )
              : const SizedBox(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              increExposure(),
              zoomCamera(),
              flashMode(),
              switchCamera(),
              Container(
                alignment: Alignment.bottomCenter,
                height: 100,
                color: Colors.black,
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
                              CupertinoIcons.switch_camera_solid,
                              color: Colors.white,
                              size: 40,
                            )),
                        InkWell(
                          onTap: _isVideoCameraSelected
                              ? () async {
                                  if (_isRecordingInProgress) {
                                    videoFile = await stopVideoRecording();
                                    _startVideoPlayer();
                                  } else {
                                    await startVideoRecording();
                                  }
                                }
                              : () async {
                                  imageFile = await takePicture();
                                  setState(() {
                                    imageFile;
                                  });
                                },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.circle,
                                color: _isVideoCameraSelected
                                    ? Colors.white
                                    : Colors.white38,
                                size: 80,
                              ),
                              Icon(
                                Icons.circle,
                                color: _isVideoCameraSelected
                                    ? Colors.red
                                    : Colors.white,
                                size: 65,
                              ),
                              _isVideoCameraSelected && _isRecordingInProgress
                                  ? const Icon(
                                      Icons.stop_rounded,
                                      color: Colors.white,
                                      size: 32,
                                    )
                                  : Container(),
                            ],
                          ),
                        ),
                        thumnailImage()
                      ]),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
  Widget thumnailImage() {
    return Hero(
      tag: 'galley',
      child: GestureDetector(
        onTap: () {
          imageFile != null
              ? Get.to(() => DisplayPictureScreen(imagePath: imageFile!.path))
              : Get.to(() => DisplayVideoScreen(videoPath: videoController!));
        },
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(50.0),
            border: Border.all(color: Colors.white, width: 2),
            image: imageFile != null
                ? DecorationImage(
                    image: FileImage(File(imageFile!.path)),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: videoController != null && videoController!.value.isInitialized
              ? CircleAvatar(
                  radius: 30,
                  child: ClipOval(child: VideoPlayer(videoController!)),
                )
              : Container(),
        ),
      ),
    );
  }

  Widget switchCamera() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FlutterToggleTab(
          isShadowEnable: true,
          selectedIndex: tabIndex,
          width: 80,
          borderRadius: 16,
          height: 46,
          selectedBackgroundColors: const [Colors.white],
          selectedTextStyle: const TextStyle(
            color: Colors.black,
          ),
          unSelectedTextStyle: const TextStyle(color: Colors.black54),
          labels: const ['Camera', 'Video'],
          selectedLabelIndex: (index) {
            setState(() {
              tabIndex = index;
              if (index == 0) {
                _isVideoCameraSelected = false;
              } else {
                _isVideoCameraSelected = true;
              }
            });
          },
        ),
      ),
    );
  }

  Widget flashMode() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        InkWell(
          onTap: () async {
            setState(() {
              _currentFlash = FlashMode.off;
            });
            await controller.setFlashMode(
              FlashMode.off,
            );
          },
          child: Icon(
            Icons.flash_off,
            color: _currentFlash == FlashMode.off ? Colors.amber : Colors.white,
          ),
        ),
        InkWell(
          onTap: () async {
            setState(() {
              _currentFlash = FlashMode.torch;
            });
            await controller.setFlashMode(
              FlashMode.torch,
            );
          },
          child: Icon(
            Icons.highlight,
            color:
                _currentFlash == FlashMode.torch ? Colors.amber : Colors.white,
          ),
        ),
      ],
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

  void handleScale(detail) async {
    _currentZoomLevel = (_baseZoomLevel * detail.scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom);
    await controller.setZoomLevel(_currentZoomLevel);
    setState(() {
      _currentZoomLevel;
    });
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final CameraController cameraController = controller;

    final Offset offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }

  void onSetFocusModeButtonPressed(FocusMode mode) {
    setFocusMode(mode).then((_) {
      if (mounted) {
        setState(() {});
      }
      // showInSnackBar('Focus mode set to ${mode.toString().split('.').last}');
    });
  }

  Future<void> setFocusMode(FocusMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller.setFocusMode(mode);
    } on CameraException catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> _startVideoPlayer() async {
    if (videoFile != null) {
      videoController = VideoPlayerController.file(File(videoFile!.path));
      await videoController!.initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized,
        // even before the play button has been pressed.
        setState(() {});
      });
      await videoController!.setLooping(true);
      await videoController!.play();
    }
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;
    if (cameraController!.value.isTakingPicture) {
      return null;
    }
    try {
      XFile file = await cameraController.takePicture();
      videoController?.dispose();
      videoController = null;
      return file;
    } on CameraException catch (e) {
      // ignore: avoid_print
      print('Error occured while taking picture: $e');
      return null;
    }
  }

  Future<void> startVideoRecording() async {
    final CameraController? cameraController = controller;
    if (controller.value.isRecordingVideo) {
      return;
    }
    try {
      await cameraController!.startVideoRecording();
      setState(() {
        _isRecordingInProgress = true;
        imageFile = null;
        // ignore: avoid_print
        print(_isRecordingInProgress);
      });
    } on CameraException catch (e) {
      // ignore: avoid_print
      print('Error starting to record video: $e');
    }
  }

  Future<XFile?> stopVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      // Recording is already is stopped state
      return null;
    }
    try {
      XFile file = await controller.stopVideoRecording();
      setState(() {
        _isRecordingInProgress = false;
        // ignore: avoid_print
        print(_isRecordingInProgress);
      });
      return file;
    } on CameraException catch (e) {
      // ignore: avoid_print
      print('Error stopping video recording: $e');
      return null;
    }
  }

  Future<void> pauseVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      // Video recording is not in progress
      return;
    }
    try {
      await controller.pauseVideoRecording();
    } on CameraException catch (e) {
      debugPrint('Error pausing video recording: $e');
    }
  }

  Future<void> resumeVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      // No video recording was in progress
      return;
    }
    try {
      await controller.resumeVideoRecording();
    } on CameraException catch (e) {
      // ignore: avoid_print
      print('Error resuming video recording: $e');
    }
  }
}
