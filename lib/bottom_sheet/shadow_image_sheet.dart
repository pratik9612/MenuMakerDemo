import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_maker_demo/editing_element_controller.dart';

class ShadowImageSheet extends StatelessWidget {
  final EditingElementController controller;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const ShadowImageSheet({
    super.key,
    required this.controller,
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
            "Modify Shadow",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          _slider("Opacity", controller.shadowOpacity, 0, 1),
          _slider("Blur", controller.radius, 0, 100),
          _slider("X Pos", controller.shadowX, -50, 50),
          _slider("Y Pos", controller.shadowY, -50, 50),

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

  Widget _slider(String label, RxDouble value, double min, double max) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          Slider(
            min: min,
            max: max,
            value: value.value.clamp(min, max),
            onChanged: (v) => value.value = v,
          ),
        ],
      ),
    );
  }
}
