import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_maker_demo/app_controller.dart';

import 'package:menu_maker_demo/bottom_sheet/text_color_sheet.dart';
import 'package:menu_maker_demo/editing_element_controller.dart';
import 'package:menu_maker_demo/main.dart';

enum MenuFontTarget { heading, description, value }

class MenuFontBottomSheet extends StatefulWidget {
  final EditingElementController controller;

  const MenuFontBottomSheet({super.key, required this.controller});

  @override
  State<MenuFontBottomSheet> createState() => _MenuFontBottomSheetState();
}

class _MenuFontBottomSheetState extends State<MenuFontBottomSheet> {
  MenuFontTarget selectedTarget = MenuFontTarget.heading;

  late double oldHeading;
  late double oldDesc;
  late double oldValue;

  late String oldHeadingColor;
  late String oldDescColor;
  late String oldValueColor;

  @override
  void initState() {
    super.initState();

    oldHeading = widget.controller.itemNameFontSize.value;
    oldDesc = widget.controller.itemDescriptionFontSize.value;
    oldValue = widget.controller.itemValueFontSize.value;

    oldHeadingColor = widget.controller.itemNameTextColor.value;
    oldDescColor = widget.controller.itemDescriptionTextColor.value;
    oldValueColor = widget.controller.itemValueTextColor.value;
  }

  double get currentSize {
    switch (selectedTarget) {
      case MenuFontTarget.heading:
        return widget.controller.itemNameFontSize.value;
      case MenuFontTarget.description:
        return widget.controller.itemDescriptionFontSize.value;
      case MenuFontTarget.value:
        return widget.controller.itemValueFontSize.value;
    }
  }

  void updateSize(double value) {
    switch (selectedTarget) {
      case MenuFontTarget.heading:
        widget.controller.itemNameFontSize.value = value;
        break;
      case MenuFontTarget.description:
        widget.controller.itemDescriptionFontSize.value = value;
        break;
      case MenuFontTarget.value:
        widget.controller.itemValueFontSize.value = value;
        break;
    }
  }

  void saveWithUndo() {
    appController.changeMenuFontStyleWithUndo(
      widget.controller,
      oldHeadingSize: oldHeading,
      oldDescSize: oldDesc,
      oldValueSize: oldValue,
      oldHeadingColor: oldHeadingColor,
      oldDescColor: oldDescColor,
      oldValueColor: oldValueColor,
      newHeadingSize: widget.controller.itemNameFontSize.value,
      newDescSize: widget.controller.itemDescriptionFontSize.value,
      newValueSize: widget.controller.itemValueFontSize.value,
      newHeadingColor: widget.controller.itemNameTextColor.value,
      newDescColor: widget.controller.itemDescriptionTextColor.value,
      newValueColor: widget.controller.itemValueTextColor.value,
    );
    Get.back();
  }

  void openMenuFontColorPicker(MenuFontTarget target) {
    final selected = widget.controller;

    late String oldColorHex;
    late RxString targetRx;

    switch (target) {
      case MenuFontTarget.heading:
        targetRx = selected.itemNameTextColor;
        oldColorHex = selected.itemNameTextColor.value;
        break;

      case MenuFontTarget.description:
        targetRx = selected.itemDescriptionTextColor;
        oldColorHex = selected.itemDescriptionTextColor.value;
        break;

      case MenuFontTarget.value:
        targetRx = selected.itemValueTextColor;
        oldColorHex = selected.itemValueTextColor.value;
        break;
    }

    final oldColor = oldColorHex.toColor();
    Color finalColor = oldColor;

    Get.bottomSheet(
      isDismissible: false,
      MenuFontColorSheet(
        initialColor: oldColor,

        onPreview: (color) {
          finalColor = color;
          targetRx.value = color.toHex();
        },

        onCancel: () {
          targetRx.value = oldColorHex;
          Get.back();
        },

        onSave: () {
          appController.registerUndo(() {
            targetRx.value = oldColorHex;
          });

          targetRx.value = finalColor.toHex();
          Get.back();
        },
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Tabs
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: MenuFontTarget.values.map((e) {
                final isSelected = selectedTarget == e;
                return GestureDetector(
                  onTap: () => setState(() => selectedTarget = e),
                  child: Column(
                    children: [
                      Text(
                        e.name.capitalize!,
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected ? Colors.orange : Colors.grey,
                        ),
                      ),
                      if (isSelected)
                        Container(height: 2, width: 30, color: Colors.orange),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            /// Font size slider
            Obx(
              () => Slider(
                min: 0,
                max: 100,
                // divisions: 92,
                value: currentSize,
                onChanged: updateSize,
              ),
            ),

            const SizedBox(height: 12),

            /// Font color
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Font Color"),
                IconButton(
                  icon: const Icon(Icons.color_lens),
                  onPressed: () => openMenuFontColorPicker(selectedTarget),
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// Save
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: saveWithUndo,
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

class MenuFontColorSheet extends StatelessWidget {
  final Color initialColor;
  final ValueChanged<Color> onPreview;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const MenuFontColorSheet({
    super.key,
    required this.initialColor,
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Font Color",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          TextColorPickerSheet(
            initialColor: initialColor,
            onColorChanged: onPreview,
            onCancel: onCancel,
            onSave: onSave,
          ),
        ],
      ),
    );
  }
}
