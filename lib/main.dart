import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:iot_project/magic_packet.dart';
import 'dart:io';
import 'package:workmanager/workmanager.dart';

import 'app.dart';

@pragma('vm:entry-point')
void callbackDispatcher(){
  Workmanager().executeTask((task, inputData) async {
    var server = await HttpServer.bind(InternetAddress.anyIPv4, inputData!["port"]);
    await for (HttpRequest request in server) {
      int result = 0;
      String response = "success";
      Uint8List magicPacket = MagicPacket.create(inputData["mac"]);
      RawDatagramSocket socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 9000);
      socket.broadcastEnabled = true;
      result = socket.send(magicPacket, InternetAddress(inputData["ip"]), 9);
      if(result == 0) {
        response = "failed";
      }
      request.response.write('Magic packet sent to ${inputData["ip"]} with MAC: ${inputData["mac"]} with result: $response');
      await request.response.close();
    }
    return Future.value(true);
  });
}
void main() {
  runApp(const App());
}

