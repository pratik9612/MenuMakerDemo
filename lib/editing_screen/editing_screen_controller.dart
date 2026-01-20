import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:menu_maker_demo/bottom_sheet/bottom_sheet_manager.dart';
import 'package:menu_maker_demo/bottom_sheet/image_sheet.dart';
import 'package:menu_maker_demo/bottom_sheet/move_bottom_sheet.dart';
import 'package:menu_maker_demo/bottom_sheet/shape_sheet.dart';
import 'package:menu_maker_demo/bottom_sheet/text_sheet.dart';
import 'package:menu_maker_demo/bottom_sheet/text_space_bottom_sheet.dart';
import 'package:menu_maker_demo/constant/app_constant.dart';
import 'package:menu_maker_demo/editing_element_controller.dart';
import 'package:menu_maker_demo/editing_screen/editing_screen_widget.dart';
import 'package:menu_maker_demo/menu/menu_one.dart';
import 'package:menu_maker_demo/model/editing_element_model.dart';
import 'package:menu_maker_demo/text_field/text_field.dart';

class EditingScreenController extends GetxController {
  final RxMap<String, Size> canvasSizes = <String, Size>{}.obs;
  final RxMap<String, Offset> scales = <String, Offset>{}.obs;

  // RxList<EditingItem> items = <EditingItem>[].obs;
  final RxMap<String, RxList<EditingItem>> pageItems =
      <String, RxList<EditingItem>>{}.obs;
  final RxMap<String, BackgroundModel> backgrounds =
      <String, BackgroundModel>{}.obs;
  final Rx<EditingElementController?> selectedController =
      Rx<EditingElementController?>(null);
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, dynamic>? lastSavedJson;

  EditorDataModel? editorData;
  final RxList<String> pageKeys = <String>[].obs;

  double superViewWidth = 0;
  double superViewHeight = 0;
  final RxDouble editorViewWidth = 0.0.obs;
  final RxDouble editorViewHeight = 0.0.obs;
  double scaleX = 0;
  double scaleY = 0;

  void clearEditor() {
    // Clear all reactive state
    backgrounds.clear();
    pageItems.clear();
    pageKeys.clear();
  }

  /// Load all pages, only background first
  void loadAllPages(EditorDataModel data) {
    pageKeys.clear();
    pageItems.clear();
    editorData = data;

    superViewWidth = data.superViewWidth;
    superViewHeight = data.superViewHeight;

    debugPrint(
      "superViewWidth: $superViewWidth = superViewHeight: $superViewHeight",
    );

    pageKeys.assignAll(data.elements.keys.toList()..sort());
  }

  void calculateChildScale() {
    if (superViewWidth <= 0 ||
        superViewHeight <= 0 ||
        editorViewWidth.value <= 0 ||
        editorViewHeight.value <= 0) {
      return;
    }
    debugPrint(
      'editorWidth: ${editorViewWidth.value}, editorHeight: ${editorViewHeight.value}',
    );
    debugPrint(
      'superViewWidth: $superViewWidth, superViewHeight: $superViewHeight',
    );

    final aspectRatio = superViewWidth / superViewHeight;
    double width = editorViewWidth.value;
    double height = width / aspectRatio;
    if (height > editorViewHeight.value) {
      height = editorViewHeight.value;
      width = height * aspectRatio;
    }

    scaleX = width / superViewWidth;
    scaleY = height / superViewHeight;
    final size = Size(width, height);
    final superViewSize = Size(superViewWidth, superViewHeight);
    generateChildrenAfterScale(size, superViewSize);
  }

  /// Generate children only AFTER user scales background
  void generateChildrenAfterScale(Size size, Size superViewSize) {
    if (editorData == null) return;

    pageItems.clear();

    for (final key in pageKeys) {
      final elements = editorData!.elements[key];
      if (elements == null || elements.isEmpty) continue;

      final RxList<EditingItem> items = <EditingItem>[].obs;

      // ================= BACKGROUND FIRST =================
      final bgModel = elements.first;

      final bgController = EditingElementController(
        type: bgModel.type,
        initX: 0,
        initY: 0,
        initWidth: size.width,
        initHeight: size.height,
        initRotation: 0,
        initScale: 1,
        isUserInteractionEnabled: false,
        isDuplicatable: false,
        isRemovable: false,
        movable: false,
        isEditable: false,
      );

      if (bgModel.type == EditingWidgetType.image.name && bgModel.url != null) {
        bgController.imageUrl.value = bgModel.url!;
      }

      items.add(
        EditingItem(
          controller: bgController,
          child: BackgroundWidget(
            backgroundModel: BackgroundModel(
              type: bgModel.type,
              url: bgModel.url ?? "",
              width: superViewWidth,
              height: superViewHeight,
              backGroundColor: bgModel.backGroundColor ?? "#FFFFFFFF",
            ),
            editorWidth: size.width,
            editorHeight: size.height,
          ),
        ),
      );

      // ================= OTHER ELEMENTS =================
      for (int i = 1; i < elements.length; i++) {
        items.add(_itemFromModel(elements[i]));
      }

      // 🔥 VERY IMPORTANT
      pageItems[key] = items;
    }
  }

