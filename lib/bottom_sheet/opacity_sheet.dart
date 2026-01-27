import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_maker_demo/editing_element_controller.dart';

class OpacityImageSheet extends StatelessWidget {
  final EditingElementController controller;
  final double initialAlpha;
  final ValueChanged<double> onPreview;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const OpacityImageSheet({
    super.key,
    required this.controller,
    required this.initialAlpha,
    required this.onPreview,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Opacity",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          Obx(
            () => Slider(
              min: 0,
              max: 100,
              value: controller.alpha.value * 100,
              onChanged: (v) => onPreview(v / 100),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel,
                  child: const Text("Cancel"),
                ),
              ),
              const SizedBox(width: 10),
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
    );
  }
}
