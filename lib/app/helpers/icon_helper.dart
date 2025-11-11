import 'package:hugeicons/hugeicons.dart';

class IconHelper {
  static const Map<String, List<List<dynamic>>> iconMap =
      <String, List<List<dynamic>>>{
        'LIGHT': HugeIcons.strokeRoundedLamp,
        'BULB': HugeIcons.strokeRoundedBulb,
        'FAN': HugeIcons.strokeRoundedFan01,
        'THERMOMETER': HugeIcons.strokeRoundedThermometer,
        'THERMOSTAT': HugeIcons.strokeRoundedTemperature,
        'AIR_CONDITIONER': HugeIcons.strokeRoundedAirbnb,
        'SMART_TV': HugeIcons.strokeRoundedSmartWatch01,
        'CAMERA': HugeIcons.strokeRoundedCamera01,
        'SECURITY_CAMERA': HugeIcons.strokeRoundedCctvCamera,
        'DOOR_LOCK': HugeIcons.strokeRoundedDoorLock,
        'GARAGE_DOOR': HugeIcons.strokeRoundedGarage,
        'WINDOW': HugeIcons.strokeRoundedWindPower,
        'CURTAIN': HugeIcons.strokeRoundedCurtains,
        'SPEAKER': HugeIcons.strokeRoundedSpeaker01,
        'WIFI': HugeIcons.strokeRoundedWifi01,
        'PLUG': HugeIcons.strokeRoundedPlug01,
        'SOCKET': HugeIcons.strokeRoundedPlugSocket,
        'MOTION_SENSOR': HugeIcons.strokeRoundedMoonAngledRainZap,
        'SMOKE_DETECTOR': HugeIcons.strokeRoundedFire,
        'WATER_SENSOR': HugeIcons.strokeRoundedWaterPolo,
        'DOORBELL': HugeIcons.strokeRoundedNotification01,
      };

  static List<List<dynamic>> getIconByName(String iconName) {
    return iconMap[iconName.toUpperCase()] ?? HugeIcons.strokeRoundedDeveloper;
  }
}
