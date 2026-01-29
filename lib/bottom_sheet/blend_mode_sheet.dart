import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BlendModeSheet extends StatelessWidget {
  final Rx<BlendMode> selectedMode;
  final RxDouble selectedOpacity;
  final VoidCallback onCancel;
  final VoidCallback onApply;

  const BlendModeSheet({
    super.key,
    required this.selectedMode,
    required this.selectedOpacity,
    required this.onCancel,
    required this.onApply,
  });

  static final List<Map<String, dynamic>> modes = [
    {"name": "Normal", "mode": BlendMode.srcIn},
    {"name": "Multiply", "mode": BlendMode.multiply},
    {"name": "Screen", "mode": BlendMode.screen},
    {"name": "Overlay", "mode": BlendMode.overlay},
    {"name": "Darken", "mode": BlendMode.darken},
    {"name": "Lighten", "mode": BlendMode.lighten},
    {"name": "Color Dodge", "mode": BlendMode.colorDodge},
    {"name": "Color Burn", "mode": BlendMode.colorBurn},
    {"name": "Soft Light", "mode": BlendMode.softLight},
    {"name": "Hard Light", "mode": BlendMode.hardLight},
  ];

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
            "Blend Mode",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          /// 🎨 Blend Mode List
          ...modes.map((item) {
            final BlendMode mode = item["mode"];
            return Obx(
              () => ListTile(
                title: Text(item["name"]),
                trailing: selectedMode.value == mode
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () => selectedMode.value = mode,
              ),
            );
          }),

          const Divider(),

          /// 🎚 Opacity Slider
          Obx(() {
            return Column(
              children: [
                const Text("Opacity"),
                Slider(
                  min: 0,
                  max: 1,
                  value: selectedOpacity.value,
                  onChanged: (v) => selectedOpacity.value = v,
                ),
                Text(selectedOpacity.value.toStringAsFixed(2)),
              ],
            );
          }),

          const SizedBox(height: 10),

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
                  onPressed: onApply,
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
