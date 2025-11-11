import 'package:flutter/material.dart';
import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/home/widgets/widgets.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool _livingRoomEnabled = true;

  bool _mainLight = true;
  double _roomTemperature = 30.5;
  double _soundbarVolume = 10;

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
            title: 'Sala',
            subtitle: '3 dispositivos',
            icon: Icons.tv,
            isEnabled: _livingRoomEnabled,
            onEnable: () {
              setState(() {
                _livingRoomEnabled = !_livingRoomEnabled;
              });
            },
            devices: [
              DeviceBooleanTile(
                device: DeviceModel(
                  id: '1',
                  title: 'Luz principal',
                  subtitle: _mainLight ? 'Encendida' : 'Apagada',
                  icon: 'LIGHT',
                  tileType: DeviceTileType.boolean,
                ),
                value: _mainLight,
                onChanged: ({value}) {
                  setState(() {
                    _mainLight = value ?? false;
                  });
                },
              ),
              DeviceNumberTile(
                device: DeviceModel(
                  id: '2',
                  title: 'Habitación',
                  subtitle: 'Termostato',
                  icon: 'THERMOSTAT',
                  tileType: DeviceTileType.number,
                  rangeMin: 10,
                  rangeMax: 80,
                  divisions: 7,
                  interval: 0.5,
                ),
                value: _roomTemperature,
                onChanged: (value) {
                  setState(() {
                    _roomTemperature = value;
                  });
                },
                onIncrement: () {
                  setState(() {
                    _roomTemperature += 0.5;
                  });
                },
                onDecrement: () {
                  setState(() {
                    _roomTemperature -= 0.5;
                  });
                },
              ),
              DeviceNumberTile(
                device: DeviceModel(
                  id: '3',
                  title: 'Habitación',
                  subtitle: 'Barra de sonido',
                  icon: 'SPEAKER',
                  tileType: DeviceTileType.number,
                  rangeMax: 20,
                  divisions: 20,
                  interval: 1,
                ),
                value: _soundbarVolume,
                onChanged: (value) {
                  setState(() {
                    _soundbarVolume = value;
                  });
                },
                onIncrement: () {
                  setState(() {
                    _soundbarVolume += 1;
                  });
                },
                onDecrement: () {
                  setState(() {
                    _soundbarVolume -= 1;
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
