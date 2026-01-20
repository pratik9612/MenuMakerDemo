import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:menu_maker_demo/editing_element_controller.dart';

class EditingItemView extends StatelessWidget {
  final EditingElementController editingElementController;
  final Widget child;
  final VoidCallback onTap;

  const EditingItemView({
    super.key,
    required this.editingElementController,
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final width = editingElementController.boxWidth.value;
      final height = editingElementController.boxHeight.value;
      return Positioned(
        left: editingElementController.x.value,
        top: editingElementController.y.value,
        child: GestureDetector(
          onTap: onTap,
          child: Opacity(
            opacity: editingElementController.alpha.value,
            child: SizedBox(width: width, height: height, child: child),
          ),
        ),
      );
    });
  }
}
