import 'dart:async';
import 'dart:io';
import 'package:basesource/app/modules/camera_screen/widgets/display_video.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  CameraController? controller;
  VideoPlayerController? videoController;

  final camId = ValueNotifier(0);

  Timer? timer;
  Duration duration = const Duration();

  late TabBar tabbar;

  // ignore: prefer_final_fields
  double _minAvailableZoom = 1.0, _maxAvailableZoom = 5.0, _baseZoomLevel = 1.0;
  final _curentZoom = ValueNotifier(1.0);

  double _minAvailableExposureOffset = -4.0, _maxAvailableExposureOffset = 4.0;
  final _currentExposureOffset = ValueNotifier(0.0);

  var tabIndex = 0;

  late TabController tabController;

  bool _isVideoCameraSelected = false, _isRecordingInProgress = false;

  XFile? imageFile, videoFile;

  void initCamera(int cameraId) {
    controller = CameraController(
      cameras[cameraId],
      ResolutionPreset.max,
    );

    controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        controller!
            .getMaxZoomLevel()
            .then((value) => _maxAvailableZoom = value);
        controller!
            .getMinZoomLevel()
            .then((value) => _minAvailableZoom = value);
        controller!
            .getMinExposureOffset()
            .then((value) => _minAvailableExposureOffset = value);
        controller!
            .getMaxExposureOffset()
            .then((value) => _maxAvailableExposureOffset = value);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    initCamera(0);
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    controller?.dispose();
    videoController?.dispose();
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller!.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: double.infinity,
            child: ValueListenableBuilder(
              valueListenable: _curentZoom,
              builder: (_, double val, __) {
                return CameraPreview(
                  controller!,
                  child: LayoutBuilder(builder:
                      (BuildContext context, BoxConstraints constraints) {
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onScaleUpdate: handleScale,
                    );
                  }),
                );
              },
            ),
          ),
          FlashModeCamera(controller: controller),
          _isRecordingInProgress
              ? Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/red_circle.gif',
                          height: 30,
                        ),
                        BuildTime(duration: duration),
                      ],
                    ),
                  ))
              : const SizedBox(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IncreaseExposure(
                  currentExposureOffset: _currentExposureOffset,
                  minAvailableExposureOffset: _minAvailableExposureOffset,
                  maxAvailableExposureOffset: _maxAvailableExposureOffset,
                  controller: controller),
              Container(
                alignment: Alignment.bottomCenter,
                color: _isVideoCameraSelected
                    ? Colors.black.withOpacity(.2)
                    : Colors.black,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      switchCamera(),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ValueListenableBuilder(
                              valueListenable: camId,
                              builder: (_, int val, __) {
                                return IconButton(
                                    onPressed: () {
                                      camId.value == 0
                                          ? {initCamera(1), camId.value = 1}
                                          : {initCamera(0), camId.value = 0};
                                    },
                                    icon: const Icon(
                                      CupertinoIcons.switch_camera_solid,
                                      color: Colors.white,
                                      size: 30,
                                    ));
                              },
                            ),
                            InkWell(
                              onTap: _isVideoCameraSelected
                                  ? () async {
                                      if (_isRecordingInProgress) {
                                        videoFile = await stopVideoRecording();
                                        startVideoPlayer();
                                        cancelTimer();
                                      } else {
                                        await startVideoRecording();
                                        startTimer();
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
                                  _isVideoCameraSelected &&
                                          _isRecordingInProgress
                                      ? const Icon(
                                          Icons.stop_rounded,
                                          color: Colors.white,
                                          size: 32,
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                            Thumbnail(
                                videoController: videoController,
                                imageFile: imageFile)
                          ]),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget switchCamera() {
    return SizedBox(
      height: 50,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TabBar(
            indicator: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(50),
                color: Colors.transparent),
            isScrollable: true,
            unselectedLabelColor: Colors.grey,
            labelColor: Colors.white,
            labelStyle:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            tabs: const [
              Tab(
                child: Text('Camera'),
              ),
              Tab(
                child: Text('Video'),
              ),
            ],
            controller: tabController,
            indicatorColor: Colors.white,
            onTap: (index) {
              index == 0
                  ? _isVideoCameraSelected = false
                  : _isVideoCameraSelected = true;
              changeColorButton();
            },
          ),
        ),
      ),
    );
  }

  void changeColorButton() {
    tabController.addListener(() {
      setState(() {});
    });
  }

  void addTime() {
    const addSeconds = 1;
    setState(() {
      final seconds = duration.inSeconds + addSeconds;
      duration = Duration(seconds: seconds);
    });
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) => addTime());
  }

  void cancelTimer() {
    setState(() {
      duration = const Duration();
      timer?.cancel();
    });
  }

  void handleScale(detail) {
    _curentZoom.value = (_baseZoomLevel * detail.scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom);
    controller?.setZoomLevel(_curentZoom.value);
  }

  Future<void> startVideoPlayer() async {
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
    if (controller!.value.isTakingPicture) {
      return null;
    }
    try {
      XFile file = await controller!.takePicture();
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
    if (controller!.value.isRecordingVideo) {
      return;
    }
    try {
      await controller?.startVideoRecording();
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
    if (!controller!.value.isRecordingVideo) {
      return null;
    }
    try {
      XFile file = await controller!.stopVideoRecording();
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
    if (!controller!.value.isRecordingVideo) {
      // Video recording is not in progress
      return;
    }
    try {
      await controller!.pauseVideoRecording();
    } on CameraException catch (e) {
      debugPrint('Error pausing video recording: $e');
    }
  }

  Future<void> resumeVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      // No video recording was in progress
      return;
    }
    try {
      await controller!.resumeVideoRecording();
    } on CameraException catch (e) {
      // ignore: avoid_print
      print('Error resuming video recording: $e');
    }
  }
}

