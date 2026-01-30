import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_maker_demo/app_controller.dart';
import 'package:menu_maker_demo/bottom_sheet/bottom_sheet_manager.dart';
import 'package:menu_maker_demo/bottom_sheet/menu_box_sheet.dart';
import 'package:menu_maker_demo/bottom_sheet/menu_font_color_sheet.dart';
import 'package:menu_maker_demo/bottom_sheet/menu_style_picker_sheet.dart';
import 'package:menu_maker_demo/constant/app_constant.dart';
import 'package:menu_maker_demo/edit_menu_item_screen/edit_menu_item_screen.dart';
import 'package:menu_maker_demo/editing_element_controller.dart';
import 'package:menu_maker_demo/editing_screen/editing_screen_controller.dart';
import 'package:menu_maker_demo/editing_screen/text_helper.dart';
import 'package:menu_maker_demo/main.dart';
import 'package:menu_maker_demo/menu/menu_one.dart';
import 'package:menu_maker_demo/model/editing_element_model.dart';

extension ChangeMenuBoxProperties on EditingScreenController {
  void onMenuBoxToolAction(MenuToolAction action) {
    final controller = selectedController.value;
    if (controller == null) return;
    switch (action) {
      case MenuToolAction.editContent:
        onEditingContentAction();
        break;
      case MenuToolAction.changeSize:
        onChangeSizeAction();
        break;
      case MenuToolAction.move:
        moveToolAction();
        break;
      case MenuToolAction.bgColor:
        openTextBgColorPicker();
        break;
      case MenuToolAction.copy:
        onCopyMenuAction();
        break;
      case MenuToolAction.lockOpration:
        break;
    }
  }

  void onEditingContentAction() {
    final selected = selectedController.value;
    if (selected == null) return;

    Get.to(() => EditMenuItemsScreen(controller: selected));
  }

  void onChangeSizeAction() {
    final selected = selectedController.value;
    if (selected == null) return;

    Get.bottomSheet(
      MenuFontBottomSheet(controller: selected),
      isScrollControlled: true,
    );
  }

  void addNewMenu() {
    Get.bottomSheet(
      MenuStylePickerSheet(
        onStyleSelected: (styleIndex) {
          _createMenuWithStyle(styleIndex);
        },
      ),
      isScrollControlled: true,
    );
  }

  void _createMenuWithStyle(int styleIndex) {
    deSelectItem();

    if (editorData == null || scaleX <= 0 || scaleY <= 0) return;

    const shapeWidth = 250.0;
    const shapeHeight = 250.0;

    final modelX = (superViewWidth - shapeWidth) / 2;
    final modelY = (superViewHeight - shapeHeight) / 2;

    final pageKey = currentPageKey.value;
    if (pageKey.isEmpty) return;

    final config = resolveItem(styleIndex);

    // MODEL
    final model = EditingElementModel(
      type: EditingWidgetType.menuBox.name,
      x: modelX,
      y: modelY,
      width: shapeWidth,
      height: shapeHeight,
      menuStyle: styleIndex,
      rotation: 0,
      alpha: 1,
      isUserInteractionEnabled: true,
      isDuplicatable: true,
      isRemovable: true,
      movable: true,
      isEditable: true,
      columnWidth: 30,
      menuData: config.menuItems,
      itemDescriptionFontSize: config.itemDescriptionFontSize,
      itemDescriptionTextColor: menuTextColor,
      itemNameFontSize: config.itemNameFontSize,
      itemNameTextColor: menuTextColor,
      itemValueFontSize: config.itemValueFontSize,
      itemValueTextColor: menuTextColor,
      itemNameFontStyle: config.itemNameFontStyle,
      itemDescriptionFontStyle: config.itemDescriptionFontStyle,
      itemValueFontStyle: config.itemValueFontStyle,
    );

    editorData!.elements[pageKey] ??= [];
    editorData!.elements[pageKey]!.add(model);

    //CONTROLLER
    final menuController = EditingElementController(
      type: model.type,
      initX: model.x * scaleX,
      initY: model.y * scaleY,
      initWidth: model.width * scaleX,
      initHeight: model.height * scaleY,
      initRotation: model.rotation,
      initScale: 1 * scaleX,
      isUserInteractionEnabled: model.isUserInteractionEnabled,
      isDuplicatable: model.isDuplicatable,
      isRemovable: model.isRemovable,
      movable: model.movable,
      isEditable: model.isEditable,
    );

    menuController.menuStyle.value = styleIndex;
    menuController.arrMenu.addAll(config.menuItems);

    menuController.columnWidth.value = model.columnWidth ?? 0.0;

    menuController.itemNameFontStyle.value = model.itemNameFontStyle ?? "";
    menuController.itemNameTextColor.value =
        model.itemNameTextColor ?? AppConstant.defultColor;
    menuController.itemNameFontSize.value = model.itemNameFontSize ?? 16;

    menuController.itemValueFontStyle.value = model.itemValueFontStyle ?? "";
    menuController.itemValueTextColor.value =
        model.itemValueTextColor ?? AppConstant.defultColor;
    menuController.itemValueFontSize.value = model.itemValueFontSize ?? 16;

    menuController.itemDescriptionFontStyle.value =
        model.itemDescriptionFontStyle ?? "";
    menuController.itemDescriptionTextColor.value =
        model.itemDescriptionTextColor ?? AppConstant.defultColor;
    menuController.itemDescriptionFontSize.value =
        model.itemDescriptionFontSize ?? 16;

    // VIEW
    final newItem = EditingItem(
      controller: menuController,
      child: MenuOne(
        editingElementController: menuController,
        scaleX: scaleX,
        scaleY: scaleY,
      ),
    );

    pageItems[pageKey] ??= <EditingItem>[].obs;
    appController.addMenuWithUndo(
      pageKey: pageKey,
      list: pageItems[pageKey]!,
      item: newItem,
    );

    selectedController.value = menuController;

    BottomSheetManager().open(
      scaffoldKey: scaffoldKey,
      sheet: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: MenuBoxSheet(onAction: onMenuBoxToolAction),
      ),
      type: EditorBottomSheetType.menuBox,
    );
  }

  void onCopyMenuAction() {
    final selected = selectedController.value;
    if (selected == null) return;
    if (selected.type.value != EditingWidgetType.menuBox.name) return;

    RxList<EditingItem>? targetList;

    pageItems.forEach((_, items) {
      for (final item in items) {
        if (item.controller == selected) {
          targetList = items;
          break;
        }
      }
    });

    if (targetList == null) return;

    final clonedController = selected.clone();

    final clonedItem = EditingItem(
      controller: clonedController,
      child: MenuOne(
        editingElementController: clonedController,
        scaleX: scaleX,
        scaleY: scaleY,
      ),
    );

    appController.duplicateItemWithUndo(targetList!, clonedItem);
  }
}
