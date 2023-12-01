import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bluetooth Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BluetoothPage(),
    );
  }
}

class BluetoothPage extends StatefulWidget {
  @override
  _BluetoothPageState createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  BluetoothConnection? connection;
  bool isConnected = false;
  String pulseRate = '0';
  String pulseStatus = '';

  @override
  void initState() {
    super.initState();
    connectToBluetooth();
  }

  Future<void> connectToBluetooth() async {
    BluetoothDevice? selectedDevice;

    try {
      List<BluetoothDevice> devices = await FlutterBluetoothSerial.instance.getBondedDevices();
      selectedDevice = devices.firstWhere(
        (device) => device.name == 'Your Bluetooth Device Name',
        orElse: () => BluetoothDevice(
          name: 'Dummy Device',
          address: '00:00:00:00:00:00', // Replace with any dummy Bluetooth address
        ),
      );
    } catch (err) {
      print('Error: $err');
    }

    if (selectedDevice != null) {
      try {
        connection = await BluetoothConnection.toAddress(selectedDevice.address!);
        connection!.input!.listen(onDataReceived).onDone(() {
          setState(() {
            isConnected = false;
            pulseRate = '0';
            pulseStatus = '';
          });
        });
        setState(() {
          isConnected = true;
        });
      } catch (err) {
        print('Error: $err');
      }
    }
  }

  void onDataReceived(Uint8List data) {
    String response = utf8.decode(data);
    setState(() {
      if (response.contains('Normal Pulse')) {
        pulseStatus = '';
      } else if (response.contains('Abnormal Pulse')) {
        pulseStatus = 'Abnormal Pulse!';
      } else {
        pulseRate = response;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('pulse watch app'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Pulse Rate:',
              style: TextStyle(fontSize: 24),
            ),
            Text(
              pulseRate.toString(),
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              pulseStatus,
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: Text('Connect to Bluetooth'),
            ),
          ],
        ),
      ),
    );
  }
}