import 'package:flutter/material.dart';

class ColorHelper {
  static const Map<String, Color> colorMap = <String, Color>{
    'RED': Colors.red,
    'PINK': Colors.pink,
    'PURPLE': Colors.purple,
    'DEEP_PURPLE': Colors.deepPurple,
    'INDIGO': Colors.indigo,
    'BLUE': Colors.blue,
    'LIGHT_BLUE': Colors.lightBlue,
    'CYAN': Colors.cyan,
    'TEAL': Colors.teal,
    'GREEN': Colors.green,
    'LIGHT_GREEN': Colors.lightGreen,
    'LIME': Colors.lime,
    'YELLOW': Colors.yellow,
    'AMBER': Colors.amber,
    'ORANGE': Colors.orange,
    'DEEP_ORANGE': Colors.deepOrange,
    'BROWN': Colors.brown,
    'GREY': Colors.grey,
    'BLUE_GREY': Colors.blueGrey,
  };

  static Color getColorByName(String colorName) {
    return colorMap[colorName.toUpperCase()] ?? Colors.indigo;
  }
}
