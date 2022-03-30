import 'dart:io';

import 'package:flutter/material.dart';

class DisplayPictureScreen extends StatelessWidget {
  final String? imagePath;

  const DisplayPictureScreen({Key? key, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'galley',
      child: Scaffold(
        backgroundColor: imagePath == null ? Colors.white : Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black87,
          title: const Text(
            'Display the Picture',
            style: TextStyle(),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.save_alt),
            )
          ],
        ),
        body: imagePath == null
            ? const Center(
                child: Text(
                  'Empty',
                  style: TextStyle(
                    decoration: TextDecoration.none,
                  ),
                ),
              )
            : Image.file(File(imagePath!)),
      ),
    );
  }
}
