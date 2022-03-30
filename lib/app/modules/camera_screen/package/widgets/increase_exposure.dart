import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

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
