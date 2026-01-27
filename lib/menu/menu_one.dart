import 'package:flutter/material.dart';
import 'package:menu_maker_demo/editing_element_controller.dart';
import 'package:menu_maker_demo/menu/menu_style_factory.dart';

class MenuOne extends StatelessWidget {
  final EditingElementController editingElementController;
  final double scaleX;
  final double scaleY;

  const MenuOne({
    super.key,
    required this.editingElementController,
    required this.scaleX,
    required this.scaleY,
  });

  @override
  Widget build(BuildContext context) {
    if (editingElementController.arrMenu.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(editingElementController.arrMenu.length, (index) {
        final item = editingElementController.arrMenu[index];
        return MenuStyleFactory.build(
          editingElementController.menuStyle.value,
          editingElementController,
          item,
        );
      }),
    );
  }
}
