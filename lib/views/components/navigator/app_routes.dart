import 'package:get/get.dart';
import 'package:mqtt_test/views/page/mqtt_screen/mqtt_binding/mqtt_binding.dart';
import 'package:mqtt_test/views/page/mqtt_screen/mqtt_screen.dart';
import 'app_pages.dart';

class AppPages {
  static var list = [

    GetPage(
        name: AppRoutes.mapScreen,
        page: () => const MqttScreen(),
        binding: MqttBinding(),
        transition: Transition.leftToRight),
  ];
}
