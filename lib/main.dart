import 'dart:async';
import 'dart:developer';

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
  String clientIdentifier = '3ytx51ifsHszdWNI';
  double _temp = 20;
  MqttClient? client;
  MqttConnectionState? connectionState;
  StreamSubscription? subscription;

  void connect() async {
    client = MqttServerClient(broker, clientIdentifier);
    client?.port = port;
    client?.logging(on: true);
    client?.keepAlivePeriod = 30;
    client?.onConnected = onConnected;
    client?.onDisconnected = _onDisconnected;

    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier(clientIdentifier)
        .startClean() // Non persistent session for testing
        .keepAliveFor(30)
        .withWillQos(MqttQos.atMostOnce);
    client?.connectionMessage = connMess;

    try {
      await client?.connect(username, passwd);
    } catch (e) {
      print(e);
      _disconnect();
    }

    if (client?.connectionState == MqttConnectionState.connected) {
      log('connect to server');
      setState(() {
        connectionState = client?.connectionState;
      });
    } else {
      _disconnect();
    }

    subscription = client?.updates?.listen(_onMessage);

    _subscribeToTopic("temp");
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
    log('response -> $recMess');

    setState(() {
      _temp = double.parse(message);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: MaterialButton(
        onPressed: () {
          connect();
        },
        child: Text("send"),
        color: Colors.deepPurple,
      )), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
