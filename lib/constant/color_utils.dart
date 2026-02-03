import 'package:flutter/material.dart';

class ColorUtils {
  static Color fromHex(String? hex, {Color fallback = Colors.transparent}) {
    if (hex == null || hex.isEmpty) return fallback;

    String value = hex.replaceFirst('#', '').toUpperCase();

    if (value.length == 6) {
      // Add full opacity
      value = 'FF$value';
    }

    if (value.length == 8) {
      return Color(int.parse(value, radix: 16));
    }

    return fallback;
  }

  /// Convert Color → #AARRGGBB (for saving JSON)
  static String toHex(Color color, {bool leadingHash = true}) {
    final hex = color.value.toRadixString(16).padLeft(8, '0').toUpperCase();
    return leadingHash ? '#$hex' : hex;
  }
}
