import 'package:get/get.dart';
import 'package:mqtt_test/views/page/mqtt_screen/mqtt_controller/mqtt_controller.dart';


class MqttBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut<MqttController>(()=> MqttController());
  }
}