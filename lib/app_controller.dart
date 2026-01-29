import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:menu_maker_demo/bottom_sheet/change_image_sheet.dart';
import 'package:menu_maker_demo/editing_element_controller.dart';
import 'package:menu_maker_demo/model/transform_snapshot.dart';
import 'package:menu_maker_demo/undo_redu/undo_redu_manager.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class AppController extends GetxController {
  final UndoRedoManager undoRedoManager = UndoRedoManager();

  final canUndo = false.obs;
  final canRedo = false.obs;

  void registerUndo(UndoAction undo) {
    undoRedoManager.registerUndo(undo);
    print("=-=-=-=- $undo");
    _sync();
  }

  void undo() {
    undoRedoManager.undo();
    _sync();
  }

  void redo() {
    undoRedoManager.redo();
    _sync();
  }

  void clearUndoRedo() {
    undoRedoManager.clear();
    _sync();
  }

  void _sync() {
    canUndo.value = undoRedoManager.canUndo;
    canRedo.value = undoRedoManager.canRedo;
  }
}

extension TransformUndo on AppController {
  void registerTransformUndo({
    required EditingElementController controller,
    required TransformSnapshot before,
    required TransformSnapshot after,
  }) {
    registerUndo(() {
      registerTransformUndo(
        controller: controller,
        before: after,
        after: before,
      );
      before.applyTo(controller);
    });
  }

  void transformChangeText(TextEditingController controller, String newText) {
    final oldText = controller.text;
    registerUndo(() => transformChangeText(controller, oldText));
    controller.text = newText;
  }

  void textMoveWithUndo(
    EditingElementController controller,
    double dx,
    double dy,
  ) {
    final after = TransformSnapshot(
      x: controller.x.value + dx,
      y: controller.y.value + dy,
      width: controller.boxWidth.value,
      height: controller.boxHeight.value,
      rotation: controller.rotation.value,
    );

    registerUndo(() => textMoveWithUndo(controller, -dx, -dy));

    after.applyTo(controller);
  }

  void changeFontSizeWithUndo(
    EditingElementController controller,
    double newSize,
  ) {
    final oldSize = controller.textSize.value;

    registerUndo(() => changeFontSizeWithUndo(controller, oldSize));

    controller.textSize.value = newSize;
    controller.updateTextBoxSize();
  }

  void changeFontStyleWithUndo(
    EditingElementController controller,
    String newFontFamily,
  ) {
    final oldFont = controller.fontURL.value;
    registerUndo(() => changeFontStyleWithUndo(controller, oldFont));
    controller.fontURL.value = newFontFamily;
  }

  void changeLetterSpacingWithUndo(
    EditingElementController controller,
    double oldSpacing,
    double newSpacing,
  ) {
    if (oldSpacing == newSpacing) return;

    registerUndo(
      () => changeLetterSpacingWithUndo(controller, newSpacing, oldSpacing),
    );

    controller.letterSpace.value = newSpacing;
  }

  void changeLineSpacingWithUndo(
    EditingElementController controller,
    double oldSpacing,
    double newSpacing,
  ) {
    if (oldSpacing == newSpacing) return;

    registerUndo(
      () => changeLineSpacingWithUndo(controller, newSpacing, oldSpacing),
    );

    controller.lineSpace.value = newSpacing;
  }

  void changeTextColorWithUndo(
    EditingElementController controller,
    String oldColor,
    String newColor,
  ) {
    if (oldColor == newColor) return;

    registerUndo(() => changeTextColorWithUndo(controller, newColor, oldColor));

    controller.textColor.value = newColor;
  }

  void changeTextBgColorWithUndo(
    EditingElementController controller,
    String oldColor,
    String newColor,
  ) {
    if (oldColor == newColor) return;

    registerUndo(
      () => changeTextBgColorWithUndo(controller, newColor, oldColor),
    );

    controller.backGroundColor.value = newColor;
  }

  void changeShapeTintColorWithUndo(
    EditingElementController controller,
    String oldColor,
    String newColor,
  ) {
    if (oldColor == newColor) return;

    registerUndo(
      () => changeShapeTintColorWithUndo(controller, newColor, oldColor),
    );

    controller.tintColor.value = newColor;
  }

  void duplicateTextWithUndo(
    RxList<EditingItem> targetList,
    EditingItem duplicatedItem,
  ) {
    registerUndo(
      () => removeDuplicatedTextWithUndo(targetList, duplicatedItem),
    );

    targetList.add(duplicatedItem);
  }

  void removeDuplicatedTextWithUndo(
    RxList<EditingItem> targetList,
    EditingItem duplicatedItem,
  ) {
    registerUndo(() => duplicateTextWithUndo(targetList, duplicatedItem));

    targetList.remove(duplicatedItem);
  }

