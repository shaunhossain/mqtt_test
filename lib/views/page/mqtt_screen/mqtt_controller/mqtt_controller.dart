import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_test/model/message_response.dart';

class MqttController extends GetxController {
  final textController = TextEditingController();
  final messageList = <MessageResponse>[].obs;
  String broker = 'retail.bmapsbd.com';
  int port = 1883;
  String username = 'rilus';
  String passwd = 'kingbob';
  String clientIdentifier = 'shaun'; // use any unique name here
  MqttClient? client;
  MqttConnectionState? connectionState;
  MqttClientPayloadBuilder mqttClientPayloadBuilder = MqttClientPayloadBuilder();
  static const String pubTopic = 'mqtt/request';

  final ImagePicker _picker = ImagePicker();
  String encodedImage = 'empty';


  @override
  void onInit() {
    initializeMQTTClient();
    super.onInit();
  }

  void initializeMQTTClient() {
    client = MqttServerClient(broker, clientIdentifier);
    client?.port = port;
    client?.doAutoReconnect(force: false);
    client?.logging(on: false);
    client?.keepAlivePeriod = 600;
    client?.onConnected = onConnected;
    client?.onDisconnected = _onDisconnected;

    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier(clientIdentifier)
        .startClean()
        .withWillRetain()
        .withWillQos(MqttQos.atMostOnce);
    client?.connectionMessage = connMess;
    print('Initialize::Mosquitto client connecting....');
  }

  void connect() async {
    try {
      await client?.connect(username, passwd);
    } catch (e) {
      print(e);
      _disconnect();
    }
    if (client?.connectionStatus!.state == MqttConnectionState.connected) {
      log('connect to server');
      connectionState = client?.connectionStatus!.state;
      update();
    } else {
      _disconnect();
    }
    client?.updates?.listen(_onMessage);
    _subscribeToTopic('mqtt/request');
  }

  // connection succeeded
  void onConnected() {
    print('Connected checked');
  }

  void _subscribeToTopic(String topic) {
    if (connectionState == MqttConnectionState.connected) {
      client?.subscribe(topic, MqttQos.exactlyOnce);
    }
  }

  void _onMessage(List<MqttReceivedMessage> event) {
    final MqttPublishMessage recMess = event[0].payload as MqttPublishMessage;
    final String message =
    MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    log('response -> $message \n');
    final MessageResponse messageResponse = messageResponseFromJson(message);
    messageList.add(messageResponse);
  }

  void _disconnect() {
    print('[MQTT client] _disconnect()');
    client?.disconnect();
    _onDisconnected();
  }

  void _onDisconnected() {
    print('[MQTT client] _onDisconnected');
    connectionState = client?.connectionStatus!.state;
    client = null;
    update();
    print('[MQTT client] MQTT client disconnected');
  }

  void sendMessage({required String message, required String image}) {
    final response = MessageResponse(msg: message, image: image);
    mqttClientPayloadBuilder.clear();
    mqttClientPayloadBuilder.addString(messageResponseToJson(response));
    client?.publishMessage(pubTopic, MqttQos.atLeastOnce, mqttClientPayloadBuilder.payload!);
  }

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    update();
    _encodeImage(image: image!);
  }

  Future<void> _encodeImage({required XFile image}) async {
    final imageByte = await image.readAsBytes();
    String base64Image = base64Encode(imageByte);
    encodedImage = base64Image;
    update();
  }

  Uint8List imageFromBase64String({required String base64String}) {
    return const Base64Decoder().convert(base64String);
  }
}
