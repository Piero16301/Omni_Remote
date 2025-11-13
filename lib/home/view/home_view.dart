import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:omni_remote/home/widgets/widgets.dart';
import 'package:user_api/user_api.dart';

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
        leading: IconButton(
          onPressed: () {},
          icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedSettings01,
            strokeWidth: 2,
          ),
        ),
      ),
      body: ListView(
        children: [
          GroupCard(
            group: GroupModel(
              id: 1,
              title: 'Sala',
              subtitle: '3 dispositivos',
              icon: 'SMART_TV',
              enabled: _livingRoomEnabled,
            ),
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
                online: true,
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
                online: true,
              ),
            ],
          ),
          Card(
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(16),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedDashboardSquareAdd,
                      strokeWidth: 2,
                    ),
                    SizedBox(width: 8),
                    Text('Nuevo grupo'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const HugeIcon(
          icon: HugeIcons.strokeRoundedComputerAdd,
          size: 28,
          strokeWidth: 2,
        ),
      ),
    );
  }
}
