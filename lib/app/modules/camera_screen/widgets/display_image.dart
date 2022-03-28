import 'dart:io';

import 'package:flutter/material.dart';

class DisplayPictureScreen extends StatelessWidget {
  final String? imagePath;

  const DisplayPictureScreen({Key? key, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: imagePath == null ? Colors.white : Colors.black,
      appBar: AppBar(title: const Text('Display the Picture')),
      body: Hero(
          tag: 'galley',
          child: imagePath == null
              ? const Center(
                  child: Text(
                    'Empty',
                    style: TextStyle(
                      decoration: TextDecoration.none,
                    ),
                  ),
                )
              : Image.file(File(imagePath!))),
    );
  }
}