class Thumbnail extends StatelessWidget {
  const Thumbnail({
    Key? key,
    required this.videoController,
    required this.imageFile,
  }) : super(key: key);

  final VideoPlayerController? videoController;
  final XFile? imageFile;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'galley',
      child: GestureDetector(
        onTap: () {
          if (videoController == null && imageFile == null) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DisplayPictureScreen(
                          imagePath: imageFile?.path,
                        )));
          }
          if (imageFile != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DisplayPictureScreen(
                        imagePath: imageFile!.path,
                      )),
            );
          } else if (videoController != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DisplayVideoScreen(
                        videoPath: videoController,
                      )),
            );
          }
        },
        child: Container(
          width: 50,
          height: 50,
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
}

class IncreaseExposure extends StatelessWidget {
  const IncreaseExposure({
    Key? key,
    required ValueNotifier<double> currentExposureOffset,
    required double minAvailableExposureOffset,
    required double maxAvailableExposureOffset,
    required this.controller,
  })  : _currentExposureOffset = currentExposureOffset,
        _minAvailableExposureOffset = minAvailableExposureOffset,
        _maxAvailableExposureOffset = maxAvailableExposureOffset,
        super(key: key);

  final ValueNotifier<double> _currentExposureOffset;
  final double _minAvailableExposureOffset;
  final double _maxAvailableExposureOffset;
  final CameraController? controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 50,
        child: Column(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(.5),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FittedBox(
                  child: ValueListenableBuilder(
                    valueListenable: _currentExposureOffset,
                    builder: (_, double val, __) {
                      return Text(
                        val.toStringAsFixed(1) + 'x',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          decoration: TextDecoration.none,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            RotatedBox(
              quarterTurns: 3,
              child: SizedBox(
                height: 30,
                child: ValueListenableBuilder(
                    valueListenable: _currentExposureOffset,
                    builder: (_, double val, __) {
                      return Slider(
                        value: val,
                        min: _minAvailableExposureOffset,
                        max: _maxAvailableExposureOffset,
                        activeColor: Colors.white,
                        inactiveColor: Colors.white30,
                        onChanged: (value) {
                          _currentExposureOffset.value = value;
                          controller!.setExposureOffset(value);
                        },
                      );
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FlashModeCamera extends StatefulWidget {
  const FlashModeCamera({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final CameraController? controller;

  @override
  State<FlashModeCamera> createState() => _FlashModeCameraState();
}

class _FlashModeCameraState extends State<FlashModeCamera> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: Colors.black.withOpacity(.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.flash_off),
            color: widget.controller!.value.flashMode == FlashMode.off
                ? Colors.orange
                : Colors.white,
            onPressed: widget.controller != null
                ? () => onSetFlashModeButtonPressed(FlashMode.off)
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.flash_auto),
            color: widget.controller!.value.flashMode == FlashMode.auto
                ? Colors.orange
                : Colors.white,
            onPressed: widget.controller != null
                ? () => onSetFlashModeButtonPressed(FlashMode.auto)
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.flash_on),
            color: widget.controller!.value.flashMode == FlashMode.always
                ? Colors.orange
                : Colors.white,
            onPressed: widget.controller != null
                ? () => onSetFlashModeButtonPressed(FlashMode.always)
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.highlight),
            color: widget.controller!.value.flashMode == FlashMode.torch
                ? Colors.orange
                : Colors.white,
            onPressed: widget.controller != null
                ? () => onSetFlashModeButtonPressed(FlashMode.torch)
                : null,
          ),
        ],
      ),
    );
  }

  Future<void> setFlashMode(FlashMode mode) async {
    try {
      await widget.controller!.setFlashMode(mode);
    } on CameraException {
      rethrow;
    }
  }

  void onSetFlashModeButtonPressed(FlashMode mode) {
    setFlashMode(mode).then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }
}

class BuildTime extends StatelessWidget {
  const BuildTime({
    Key? key,
    required this.duration,
  }) : super(key: key);

  final Duration duration;

  @override
  Widget build(BuildContext context) {
    // ignore: non_constant_identifier_names
    String TwoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = TwoDigits(duration.inHours.remainder(60));
    final minutes = TwoDigits(duration.inMinutes.remainder(60));
    final seconds = TwoDigits(duration.inSeconds.remainder(60));
    return Text(
      '$hours:$minutes:$seconds',
      textAlign: TextAlign.center,
      style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          decoration: TextDecoration.none),
    );
  }
}
