import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:velocity_x/velocity_x.dart';

class MediaView extends StatefulWidget {
  const MediaView({
    Key? key,
  }) : super(key: key);

  @override
  MediaViewState createState() => MediaViewState();
}

class MediaViewState extends State<MediaView> {
  File? _image;
  Future getImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _image = File(image!.path);
    });
  }

  Future getImageCam() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    setState(() {
      _image = File(image!.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: SingleChildScrollView(
      child: Column(
        children: [
          _image == null
              ? (Image.network(
                  'https://i.pinimg.com/564x/e6/57/55/e65755e73d8085e30aedfa21fde07f1b.jpg'))
              : Image.file(_image!),
          Center(
              child: ElevatedButton.icon(
                  onPressed: () {
                    Get.bottomSheet(
                      SingleChildScrollView(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10.0),
                            topRight: Radius.circular(10.0),
                          ),
                          child: Container(
                            color: Colors.white,
                            height: 250,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    "Pic Image From",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      getImageCam();
                                    },
                                    icon: const Icon(Icons.camera),
                                    label: const Text("CAMERA"),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      getImage();
                                    },
                                    icon: const Icon(Icons.image),
                                    label: const Text("GALLERY"),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Get.back();
                                    },
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(Colors.red),
                                    ),
                                    icon: const Icon(Icons.close),
                                    label: const Text("CANCEL"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.upload),
                  label: 'Upload'.text.make()))
        ],
      ),
    )));
  }
}
