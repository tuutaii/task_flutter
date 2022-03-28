import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CameraUIPackage extends StatelessWidget {
  const CameraUIPackage(
      {Key? key,
      this.controller,
      this.tabController,
      this.videoController,
      this.timer,
      this.imageFile,
      this.videoFile})
      : super(key: key);
  final CameraController? controller;
  final TabController? tabController;
  final VideoPlayerController? videoController;

  final tabIndex = 0;

  final double minAvailableZoom = 1.0,
      maxAvailableZoom = 5.0,
      currentZoomLevel = 1.0,
      baseZoomLevel = 1.0,
      minAvailableExposureOffset = -4.0,
      maxAvailableExposureOffset = 4.0,
      currentExposureOffset = 0.0;

  final int camId = 0;
  final Timer? timer;
  final Duration duration = const Duration();
  final bool isVideoCameraSelected = false, isRecordingInProgress = false;
  final XFile? imageFile, videoFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: const [
      Text('data'),
      // flashMode(),
    ]));
  }
}

// Widget flashMode() {
//   CameraController? controller;
//   return Container(
//     height: 50,
//     color: Colors.black.withOpacity(.5),
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
//         IconButton(
//           icon: const Icon(Icons.flash_off),
//           color: controller!.value.flashMode == FlashMode.off
//               ? Colors.orange
//               : Colors.white,
//           onPressed: () => onSetFlashModeButtonPressed(FlashMode.off),
//         ),
//         IconButton(
//             icon: const Icon(Icons.flash_auto),
//             color: controller.value.flashMode == FlashMode.auto
//                 ? Colors.orange
//                 : Colors.white,
//             onPressed: () => onSetFlashModeButtonPressed(FlashMode.auto)),
//         IconButton(
//             icon: const Icon(Icons.flash_on),
//             color: controller.value.flashMode == FlashMode.always
//                 ? Colors.orange
//                 : Colors.white,
//             onPressed: () => onSetFlashModeButtonPressed(FlashMode.always)),
//         IconButton(
//             icon: const Icon(Icons.highlight),
//             color: controller.value.flashMode == FlashMode.torch
//                 ? Colors.orange
//                 : Colors.white,
//             onPressed: () => onSetFlashModeButtonPressed(FlashMode.torch)),
//       ],
//     ),
//   );
// }

// onSetFlashModeButtonPressed(FlashMode off) {}
