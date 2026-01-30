import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_maker_demo/constant/app_constant.dart';
import 'package:menu_maker_demo/model/editing_element_model.dart';

class EditingElementController extends GetxController {
  RxString type = "".obs;

  // Position & size
  RxDouble x = 0.0.obs;
  RxDouble y = 0.0.obs;
  RxDouble boxWidth = 0.0.obs;
  RxDouble boxHeight = 0.0.obs;
  RxDouble scale = 1.0.obs;
  RxDouble rotation = 0.0.obs;
  RxDouble alpha = 1.0.obs;

  RxBool isUserInteractionEnabled = true.obs;
  RxBool isDuplicatable = true.obs;
  RxBool isRemovable = true.obs; // used
  RxBool movable = true.obs; // used
  RxBool isEditable = true.obs;
  RxDouble letterSpace = 0.0.obs;
  RxDouble lineSpace = 0.0.obs;
  RxInt alignment = 1.obs;
  RxDouble blurAlpha = 0.0.obs;
  final RxDouble shadowOpacity = 0.0.obs; // 0–1
  final RxDouble radius = 0.0.obs; // 0–50
  final RxDouble shadowX = 0.0.obs; // -50 to 50
  final RxDouble shadowY = 0.0.obs; // -50 to 50
  final Rx<BlendMode> blendMode = BlendMode.srcIn.obs; // default normal

  final RxString imageUrl = "".obs;
  final RxString text = ''.obs;
  final RxString textColor = AppConstant.defultColor.obs;
  final RxString tintColor = AppConstant.transparentColor.obs;
  final RxString backGroundColor = AppConstant.transparentColor.obs;
  final RxDouble textSize = 36.0.obs;
  final RxString fontURL = "".obs;

  // Menu
  RxInt menuStyle = 1.obs;
  RxDouble columnWidth = 0.0.obs;
  final RxList<MenuItemModel> arrMenu = <MenuItemModel>[].obs;

  RxString itemNameFontStyle = "".obs;
  RxString itemNameTextColor = AppConstant.defultColor.obs;
  RxDouble itemNameFontSize = 0.0.obs;

  RxString itemValueFontStyle = "".obs;
  RxString itemValueTextColor = AppConstant.defultColor.obs;
  RxDouble itemValueFontSize = 0.0.obs;

  RxString itemDescriptionFontStyle = "".obs;
  RxString itemDescriptionTextColor = AppConstant.defultColor.obs;
  RxDouble itemDescriptionFontSize = 0.0.obs;
  final RxBool flipX = false.obs;
  final RxBool flipY = false.obs;

  // Runtime usefull
  RxBool isRotating = false.obs;
  RxBool isScaling = false.obs;

  EditingElementController({
    required String type,
    required double initX,
    required double initY,
    required double initWidth,
    required double initHeight,
    required double initScale,
    required double initRotation,
    required bool isUserInteractionEnabled,
    required bool isDuplicatable,
    required bool isRemovable,
    required bool movable,
    required bool isEditable,
  }) {
    this.type.value = type;
    x.value = initX;
    y.value = initY;
    boxWidth.value = initWidth;
    boxHeight.value = initHeight;
    scale.value = initScale;
    rotation.value = initRotation;
    this.isUserInteractionEnabled.value = isUserInteractionEnabled;
    this.isDuplicatable.value = isDuplicatable;
    this.isRemovable.value = isRemovable;
    this.movable.value = movable;
    this.isEditable.value = isEditable;
  }

  void move(double dx, double dy) {
    x.value += dx;
    y.value += dy;
  }

  void addMenuItem({
    required String itemName,
    String description = "",
    Map<String, String>? values,
  }) {
    arrMenu.add(
      MenuItemModel(
        itemName: itemName,
        description: description,
        values: values ?? {},
      ),
    );
  }

  void removeMenuItem(int index) {
    if (index >= 0 && index < arrMenu.length) {
      arrMenu.removeAt(index);
    }
  }

  void updateMenuItem(
    int index, {
    String? itemName,
    String? description,
    Map<String, String>? values,
  }) {
    final old = arrMenu[index];
    arrMenu[index] = MenuItemModel(
      itemName: itemName ?? old.itemName,
      description: description ?? old.description,
      values: values ?? old.values,
    );
  }

  void updateTextBoxSize() {
    final font = AppConstant.resolve(fontURL.value);

    final style = TextStyle(
      fontSize: textSize.value,
      height: lineSpace.value,
      letterSpacing: letterSpace.value,
      fontFamily: font.fontFamily,
      fontWeight: font.fontWeight,
      fontStyle: font.fontStyle,
    );

    final calculatedHeight =
        _measureTextHeight(
          text: text.value,
          maxWidth: boxWidth.value,
          style: style,
        ) +
        16;

    boxHeight.value = calculatedHeight;
  }

  double _measureTextHeight({
    required String text,
    required double maxWidth,
    required TextStyle style,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: null,
    )..layout(maxWidth: maxWidth);

    return painter.height;
  }

  Alignment getTextAlign() {
    switch (alignment.value) {
      case 0:
        return Alignment.centerLeft;
      case 2:
        return Alignment.centerRight;
      default:
        return Alignment.center;
    }
  }
}

class EditingItem {
  final EditingElementController controller;
  final Widget child;

  EditingItem({required this.controller, required this.child});
}
