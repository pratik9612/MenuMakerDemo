import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';

class TextColorPickerSheet extends StatelessWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  TextColorPickerSheet({
    super.key,
    required this.initialColor,
    required this.onColorChanged,
    required this.onCancel,
    required this.onSave,
  });

  final Rx<Color> tempColor = Rx<Color>(Colors.black);

  @override
  Widget build(BuildContext context) {
    tempColor.value = initialColor;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Pick Text Color",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            /// 🎨 Color Picker with GetX
            Obx(() {
              return ColorPicker(
                pickerColor: tempColor.value,
                onColorChanged: (color) {
                  tempColor.value = color;
                  onColorChanged(color); // live preview
                },
                enableAlpha: true,
                displayThumbColor: true,
                showLabel: true,
              );
            }),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onSave,
                    child: const Text("Apply"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

extension ColorParsing on String {
  Color toColor() {
    String hex = replaceAll("#", "");
    if (hex.length == 6) hex = "FF$hex";
    return Color(int.parse(hex, radix: 16));
  }
}

extension ColorToHex on Color {
  String toHex() {
    return '#${value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }
}
