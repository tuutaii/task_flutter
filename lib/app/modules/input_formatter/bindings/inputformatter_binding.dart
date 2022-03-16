import 'package:get/get.dart';

import '../controllers/inputformatter_controller.dart';

class InputFormatterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InputFormatterController>(
      () => InputFormatterController(),
    );
  }
}
