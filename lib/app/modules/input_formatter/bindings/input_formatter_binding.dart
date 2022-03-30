import 'package:get/get.dart';

import '../controllers/input_formatter_controller.dart';

class InputFormatterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InputFormatterController>(
      () => InputFormatterController(),
    );
  }
}
