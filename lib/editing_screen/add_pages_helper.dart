import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_maker_demo/bottom_sheet/bottom_sheet_manager.dart';
import 'package:menu_maker_demo/bottom_sheet/page_add_sheet.dart';
import 'package:menu_maker_demo/constant/app_constant.dart';
import 'package:menu_maker_demo/editing_element_controller.dart';
import 'package:menu_maker_demo/editing_screen/editing_screen_controller.dart';
import 'package:menu_maker_demo/model/editing_element_model.dart';

extension AddPage on EditingScreenController {
  void onAddPageToolAction(AddPageToolAction action) {
    switch (action) {
      case AddPageToolAction.addPage:
        addPageWithFirstElement();
        BottomSheetManager().close();
        break;

      case AddPageToolAction.copy:
        copyCurrentPage();
        BottomSheetManager().close();
        break;

      case AddPageToolAction.delete:
        deletePage();
        BottomSheetManager().close();
        break;

      case AddPageToolAction.cancel:
        BottomSheetManager().close();
        break;

      case AddPageToolAction.save:
        BottomSheetManager().close();
        break;
    }
  }

  void addPageWithFirstElement() {
    final currentKey = currentPageKey.value;
    if (currentKey.isEmpty) return;

    final currentItems = pageItems[currentKey];
    if (currentItems == null || currentItems.isEmpty) return;

    // 1️⃣ Convert FIRST controller (background) → model
    final bgController = currentItems.first.controller;
    final bgModel = buildElement(bgController.type.value, bgController);

    // 2️⃣ Generate new page key
    final newKey = generateNewPageKey();

    // 3️⃣ Save ONLY background model for new page
    editorData!.elements[newKey] = [
      EditingElementModel.fromJson(bgModel.toJson()),
    ];

    // 4️⃣ Insert page key AFTER current page
    final insertIndex = pageKeys.indexOf(currentKey) + 1;
    pageKeys.insert(insertIndex, newKey);

    // 5️⃣ Build widgets/controllers from model (single source of truth)
    pageItems[newKey] = editorData!.elements[newKey]!
        .map(itemFromModel)
        .toList()
        .obs;

    // 6️⃣ Redirect user to new page
    currentPageIndex.value = insertIndex;
    currentPageKey.value = newKey;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      pageController.jumpToPage(insertIndex);
    });

    debugPrint("New page added & redirected. Key: $newKey");
  }

  void copyCurrentPage() {
    final currentKey = currentPageKey.value;
    if (currentKey.isEmpty) return;

    final currentItems = pageItems[currentKey];
    if (currentItems == null || currentItems.isEmpty) return;

    // 1️⃣ Sync controllers to model
    final currentModels = currentItems.map((item) {
      return buildElement(
        item.controller.type.value,
        item.controller,
      ); // <-- your function
    }).toList();

    // 2️⃣ Generate new page key
    final newKey = generateNewPageKey();
    final insertIndex = pageKeys.indexOf(currentKey) + 1;

    // 3️⃣ Deep copy models for the new page
    final newModels = currentModels
        .map((e) => EditingElementModel.fromJson(e.toJson()))
        .toList();

    editorData!.elements[newKey] = newModels;

    // 4️⃣ Insert key and build widgets
    pageKeys.insert(insertIndex, newKey);
    pageItems[newKey] = newModels
        .map((model) => itemFromModelForCopyPage(model))
        .toList()
        .obs;

    // 5️⃣ Select the new page
    currentPageKey.value = newKey;
    currentPageIndex.value = insertIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      pageController.jumpToPage(insertIndex);
    });

    debugPrint("Page copied successfully. Total pages: ${pageKeys.length}");
  }

  String generateNewPageKey() {
    if (pageKeys.isEmpty) return '0';
    final maxKey = pageKeys.map(int.parse).reduce((a, b) => a > b ? a : b);
    return (maxKey + 1).toString();
  }

  void deletePage() {
    final currentKey = currentPageKey.value;
    if (currentKey.isEmpty || editorData == null) return;
    // 🚫 Never delete last remaining page
    if (pageKeys.length <= 1) return;

    final deleteIndex = pageKeys.indexOf(currentKey);
    if (deleteIndex == -1) return;

    // 1️⃣ Remove from model
    editorData!.elements.remove(currentKey);

    // 2️⃣ Remove UI/controllers
    pageItems.remove(currentKey);

    // 3️⃣ Remove Page key
    pageKeys.removeAt(deleteIndex);

    // 4️⃣ Decide redirect page
    int newIndex;

    if (deleteIndex == 0) {
      // Deleted first page → go to next
      newIndex = 0;
    } else {
      // Deleted middle or last → go to previous
      newIndex = deleteIndex - 1;
    }

    currentPageIndex.value = newIndex;
    currentPageKey.value = pageKeys[newIndex];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      pageController.jumpToPage(currentPageIndex.value);
    });

    debugPrint(
      "Deleted page. Redirected to index $newIndex, key ${currentPageKey.value}",
    );
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
