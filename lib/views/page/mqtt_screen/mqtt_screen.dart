import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mqtt_test/utils/size_config.dart';
import 'package:mqtt_test/views/page/mqtt_screen/mqtt_controller/mqtt_controller.dart';

class MqttScreen extends StatelessWidget {
  const MqttScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return GetBuilder<MqttController>(builder: (controller) {
      return SafeArea(
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: const Text("MQTT test"),
          ),
          body: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(
                  height: 16,
                ),
                MaterialButton(
                  onPressed: () {
                    controller.connect();
                  },
                  color: Colors.greenAccent,
                  child: const Text('Connect to server'),
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        flex: 4,
                        child: TextField(
                          controller: controller.textController,
                          decoration: InputDecoration(
                            isDense: true,
                            filled: true,
                            fillColor: Colors.blue.shade100,
                            border: const OutlineInputBorder(),
                            hintText: 'Your message',
                            counterText: 'Send Button',
                            icon: IconButton(
                                color: Colors.deepPurple,
                                iconSize: 30,
                                onPressed: () {
                                  controller.pickImage();
                                },
                                icon: const Icon(Icons.upload_file)),
                            suffixIcon: IconButton(
                                onPressed: () {
                                  Future.delayed(Duration.zero,(){
                                    controller.sendMessage(
                                        message: controller.textController.text, image: controller.encodedImage);
                                  }).then((value){
                                    controller.textController.clear();
                                  });
                                },
                                icon: const Icon(Icons.send)),
                          ),
                        )),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                Obx(() {
                  return Expanded(
                      child: ListView.builder(
                          itemCount: controller.messageList.value.length,
                          itemBuilder: (context, index) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    '${controller.messageList.value[index].msg}'),
                                if(controller.messageList.value[index].image != null && controller.messageList.value[index].image != 'empty')
                                  FittedBox(child: Image.memory(controller.imageFromBase64String(base64String: controller.messageList.value[index].image!))),
                              ],
                            );
                          }));
                })
              ],
            ),
          ),
        ),
      );
    });
  }
}
