import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    GetMaterialApp(
        showPerformanceOverlay: false,
        debugShowCheckedModeBanner: false,
        title: "Application",
        initialRoute: AppPages.initial,
        getPages: AppPages.routes,
        theme: ThemeData.light().copyWith(
            pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
        }))),
  );
}
