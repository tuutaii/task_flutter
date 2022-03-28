import 'package:get/get.dart';

import '../modules/camera_screen/bindings/camera_screen_binding.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/input_formatter/bindings/inputformatter_binding.dart';
import '../modules/media/bindings/media_binding.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/tab_web/bindings/tab_web_binding.dart';
import '../modules/test/bindings/test_binding.dart';
import '../modules/test/views/test_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.home;

  static final routes = [
    GetPage(
        name: _Paths.home,
        page: () => const HomeView(),
        binding: HomeBinding(),
        bindings: [
          TabWebBinding(),
          InputFormatterBinding(),
          ProfileBinding(),
          MediaBinding(),
          CameraScreenBinding(),
        ]),
    GetPage(
      name: _Paths.test,
      page: () => const TestView(),
      binding: TestBinding(),
    ),
  ];
}
