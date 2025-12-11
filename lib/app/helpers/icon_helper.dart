import 'package:hugeicons/hugeicons.dart';

class IconHelper {
  static const String getGroupFirstIcon = 'BEDROOM';
  static const String getDeviceFirstIcon = 'LIGHT';

  static const Map<String, List<List<dynamic>>> iconMap =
      <String, List<List<dynamic>>>{
    // Icons for Devices
    ...deviceIcons,

    // Icons for Groups
    ...groupIcons,
  };

  static const Map<String, List<List<dynamic>>> groupIcons =
      <String, List<List<dynamic>>>{
    'BEDROOM': HugeIcons.strokeRoundedBed,
    'LIVING_ROOM': HugeIcons.strokeRoundedSofa01,
    'KITCHEN': HugeIcons.strokeRoundedKitchenUtensils,
    'BATHROOM': HugeIcons.strokeRoundedBathtub01,
    'OFFICE': HugeIcons.strokeRoundedOfficeChair,
    'GARAGE': HugeIcons.strokeRoundedGarage,
    'GARDEN': HugeIcons.strokeRoundedPlant01,
    'DINING_ROOM': HugeIcons.strokeRoundedDiningTable,
    'KIDS_ROOM': HugeIcons.strokeRoundedKid,
    'BASEMENT': HugeIcons.strokeRoundedHome01,
    'BALCONY': HugeIcons.strokeRoundedBuilding01,
    'TERRACE': HugeIcons.strokeRoundedUmbrella,
    'GYM': HugeIcons.strokeRoundedDumbbell01,
    'LAUNDRY_ROOM': HugeIcons.strokeRoundedClean,
    'HALLWAY': HugeIcons.strokeRoundedDoor,
    'ENTRANCE': HugeIcons.strokeRoundedDoor01,
    'CLOSET': HugeIcons.strokeRoundedWardrobe01,
    'STUDIO': HugeIcons.strokeRoundedPaintBoard,
    'ATTIC': HugeIcons.strokeRoundedHome05,
    'POOL': HugeIcons.strokeRoundedSwimmingCap,
    'PATIO': HugeIcons.strokeRoundedChair01,
  };

  static const Map<String, List<List<dynamic>>> deviceIcons =
      <String, List<List<dynamic>>>{
    'LIGHT': HugeIcons.strokeRoundedLamp,
    'BULB': HugeIcons.strokeRoundedBulb,
    'FAN': HugeIcons.strokeRoundedFan01,
    'THERMOMETER': HugeIcons.strokeRoundedThermometer,
    'THERMOSTAT': HugeIcons.strokeRoundedTemperature,
    'AIR_CONDITIONER': HugeIcons.strokeRoundedSnow,
    'HEATER': HugeIcons.strokeRoundedFire,
    'SMART_TV': HugeIcons.strokeRoundedTv01,
    'CAMERA': HugeIcons.strokeRoundedCamera01,
    'SECURITY_CAMERA': HugeIcons.strokeRoundedCctvCamera,
    'DOOR_LOCK': HugeIcons.strokeRoundedDoorLock,
    'GARAGE_DOOR': HugeIcons.strokeRoundedGarage,
    'WINDOW': HugeIcons.strokeRoundedSquare,
    'CURTAIN': HugeIcons.strokeRoundedCurtains,
    'BLINDS': HugeIcons.strokeRoundedMenu01,
    'SPEAKER': HugeIcons.strokeRoundedSpeaker01,
    'WIFI': HugeIcons.strokeRoundedWifi01,
    'ROUTER': HugeIcons.strokeRoundedRouter,
    'PLUG': HugeIcons.strokeRoundedPlug01,
    'SOCKET': HugeIcons.strokeRoundedPlugSocket,
    'SWITCH': HugeIcons.strokeRoundedToggleOn,
    'MOTION_SENSOR': HugeIcons.strokeRoundedRadar01,
    'SMOKE_DETECTOR': HugeIcons.strokeRoundedFire,
    'WATER_SENSOR': HugeIcons.strokeRoundedWaterEnergy,
    'DOORBELL': HugeIcons.strokeRoundedNotification01,
    'ALARM': HugeIcons.strokeRoundedAlarmClock,
    'VACUUM': HugeIcons.strokeRoundedSmartPhone01,
    'REFRIGERATOR': HugeIcons.strokeRoundedFridge,
    'DISHWASHER': HugeIcons.strokeRoundedClean,
    'OVEN': HugeIcons.strokeRoundedOven,
    'MICROWAVE': HugeIcons.strokeRoundedMicrowave,
    'COFFEE_MAKER': HugeIcons.strokeRoundedCoffee01,
    'HUMIDIFIER': HugeIcons.strokeRoundedHumidity,
    'AIR_PURIFIER': HugeIcons.strokeRoundedWindPower,
    'PROJECTOR': HugeIcons.strokeRoundedProjector,
    'PRINTER': HugeIcons.strokeRoundedPrinter,
  };

  static List<List<dynamic>> getIconByName(String iconName) {
    return iconMap[iconName.toUpperCase()] ?? HugeIcons.strokeRoundedDeveloper;
  }
}