  EditingItem _itemFromModel(EditingElementModel model) {
    double viewWidth = (model.width * scaleX);
    double viewHeight = (model.height * scaleY);
    double positionX = model.x * scaleX;
    double positionY = model.y * scaleY;

    final controller = EditingElementController(
      type: model.type,
      initX: positionX,
      initY: positionY,
      initWidth: viewWidth,
      initHeight: viewHeight,
      initRotation: model.rotation,
      initScale: model.scale * scaleX,
      isUserInteractionEnabled: model.isUserInteractionEnabled,
      isDuplicatable: model.isDuplicatable,
      isRemovable: model.isRemovable,
      movable: model.movable,
      isEditable: model.isEditable,
    );

    if (model.type == EditingWidgetType.label.name) {
      double scaledTextSize =
          (model.textSize ?? 24) * ((scaleX < scaleY) ? scaleX : scaleY);
      controller.text.value = model.text ?? '';
      controller.textColor.value = model.textColor ?? '#FF000000';
      controller.backGroundColor.value = model.backGroundColor ?? '#00000000';
      controller.textSize.value = scaledTextSize;
      controller.fontURL.value = model.fontURL ?? '';
    }

    if (model.type == EditingWidgetType.image.name && model.url != null) {
      controller.imageUrl.value = model.url!;
    }

    if (model.type == EditingWidgetType.menuBox.name) {
      controller.menuStyle.value = model.menuStyle ?? 1;
      controller.columnWidth.value = model.columnWidth ?? 0.0;
      controller.arrMenu.assignAll(model.menuData ?? []);

      controller.itemNameFontStyle.value = model.itemNameFontStyle ?? "";
      controller.itemNameTextColor.value =
          model.itemNameTextColor ?? AppConstant.defultColor;
      controller.itemNameFontSize.value = model.itemNameFontSize ?? 16;

      controller.itemValueFontStyle.value = model.itemValueFontStyle ?? "";
      controller.itemValueTextColor.value =
          model.itemValueTextColor ?? AppConstant.defultColor;
      controller.itemValueFontSize.value = model.itemValueFontSize ?? 16;

      controller.itemDescriptionFontStyle.value =
          model.itemDescriptionFontStyle ?? "";
      controller.itemDescriptionTextColor.value =
          model.itemDescriptionTextColor ?? AppConstant.defultColor;
      controller.itemDescriptionFontSize.value =
          model.itemDescriptionFontSize ?? 16;
    }

    return EditingItem(
      controller: controller,
      child: _buildChild(model, controller),
    );
  }

  Widget _buildChild(
    EditingElementModel model,
    EditingElementController controller,
  ) {
    if (model.type == EditingWidgetType.image.name) {
      return controller.imageUrl.value.startsWith('Templates')
          ? Image.network(
              "${AppConstant.imageBaseUrl}${controller.imageUrl.value}",
              fit: BoxFit.contain,
            )
          : Image.asset(controller.imageUrl.value, fit: BoxFit.contain);
    } else if (model.type == EditingWidgetType.label.name) {
      return EditingTextField(controller: controller);
    } else {
      return MenuOne(
        editingElementController: controller,
        scaleX: scaleX,
        scaleY: scaleY,
      );
    }
  }

  void selectItem(EditingElementController editingElementController) {
    debugPrint("select Item");
    if (!editingElementController.isUserInteractionEnabled.value ||
        editingElementController == selectedController.value) {
      return;
    }
    selectedController.value = editingElementController;
    if (editingElementController.type.value == EditingWidgetType.label.name) {
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
    } else if (editingElementController.type.value ==
        EditingWidgetType.image.name) {
      BottomSheetManager().open(
        scaffoldKey: scaffoldKey,
        sheet: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ImageSheet(onAction: onImageToolAction),
        ),
        type: EditorBottomSheetType.image,
      );
    } else if (editingElementController.type.value ==
        EditingWidgetType.shape.name) {
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
  }

  bool isSelected(EditingElementController editingElementController) {
    return selectedController.value == editingElementController;
  }

  void deSelectItem() {
    selectedController.value = null;
    BottomSheetManager().close();
  }

