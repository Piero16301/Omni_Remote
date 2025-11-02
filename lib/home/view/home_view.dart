import 'package:flutter/material.dart';
import 'package:omni_remote/home/widgets/widgets.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Estado de las habitaciones expandidas
  bool _livingRoomExpanded = true;
  bool _bedroomExpanded = true;
  bool _kitchenExpanded = true;

  // Estado de los dispositivos de la sala
  bool _mainLightOn = true;
  double _ambientLampBrightness = 75;
  double _thermostatTemp = 22.5;

  // Estado de los dispositivos del dormitorio
  bool _bedsideLampOn = false;
  double _ceilingFanSpeed = 60; // Level 3 de 5 niveles = 60%

  // Estado de los dispositivos de la cocina
  bool _coffeeMakerOn = false;
  bool _underCabinetLightsOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 28),
            onPressed: () {
              // Acción para agregar nuevo dispositivo o habitación
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 16, bottom: 24),
        children: [
          // Living Room
          RoomCard(
            icon: Icons.weekend_outlined,
            title: 'Living Room',
            isExpanded: _livingRoomExpanded,
            onToggle: () {
              setState(() {
                _livingRoomExpanded = !_livingRoomExpanded;
              });
            },
            devices: [
              const SizedBox(height: 8),
              DeviceSwitchTile(
                icon: Icons.lightbulb_outline,
                title: 'Main Light',
                subtitle: 'On',
                isOn: _mainLightOn,
                onChanged: (value) {
                  setState(() {
                    _mainLightOn = value;
                  });
                },
              ),
              DeviceSliderTile(
                icon: Icons.lightbulb_outline,
                title: 'Ambient Lamp',
                subtitle: 'Brightness',
                value: _ambientLampBrightness,
                displayValue: '${_ambientLampBrightness.round()}%',
                onChanged: (value) {
                  setState(() {
                    _ambientLampBrightness = value;
                  });
                },
              ),
              ThermostatTile(
                temperature: _thermostatTemp,
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
              const SizedBox(height: 12),
            ],
          ),

          // Bedroom
          RoomCard(
            icon: Icons.bed_outlined,
            title: 'Bedroom',
            isExpanded: _bedroomExpanded,
            onToggle: () {
              setState(() {
                _bedroomExpanded = !_bedroomExpanded;
              });
            },
            devices: [
              const SizedBox(height: 8),
              DeviceSwitchTile(
                icon: Icons.nightlight_outlined,
                title: 'Bedside Lamp',
                subtitle: 'Off',
                isOn: _bedsideLampOn,
                onChanged: (value) {
                  setState(() {
                    _bedsideLampOn = value;
                  });
                },
              ),
              DeviceSliderTile(
                icon: Icons.air_outlined,
                title: 'Ceiling Fan',
                subtitle: 'Speed',
                value: _ceilingFanSpeed,
                displayValue: 'Level ${(_ceilingFanSpeed / 20).round()}',
                onChanged: (value) {
                  setState(() {
                    _ceilingFanSpeed = value;
                  });
                },
              ),
              const SizedBox(height: 12),
            ],
          ),

          // Kitchen
          RoomCard(
            icon: Icons.kitchen_outlined,
            title: 'Kitchen',
            isExpanded: _kitchenExpanded,
            onToggle: () {
              setState(() {
                _kitchenExpanded = !_kitchenExpanded;
              });
            },
            devices: [
              const SizedBox(height: 8),
              DeviceSwitchTile(
                icon: Icons.coffee_outlined,
                title: 'Coffee Maker',
                subtitle: 'Off',
                isOn: _coffeeMakerOn,
                onChanged: (value) {
                  setState(() {
                    _coffeeMakerOn = value;
                  });
                },
              ),
              DeviceSwitchTile(
                icon: Icons.lightbulb_outline,
                title: 'Under Cabinet Lights',
                subtitle: 'Off',
                isOn: _underCabinetLightsOn,
                onChanged: (value) {
                  setState(() {
                    _underCabinetLightsOn = value;
                  });
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ],
      ),
    );
  }
}
