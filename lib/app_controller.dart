import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_maker_demo/editing_element_controller.dart';
import 'package:menu_maker_demo/model/transform_snapshot.dart';
import 'package:menu_maker_demo/undo_redu/undo_redu_manager.dart';

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
  }

  void changeFontStyleWithUndo(
    EditingElementController controller,
    String newFontFamily,
  ) {
    final oldFont = controller.fontURL.value;
    registerUndo(() => changeFontStyleWithUndo(controller, oldFont));
    controller.fontURL.value = newFontFamily;
  }
}
