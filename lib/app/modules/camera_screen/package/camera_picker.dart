import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'widgets/build_time_recording.dart';
import 'widgets/button_custom.dart';
import 'widgets/camera_mode.dart';
import 'widgets/flash_mode_camera.dart';
import 'widgets/icon_button_custom.dart';
import 'widgets/increase_exposure.dart';
import 'widgets/thumb_nail.dart';

List<CameraDescription> _cameras = [];

class CameraPickerCustom extends StatefulWidget {
  const CameraPickerCustom({Key? key}) : super(key: key);
  static Future<File?> cameraPicker(BuildContext context) async {
    _cameras = await availableCameras();
    return Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const CameraPickerCustom()));
  }

  @override
  State<CameraPickerCustom> createState() => _CameraPickerCustomState();
}

class _CameraPickerCustomState extends State<CameraPickerCustom>
    with TickerProviderStateMixin {
  CameraController? controller;
  TabController? tabController;
  late TabBar tabbar;
  double _minAvailableZoom = 1.0,
      _maxAvailableZoom = 1.0,
      baseZoomLevel = 1.0,
      currentZoom = 1.0;
  double _minAvailableExposureOffset = -4.0, _maxAvailableExposureOffset = 4.0;
  final _currentExposureOffset = ValueNotifier(0.0);
  var tabIndex = 0;

  bool _isVideoCameraSelected = false;
  final _isRecordingPaused = ValueNotifier(false);
  final _isRecordingInProgress = ValueNotifier(false);
  final file = ValueNotifier<XFile?>(null);
  final duration = ValueNotifier<Duration>(const Duration());
  final cameraId = ValueNotifier(0);
  Timer? timer;

  void initCamera(int id, {bool isForce = false}) {
    controller = CameraController(
      _cameras[id],
      ResolutionPreset.max,
    );
    controller?.initialize().then(
      (_) {
        if (!mounted) {
          return;
        }
        controller
            ?.getMaxZoomLevel()
            .then((value) => _maxAvailableZoom = value);
        controller
            ?.getMinZoomLevel()
            .then((value) => _minAvailableZoom = value);
        controller
            ?.getMinExposureOffset()
            .then((value) => _minAvailableExposureOffset = value);
        controller
            ?.getMaxExposureOffset()
            .then((value) => _maxAvailableExposureOffset = value);
        if (isForce) {
          setState(() {});
        }
        cameraId.value = id;
      },
    );
  }

  void addSeconds() {
    duration.value = Duration(seconds: duration.value.inSeconds + 1);
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) => addSeconds());
  }

  void cancelTimer() {
    duration.value = const Duration();
    timer?.cancel();
  }

  void pauseTimer() {
    _isRecordingPaused.value = true;
    timer?.cancel();
  }

  void resumeTimer() {
    _isRecordingPaused.value = false;
    timer = Timer.periodic(const Duration(seconds: 1), (_) => addSeconds());
  }

  void handleScaleStart(ScaleStartDetails details) {
    baseZoomLevel = currentZoom;
  }

  void handleScale(detail) {
    currentZoom = (baseZoomLevel * detail.scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom);
    controller?.setZoomLevel(currentZoom);
  }

  void stopVideoRecording() {
    if (controller!.value.isRecordingVideo) {
      try {
        controller!.stopVideoRecording().then((value) => file.value = value);
        _isRecordingInProgress.value = false;
        log(_isRecordingInProgress.toString());
      } on CameraException catch (e) {
        log('Error stopping video recording: $e');
      }
    }
  }

  void takePicture() {
    if (!controller!.value.isTakingPicture) {
      try {
        controller!.takePicture().then((value) => file.value = value);
      } on CameraException catch (e) {
        log('Error occurred while taking picture: $e');
      }
    }
  }

  Future<void> startVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      try {
        _isRecordingInProgress.value = true;
        await controller?.startVideoRecording();
      } on CameraException catch (e) {
        log('Error starting to record video: $e');
      }
    }
  }

  Future<void> pauseVideoRecording() async {
    if (controller!.value.isRecordingVideo) {
      try {
        _isRecordingPaused.value = true;
        await controller!.pauseVideoRecording();
      } on CameraException catch (e) {
        log('Error pausing video recording: $e');
      }
    }
  }

  Future<void> resumeVideoRecording() async {
    if (controller!.value.isRecordingVideo) {
      try {
        _isRecordingPaused.value = false;
        await controller!.resumeVideoRecording();
      } on CameraException catch (e) {
        log('Error resuming video recording: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    initCamera(cameraId.value, isForce: true);
    tabController = TabController(length: 2, vsync: this);
    tabController!.addListener(() {
      setState(() {
        _isVideoCameraSelected = tabController!.index == 1;
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller!.value.isInitialized) {
      return const SizedBox();
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            FlashModeCamera(controller: controller),
            Expanded(
              child: Stack(
                children: [
                  ValueListenableBuilder(
                    valueListenable: cameraId,
                    builder: (_, __, ___) {
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onScaleStart: handleScaleStart,
                        onScaleUpdate: handleScale,
                        child: SizedBox(
                          width: double.infinity,
                          child: CameraPreview(controller!),
                        ),
                      );
                    },
                  ),
                  ValueListenableBuilder(
                    valueListenable: _isRecordingInProgress,
                    child: BuildTimeRecording(duration: duration),
                    builder: (_, bool isRecord, Widget? buildTime) {
                      return isRecord ? buildTime! : const SizedBox();
                    },
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: IncreaseExposure(
                      currentExposureOffset: _currentExposureOffset,
                      minAvailableExposureOffset: _minAvailableExposureOffset,
                      maxAvailableExposureOffset: _maxAvailableExposureOffset,
                      controller: controller,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  CameraMode(
                    tabController: tabController!,
                    isVideoCameraSelected: _isVideoCameraSelected,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ValueListenableBuilder(
                          valueListenable: _isRecordingInProgress,
                          builder: (_, bool isRecord, __) {
                            if (isRecord) {
                              return ValueListenableBuilder(
                                valueListenable: _isRecordingPaused,
                                builder: (_, bool isPause, __) {
                                  return IconButtonCustom(
                                    iconData: isPause
                                        ? Icons.play_circle_fill_rounded
                                        : Icons.pause_circle_rounded,
                                    onTap: () {
                                      if (isPause) {
                                        resumeVideoRecording();
                                        resumeTimer();
                                      } else {
                                        pauseVideoRecording();
                                        pauseTimer();
                                      }
                                    },
                                  );
                                },
                              );
                            } else {
                              return IconButtonCustom(
                                iconData: CupertinoIcons.switch_camera_solid,
                                onTap: () {
                                  if (cameraId.value == 0) {
                                    initCamera(1);
                                  } else {
                                    initCamera(0);
                                  }
                                },
                              );
                            }
                          },
                        ),
                        InkWell(
                          onTap: () {
                            if (_isVideoCameraSelected) {
                              if (_isRecordingInProgress.value) {
                                stopVideoRecording();
                                cancelTimer();
                              } else {
                                startVideoRecording();
                                startTimer();
                              }
                            } else {
                              takePicture();
                            }
                          },
                          child: Align(
                            alignment: Alignment.center,
                            child: _isVideoCameraSelected
                                ? ValueListenableBuilder(
                                    valueListenable: _isRecordingInProgress,
                                    builder: (_, bool isRecord, __) {
                                      if (isRecord) {
                                        return const ButtonCustom(
                                          icon: Icon(
                                            Icons.stop_rounded,
                                            color: Colors.black,
                                            size: 30,
                                          ),
                                        );
                                      } else {
                                        return const ButtonCustom(
                                          icon: Icon(
                                            Icons.circle_rounded,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                        );
                                      }
                                    },
                                  )
                                : const ButtonCustom(),
                          ),
                        ),
                        ValueListenableBuilder(
                          valueListenable: file,
                          builder: (_, XFile? file, __) {
                            if (file == null) {
                              return const CircleAvatar(
                                minRadius: 25,
                                backgroundColor: Colors.white,
                              );
                            } else {
                              return Thumbnail(
                                file: file,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
