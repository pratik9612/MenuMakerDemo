import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:menu_maker_demo/bottom_sheet/shape_list_sheet.dart';
import 'package:menu_maker_demo/constant/color_utils.dart';
import 'package:path/path.dart' as p;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_maker_demo/app_controller.dart';
import 'package:menu_maker_demo/blend_mask.dart';
import 'package:menu_maker_demo/bottom_sheet/blend_mode_sheet.dart';
import 'package:menu_maker_demo/bottom_sheet/blur_alpha_sheet.dart';
import 'package:menu_maker_demo/bottom_sheet/bottom_sheet_manager.dart';
import 'package:menu_maker_demo/bottom_sheet/change_image_sheet.dart';
import 'package:menu_maker_demo/bottom_sheet/edit_text_sheet.dart';
import 'package:menu_maker_demo/bottom_sheet/font_size_sheet.dart';
import 'package:menu_maker_demo/bottom_sheet/font_style_sheet.dart';
import 'package:menu_maker_demo/bottom_sheet/image_sheet.dart';
import 'package:menu_maker_demo/bottom_sheet/menu_box_sheet.dart';
import 'package:menu_maker_demo/bottom_sheet/menu_font_color_sheet.dart';
import 'package:menu_maker_demo/bottom_sheet/move_bottom_sheet.dart';
import 'package:menu_maker_demo/bottom_sheet/opacity_sheet.dart';
import 'package:menu_maker_demo/bottom_sheet/shadow_image_sheet.dart';
import 'package:menu_maker_demo/bottom_sheet/shape_sheet.dart';
import 'package:menu_maker_demo/bottom_sheet/text_color_sheet.dart';
import 'package:menu_maker_demo/bottom_sheet/text_sheet.dart';
import 'package:menu_maker_demo/bottom_sheet/text_space_bottom_sheet.dart';
import 'package:menu_maker_demo/bottom_sheet/text_space_sheet.dart';
import 'package:menu_maker_demo/constant/app_constant.dart';
import 'package:menu_maker_demo/edit_menu_item_screen/edit_menu_item_screen.dart';
import 'package:menu_maker_demo/editing_element_controller.dart';
import 'package:menu_maker_demo/editing_screen/editing_screen_widget.dart';
import 'package:menu_maker_demo/main.dart';
import 'package:menu_maker_demo/menu/menu_one.dart';
import 'package:menu_maker_demo/model/editing_element_model.dart';
import 'package:menu_maker_demo/text_field/text_field.dart';
import 'package:path_provider/path_provider.dart';

class EditingScreenController extends GetxController {
  final RxMap<String, Size> canvasSizes = <String, Size>{}.obs;
  final RxMap<String, Offset> scales = <String, Offset>{}.obs;

