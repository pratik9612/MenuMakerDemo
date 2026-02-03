import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_maker_demo/editing_element_controller.dart';
import 'package:menu_maker_demo/menu/menu_style_factory.dart';

class MenuOne extends StatelessWidget {
  final EditingElementController editingElementController;

  const MenuOne({super.key, required this.editingElementController});

  @override
  Widget build(BuildContext context) {
    if (editingElementController.arrMenu.isEmpty) {
      return const SizedBox.shrink();
    }

    return Obx(() {
      final items = editingElementController.arrMenu;
      if (items.isEmpty) return const SizedBox.shrink();
      return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: items.length == 1
            ? MainAxisAlignment.center
            : MainAxisAlignment.spaceBetween,
        children: List.generate(items.length, (index) {
          return SizedBox(
            width: double.infinity,
            child: Align(
              alignment: editingElementController.menuStyle.value == 7
                  ? Alignment.centerLeft
                  : Alignment.center,
              child: MenuStyleFactory.build(
                editingElementController.menuStyle.value,
                editingElementController,
                items[index],
              ),
            ),
          );
        }),
      );
    });
  }
}
