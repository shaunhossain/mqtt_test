# mqtt_test

For our application to connect with the local MQTT broker, we will use the pub mqtt_client, which can be found on pub.dev with installation instructions here — [https://pub.dev/packages/mqtt_client].

Further, let’s create an MQTTClientManager.dart class to help us with the various operations we would like to run in our mobile client. It contains the connect, disconnect, subscribe, publish, and other helper methods required to communicate with the broker.


- [https://betterprogramming.pub/streaming-flutter-events-with-mosquitto-mqtt-broker-28998a3b81c2]