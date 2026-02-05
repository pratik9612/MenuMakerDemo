import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_maker_demo/bottom_sheet/bottom_sheet_manager.dart';
import 'package:menu_maker_demo/bottom_sheet/page_add_sheet.dart';
import 'package:menu_maker_demo/constant/app_constant.dart';
import 'package:menu_maker_demo/editing_element_controller.dart';
import 'package:menu_maker_demo/editing_screen/editing_screen_controller.dart';
import 'package:menu_maker_demo/main.dart';

import 'package:menu_maker_demo/model/editing_element_model.dart';

extension AddPage on EditingScreenController {
  void onAddPageToolAction(AddPageToolAction action) {
    switch (action) {
      case AddPageToolAction.addPage:
        addPageWithUndo();
        BottomSheetManager().close();
        break;

      case AddPageToolAction.copy:
        copyPageWithUndo();
        BottomSheetManager().close();
        break;

      case AddPageToolAction.delete:
        deletePageWithUndo();
        BottomSheetManager().close();
        break;

      case AddPageToolAction.cancel:
      case AddPageToolAction.save:
        BottomSheetManager().close();
        break;
    }
  }

  void addPageWithUndo() {
    final currentKey = currentPageKey.value;
    if (currentKey.isEmpty) return;

    final insertIndex = pageKeys.indexOf(currentKey) + 1;
    final newKey = generateNewPageKey();
    appController.beginUndoTransaction();
    addPageInternal(newKey, insertIndex);
    appController.endUndoTransaction();
  }

