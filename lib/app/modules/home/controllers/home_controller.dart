import 'package:camera/camera.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  var selectedIndex = 0;
  var title = 'Input Formatter';
  late CameraController cameraController;

  void changeTabIndex(int index) {
    selectedIndex = index;
    switch (index) {
      case 0:
        {
          title = 'Input Formatter';
        }
        break;
      case 1:
        {
          title = 'Web View';
        }
        break;
      case 2:
        {
          title = 'Camera picker';
        }
        break;
      case 3:
        {
          title = 'Profile API';
        }
        break;
    }
    update();
  }
}
