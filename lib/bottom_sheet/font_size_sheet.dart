import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FontSizeSheet extends StatelessWidget {
  final double initialValue;
  final ValueChanged<double> onChanged;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  FontSizeSheet({
    super.key,
    required this.initialValue,
    required this.onChanged,
    required this.onCancel,
    required this.onSave,
  });

  final RxDouble _currentValue = 0.0.obs;

  @override
  Widget build(BuildContext context) {
    _currentValue.value = initialValue;

    return Container(
      padding: const EdgeInsets.only(right: 16, left: 16, top: 16, bottom: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: const Icon(Icons.close), onPressed: onCancel),
              const Text(
                "Font Size",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              IconButton(icon: const Icon(Icons.check), onPressed: onSave),
            ],
          ),

          const SizedBox(height: 12),

          /// Live value
          Obx(
            () => Text(
              _currentValue.value.toStringAsFixed(0),
              style: const TextStyle(fontSize: 14),
            ),
          ),

          /// Slider
          Obx(
            () => Slider(
              value: _currentValue.value,
              min: 8,
              max: 100,
              divisions: 92,
              onChanged: (value) {
                _currentValue.value = value;
                onChanged(value); // LIVE PREVIEW
              },
            ),
          ),
        ],
      ),
    );
  }
}
