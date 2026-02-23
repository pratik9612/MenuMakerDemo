import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_maker_demo/constant/color_utils.dart';
import 'package:menu_maker_demo/editing_element_controller.dart';
import 'package:menu_maker_demo/main.dart';

class EditingTextField extends StatelessWidget {
  final EditingElementController controller;
  const EditingTextField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Text(
        controller.text.value,
        textAlign: appController.getTextAlign(controller.alignment.value),
        style: TextStyle(
          color: ColorUtils.fromHex(controller.textColor.value),
          fontFamily: controller.fontURL.value,
          fontSize: controller.textSize.value,
          letterSpacing: controller.letterSpace.value,
          height: controller.lineSpace.value,
        ),
      );
    });
  }
}
