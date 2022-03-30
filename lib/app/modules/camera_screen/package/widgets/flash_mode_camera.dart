import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

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
    final top = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.only(top: top),
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