  void duplicateItemWithUndo(
    RxList<EditingItem> targetList,
    EditingItem duplicatedItem,
  ) {
    registerUndo(() {
      // UNDO: remove the duplicated item
      _removeDuplicatedItem(targetList, duplicatedItem);
    });

    // FORWARD: add duplicated item
    targetList.add(duplicatedItem);
    targetList.refresh();
  }

  void _removeDuplicatedItem(
    RxList<EditingItem> targetList,
    EditingItem duplicatedItem,
  ) {
    registerUndo(() {
      // REDO: re-add the duplicated item
      duplicateItemWithUndo(targetList, duplicatedItem);
    });

    targetList.remove(duplicatedItem);
    targetList.refresh();
  }

  void flipImageHorizontallyWithUndo(EditingElementController controller) {
    final oldFlip = controller.flipX.value;

    registerUndo(() => flipImageHorizontallyWithUndo(controller));

    controller.flipX.value = !oldFlip;
  }

  void flipImageVerticallyWithUndo(EditingElementController controller) {
    final oldFlip = controller.flipY.value;

    registerUndo(() => flipImageVerticallyWithUndo(controller));

    controller.flipY.value = !oldFlip;
  }

  void changeImageWithUndo(
    EditingElementController controller,
    ImageSnapshot oldImageSnapShot,
    ImageSnapshot newImageSnapShot,
  ) {
    if (oldImageSnapShot.imageUrl == newImageSnapShot.imageUrl) return;

    registerUndo(
      () => changeImageWithUndo(controller, newImageSnapShot, oldImageSnapShot),
    );

    controller.imageUrl.value = newImageSnapShot.imageUrl;
    controller.boxWidth.value = newImageSnapShot.width;
    controller.boxHeight.value = newImageSnapShot.height;
  }

  void changeImageCropWithUndo(
    EditingElementController controller, {
    required String oldUrl,
    required String newUrl,
    required Rect oldRect,
    required Rect newRect,
  }) {
    registerUndo(
      () => changeImageCropWithUndo(
        controller,
        oldUrl: newUrl,
        newUrl: oldUrl,
        oldRect: newRect,
        newRect: oldRect,
      ),
    );

    controller.imageUrl.value = newUrl;
    controller.x.value = newRect.left;
    controller.y.value = newRect.top;
    controller.boxWidth.value = newRect.width;
    controller.boxHeight.value = newRect.height;
  }

  void changeImageBlurWithUndo(
    EditingElementController controller,
    double oldBlur,
    double newBlur,
  ) {
    if (oldBlur == newBlur) return;

    registerUndo(() => changeImageBlurWithUndo(controller, newBlur, oldBlur));

    controller.blurAlpha.value = newBlur;
  }

  void changeImageOpacityWithUndo(
    EditingElementController controller,
    double oldAlpha,
    double newAlpha,
  ) {
    if (oldAlpha == newAlpha) return;

    registerUndo(
      () => changeImageOpacityWithUndo(controller, newAlpha, oldAlpha),
    );

    controller.alpha.value = newAlpha;
  }

  void changeImageShadowWithUndo(
    EditingElementController controller,
    double oldOpacity,
    double oldBlur,
    double oldX,
    double oldY,
    double newOpacity,
    double newBlur,
    double newX,
    double newY,
  ) {
    registerUndo(
      () => changeImageShadowWithUndo(
        controller,
        newOpacity,
        newBlur,
        newX,
        newY,
        oldOpacity,
        oldBlur,
        oldX,
        oldY,
      ),
    );

    controller.shadowOpacity.value = newOpacity;
    controller.radius.value = newBlur;
    controller.shadowX.value = newX;
    controller.shadowY.value = newY;
  }

  void changeImageBlendWithUndo(
    EditingElementController controller,
    BlendMode oldMode,
    double oldOpacity,
    BlendMode newMode,
    double newOpacity,
  ) {
    if (oldMode == newMode && oldOpacity == newOpacity) return;

    registerUndo(
      () => changeImageBlendWithUndo(
        controller,
        newMode,
        newOpacity,
        oldMode,
        oldOpacity,
      ),
    );

    controller.blendMode.value = newMode;
    controller.alpha.value = newOpacity;
  }
}

extension AppControllerImagePicker on AppController {
  static final ImagePicker _picker = ImagePicker();

  Future<String?> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    return image?.path;
  }

  Future<String?> pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    return image?.path;
  }

  Future<String?> pickImageFromFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      return result.files.single.path;
    }
    return null;
  }

  Future<String?> cropImage(String imagePath) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imagePath,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: 'Crop Image'),
      ],
    );

    return croppedFile?.path;
  }

  Future<String?> downloadImageToLocal(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return null;

      final dir = await getTemporaryDirectory();
      final filePath =
          "${dir.path}/img_${DateTime.now().millisecondsSinceEpoch}.png";

      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      return filePath;
    } catch (e) {
      debugPrint("Download failed: $e");
      return null;
    }
  }
}
