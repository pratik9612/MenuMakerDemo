import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_maker_demo/app_controller.dart';
import 'package:menu_maker_demo/bottom_sheet/bottom_sheet_manager.dart';
import 'package:menu_maker_demo/bottom_sheet/edit_text_sheet.dart';
import 'package:menu_maker_demo/bottom_sheet/font_size_sheet.dart';
import 'package:menu_maker_demo/bottom_sheet/font_style_sheet.dart';
import 'package:menu_maker_demo/bottom_sheet/move_bottom_sheet.dart';
import 'package:menu_maker_demo/bottom_sheet/text_color_sheet.dart';
import 'package:menu_maker_demo/bottom_sheet/text_sheet.dart';
import 'package:menu_maker_demo/bottom_sheet/text_space_bottom_sheet.dart';
import 'package:menu_maker_demo/bottom_sheet/text_space_sheet.dart';
import 'package:menu_maker_demo/constant/app_constant.dart';
import 'package:menu_maker_demo/editing_element_controller.dart';
import 'package:menu_maker_demo/editing_screen/editing_screen_controller.dart';
import 'package:menu_maker_demo/main.dart';
import 'package:menu_maker_demo/model/editing_element_model.dart';
import 'package:menu_maker_demo/text_field/text_field.dart';

extension ChangeTextProperties on EditingScreenController {
  void onTextToolAction(TextToolAction action) {
    final controller = selectedController.value;
    if (controller == null) return;

    switch (action) {
      case TextToolAction.editText:
        openTextEditSheet();
        break;
      case TextToolAction.move:
        moveToolAction();
        break;
      case TextToolAction.fontStyle:
        openFontStyleSheet();
        break;
      case TextToolAction.fontSize:
        openFontSizeSheet();
        break;
      case TextToolAction.textSpace:
        BottomSheetManager().open(
          scaffoldKey: scaffoldKey,
          sheet: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: LabelSpaceToolSheet(onAction: onLabelSpaceToolAction),
          ),
          type: EditorBottomSheetType.labelSpace,
        );
        break;
      case TextToolAction.fontColor:
        openTextColorPicker();
        break;
      case TextToolAction.bgColor:
        openTextBgColorPicker();
        break;
      case TextToolAction.copy:
        duplicateTextWithUndo();
        break;
    }
  }

  void openTextEditSheet() {
    final selected = selectedController.value;
    if (selected == null) return;
    if (selected.type.value != EditingWidgetType.label.name) return;

    final oldText = selected.text.value;
    final oldHeight = selected.boxHeight.value;
    final textController = TextEditingController(text: oldText);

    /// Live preview
    textController.addListener(() {
      selected.text.value = textController.text;
      selected.updateTextBoxSize();
    });

    Get.bottomSheet(
      isDismissible: false,
      TextEditSheet(
        controller: textController,
        onCancel: () {
          textController.text = oldText;
          selected.text.value = oldText;
          selected.boxHeight.value = oldHeight;
          Get.back();
        },
        onSave: () {
          final newText = textController.text;
          textController.text = oldText;
          appController.transformChangeText(textController, newText);
          Get.back();
        },
      ),
      isScrollControlled: true,
    );
  }

  void openFontStyleSheet() {
    final selected = selectedController.value;
    if (selected == null) return;
    if (selected.type.value != EditingWidgetType.label.name) return;

    final initialFont = selected.fontURL.value;

    final fonts = [
      "Lato",
      "Lora",
      "AbrilFatface",
      "Allison",
      "Poppins",
      "Lemon",
      "KeaniaOne",
      "Arizonia",
      "InriaSans",
      "Limelight",
      "ArefRuqaaInk",
      "DellaRespira",
      "LobsterTwo",
      "Junge",
      "MarkoOne",
      "Raleway",
      "Inter",
    ];

    Get.bottomSheet(
      isDismissible: false,
      FontStyleSheet(
        fonts: fonts,
        initialFont: initialFont,
        onPreview: (font) {
          selected.fontURL.value = font;
        },
        onCancel: () {
          selected.fontURL.value = initialFont;
          Get.back();
        },
        onSave: () {
          final newFont = selected.fontURL.value;

          selected.fontURL.value = initialFont;
          appController.changeFontStyleWithUndo(selected, newFont);
          Get.back();
        },
      ),
      isScrollControlled: true,
    );
  }

  void openFontSizeSheet() {
    final selected = selectedController.value;
    if (selected == null) return;
    if (selected.type.value != EditingWidgetType.label.name) return;

    final initialFontSize = selected.textSize.value;
    final initialHeight = selected.boxHeight.value;

    Get.bottomSheet(
      isDismissible: false,
      FontSizeSheet(
        initialValue: selected.textSize.value,
        onChanged: (value) {
          selected.textSize.value = value;
          selected.updateTextBoxSize();
        },
        onCancel: () {
          selected.textSize.value = initialFontSize;
          selected.boxHeight.value = initialHeight;
          Get.back();
        },
        onSave: () {
          final newSize = selected.textSize.value;
          selected.textSize.value = initialFontSize;
          appController.changeFontSizeWithUndo(selected, newSize);
          Get.back();
        },
      ),
    );
  }

  void onLabelSpaceToolAction(LabelSpaceToolAction action) {
    final controller = selectedController.value;
    if (controller == null) return;

    if (action == LabelSpaceToolAction.textSpacing) {
      _openLetterSpacingSheet(controller);
    } else if (action == LabelSpaceToolAction.lineSpacing) {
      _openLineSpacingSheet(controller);
    }
  }

  void openTextColorPicker() {
    final selected = selectedController.value;
    if (selected == null) return;
    if (selected.type.value != EditingWidgetType.label.name) return;

    final oldColor = selected.textColor.value.toColor();
    Color finalColor = oldColor;

    Get.bottomSheet(
      isDismissible: false,

      TextColorPickerSheet(
        initialColor: oldColor,
        onColorChanged: (color) {
          finalColor = color;
          selected.textColor.value = color.toHex();
        },
        onCancel: () {
          selected.textColor.value = oldColor.toHex();
          Get.back();
        },
        onSave: () {
          appController.changeTextColorWithUndo(
            selected,
            oldColor.toHex(),
            finalColor.toHex(),
          );
          Get.back();
        },
      ),
      isScrollControlled: true,
    );
  }

  void openTextBgColorPicker() {
    final selected = selectedController.value;
    if (selected == null) return;

    final oldColor = selected.backGroundColor.value.toColor();
    Color finalColor = oldColor;

    Get.bottomSheet(
      isDismissible: false,
      TextColorPickerSheet(
        initialColor: oldColor,
        onColorChanged: (color) {
          finalColor = color;
          selected.backGroundColor.value = color.toHex();
        },
        onCancel: () {
          selected.backGroundColor.value = oldColor.toHex();
          Get.back();
        },
        onSave: () {
          appController.changeTextBgColorWithUndo(
            selected,
            oldColor.toHex(),
            finalColor.toHex(),
          );
          Get.back();
        },
      ),
      isScrollControlled: true,
    );
  }

  void duplicateTextWithUndo() {
    final selected = selectedController.value;
    if (selected == null) return;
    // if (selected.type.value != EditingWidgetType.label.name) return;

    RxList<EditingItem>? targetList;

    /// 🔍 Find selected item inside pages
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
      child: EditingTextField(controller: clonedController),
    );

    appController.duplicateTextWithUndo(targetList!, clonedItem);
  }

  void addNewText() {
    deSelectItem();
    debugPrint("New Add");
    if (editorData == null || scaleX <= 0 || scaleY <= 0) return;

    const double shapeWidth = 250;
    const double shapeHeight = 50;

    // superView space
    final double modelX = (superViewWidth - shapeWidth) / 2;
    final double modelY = (superViewHeight - shapeHeight) / 2;

    final pageKey = currentPageKey.value;
    if (pageKey.isEmpty) return;

    // ================= 1️⃣ MODEL (JSON) =================
    final model = EditingElementModel(
      type: EditingWidgetType.label.name,
      x: modelX,
      y: modelY,
      width: shapeWidth,
      height: shapeHeight,
      rotation: 0,
      alpha: 1,
      isUserInteractionEnabled: true,
      isDuplicatable: true,
      isRemovable: true,
      movable: true,
      isEditable: true,
      text: "Your Text Here",
      textColor: AppConstant.defultColor,
      backGroundColor: AppConstant.transparentColor,
      textSize: 24.0,
    );

    editorData!.elements[pageKey] ??= <EditingElementModel>[];
    editorData!.elements[pageKey]!.add(model);

    // ================= 2️⃣ VIEW ITEM (MANUAL SCALE) =================
    final controller = EditingElementController(
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

    controller.text.value = model.text ?? '';
    controller.textColor.value = model.textColor ?? AppConstant.defultColor;
    controller.backGroundColor.value =
        model.backGroundColor ?? AppConstant.transparentColor;
    controller.textSize.value = model.textSize ?? 24;
    controller.rotation.value = model.rotation;

    final newItem = EditingItem(
      controller: controller,
      child: EditingTextField(controller: controller),
    );

    pageItems[pageKey] ??= <EditingItem>[].obs;
    appController.addTextWithUndo(
      pageKey: pageKey,
      list: pageItems[pageKey]!,
      item: newItem,
      selectedController: selectedController,
    );

    BottomSheetManager().open(
      scaffoldKey: scaffoldKey,
      sheet: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: TextSheet(onAction: onTextToolAction),
      ),
      type: EditorBottomSheetType.label,
    );
  }

  void onMoveToolAction(MoveToolAction action) {
    final controller = selectedController.value;
    if (controller == null) return;
    switch (action) {
      case MoveToolAction.leftMove:
        moveSelectedLeft(2);
        break;
      case MoveToolAction.topMove:
        moveSelectedTop(2);
        break;
      case MoveToolAction.rightMove:
        moveSelectedRight(2);
        break;
      case MoveToolAction.bottomMove:
        moveSelectedBottom(2);
        break;
      case MoveToolAction.leftLongPress:
        startContinuousMove(MoveToolAction.leftLongPress);
        break;
      case MoveToolAction.topLongPress:
        startContinuousMove(MoveToolAction.topLongPress);
        break;
      case MoveToolAction.rightLongPress:
        startContinuousMove(MoveToolAction.rightLongPress);
        break;
      case MoveToolAction.bottomLongPress:
        startContinuousMove(MoveToolAction.bottomLongPress);
        break;
    }
  }
}

