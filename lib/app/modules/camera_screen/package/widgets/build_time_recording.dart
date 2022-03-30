import 'package:flutter/material.dart';

class BuildTimeRecording extends StatelessWidget {
  const BuildTimeRecording({
    Key? key,
    required this.duration,
  }) : super(key: key);

  final ValueNotifier<Duration> duration;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/red_circle.gif',
            height: 30,
          ),
          ValueListenableBuilder(
            valueListenable: duration,
            builder: (_, Duration duration, __) => Text(
              duration.toString().split('.').first.padLeft(8, "0"),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