  void deleteChildWidget(String pageKey, EditingElementController controller) {
    final items = pageItems[pageKey];
    if (items == null || items.isEmpty) return;
    items.removeWhere((item) => identical(item.controller, controller));
    items.refresh();
    if (selectedController.value == controller) {
      deSelectItem();
    }
  }

  void moveSelectedLeft(double delta) {
    if (selectedController.value != null) {
      selectedController.value!.x.value -= delta;
    }
  }

  void moveSelectedTop(double delta) {
    if (selectedController.value != null) {
      selectedController.value!.y.value -= delta;
    }
  }

  void moveSelectedRight(double delta) {
    if (selectedController.value != null) {
      selectedController.value!.x.value += delta;
    }
  }

  void moveSelectedBottom(double delta) {
    if (selectedController.value != null) {
      selectedController.value!.y.value += delta;
    }
  }

  void changeApha(double alpha) {
    final selected = selectedController.value;
    if (selected != null) {
      selected.alpha.value = alpha.clamp(0.0, 1.0);
    }
  }

  void saveAndReload() async {
    // 1️⃣ Save the current editor state
    saveMenu();

    // 2️⃣ Clear the UI immediately
    clearEditor();
    debugPrint("Editor cleared. Will reload in 3 seconds...");

    // 3️⃣ Wait 3 seconds
    await Future.delayed(const Duration(seconds: 3));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (editorData != null) {
        loadAllPages(editorData!);

        // regenerate children after scale
        calculateChildScale();

        debugPrint("Editor reloaded with saved data.");
      }
    });
  }

  void saveMenu() async {
    if (backgrounds.isEmpty) return;

    final Map<String, dynamic> savedData = {};

    savedData["preview_img"] = "";
    savedData["superViewWidth"] = superViewWidth;
    savedData["superViewHeight"] = superViewHeight;

    final Map<String, List<Map<String, dynamic>>> elements = {};

    for (final pageKey in pageKeys) {
      final List<Map<String, dynamic>> itemList = [];

      /// 1️⃣ Save background first
      final bg = backgrounds[pageKey];
      if (bg == null) continue;

      itemList.add({
        "type": bg.type,
        "url": bg.url,
        "width": superViewWidth,
        "height": superViewHeight,
        "backGroundColor": bg.backGroundColor,
      });

      /// 2️⃣ Save child widgets
      final items = pageItems[pageKey] ?? [];

      for (final item in items) {
        final c = item.controller;

        final Map<String, dynamic> itemData = {
          "type": c.type,
          "x": c.x.value, // convert back to superView coordinates
          "y": c.y.value,
          "width": c.boxWidth.value,
          "height": c.boxHeight.value,
          "rotation": c.rotation.value,
          "scale": c.scale.value,
          "alpha": c.alpha.value,
          "isUserInteractionEnabled": c.isUserInteractionEnabled.value,
          "movable": c.movable.value,
          "isRemovable": c.isRemovable.value,
          "isDuplicatable": c.isDuplicatable.value,
          "isEditable": c.isEditable.value,
        };

        /// Extra properties for label/image
        if (c.type == EditingWidgetType.label.name) {
          itemData.addAll({
            "text": c.text.value,
            "textColor": c.textColor.value,
            "size": c.textSize.value,
            "fontURL": c.fontURL.value,
          });
        } else if (c.type == EditingWidgetType.image.name) {
          itemData["url"] = c.imageUrl.value;
        } else if (c.type == EditingWidgetType.menuBox.name) {
          itemData.addAll({
            "menuStyle": c.menuStyle.value,
            "columnWidth": c.columnWidth.value,

            "itemNameFontSize": c.itemNameFontSize.value,
            "itemNameFontStyle": c.itemNameFontStyle.value,
            "itemNameTextColor": c.itemNameTextColor.value,

            "itemValueFontSize": c.itemValueFontSize.value,
            "itemValueFontStyle": c.itemValueFontStyle.value,
            "itemValueTextColor": c.itemValueTextColor.value,

            "itemDescriptionFontSize": c.itemDescriptionFontSize.value,
            "itemDescriptionFontStyle": c.itemDescriptionFontStyle.value,
            "itemDescriptionTextColor": c.itemDescriptionTextColor.value,

            "menuData": c.arrMenu.value.map((e) => e.toJson()).toList(),
          });
        }

        itemList.add(itemData);
      }
      elements[pageKey] = itemList;
    }

    savedData["elements"] = elements;
    editorData = EditorDataModel.fromJson(savedData);
  }
}

class BackgroundModel {
  final String type;
  final String url;
  final double width;
  final double height;
  final String backGroundColor;

