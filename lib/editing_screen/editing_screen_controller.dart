import 'dart:async';
import 'dart:io';
import 'package:flutter_svg/svg.dart';
import 'package:menu_maker_demo/constant/color_utils.dart';
import 'package:menu_maker_demo/editing_screen/image_and_shape_helper.dart';
import 'package:menu_maker_demo/editing_screen/menu_box_helper.dart';
import 'package:menu_maker_demo/editing_screen/save_menu_canvas.dart';
import 'package:menu_maker_demo/editing_screen/text_helper.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_maker_demo/app_controller.dart';
import 'package:menu_maker_demo/blend_mask.dart';
import 'package:menu_maker_demo/bottom_sheet/bottom_sheet_manager.dart';
import 'package:menu_maker_demo/bottom_sheet/image_sheet.dart';
import 'package:menu_maker_demo/bottom_sheet/menu_box_sheet.dart';
import 'package:menu_maker_demo/bottom_sheet/move_bottom_sheet.dart';
import 'package:menu_maker_demo/bottom_sheet/shape_sheet.dart';
import 'package:menu_maker_demo/bottom_sheet/text_color_sheet.dart';
import 'package:menu_maker_demo/bottom_sheet/text_sheet.dart';
import 'package:menu_maker_demo/constant/app_constant.dart';
import 'package:menu_maker_demo/editing_element_controller.dart';
import 'package:menu_maker_demo/editing_screen/editing_screen_widget.dart';
import 'package:menu_maker_demo/main.dart';
import 'package:menu_maker_demo/menu/menu_one.dart';
import 'package:menu_maker_demo/model/background_model.dart';
import 'package:menu_maker_demo/model/editing_element_model.dart';
import 'package:menu_maker_demo/text_field/text_field.dart';

class EditingScreenController extends GetxController {
  final RxMap<String, Size> canvasSizes = <String, Size>{}.obs;
  final RxMap<String, Offset> scales = <String, Offset>{}.obs;

  final RxMap<String, RxList<EditingItem>> pageItems =
      <String, RxList<EditingItem>>{}.obs;

  final Rx<EditingElementController?> selectedController =
      Rx<EditingElementController?>(null);
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, dynamic>? lastSavedJson;

  EditorDataModel? editorData;
  final RxList<String> pageKeys = <String>[].obs;
  final RxInt currentPageIndex = 0.obs;
  final RxString currentPageKey = ''.obs;
  late final PageController pageController;

  double superViewWidth = 0;
  double superViewHeight = 0;
  final RxDouble editorViewWidth = 0.0.obs;
  final RxDouble editorViewHeight = 0.0.obs;
  double scaleX = 0;
  double scaleY = 0;
  String menuTextColor = AppConstant.defultColor;

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

