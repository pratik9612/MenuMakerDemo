import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:menu_maker_demo/app_controller.dart';
import 'package:menu_maker_demo/bottom_sheet/blend_mode_sheet.dart';
import 'package:menu_maker_demo/bottom_sheet/blur_alpha_sheet.dart';
import 'package:menu_maker_demo/bottom_sheet/bottom_sheet_manager.dart';
import 'package:menu_maker_demo/bottom_sheet/change_image_sheet.dart';
import 'package:menu_maker_demo/bottom_sheet/image_sheet.dart';
import 'package:menu_maker_demo/bottom_sheet/opacity_sheet.dart';
import 'package:menu_maker_demo/bottom_sheet/shadow_image_sheet.dart';
import 'package:menu_maker_demo/bottom_sheet/shape_list_sheet.dart';
import 'package:menu_maker_demo/bottom_sheet/shape_sheet.dart';
import 'package:menu_maker_demo/bottom_sheet/text_color_sheet.dart';
import 'package:menu_maker_demo/constant/app_constant.dart';
import 'package:menu_maker_demo/editing_element_controller.dart';
import 'package:menu_maker_demo/editing_screen/editing_screen_controller.dart';
import 'package:menu_maker_demo/editing_screen/text_helper.dart';
import 'package:menu_maker_demo/main.dart';
import 'package:menu_maker_demo/model/editing_element_model.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

extension ChangeImageAndShapeProperties on EditingScreenController {
  void onImageToolAction(ImageToolAction action) {
    final controller = selectedController.value;
    if (controller == null) return;

    switch (action) {
      case ImageToolAction.change:
        imageChangeAction();
        break;
      case ImageToolAction.move:
        moveToolAction();
        break;
      case ImageToolAction.flipH:
        flipHImageAction();
        break;
      case ImageToolAction.flipV:
        flipVImageAction();
        break;
      case ImageToolAction.crop:
        cropeImageAction();
        break;
      case ImageToolAction.adjustments:
        break;
      case ImageToolAction.bgColor:
        openTextBgColorPicker();
        break;
      case ImageToolAction.blur:
        blurImageAction();
        break;
      case ImageToolAction.opacity:
        opacityImageAction();
        break;
      case ImageToolAction.shadow:
        shadowImageAction();
        break;
      case ImageToolAction.blendModes:
        blendModeImageAction();
        break;
      case ImageToolAction.copy:
        duplicateImageWithUndo();
        break;
    }
  }

  void imageChangeAction() {
    final selected = selectedController.value;
    if (selected == null) return;
    if (selected.type.value != EditingWidgetType.image.name) return;

    Get.bottomSheet(
      ChangeImageSheet(
        onGallery: () async {
          Get.back();
          final newImage = await appController.pickImageFromGallery();
          _applyImageChange(newImage);
        },
        onFile: () async {
          Get.back();
          final newImage = await appController.pickImageFromFile();
          _applyImageChange(newImage);
        },
        onCamera: () async {
          Get.back();
          final newImage = await appController.pickImageFromCamera();
          _applyImageChange(newImage);
        },
      ),
      isScrollControlled: true,
    );
  }

  Future<void> _applyImageChange(String? newUrl) async {
    if (newUrl == null || newUrl.isEmpty) return;

    final selected = selectedController.value;
    if (selected == null) return;

    ImageSnapshot oldSnalShot = ImageSnapshot(
      imageUrl: selected.imageUrl.value,
      width: selected.boxWidth.value,
      height: selected.boxHeight.value,
    );

    final imageSize = await getImageSize(newUrl);
    final newBoxSize = computeBoxSize(
      imageSize: imageSize,
      targetWidth: selected.boxWidth.value,
    );

    ImageSnapshot newSnalShot = ImageSnapshot(
      imageUrl: newUrl,
      width: newBoxSize.width,
      height: newBoxSize.height,
    );

    appController.changeImageWithUndo(selected, oldSnalShot, newSnalShot);
  }

  Size computeBoxSize({required Size imageSize, required double targetWidth}) {
    final ratio = imageSize.height / imageSize.width;
    return Size(targetWidth, targetWidth * ratio);
  }

