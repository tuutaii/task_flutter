import 'package:basesource/app/modules/camera_screen/views/camera_screen_view.dart';
import 'package:basesource/app/modules/media/views/media_view.dart';
import 'package:basesource/app/modules/profile/views/profile_view.dart';
import 'package:basesource/app/modules/tab_web/views/tab_web_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../input_formatter/views/inputformatter_view.dart';
import '../controllers/home_controller.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (controller) {
      return Scaffold(
          appBar: AppBar(
            title: Text(
              controller.title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0.5,
          ),
          body: SafeArea(
            child: IndexedStack(
              index: controller.selectedIndex,
              children: [
                InputFormatterView(),
                const TabWebView(),
                const MediaView(),
                const CameraScreenView(),
                const ProfileView(),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
              showUnselectedLabels: true,
              showSelectedLabels: true,
              onTap: controller.changeTabIndex,
              currentIndex: controller.selectedIndex,
              backgroundColor: Colors.white,
              unselectedItemColor: Colors.grey.withOpacity(0.5),
              selectedItemColor: Colors.black,
              unselectedLabelStyle: TextStyle(
                  color: Colors.black.withOpacity(0.5),
                  fontWeight: FontWeight.w500,
                  fontSize: 12),
              selectedLabelStyle: selectedLabelStyle,
              type: BottomNavigationBarType.fixed,
              items: [
                buildBottomNavigationMenu(
                  const Icon(Icons.keyboard),
                  'Home',
                ),
                buildBottomNavigationMenu(
                  const Icon(
                    Icons.language_outlined,
                  ),
                  'Web View',
                ),
                buildBottomNavigationMenu(
                    const Icon(
                      Icons.photo_camera_outlined,
                    ),
                    'Media '),
                buildBottomNavigationMenu(
                    const Icon(
                      Icons.photo_camera_outlined,
                    ),
                    'Camera '),
                buildBottomNavigationMenu(
                  const Icon(Icons.person),
                  'Profile',
                ),
              ]));
    });
  }
}

final TextStyle unselectedLabelStyle = TextStyle(
    color: Colors.white.withOpacity(0.5),
    fontWeight: FontWeight.w500,
    fontSize: 12);

TextStyle selectedLabelStyle = const TextStyle(
    color: Colors.white, fontWeight: FontWeight.w500, fontSize: 12);

buildBottomNavigationMenu(
  Icon icon,
  String lable,
) {
  return BottomNavigationBarItem(
      icon: Container(margin: const EdgeInsets.only(bottom: 7), child: icon),
      label: lable,
      backgroundColor: Colors.blue);
}