  BackgroundModel({
    required this.type,
    required this.url,
    required this.width,
    required this.height,
    required this.backGroundColor,
  });
}

extension ChangeTextProperties on EditingScreenController {
  void changeTextValue() {
    final selected = selectedController.value;
    if (selected == null) return;
    // Only apply to text widgets
    if (selected.type.value != EditingWidgetType.label.name) return;
    selected.text.value = "Hello, sir";
  }

  void changeTextSize() {
    final selected = selectedController.value;
    if (selected == null) return;
    if (selected.type.value != EditingWidgetType.label.name) return;
    selected.textSize.value = 36;
  }

  void textSpace() {
    // letter spacing, line spacing
  }

  void changeTextColor() {
    final selected = selectedController.value;
    if (selected == null) return;
    // Only apply to text widgets
    if (selected.type.value != EditingWidgetType.label.name) return;
    selected.textColor.value = "#FFFF0000";
  }

  void changeTextBgColor() {
    final selected = selectedController.value;
    if (selected == null) return;
    // Only apply to text widgets
    if (selected.type.value != EditingWidgetType.label.name) return;
    selected.backGroundColor.value = "#FFFF0000";
  }

  void copyText() {
    final selected = selectedController.value;
    if (selected == null) return;
    if (selected.type.value != EditingWidgetType.label.name) return;
    Clipboard.setData(ClipboardData(text: selected.text.value));
  }

  void onTextToolAction(TextToolAction action) {
    final controller = selectedController.value;
    if (controller == null) return;

    switch (action) {
      case TextToolAction.editText:
        changeTextValue();
        break;

      case TextToolAction.move:
        BottomSheetManager().open(
          scaffoldKey: scaffoldKey,
          sheet: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: MoveToolSheet(onAction: onMoveToolAction),
          ),
          type: EditorBottomSheetType.move,
        );
        break;
      case TextToolAction.fontStyle:
        break;
      case TextToolAction.fontSize:
        changeTextSize();
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
        changeTextColor();
        break;
      case TextToolAction.bgColor:
        changeTextBgColor();
        break;
      case TextToolAction.copy:
        copyText();
        break;
    }
  }

  void onMoveToolAction(MoveToolAction action) {
    final controller = selectedController.value;
    if (controller == null) return;
    switch (action) {
      case MoveToolAction.leftMove:
        moveSelectedLeft(5);
        break;
      case MoveToolAction.topMove:
        moveSelectedTop(5);
        break;
      case MoveToolAction.rightMove:
        moveSelectedRight(5);
        break;
      case MoveToolAction.bottomMove:
        moveSelectedBottom(5);
        break;
    }
  }

  void onLabelSpaceToolAction(LabelSpaceToolAction action) {
    final controller = selectedController.value;
    if (controller == null) return;
  }
}

extension ChangeImageProperties on EditingScreenController {
  void onImageToolAction(ImageToolAction action) {
    final controller = selectedController.value;
    if (controller == null) return;

    switch (action) {
      case ImageToolAction.change:
        break;
      case ImageToolAction.move:
        break;
      case ImageToolAction.flipH:
        break;
      case ImageToolAction.flipV:
        break;
      case ImageToolAction.crop:
        break;
      case ImageToolAction.adjustments:
        break;
      case ImageToolAction.bgColor:
        break;
      case ImageToolAction.blur:
        break;
      case ImageToolAction.opacity:
        break;
      case ImageToolAction.shadow:
        break;
      case ImageToolAction.blendModes:
        break;
      case ImageToolAction.copy:
        break;
    }
  }
}

extension ChangeShapeProperties on EditingScreenController {
  void onShapeToolAction(ShapeToolAction action) {
    final controller = selectedController.value;
    if (controller == null) return;
    switch (action) {
      case ShapeToolAction.star:
        break;
      case ShapeToolAction.curvedCircle:
        break;
      case ShapeToolAction.circleFilled:
        break;
      case ShapeToolAction.circle:
        break;
      case ShapeToolAction.capsule:
        break;
      case ShapeToolAction.heartFilled:
        break;
      case ShapeToolAction.heart:
        break;
      case ShapeToolAction.line:
        break;
      case ShapeToolAction.lineBreaked:
        break;
      case ShapeToolAction.rectangleCircle:
        break;
      case ShapeToolAction.rectangleFilled:
        break;
      case ShapeToolAction.rectangle:
        break;
      case ShapeToolAction.square:
        break;
      case ShapeToolAction.arrowFilled:
        break;
      case ShapeToolAction.arrow:
        break;
      case ShapeToolAction.arrowThinFilled:
        break;
      case ShapeToolAction.arrowThin:
        break;
    }
  }
}