  void flipHImageAction() {
    debugPrint("flipHImageAction");
    final selected = selectedController.value;
    if (selected == null) return;
    appController.flipImageHorizontallyWithUndo(selected);
  }

  void flipVImageAction() {
    final selected = selectedController.value;
    if (selected == null) return;
    appController.flipImageVerticallyWithUndo(selected);
  }

  Future<Size> getImageSize(String path) async {
    final file = File(path);
    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return Size(frame.image.width.toDouble(), frame.image.height.toDouble());
  }

  void cropeImageAction() async {
    final selected = selectedController.value;
    if (selected == null) return;
    if (selected.type.value != EditingWidgetType.image.name) return;

    final String oldUrl = selected.imageUrl.value;
    if (oldUrl.isEmpty) return;

    // 1️⃣ GET LOCAL IMAGE

    String? localPath = oldUrl;

    if (oldUrl.startsWith('http') || oldUrl.startsWith('Templates')) {
      final fullUrl = oldUrl.startsWith('Templates')
          ? "${AppConstant.imageBaseUrl}$oldUrl"
          : oldUrl;

      localPath = await appController.downloadImageToLocal(fullUrl);
      if (localPath == null) return;
    }

    // 2️⃣ SNAPSHOT BEFORE CHANGE
    final oldSnapshot = ImageTransformSnapshot(
      imageUrl: selected.imageUrl.value,
      rect: Rect.fromLTWH(
        selected.x.value,
        selected.y.value,
        selected.boxWidth.value,
        selected.boxHeight.value,
      ),
      flipX: selected.flipX.value,
      flipY: selected.flipY.value,
    );

    // 3️⃣ APPLY FLIP TO FILE
    if (selected.flipX.value || selected.flipY.value) {
      final flippedPath = await flipImage(
        localPath,
        flipX: selected.flipX.value,
        flipY: selected.flipY.value,
      );

      if (flippedPath == null) return;

      localPath = flippedPath;
    }

    // 4️⃣ CROP IMAGE
    final croppedPath = await appController.cropImage(localPath);
    if (croppedPath == null) return;

    final rawSize = await getImageSize(croppedPath);

    final fittedSize = fitSizeInsideBox(
      rawSize,
      editorViewWidth.value * 0.8,
      editorViewHeight.value * 0.8,
    );

    final centerX = oldSnapshot.rect.left + oldSnapshot.rect.width / 2;
    final centerY = oldSnapshot.rect.top + oldSnapshot.rect.height / 2;

    final newRect = Rect.fromLTWH(
      centerX - fittedSize.width / 2,
      centerY - fittedSize.height / 2,
      fittedSize.width,
      fittedSize.height,
    );

    // 5️⃣ APPLY CHANGE WITH UNDO
    final newSnapshot = ImageTransformSnapshot(
      imageUrl: croppedPath,
      rect: newRect,
      flipX: false, // baked into file
      flipY: false,
    );

    appController.changeImageTransformWithUndo(
      selected,
      oldSnapshot,
      newSnapshot,
    );
  }

  Size fitSizeInsideBox(Size original, double maxW, double maxH) {
    final ratioW = maxW / original.width;
    final ratioH = maxH / original.height;
    final ratio = ratioW < ratioH ? ratioW : ratioH;

    if (ratio >= 1) return original;

    return Size(original.width * ratio, original.height * ratio);
  }

  Future<String?> flipImage(
    String imagePath, {
    bool flipX = false,
    bool flipY = false,
  }) async {
    if (!flipX && !flipY) {
      final localPath = await appController.downloadImageToLocal(imagePath);
      return localPath;
    }

    Uint8List bytes;

    // 🔹 1. Load bytes based on source
    if (imagePath.startsWith('http')) {
      // HTTP / HTTPS
      final response = await http.get(Uri.parse(imagePath));
      if (response.statusCode != 200) {
        throw Exception('Failed to load network image');
      }
      bytes = response.bodyBytes;
    } else if (imagePath.startsWith('assets/')) {
      // Asset image
      final data = await rootBundle.load(imagePath);
      bytes = data.buffer.asUint8List();
    } else {
      // Local file
      bytes = await File(imagePath).readAsBytes();
    }

    // 🔹 2. Decode image
    final image = img.decodeImage(bytes);
    if (image == null) {
      throw Exception('Unsupported image format');
    }

    img.Image result = image;

    if (flipX) {
      result = img.flipHorizontal(result);
    }
    if (flipY) {
      result = img.flipVertical(result);
    }

    // 🔹 3. Save flipped image to temp directory
    final tempDir = await getTemporaryDirectory();
    final newPath = p.join(
      tempDir.path,
      'flipped_${DateTime.now().millisecondsSinceEpoch}.png',
    );

    final file = File(newPath);
    await file.writeAsBytes(img.encodePng(result));

    return newPath;
  }

