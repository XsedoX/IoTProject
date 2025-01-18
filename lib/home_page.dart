import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

import 'main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _targetIpController = TextEditingController();
  final TextEditingController _targetMacController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final RegExp macAddressRegExp = RegExp(
    r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$',
  );
  final RegExp ipv4RegExp = RegExp(
    r'^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
  );
  bool _isListening = false;
  bool workmanagerInitialized = false;

  Future<void> _startListening() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    int port = int.parse(_portController.text);
    setState(() {
      _isListening = !_isListening;
    });
    if (!workmanagerInitialized) {
      bool? isAllBatteryOptimizationDisabled = await DisableBatteryOptimization.isAllBatteryOptimizationDisabled;
      if(!(isAllBatteryOptimizationDisabled == true)) {
        await DisableBatteryOptimization.showDisableAllOptimizationsSettings(
          'Enable Auto Start',
          'Please enable auto start for this app',
          'Disable Manufacturer Battery Optimization',
          'Please disable manufacturer battery optimization for this app',
        );
      }
      Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: true,
      );
      setState(() => workmanagerInitialized = true);
    }
    switch (_isListening) {
      case true:
        Workmanager().registerOneOffTask('1', 'magicPacketServer',
            inputData: {
              'port': port,
              'mac': _targetMacController.text,
              'ip': _targetIpController.text
            },
            constraints: Constraints(
                networkType: NetworkType.connected,
                requiresCharging: false,
                requiresBatteryNotLow: false,
                requiresStorageNotLow: false,
                requiresDeviceIdle: false
            ));
        break;
      case false:
        Workmanager().cancelByUniqueName('1');
        break;
    }
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _portController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter Port Number',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a port number';
                    }
                    if(int.tryParse(value) == null || int.parse(value) < 2000 || int.parse(value) > 65535) {
                      return 'Please enter a valid port number (2000-65535)';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _targetMacController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter MAC address to put into Magic Packet',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a MAC address';
                    }
                    if(!macAddressRegExp.hasMatch(value)) {
                      return 'Please enter a valid MAC address';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _targetIpController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter an IP address to send Magic Packet to (preferably broadcast)',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an IP address';
                    }
                    if(!ipv4RegExp.hasMatch(value)) {
                      return 'Please enter a valid IP address';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startListening,
        tooltip: 'Start listening',
        child: _isListening ? const Icon(Icons.stop) : const Icon(Icons.play_arrow),
      ),
    );
  }
}