    if (pageKeys.isNotEmpty) {
      currentPageIndex.value = 0;
      currentPageKey.value = pageKeys.first;
    }
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
              backGroundColor:
                  bgModel.backGroundColor ?? AppConstant.transparentColor,
            ),
            editorWidth: size.width,
            editorHeight: size.height,
          ),
        ),
      );

      // ================= OTHER ELEMENTS =================
      for (int i = 1; i < elements.length; i++) {
        items.add(itemFromModel(elements[i]));
      }

      // 🔥 VERY IMPORTANT
      pageItems[key] = items;
    }
  }

  EditingItem itemFromModel(EditingElementModel model) {
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
      initScale: 1 * scaleX,
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
      double scaledColumnWidth =
          (model.columnWidth ?? 24) * ((scaleX < scaleY) ? scaleX : scaleY);
      double scaledItemNameFontSize =
          (model.itemNameFontSize ?? 24) *
          ((scaleX < scaleY) ? scaleX : scaleY);
      double scaledItemDescriptionFontSize =
          (model.itemDescriptionFontSize ?? 24) *
          ((scaleX < scaleY) ? scaleX : scaleY);
      double scaledItemValueFontSize =
          (model.itemValueFontSize ?? 24) *
          ((scaleX < scaleY) ? scaleX : scaleY);
      controller.menuStyle.value = model.menuStyle ?? 1;
      controller.columnWidth.value = scaledColumnWidth;
      controller.arrMenu.assignAll(model.menuData ?? []);

      controller.itemNameFontStyle.value = model.itemNameFontStyle ?? "";
      controller.itemNameTextColor.value =
          model.itemNameTextColor ?? AppConstant.defultColor;
      controller.itemNameFontSize.value = scaledItemNameFontSize;

      controller.itemValueFontStyle.value = model.itemValueFontStyle ?? "";
      controller.itemValueTextColor.value =
          model.itemValueTextColor ?? AppConstant.defultColor;
      controller.itemValueFontSize.value = scaledItemValueFontSize;

      controller.itemDescriptionFontStyle.value =
          model.itemDescriptionFontStyle ?? "";
      controller.itemDescriptionTextColor.value =
          model.itemDescriptionTextColor ?? AppConstant.defultColor;
      controller.itemDescriptionFontSize.value = scaledItemDescriptionFontSize;
      menuTextColor = model.itemNameTextColor ?? AppConstant.defultColor;
    }

    return EditingItem(
      controller: controller,
      child: buildRequiredChild(model, controller),
    );
  }

  Widget buildRequiredChild(
    EditingElementModel model,
    EditingElementController controller,
  ) {
    if (model.type == EditingWidgetType.image.name) {
      return buildImageWidget(controller);
    } else if (model.type == EditingWidgetType.label.name) {
      return EditingTextField(controller: controller);
    } else if (model.type == EditingWidgetType.menuBox.name) {
      return MenuOne(editingElementController: controller);
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
      final shadowRadius = controller.shadowRadius.value;
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

      Widget finalImage = blendMode == BlendMode.srcIn
          ? bgColor != AppConstant.transparentColor.toColor()
                ? Container(
                    decoration: BoxDecoration(
                      color: bgColor,
                      boxShadow: shadowOpacity > 0
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: shadowOpacity,
                                ),
                                offset: Offset(shadowX, shadowY),
                                blurRadius: shadowRadius,
                                spreadRadius: shadowRadius,
                              ),
                            ]
                          : null,
                    ),
                    child: imageWidget,
                  )
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      if (shadowOpacity > 0)
                        Transform.translate(
                          offset: Offset(shadowX, shadowY),
                          child: ImageFiltered(
                            imageFilter: ImageFilter.blur(
                              sigmaX: shadowRadius,
                              sigmaY: shadowRadius,
                            ),
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                Colors.black.withValues(alpha: shadowOpacity),
                                BlendMode.srcATop,
                              ),
                              child: imageWidget,
                            ),
                          ),
                        ),

                      /// ORIGINAL IMAGE
                      Container(color: bgColor, child: imageWidget),
                    ],
                  )
          : imageWidget;

      if (blendMode != BlendMode.srcIn) {
        finalImage = RepaintBoundary(
          child: BlendMask(
            key: ValueKey(
              '${blurValue}_${opacity}_${blendMode.index}_${shadowRadius}_${shadowOpacity}_${Offset(shadowX, shadowY)}',
            ),
            blendMode: blendMode,
            opacity: opacity,
            blur: blurValue,
            shadowBlur: shadowRadius,
            shadowOpacity: shadowOpacity,
            shadowOffset: Offset(shadowX, shadowY),
            child: finalImage,
          ),
        );
      } else {
        finalImage = Opacity(opacity: opacity, child: finalImage);
      }

      /// Blur FIRST
      if (blurValue > 0 && blendMode == BlendMode.srcIn) {
        finalImage = ImageFiltered(
          imageFilter: ImageFilter.blur(
            sigmaX: blurValue * 15,
            sigmaY: blurValue * 15,
          ),
          child: finalImage,
        );
      }

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
      final shadowRadius = controller.shadowRadius.value;
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

      Widget finalImage = blendMode == BlendMode.srcIn
          ? Container(
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
            )
          : shapeWidget;

      if (blendMode != BlendMode.srcIn) {
        finalImage = RepaintBoundary(
          child: BlendMask(
            key: ValueKey(
              '${blurValue}_${opacity}_${blendMode.index}_${shadowRadius}_${shadowOpacity}_${Offset(shadowX, shadowY)}',
            ),
            blendMode: blendMode,
            opacity: opacity,
            blur: blurValue,
            shadowBlur: shadowRadius,
            shadowOpacity: shadowOpacity,
            shadowOffset: Offset(shadowX, shadowY),
            child: finalImage,
          ),
        );
      } else {
        finalImage = Opacity(opacity: opacity, child: finalImage);
      }

      /// Blur FIRST
      if (blurValue > 0 && blendMode == BlendMode.srcIn) {
        finalImage = ImageFiltered(
          imageFilter: ImageFilter.blur(
            sigmaX: blurValue * 15,
            sigmaY: blurValue * 15,
          ),
          child: finalImage,
        );
      }

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

  Future<void> saveMenu() async {
    final Map<String, List<EditingElementModel>> elements = {};

    for (final pageKey in pageKeys) {
      final items = pageItems[pageKey] ?? [];

      elements[pageKey] = items.map<EditingElementModel>((item) {
        final c = item.controller;
        String type = c.type.value;

        return buildElement(type, c);
      }).toList();
    }

    /// ✅ BUILD MODEL DIRECTLY
    editorData = EditorDataModel(
      previewImg: "", // String, not Rx
      superViewWidth: superViewWidth,
      superViewHeight: superViewHeight,
      elements: elements,
    );

    final pages = await generateWhitePagesFromModel(editorData: editorData!);
    // Export PNG
    final pngBytes = await exportImage(pages[0]);

    // Save to cache
    final file = await savePngToCache(pngBytes, 'page_0.png');

    debugPrint('PNG saved at: ${file.path}');

    /// ✅ Convert to JSON only when needed
    // final jsonString = jsonEncode(editorData!.toJson());
  }

  EditingElementModel buildElement(String type, EditingElementController c) {
    // Common fields
    final base = EditingElementModel(
      type: c.type.value,
      x: c.x.value,
      y: c.y.value,
      width: c.boxWidth.value,
      height: c.boxHeight.value,
      rotation: c.rotation.value,
      alpha: c.alpha.value,
      isUserInteractionEnabled: c.isUserInteractionEnabled.value,
      isRemovable: c.isRemovable.value,
      movable: c.movable.value,
      isDuplicatable: c.isDuplicatable.value,
      isEditable: c.isEditable.value,
    );

    if (type == EditingWidgetType.label.name) {
      return base.copyWith(
        text: c.text.value.isEmpty ? null : c.text.value,
        textColor: c.textColor.value,
        backGroundColor: c.backGroundColor.value,
        textSize: c.textSize.value,
        fontURL: c.fontURL.value,
        letterSpace: c.letterSpace.value,
        lineSpace: c.lineSpace.value,
        alignment: c.alignment.value,
      );
    } else if (type == EditingWidgetType.image.name) {
      return base.copyWith(
        url: c.imageUrl.value,
        backGroundColor: c.backGroundColor.value,
        blendMode: c.blendMode.value.name,
        blurAlpha: c.blurAlpha.value,
        flipX: c.flipX.value,
        flipY: c.flipY.value,
        shadowOpacity: c.shadowOpacity.value,
        shadowRadius: c.shadowRadius.value,
      );
    } else if (type == EditingWidgetType.shape.name) {
      return base.copyWith(
        url: c.imageUrl.value,
        tintColor: c.tintColor.value,
        blendMode: c.blendMode.value.name,
        blurAlpha: c.blurAlpha.value,
        flipX: c.flipX.value,
        flipY: c.flipY.value,
        shadowOpacity: c.shadowOpacity.value,
        shadowRadius: c.shadowRadius.value,
      );
    } else if (type == EditingWidgetType.menuBox.name) {
      return base.copyWith(
        menuStyle: c.menuStyle.value,
        columnWidth: c.columnWidth.value,
        itemNameFontStyle: c.itemNameFontStyle.value,
        itemNameTextColor: c.itemNameTextColor.value,
        itemNameFontSize: c.itemNameFontSize.value,
        itemValueFontStyle: c.itemValueFontStyle.value,
        itemValueTextColor: c.itemValueTextColor.value,
        itemValueFontSize: c.itemValueFontSize.value,
        itemDescriptionFontStyle: c.itemDescriptionFontStyle.value,
        itemDescriptionTextColor: c.itemDescriptionTextColor.value,
        itemDescriptionFontSize: c.itemDescriptionFontSize.value,
        backGroundColor: c.backGroundColor.value,
        menuData: List<MenuItemModel>.from(c.arrMenu.map((e) => e.clone())),
      );
    } else {
      return base;
    }
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
      c.shadowRadius.value = shadowRadius.value;
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
      c.shadowRadius.value = shadowRadius.value;
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