  void blurImageAction() {
    final selected = selectedController.value;
    if (selected == null) return;

    final oldBlur = selected.blurAlpha.value;
    double finalBlur = oldBlur;

    Get.bottomSheet(
      isDismissible: false,
      BlurImageSheet(
        controller: selected,
        onPreview: (value) {
          finalBlur = value;
          selected.blurAlpha.value = value; // live preview
        },
        onCancel: () {
          selected.blurAlpha.value = oldBlur;
          Get.back();
        },
        onSave: () {
          appController.changeImageBlurWithUndo(selected, oldBlur, finalBlur);
          Get.back();
        },
      ),
      isScrollControlled: true,
    );
  }

  void opacityImageAction() {
    final selected = selectedController.value;
    if (selected == null) return;

    final oldAlpha = selected.alpha.value;
    double finalAlpha = oldAlpha;

    Get.bottomSheet(
      isDismissible: false,
      OpacityImageSheet(
        controller: selected,
        initialAlpha: oldAlpha,
        onPreview: (value) {
          finalAlpha = value;
          selected.alpha.value = value;
        },
        onCancel: () {
          selected.alpha.value = oldAlpha;
          Get.back();
        },
        onSave: () {
          appController.changeImageOpacityWithUndo(
            selected,
            oldAlpha,
            finalAlpha,
          );
          Get.back();
        },
      ),
      isScrollControlled: true,
    );
  }

  void shadowImageAction() {
    final selected = selectedController.value;
    if (selected == null) return;

    final oldOpacity = selected.shadowOpacity.value;
    final oldBlur = selected.shadowRadius.value;
    final oldX = selected.shadowX.value;
    final oldY = selected.shadowY.value;

    Get.bottomSheet(
      isDismissible: false,
      ShadowImageSheet(
        controller: selected,
        onCancel: () {
          selected.shadowOpacity.value = oldOpacity;
          selected.shadowRadius.value = oldBlur;
          selected.shadowX.value = oldX;
          selected.shadowY.value = oldY;
          Get.back();
        },
        onSave: () {
          appController.changeImageShadowWithUndo(
            selected,
            oldOpacity,
            oldBlur,
            oldX,
            oldY,
            selected.shadowOpacity.value,
            selected.shadowRadius.value,
            selected.shadowX.value,
            selected.shadowY.value,
          );
          Get.back();
        },
      ),
      isScrollControlled: true,
    );
  }

  void blendModeImageAction() {
    final selected = selectedController.value;
    if (selected == null) return;

    final oldMode = selected.blendMode.value;
    final oldOpacity = selected.alpha.value;

    final tempMode = oldMode.obs;
    final tempOpacity = oldOpacity.obs;

    Get.bottomSheet(
      isDismissible: false,
      BlendModeSheet(
        selectedMode: tempMode,
        selectedOpacity: tempOpacity,
        onCancel: () {
          selected.blendMode.value = oldMode;
          selected.alpha.value = oldOpacity;
          Get.back();
        },
        onApply: () {
          appController.changeImageBlendWithUndo(
            selected,
            oldMode,
            oldOpacity,
            tempMode.value,
            tempOpacity.value,
          );
          Get.back();
        },
      ),
      isScrollControlled: true,
    );
  }

  void duplicateImageWithUndo() {
    final selected = selectedController.value;
    if (selected == null) return;
    if (selected.type.value != EditingWidgetType.image.name) return;

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
      child: buildImageWidget(clonedController), // ✅ SAME PIPELINE
    );