  // RxList<EditingItem> items = <EditingItem>[].obs;
  final RxMap<String, RxList<EditingItem>> pageItems =
      <String, RxList<EditingItem>>{}.obs;

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
      controller.letterSpace.value = model.letterSpace ?? 0.0;
      controller.lineSpace.value = model.lineSpace ?? 0.0;
      controller.rotation.value = model.rotation;
    }

    if (model.type == EditingWidgetType.image.name && model.url != null) {
      controller.imageUrl.value = model.url!;
    }
    if (model.type == EditingWidgetType.shape.name && model.url != null) {
      controller.imageUrl.value = model.url!;
      controller.tintColor.value = model.tintColor ?? "#00000000";
      controller.alpha.value = model.alpha;
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
      return buildImageWidget(controller);
    } else if (model.type == EditingWidgetType.label.name) {
      return EditingTextField(controller: controller);
    } else if (model.type == EditingWidgetType.menuBox.name) {
      return MenuOne(
        editingElementController: controller,
        scaleX: scaleX,
        scaleY: scaleY,
      );
    } else if (model.type == EditingWidgetType.shape.name) {
      return buildShapeWidget(controller);
    } else {
      return Container();
    }
  }

  Widget buildImageWidget(EditingElementController controller) {
    return Obx(() {
      final url = controller.imageUrl.value;
      final blurValue = controller.blurAlpha.value;
      final opacity = controller.alpha.value.clamp(0.01, 1.0);
      final bgColor = controller.backGroundColor.value.toColor();
      final shadowOpacity = controller.shadowOpacity.value;
      final shadowRadius = controller.radius.value;
      final shadowX = controller.shadowX.value;
      final shadowY = controller.shadowY.value;
      final blendMode = controller.blendMode.value;

      if (url.isEmpty) return const SizedBox();

      Widget imageWidget;

      if (url.startsWith('Templates')) {
        imageWidget = Image.network(
          "${AppConstant.imageBaseUrl}$url",
          fit: BoxFit.contain,
        );
      } else if (url.startsWith('http')) {
        imageWidget = Image.network(url, fit: BoxFit.contain);
      } else {
        imageWidget = Image.file(File(url), fit: BoxFit.contain);
      }

      Widget finalImage = Container(
        decoration: BoxDecoration(
          color: bgColor,
          boxShadow: shadowOpacity > 0
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: shadowOpacity),
                    offset: Offset(shadowX, shadowY),
                    blurRadius: shadowRadius,
                    spreadRadius: shadowRadius,
                  ),
                ]
              : null,
        ),
        child: imageWidget,
      );

      print("Blend: $blendMode | Opacity: $opacity");

      if (blendMode != BlendMode.srcIn) {
        finalImage = RepaintBoundary(
          child: BlendMask(
            key: ValueKey(opacity),
            blendMode: blendMode,
            opacity: opacity,
            child: finalImage,
          ),
        );
      } else {
        finalImage = Opacity(opacity: opacity, child: finalImage);
      }

      /// Blur FIRST
      if (blurValue > 0) {
        finalImage = ImageFiltered(
          imageFilter: ImageFilter.blur(
            sigmaX: blurValue * 15,
            sigmaY: blurValue * 15,
          ),
          child: finalImage,
        );
      }

      // finalImage = Opacity(opacity: opacity, child: finalImage);

      /// Flip LAST
      return Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..scale(
            controller.flipX.value ? -1.0 : 1.0,
            controller.flipY.value ? -1.0 : 1.0,
          ),
        child: finalImage,
      );
    });
  }

  Widget buildShapeWidget(EditingElementController controller) {
    return Obx(() {
      final url = controller.imageUrl.value;
      final blurValue = controller.blurAlpha.value;
      final opacity = controller.alpha.value.clamp(0.01, 1.0);
      final tintColor = controller.tintColor.value;
      final shadowOpacity = controller.shadowOpacity.value;
      final shadowRadius = controller.radius.value;
      final shadowX = controller.shadowX.value;
      final shadowY = controller.shadowY.value;
      final blendMode = controller.blendMode.value;

      if (url.isEmpty) return const SizedBox();
      Widget shapeWidget;

      String finalUrl = "assets/shapes/$url.svg";

      shapeWidget = SvgPicture.asset(
        finalUrl,
        key: UniqueKey(),
        fit: BoxFit.contain,
        color: ColorUtils.fromHex(
          tintColor,
        ).withValues(alpha: controller.alpha.value),
        // colorFilter: ColorFilter.mode(
        //   ColorUtils.fromHex(
        //     tintColor,
        //   ).withValues(alpha: controller.alpha.value),
        //   blendMode,
        // ),
      );

      Widget finalImage = Container(
        decoration: BoxDecoration(
          boxShadow: shadowOpacity > 0
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: shadowOpacity),
                    offset: Offset(shadowX, shadowY),
                    blurRadius: shadowRadius,
                    spreadRadius: shadowRadius,
                  ),
                ]
              : null,
        ),
        child: shapeWidget,
      );

      if (blendMode != BlendMode.srcIn) {
        finalImage = RepaintBoundary(
          child: BlendMask(
            key: ValueKey(opacity),
            blendMode: blendMode,
            opacity: opacity,
            child: finalImage,
          ),
        );
      } else {
        finalImage = Opacity(opacity: opacity, child: finalImage);
      }

      /// Blur FIRST
      if (blurValue > 0) {
        finalImage = ImageFiltered(
          imageFilter: ImageFilter.blur(
            sigmaX: blurValue * 15,
            sigmaY: blurValue * 15,
          ),
          child: finalImage,
        );
      }

      // finalImage = Opacity(opacity: opacity, child: finalImage);

      /// Flip LAST
      return Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..scale(
            controller.flipX.value ? -1.0 : 1.0,
            controller.flipY.value ? -1.0 : 1.0,
          ),
        child: finalImage,
      );
    });
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
    } else if (editingElementController.type.value ==
        EditingWidgetType.menuBox.name) {
      BottomSheetManager().open(
        scaffoldKey: scaffoldKey,
        sheet: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: MenuBoxSheet(onAction: onMenuBoxToolAction),
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

  Timer? _moveTimer;

  void startContinuousMove(MoveToolAction action) {
    // move immediately
    if (action == MoveToolAction.leftLongPress) {
      moveSelectedLeft(2);
    } else if (action == MoveToolAction.topLongPress) {
      moveSelectedTop(2);
    } else if (action == MoveToolAction.rightLongPress) {
      moveSelectedRight(2);
    } else if (action == MoveToolAction.bottomLongPress) {
      moveSelectedBottom(2);
    }

    _moveTimer?.cancel();
    _moveTimer = Timer.periodic(const Duration(milliseconds: 40), (_) {
      if (action == MoveToolAction.leftLongPress) {
        moveSelectedLeft(2);
      } else if (action == MoveToolAction.topLongPress) {
        moveSelectedTop(2);
      } else if (action == MoveToolAction.rightLongPress) {
        moveSelectedRight(2);
      } else if (action == MoveToolAction.bottomLongPress) {
        moveSelectedBottom(2);
      }
    });
  }

  void stopContinuousMove() {
    _moveTimer?.cancel();
    _moveTimer = null;
  }

  void moveSelectedLeft(double delta) {
    final selected = selectedController.value;
    if (selected == null) return;
    appController.textMoveWithUndo(selected, -delta, 0);
  }

  void moveSelectedTop(double delta) {
    final selected = selectedController.value;
    if (selected == null) return;
    appController.textMoveWithUndo(selected, 0, -delta);
  }

  void moveSelectedRight(double delta) {
    final selected = selectedController.value;
    if (selected == null) return;
    appController.textMoveWithUndo(selected, delta, 0);
  }

  void moveSelectedBottom(double delta) {
    final selected = selectedController.value;
    if (selected == null) return;
    appController.textMoveWithUndo(selected, 0, delta);
  }

  void saveAndReload() async {
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
    final Map<String, dynamic> savedData = {};

    savedData["preview_img"] = "";
    savedData["superViewWidth"] = superViewWidth;
    savedData["superViewHeight"] = superViewHeight;

    final Map<String, List<Map<String, dynamic>>> elements = {};

    for (final pageKey in pageKeys) {
      final List<Map<String, dynamic>> itemList = [];

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
            "backGroundColor": c.backGroundColor.value,
            "size": c.textSize.value,
            "fontURL": c.fontURL.value,
            "letterSpace": c.letterSpace.value,
            "lineSpace": c.lineSpace.value,
          });
        } else if (c.type == EditingWidgetType.image.name) {
          itemData["url"] = c.imageUrl.value;
        } else if (c.type == EditingWidgetType.shape.name) {
          itemData["url"] = c.imageUrl.value;
          itemData["tintColor"] = c.tintColor.value;
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
    final jsonMap = editorData!.toJson();
    final jsonString = jsonEncode(jsonMap);
    debugPrint(jsonString);
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

  void openTextColorPicker() {
    final selected = selectedController.value;
    if (selected == null) return;
    if (selected.type.value == EditingWidgetType.label.name) return;

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
    final oldBlur = selected.radius.value;
    final oldX = selected.shadowX.value;
    final oldY = selected.shadowY.value;

    Get.bottomSheet(
      isDismissible: false,
      ShadowImageSheet(
        controller: selected,
        onCancel: () {
          selected.shadowOpacity.value = oldOpacity;
          selected.radius.value = oldBlur;
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
            selected.radius.value,
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

  void onLabelSpaceToolAction(LabelSpaceToolAction action) {
    final controller = selectedController.value;
    if (controller == null) return;

    if (action == LabelSpaceToolAction.textSpacing) {
      _openLetterSpacingSheet(controller);
    } else if (action == LabelSpaceToolAction.lineSpacing) {
      _openLineSpacingSheet(controller);
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

  void moveToolAction() {
    BottomSheetManager().open(
      scaffoldKey: scaffoldKey,
      sheet: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: MoveToolSheet(
          onAction: onMoveToolAction,
          onLongPressStart: onMoveToolAction,
          onLongPressEnd: () => stopContinuousMove(),
        ),
      ),
      type: EditorBottomSheetType.move,
    );
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

  Future<Size> getImageSize(String path) async {
    final file = File(path);
    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return Size(frame.image.width.toDouble(), frame.image.height.toDouble());
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

  void cropeImageAction() async {
    final selected = selectedController.value;
    if (selected == null) return;
    if (selected.type.value != EditingWidgetType.image.name) return;

    String oldUrl = selected.imageUrl.value;
    if (oldUrl.isEmpty) return;

    String? localPath = oldUrl;

    if (oldUrl.startsWith('http') || oldUrl.startsWith('Templates')) {
      final fullUrl = oldUrl.startsWith('Templates')
          ? "${AppConstant.imageBaseUrl}$oldUrl"
          : oldUrl;

      localPath = await appController.downloadImageToLocal(fullUrl);
      debugPrint("localPath: $localPath");
      if (localPath == null) return;
    }

    final croppedPath = await appController.cropImage(localPath);
    if (croppedPath == null) return;

    debugPrint("croppedPath: $croppedPath");
    final rawSize = await getImageSize(croppedPath);

    /// 🎯 Clamp size to editor bounds
    final fittedSize = fitSizeInsideBox(
      rawSize,
      editorViewWidth.value * 0.8,
      editorViewHeight.value * 0.8,
    );

    final oldW = selected.boxWidth.value;
    final oldH = selected.boxHeight.value;
    final oldX = selected.x.value;
    final oldY = selected.y.value;

    final centerX = oldX + oldW / 2;
    final centerY = oldY + oldH / 2;

    final newX = centerX - fittedSize.width / 2;
    final newY = centerY - fittedSize.height / 2;

    appController.changeImageCropWithUndo(
      selected,
      oldUrl: oldUrl,
      newUrl: croppedPath,
      oldRect: Rect.fromLTWH(oldX, oldY, oldW, oldH),
      newRect: Rect.fromLTWH(newX, newY, fittedSize.width, fittedSize.height),
    );
  }
}

void _openLetterSpacingSheet(EditingElementController controller) {
  final oldValue = controller.letterSpace.value.clamp(0.0, 20.0);

  Get.bottomSheet(
    isDismissible: false,
    TextSpacingSheet(
      title: "Letter Spacing",
      min: 0.0,
      max: 20.0,
      initialValue: oldValue,
      onPreview: (value) {
        controller.letterSpace.value = value;
      },
      onCancel: () {
        controller.letterSpace.value = oldValue;
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

  Get.bottomSheet(
    isDismissible: false,
    TextSpacingSheet(
      title: "Line Spacing",
      min: 0.0,
      max: 20.0,
      initialValue: oldValue,
      onPreview: (value) {
        controller.lineSpace.value = value;
      },
      onCancel: () {
        controller.lineSpace.value = oldValue;
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

extension ChangeImageProperties on EditingScreenController {
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
}

extension ChangeShapeProperties on EditingScreenController {
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
            child: ShapeTypeSheet(onAction: onShapeTypeToolAction),
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
}

extension ShapeTypeProperties on EditingScreenController {
  void onShapeTypeToolAction(ShapeTypeToolAction action) {
    final controller = selectedController.value;
    if (controller == null) return;
    switch (action) {
      case ShapeTypeToolAction.star:
        replaceShape(action);
        break;
      case ShapeTypeToolAction.curvedCircle:
        replaceShape(action);
        break;
      case ShapeTypeToolAction.circleFilled:
        replaceShape(action);
        break;
      case ShapeTypeToolAction.circle:
        replaceShape(action);
        break;
      case ShapeTypeToolAction.capsule:
        replaceShape(action);
        break;
      case ShapeTypeToolAction.heartFilled:
        replaceShape(action);
        break;
      case ShapeTypeToolAction.heart:
        replaceShape(action);
        break;
      case ShapeTypeToolAction.line:
        replaceShape(action);
        break;
      case ShapeTypeToolAction.lineBreaked:
        replaceShape(action);
        break;
      case ShapeTypeToolAction.rectangleCircle:
        replaceShape(action);
        break;
      case ShapeTypeToolAction.rectangleFilled:
        replaceShape(action);
        break;
      case ShapeTypeToolAction.rectangle:
        replaceShape(action);
        break;
      case ShapeTypeToolAction.square:
        replaceShape(action);
        break;
      case ShapeTypeToolAction.arrowFilled:
        replaceShape(action);
        break;
      case ShapeTypeToolAction.arrow:
        replaceShape(action);
        break;
      case ShapeTypeToolAction.arrowThinFilled:
        replaceShape(action);
        break;
      case ShapeTypeToolAction.arrowThin:
        replaceShape(action);
        break;
    }
  }

  void replaceShape(ShapeTypeToolAction shapeType) async {
    final controller = selectedController.value;
    if (controller == null) return;
    controller.imageUrl.value = shapeType.name;

    debugPrint("shapeType: ${controller.imageUrl.value}");
  }
}

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
}

extension EditingElementClone on EditingElementController {
  EditingElementController clone() {
    final c = EditingElementController(
      type: type.value,
      initX: x.value + 10, // 👈 shift
      initY: y.value + 10, // 👈 shift
      initWidth: boxWidth.value, // same width
      initHeight: boxHeight.value, // same height
      initRotation: rotation.value,
      initScale: scale.value,
      isUserInteractionEnabled: isUserInteractionEnabled.value,
      isDuplicatable: isDuplicatable.value,
      isRemovable: isRemovable.value,
      movable: movable.value,
      isEditable: isEditable.value,
    );

    // ===== Common =====
    c.alpha.value = alpha.value;
    c.backGroundColor.value = backGroundColor.value;

    // ===== IMAGE =====
    if (type.value == EditingWidgetType.image.name) {
      c.imageUrl.value = imageUrl.value;
      c.blurAlpha.value = blurAlpha.value;
      c.flipX.value = flipX.value;
      c.flipY.value = flipY.value;
      c.shadowX.value = shadowX.value;
      c.shadowY.value = shadowY.value;
      c.radius.value = radius.value;
      c.shadowOpacity.value = shadowOpacity.value;
      c.blendMode.value = blendMode.value;
    }

    // ===== SHAPE =====
    if (type.value == EditingWidgetType.shape.name) {
      c.imageUrl.value = imageUrl.value;
      c.tintColor.value = tintColor.value;
      c.blurAlpha.value = blurAlpha.value;
      c.flipX.value = flipX.value;
      c.flipY.value = flipY.value;
      c.shadowX.value = shadowX.value;
      c.shadowY.value = shadowY.value;
      c.radius.value = radius.value;
      c.shadowOpacity.value = shadowOpacity.value;
      c.blendMode.value = blendMode.value;
    }

    // ===== TEXT =====
    if (type.value == EditingWidgetType.label.name) {
      c.text.value = text.value;
      c.textColor.value = textColor.value;
      c.textSize.value = textSize.value;
      c.fontURL.value = fontURL.value;
      c.letterSpace.value = letterSpace.value;
      c.lineSpace.value = lineSpace.value;
    }
    if (type.value == EditingWidgetType.menuBox.name) {
      c.menuStyle.value = menuStyle.value;
      c.columnWidth.value = columnWidth.value;

      c.arrMenu.clear();
      c.arrMenu.addAll(arrMenu.map((e) => e.clone()));

      c.itemNameFontSize.value = itemNameFontSize.value;
      c.itemDescriptionFontSize.value = itemDescriptionFontSize.value;
      c.itemValueFontSize.value = itemValueFontSize.value;

      // font colors
      c.itemNameTextColor.value = itemNameTextColor.value;
      c.itemDescriptionTextColor.value = itemDescriptionTextColor.value;
      c.itemValueTextColor.value = itemValueTextColor.value;
      // font styles
      c.itemNameFontStyle.value = itemNameFontStyle.value;
      c.itemDescriptionFontStyle.value = itemDescriptionFontStyle.value;
      c.itemValueFontStyle.value = itemValueFontStyle.value;
    }
    return c;
  }
}
