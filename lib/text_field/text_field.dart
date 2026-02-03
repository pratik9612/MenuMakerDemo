import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_maker_demo/constant/color_utils.dart';
import 'package:menu_maker_demo/editing_element_controller.dart';

class EditingTextField extends StatelessWidget {
  final EditingElementController controller;
  const EditingTextField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // final font = AppConstant.resolve(controller.fontURL.value);
      return Text(
        controller.text.value,
        textAlign: controller.getTextAlign(),
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