    appController.duplicateItemWithUndo(targetList!, clonedItem);
  }

  void onShapeToolAction(ShapeToolAction action) {
    final controller = selectedController.value;
    if (controller == null) return;
    switch (action) {
      case ShapeToolAction.change:
        BottomSheetManager().open(
          scaffoldKey: scaffoldKey,
          sheet: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: ShapeTypeSheet(
              onAction: (action) {
                onShapeTypeToolAction(action, isNewAdd: false);
              },
            ),
          ),
          type: EditorBottomSheetType.shapeType,
        );
        break;
      case ShapeToolAction.flipH:
        flipHImageAction();
        break;
      case ShapeToolAction.flipV:
        flipVImageAction();
        break;
      case ShapeToolAction.color:
        openShapeTintColorPicker();
        break;
      case ShapeToolAction.blur:
        blurImageAction();
        break;
      case ShapeToolAction.opacity:
        opacityImageAction();
        break;
      case ShapeToolAction.shadow:
        shadowImageAction();
        break;
      case ShapeToolAction.blendMode:
        blendModeImageAction();
        break;
      case ShapeToolAction.move:
        moveToolAction();
        break;
      case ShapeToolAction.copy:
        duplicateShapeWithUndo();
        break;
      case ShapeToolAction.lockOpration:
        break;
    }
  }

  void openShapeTintColorPicker() {
    final selected = selectedController.value;
    if (selected == null) return;

    final oldColor = selected.tintColor.value.toColor();
    Color finalColor = oldColor;

    Get.bottomSheet(
      isDismissible: false,
      TextColorPickerSheet(
        initialColor: oldColor,
        onColorChanged: (color) {
          finalColor = color;
          selected.tintColor.value = color.toHex();
        },
        onCancel: () {
          selected.tintColor.value = oldColor.toHex();
          Get.back();
        },
        onSave: () {
          appController.changeShapeTintColorWithUndo(
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

  void duplicateShapeWithUndo() {
    final selected = selectedController.value;
    if (selected == null) return;
    if (selected.type.value != EditingWidgetType.shape.name) return;

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
      child: buildShapeWidget(clonedController),
    );

    appController.duplicateItemWithUndo(targetList!, clonedItem);
  }

  void onShapeTypeToolAction(
    ShapeTypeToolAction action, {
    required bool isNewAdd,
  }) {
    if (isNewAdd) {
      addNewShape(action);
    } else {
      replaceShape(action);
    }
  }

  void addNewShape(ShapeTypeToolAction shapeType) {
    deSelectItem();
    if (editorData == null || scaleX <= 0 || scaleY <= 0) return;

    const double shapeWidth = 250;
    const double shapeHeight = 250;

    // superView space
    final double modelX = (superViewWidth - shapeWidth) / 2;
    final double modelY = (superViewHeight - shapeHeight) / 2;

    final pageKey = currentPageKey.value;
    if (pageKey.isEmpty) return;

    // ================= 1️⃣ MODEL (JSON) =================
    final model = EditingElementModel(
      type: EditingWidgetType.shape.name,
      x: modelX,
      y: modelY,
      width: shapeWidth,
      height: shapeHeight,
      rotation: 0,
      url: shapeType.name,
      tintColor: "#FFFFFFFF",
      alpha: 1,
      isUserInteractionEnabled: true,
      isDuplicatable: true,
      isRemovable: true,
      movable: true,
      isEditable: true,
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

    controller.imageUrl.value = model.url!;
    controller.tintColor.value = model.tintColor!;
    controller.alpha.value = model.alpha;

    final newItem = EditingItem(
      controller: controller,
      child: buildShapeWidget(controller),
    );

    pageItems[pageKey] ??= <EditingItem>[].obs;

    appController.addShapeWithUndo(
      list: pageItems[pageKey]!,
      item: newItem,
      selectedController: selectedController,
    );
    selectedController.value = controller;
    BottomSheetManager().open(
      scaffoldKey: scaffoldKey,
      sheet: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ShapeSheet(onAction: onShapeToolAction),
      ),
      type: EditorBottomSheetType.shape,
    );
  }

  void replaceShape(ShapeTypeToolAction shapeType) async {
    final selected = selectedController.value;
    if (selected == null) return;

    String oldShapeType = selected.imageUrl.value;

    selected.imageUrl.value = shapeType.name;

    String newShapeType = selected.imageUrl.value;

    appController.changeShapeWithUndo(selected, oldShapeType, newShapeType);
  }
}
