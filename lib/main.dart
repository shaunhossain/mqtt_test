import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_test/views/components/navigator/app_pages.dart';
import 'package:mqtt_test/views/components/navigator/app_routes.dart';
import 'package:mqtt_test/views/components/themes/themes.dart';
import 'package:mqtt_test/views/page/mqtt_screen/mqtt_binding/mqtt_binding.dart';
import 'package:mqtt_test/views/services/theme_service/theme_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "MQTT test",
      initialBinding: MqttBinding(),
      initialRoute: AppRoutes.mapScreen,
      getPages: AppPages.list,
      theme: Themes.light,
      darkTheme: Themes.dark,
      themeMode: ThemeService().theme,
    );
  }
}
