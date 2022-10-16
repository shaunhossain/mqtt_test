import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    connect();
    super.initState();
  }

  String broker = 'retail.bmapsbd.com';
  int port = 1883;
  String username = 'rilus';
  String passwd = 'kingbob';
  String clientIdentifier = 'shaun'; // use any unique name here
  String _temp = '';
  MqttClient? client;
  MqttConnectionState? connectionState;
  StreamSubscription? subscription;
  MqttClientPayloadBuilder mqttClientPayloadBuilder = MqttClientPayloadBuilder();
  static const String pubTopic = 'mqtt/request';

  void connect() async {
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

    try {
      await client?.connect(username, passwd);
    } catch (e) {
      print(e);
      _disconnect();
    }

    if (client?.connectionStatus!.state == MqttConnectionState.connected) {
      log('connect to server');
      setState(() {
        connectionState = client?.connectionStatus!.state;
      });
    } else {
      _disconnect();
    }

    client?.updates?.listen(_onMessage);
    _subscribeToTopic('mqtt/request');
    _sendMessage();
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

    setState(() {
      _temp = message;
    });
  }

  void _disconnect() {
    print('[MQTT client] _disconnect()');
    client?.disconnect();
    _onDisconnected();
  }

  void _onDisconnected() {
    print('[MQTT client] _onDisconnected');
    setState(() {
      //topics.clear();
      connectionState = client?.connectionState;
      client = null;
      subscription?.cancel();
      subscription = null;
    });
    print('[MQTT client] MQTT client disconnected');
  }

  void _sendMessage() {
    mqttClientPayloadBuilder.clear();
    mqttClientPayloadBuilder.addString('Hello MQTT');
    client?.publishMessage(pubTopic, MqttQos.atLeastOnce, mqttClientPayloadBuilder.payload!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: MaterialButton(
        onPressed: () {
          _sendMessage();
        },
        child: const Text("send"),
      )), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
