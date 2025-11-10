import 'package:flutter/material.dart';
import 'package:omni_remote/home/widgets/widgets.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool _livingRoomExpanded = true;

  bool _mainLightOn = true;
  double _ambientLampBrightness = 75;
  double _thermostatTemp = 65.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 28),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        children: [
          GroupCard(
            icon: Icons.weekend_outlined,
            title: 'Living Room',
            subtitle: '3 Devices',
            isActive: _livingRoomExpanded,
            onActivate: () {
              setState(() {
                _livingRoomExpanded = !_livingRoomExpanded;
              });
            },
            devices: [
              DeviceBooleanTile(
                icon: Icons.lightbulb_outline,
                title: 'Main Light',
                subtitle: _mainLightOn ? 'On' : 'Off',
                value: _mainLightOn,
                onChanged: ({value}) {
                  setState(() {
                    _mainLightOn = value ?? false;
                  });
                },
              ),
              DeviceNumberTile(
                icon: Icons.lightbulb_outline,
                title: 'Ambient Lamp',
                subtitle: 'Brightness',
                value: _ambientLampBrightness,
                onChanged: (value) {
                  setState(() {
                    _ambientLampBrightness = value;
                  });
                },
                onIncrement: () {
                  setState(() {
                    _ambientLampBrightness += 0.5;
                  });
                },
                onDecrement: () {
                  setState(() {
                    _ambientLampBrightness -= 0.5;
                  });
                },
              ),
              DeviceNumberTile(
                icon: Icons.thermostat_outlined,
                title: 'Thermostat',
                subtitle: 'Temperature',
                value: _thermostatTemp,
                onChanged: (value) {
                  setState(() {
                    _thermostatTemp = value;
                  });
                },
                onIncrement: () {
                  setState(() {
                    _thermostatTemp += 0.5;
                  });
                },
                onDecrement: () {
                  setState(() {
                    _thermostatTemp -= 0.5;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
