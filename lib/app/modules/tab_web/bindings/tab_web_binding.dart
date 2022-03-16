import 'package:get/get.dart';

import '../controllers/tab_web_controller.dart';

class TabWebBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TabWebController>(
      () => TabWebController(),
    );
  }
}
