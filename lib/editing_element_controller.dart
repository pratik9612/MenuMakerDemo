import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  final RxString imageUrl = "".obs;
  final RxString text = ''.obs;
  final RxString textColor = '#FF00FF00'.obs;
  final RxDouble textSize = 36.0.obs;
  final RxString fontURL = "Roboto".obs;

  // Menu
  RxInt menuStyle = 1.obs;
  RxDouble columnWidth = 0.0.obs;
  final RxList<MenuItemModel> arrMenu = <MenuItemModel>[].obs;

  RxString itemNameFontStyle = "".obs;
  RxString itemNameTextColor = "#FFFFFFFF".obs;
  RxDouble itemNameFontSize = 0.0.obs;

  RxString itemValueFontStyle = "".obs;
  RxString itemValueTextColor = "#FFFFFFFF".obs;
  RxDouble itemValueFontSize = 0.0.obs;

  RxString itemDescriptionFontStyle = "".obs;
  RxString itemDescriptionTextColor = "#FFFFFFFF".obs;
  RxDouble itemDescriptionFontSize = 0.0.obs;

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
}

class EditingItem {
  final EditingElementController controller;
  final Widget child;

  EditingItem({required this.controller, required this.child});
}
