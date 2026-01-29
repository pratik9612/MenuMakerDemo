import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_maker_demo/editing_element_controller.dart';

class BlurImageSheet extends StatelessWidget {
  final EditingElementController controller;
  final ValueChanged<double> onPreview;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const BlurImageSheet({
    super.key,
    required this.controller,
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
            "Blur",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          /// Slider
          Obx(
            () => Slider(
              min: 0.0,
              max: 1.0,
              value: controller.blurAlpha.value,
              onChanged: onPreview,
            ),
          ),

          const SizedBox(height: 12),

          /// Buttons
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
