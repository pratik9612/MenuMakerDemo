import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_maker_demo/constant/app_constant.dart';
import 'package:menu_maker_demo/constant/color_utils.dart';
import 'package:menu_maker_demo/editing_element_controller.dart';

class EditingTextField extends StatelessWidget {
  final EditingElementController controller;
  const EditingTextField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final font = AppConstant.resolve(controller.fontURL.value);
      return Text(
        controller.text.value,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: ColorUtils.fromHex(controller.textColor.value),
          fontFamily: font.fontFamily,
          fontWeight: font.fontWeight,
          fontStyle: font.fontStyle,
          fontSize: controller.textSize.value,
          letterSpacing: controller.letterSpace.value,
          height: controller.lineSpace.value,
        ),
      );
    });
  }
}
