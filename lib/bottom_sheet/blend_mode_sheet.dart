import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BlendModeSheet extends StatelessWidget {
  final List<BlendModeItemModel> items;
  final Rx<BlendMode> selectedMode;
  final RxDouble selectedOpacity;
  final VoidCallback onCancel;
  final VoidCallback onApply;

  const BlendModeSheet({
    super.key,
    required this.items,
    required this.selectedMode,
    required this.selectedOpacity,
    required this.onCancel,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(
            () => Slider(
              min: 0,
              max: 1,
              value: selectedOpacity.value,
              activeColor: Colors.black,
              onChanged: (v) => selectedOpacity.value = v,
            ),
          ),

          const SizedBox(height: 12),

          /// HORIZONTAL MODES
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final item = items[index];

                return Obx(() {
                  final isSelected = selectedMode.value == item.mode;

                  return GestureDetector(
                    onTap: () => selectedMode.value = item.mode,
                    child: Column(
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            color: isSelected ? Colors.yellow : Colors.black,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                });
              },
            ),
          ),

          const SizedBox(height: 16),

          /// BOTTOM BAR
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(onPressed: onCancel, icon: const Icon(Icons.close)),
              const Text(
                "Edit Image",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              IconButton(onPressed: onApply, icon: const Icon(Icons.check)),
            ],
          ),
        ],
      ),
    );
  }
}

class BlendModeItemModel {
  final String title;
  final BlendMode mode;
  final String previewPng;

  const BlendModeItemModel({
    required this.title,
    required this.mode,
    required this.previewPng,
  });
}