void _openLetterSpacingSheet(EditingElementController controller) {
  final oldValue = controller.letterSpace.value.clamp(0.0, 20.0);
  final oldHeight = controller.boxHeight.value;

  Get.bottomSheet(
    isDismissible: false,
    TextSpacingSheet(
      title: "Letter Spacing",
      min: 0.0,
      max: 20.0,
      initialValue: oldValue,
      onPreview: (value) {
        controller.letterSpace.value = value;
        controller.updateTextBoxSize();
      },
      onCancel: () {
        controller.letterSpace.value = oldValue;
        controller.boxHeight.value = oldHeight;
        Get.back();
      },
      onSave: () {
        final newValue = controller.letterSpace.value;
        appController.changeLetterSpacingWithUndo(
          controller,
          oldValue,
          newValue,
        );
        Get.back();
      },
    ),
    isScrollControlled: true,
  );
}

void _openLineSpacingSheet(EditingElementController controller) {
  final oldValue = controller.lineSpace.value.clamp(0.0, 20.0);
  final oldHeight = controller.boxHeight.value;
  Get.bottomSheet(
    isDismissible: false,
    TextSpacingSheet(
      title: "Line Spacing",
      min: 0.0,
      max: 20.0,
      initialValue: oldValue,
      onPreview: (value) {
        controller.lineSpace.value = value;
        controller.updateTextBoxSize();
      },
      onCancel: () {
        controller.lineSpace.value = oldValue;
        controller.boxHeight.value = oldHeight;
        Get.back();
      },
      onSave: () {
        final newValue = controller.lineSpace.value;
        appController.changeLineSpacingWithUndo(controller, oldValue, newValue);
        Get.back();
      },
    ),
    isScrollControlled: true,
  );
}