  void addPageInternal(String newKey, int insertIndex) {
    // 🔁 register inverse for REDO
    appController.registerUndo(() => removePageInternal(newKey, insertIndex));

    final currentItems = pageItems[currentPageKey.value];
    if (currentItems == null || currentItems.isEmpty) return;

    final bgController = currentItems.first.controller;
    final bgModel = buildElement(bgController.type.value, bgController);

    editorData!.elements[newKey] = [
      EditingElementModel.fromJson(bgModel.toJson()),
    ];

    pageKeys.insert(insertIndex, newKey);

    pageItems[newKey] = editorData!.elements[newKey]!
        .map(itemFromModel)
        .toList()
        .obs;

    currentPageKey.value = newKey;
    currentPageIndex.value = insertIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (pageController.hasClients) {
        pageController.jumpToPage(insertIndex);
      }
    });
  }

  void copyPageWithUndo() {
    final sourceKey = currentPageKey.value;
    if (sourceKey.isEmpty) return;

    final insertIndex = pageKeys.indexOf(sourceKey) + 1;
    final newKey = generateNewPageKey();

    appController.beginUndoTransaction();

    copyPageInternal(sourceKey, newKey, insertIndex);

    appController.endUndoTransaction();
  }

  void copyPageInternal(String sourceKey, String newKey, int insertIndex) {
    final sourceItems = pageItems[sourceKey];
    if (sourceItems == null) return;

    final models = sourceItems
        .map(
          (item) => EditingElementModel.fromJson(
            buildElement(item.controller.type.value, item.controller).toJson(),
          ),
        )
        .toList();

    // 🔁 register inverse (for UNDO & REDO)
    appController.registerUndo(() => removePageInternal(newKey, insertIndex));

    editorData!.elements[newKey] = models;
    pageKeys.insert(insertIndex, newKey);

    pageItems[newKey] = models.map(itemFromModelForCopyPage).toList().obs;

    currentPageKey.value = newKey;
    currentPageIndex.value = insertIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (pageController.hasClients) {
        pageController.jumpToPage(insertIndex);
      }
    });
  }

  String generateNewPageKey() {
    if (pageKeys.isEmpty) return '0';
    final maxKey = pageKeys.map(int.parse).reduce((a, b) => a > b ? a : b);
    return (maxKey + 1).toString();
  }

  void deletePageWithUndo() {
    if (pageKeys.length <= 1) return;

    final key = currentPageKey.value;
    final index = pageKeys.indexOf(key);
    if (index == -1) return;

    appController.beginUndoTransaction();

    removePageInternal(key, index);

    appController.endUndoTransaction();
  }

  void removePageInternal(String key, int index) {
    final removedModels = editorData!.elements[key]!
        .map((e) => EditingElementModel.fromJson(e.toJson()))
        .toList();

    // 🔁 register inverse for REDO
    appController.registerUndo(
      () => restorePageInternal(key, index, removedModels),
    );

    editorData!.elements.remove(key);
    pageItems.remove(key);
    pageKeys.remove(key);

    final newIndex = index == 0 ? 0 : index - 1;
    currentPageIndex.value = newIndex;
    currentPageKey.value = pageKeys[newIndex];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (pageController.hasClients) {
        pageController.jumpToPage(newIndex);
      }
    });
  }

  void restorePageInternal(
    String key,
    int index,
    List<EditingElementModel> models,
  ) {
    // 🔁 register inverse for REDO
    appController.registerUndo(() => removePageInternal(key, index));

    editorData!.elements[key] = models
        .map((e) => EditingElementModel.fromJson(e.toJson()))
        .toList();

    pageKeys.insert(index, key);

    pageItems[key] = editorData!.elements[key]!.map(itemFromModel).toList().obs;

    currentPageKey.value = key;
    currentPageIndex.value = index;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (pageController.hasClients) {
        pageController.jumpToPage(index);
      }
    });
  }

  EditingItem itemFromModelForCopyPage(EditingElementModel model) {
    double viewWidth = (model.width);
    double viewHeight = (model.height);
    double positionX = model.x;
    double positionY = model.y;

    final controller = EditingElementController(
      type: model.type,
      initX: positionX,
      initY: positionY,
      initWidth: viewWidth,
      initHeight: viewHeight,
      initRotation: model.rotation,
      initScale: 1 * scaleX,
      isUserInteractionEnabled: model.isUserInteractionEnabled,
      isDuplicatable: model.isDuplicatable,
      isRemovable: model.isRemovable,
      movable: model.movable,
      isEditable: model.isEditable,
    );

    if (model.type == EditingWidgetType.label.name) {
      double scaledTextSize = (model.textSize ?? 24);
      controller.text.value = model.text ?? '';
      controller.textColor.value = model.textColor ?? AppConstant.defultColor;
      controller.backGroundColor.value =
          model.backGroundColor ?? AppConstant.transparentColor;
      controller.textSize.value = scaledTextSize;
      controller.fontURL.value = model.fontURL ?? '';
      controller.letterSpace.value = model.letterSpace ?? 0.0;
      controller.lineSpace.value = model.lineSpace ?? 0.0;
      controller.alignment.value = model.alignment ?? 1;
    }

    if (model.type == EditingWidgetType.image.name && model.url != null) {
      controller.imageUrl.value = model.url!;
      controller.backGroundColor.value =
          model.backGroundColor ?? AppConstant.transparentColor;
      controller.alpha.value = model.alpha;
      controller.blendMode.value = controller.blendMode.value = BlendMode.values
          .firstWhere(
            (e) => e.name == model.blendMode,
            orElse: () => BlendMode.srcIn,
          );
      controller.blurAlpha.value = model.blurAlpha ?? 0.0;
      controller.flipX.value = model.flipX ?? false;
      controller.flipY.value = model.flipY ?? false;
      controller.shadowOpacity.value = model.shadowOpacity ?? 0.0;
      controller.shadowRadius.value = model.shadowRadius ?? 0.0;
    }
    if (model.type == EditingWidgetType.shape.name && model.url != null) {
      controller.imageUrl.value = model.url!;
      controller.tintColor.value =
          model.tintColor ?? AppConstant.transparentColor;
      controller.alpha.value = model.alpha;
      controller.blendMode.value = controller.blendMode.value = BlendMode.values
          .firstWhere(
            (e) => e.name == model.blendMode,
            orElse: () => BlendMode.srcIn,
          );
      controller.blurAlpha.value = model.blurAlpha ?? 0.0;
      controller.flipX.value = model.flipX ?? false;
      controller.flipY.value = model.flipY ?? false;
      controller.shadowOpacity.value = model.shadowOpacity ?? 0.0;
      controller.shadowRadius.value = model.shadowRadius ?? 0.0;
    }
    if (model.type == EditingWidgetType.menuBox.name) {
      controller.menuStyle.value = model.menuStyle ?? 1;
      controller.columnWidth.value = model.columnWidth ?? 24;
      controller.arrMenu.assignAll(model.menuData ?? []);

      controller.itemNameFontStyle.value = model.itemNameFontStyle ?? "";
      controller.itemNameTextColor.value =
          model.itemNameTextColor ?? AppConstant.defultColor;
      controller.itemNameFontSize.value = model.itemNameFontSize ?? 24;

      controller.itemValueFontStyle.value = model.itemValueFontStyle ?? "";
      controller.itemValueTextColor.value =
          model.itemValueTextColor ?? AppConstant.defultColor;
      controller.itemValueFontSize.value = model.itemValueFontSize ?? 24;

      controller.itemDescriptionFontStyle.value =
          model.itemDescriptionFontStyle ?? "";
      controller.itemDescriptionTextColor.value =
          model.itemDescriptionTextColor ?? AppConstant.defultColor;
      controller.itemDescriptionFontSize.value =
          model.itemDescriptionFontSize ?? 24;
      menuTextColor = model.itemNameTextColor ?? AppConstant.defultColor;
    }

    return EditingItem(
      controller: controller,
      child: buildRequiredChild(model, controller),
    );
  }
}
