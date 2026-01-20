// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:menu_maker_demo/constant/app_constant.dart';
// import 'package:menu_maker_demo/constant/color_utils.dart';
// import 'package:menu_maker_demo/editing_element_controller.dart';
// import 'package:menu_maker_demo/menu/menu_one.dart';
// import 'package:menu_maker_demo/model/editing_element_model.dart';

// class EditingScreenController extends GetxController {
//   final RxMap<String, Size> canvasSizes = <String, Size>{}.obs;
//   final RxMap<String, Offset> scales = <String, Offset>{}.obs;

//   // RxList<EditingItem> items = <EditingItem>[].obs;
//   final RxMap<String, RxList<EditingItem>> pageItems =
//       <String, RxList<EditingItem>>{}.obs;
//   final RxMap<String, BackgroundModel> backgrounds =
//       <String, BackgroundModel>{}.obs;
//   final Rx<EditingElementController?> selectedController =
//       Rx<EditingElementController?>(null);

//   Map<String, dynamic>? lastSavedJson;

//   EditorDataModel? editorData;
//   final RxList<String> pageKeys = <String>[].obs;

//   double superViewWidth = 0;
//   double superViewHeight = 0;
//   double editorViewWidth = 0;
//   double editorViewHeight = 0;
//   double scaleX = 0;
//   double scaleY = 0;

//   /// Load all pages, only background first
//   void loadAllPages(EditorDataModel data) async {
//     pageKeys.clear();
//     backgrounds.clear();
//     pageItems.clear();
//     editorData = data;
//     superViewWidth = data.superViewWidth;
//     superViewHeight = data.superViewHeight;

//     pageKeys.assignAll(data.elements.keys.toList()..sort());

//     for (final key in pageKeys) {
//       final elements = data.elements[key];
//       if (elements == null || elements.isEmpty) continue;

//       final bgItem = elements.first;
//       backgrounds[key] = BackgroundModel(
//         type: bgItem.type,
//         url: bgItem.url ?? "",
//         width: superViewWidth,
//         height: superViewHeight,
//         backGroundColor: bgItem.backGroundColor ?? "#FFFFFFFF",
//       );
//     }
//   }

//   void calculateChildScale() {
//     if (superViewWidth <= 0 ||
//         superViewHeight <= 0 ||
//         editorViewWidth <= 0 ||
//         editorViewHeight <= 0) {
//       return;
//     }
//     debugPrint(
//       'editorWidth: $editorViewWidth, editorHeight: $editorViewHeight',
//     );
//     debugPrint(
//       'superViewWidth: $superViewWidth, superViewHeight: $superViewHeight',
//     );

//     final aspectRatio = superViewWidth / superViewHeight;
//     double width = editorViewWidth;
//     double height = width / aspectRatio;
//     if (height > editorViewHeight) {
//       height = editorViewHeight;
//       width = height * aspectRatio;
//     }

//     scaleX = width / superViewWidth;
//     scaleY = height / superViewHeight;
//     final size = Size(width, height);
//     final superViewSize = Size(superViewWidth, superViewHeight);
//     generateChildrenAfterScale(size, superViewSize);
//   }

//   /// Generate children only AFTER user scales background
//   void generateChildrenAfterScale(Size size, Size superViewSize) {
//     if (editorData == null) return;
//     pageItems.clear();

//     for (final key in pageKeys) {
//       final elements = editorData!.elements[key];
//       if (elements == null || elements.length <= 1) continue;

//       final RxList<EditingItem> items = <EditingItem>[].obs;

//       for (int i = 1; i < elements.length; i++) {
//         items.add(_itemFromModel(elements[i]));
//       }

//       pageItems[key] = items;
//     }
//   }

//   EditingItem _itemFromModel(EditingElementModel model) {
//     double viewWidth = model.width * scaleX;
//     double viewHeight = model.height * scaleY;
//     double positionX = model.x * scaleX;
//     double positionY = model.y * scaleY;

//     final controller = EditingElementController(
//       type: model.type,
//       initX: positionX,
//       initY: positionY,
//       initWidth: viewWidth,
//       initHeight: viewHeight,
//       initRotation: model.rotation,
//       initScale: model.scale * scaleX,
//       isUserInteractionEnabled: model.isUserInteractionEnabled,
//       isDuplicatable: model.isDuplicatable,
//       isRemovable: model.isRemovable,
//       movable: model.movable,
//       isEditable: model.isEditable,
//     );

//     if (model.type == EditingWidgetType.label.name) {
//       double scaledTextSize =
//           (model.textSize ?? 24) * ((scaleX < scaleY) ? scaleX : scaleY);
//       controller.text.value = model.text ?? '';
//       controller.textColor.value = model.textColor ?? '#FF000000';
//       controller.textSize.value = scaledTextSize;
//       controller.fontURL.value = model.fontURL ?? '';
//     }

//     if (model.type == EditingWidgetType.image.name && model.url != null) {
//       controller.imageUrl.value = model.url!;
//     }

//     return EditingItem(
//       controller: controller,
//       child: _buildChild(model, controller),
//     );
//   }

//   Widget _buildChild(
//     EditingElementModel model,
//     EditingElementController controller,
//   ) {
//     if (model.type == EditingWidgetType.image.name) {
//       return controller.imageUrl.value.startsWith('images')
//           ? Image.network(
//               "${AppConstant.imageBaseUrl}${controller.imageUrl.value}",
//               fit: BoxFit.contain,
//             )
//           : Image.asset(controller.imageUrl.value, fit: BoxFit.contain);
//     } else if (model.type == EditingWidgetType.label.name) {
//       return Text(
//         model.text ?? '',
//         style: TextStyle(
//           color: ColorUtils.fromHex(controller.textColor.value),
//           fontSize: controller.textSize.value,
//         ),
//       );
//     } else {
//       return MenuOne(
//         editingElementModel: model,
//         scaleX: scaleX,
//         scaleY: scaleY,
//       );
//     }
//   }

//   void selectItem(EditingElementController editingElementController) {
//     debugPrint("select Item");
//     if (!editingElementController.isUserInteractionEnabled.value) return;
//     selectedController.value = editingElementController;
//   }

//   bool isSelected(EditingElementController editingElementController) {
//     return selectedController.value == editingElementController;
//   }

//   void deSelectItem() {
//     selectedController.value = null;
//   }

//   void deleteChildWidget(String pageKey, EditingElementController controller) {
//     final items = pageItems[pageKey];
//     if (items == null || items.isEmpty) return;
//     items.removeWhere((item) => identical(item.controller, controller));
//     items.refresh();
//     if (selectedController.value == controller) {
//       deSelectItem();
//     }
//   }

//   void moveSelectedRight(double delta) {
//     if (selectedController.value != null) {
//       selectedController.value!.x.value += delta;
//     }
//   }

//   void moveSelectedLeft(double delta) {
//     if (selectedController.value != null) {
//       selectedController.value!.x.value -= delta;
//     }
//   }

//   void changeApha(double alpha) {
//     final selected = selectedController.value;
//     if (selected != null) {
//       selected.alpha.value = alpha.clamp(0.0, 1.0);
//     }
//   }

//   void saveMenu() async {
//     if (backgrounds.isEmpty) return;

//     final Map<String, dynamic> savedData = {};

//     savedData["preview_img"] = "";
//     savedData["superViewWidth"] = superViewWidth;
//     savedData["superViewHeight"] = superViewHeight;

//     final Map<String, List<Map<String, dynamic>>> elements = {};

//     for (final pageKey in pageKeys) {
//       final List<Map<String, dynamic>> itemList = [];

//       /// 1️⃣ Save background first
//       final bg = backgrounds[pageKey];
//       if (bg == null) continue;

//       itemList.add({
//         "type": bg.type,
//         "url": bg.url,
//         "width": superViewWidth,
//         "height": superViewHeight,
//         "backGroundColor": bg.backGroundColor,
//       });

//       /// 2️⃣ Save child widgets
//       final items = pageItems[pageKey] ?? [];

//       for (final item in items) {
//         final c = item.controller;

//         final Map<String, dynamic> itemData = {
//           "type": c.type,
//           "x": c.x.value, // convert back to superView coordinates
//           "y": c.y.value,
//           "width": c.boxWidth.value,
//           "height": c.boxHeight.value,
//           "rotation": c.rotation.value,
//           "scale": c.scale.value,
//           "alpha": c.alpha.value,
//           "isUserInteractionEnabled": c.isUserInteractionEnabled.value,
//           "movable": c.movable.value,
//           "isRemovable": c.isRemovable.value,
//           "isDuplicatable": c.isDuplicatable.value,
//           "isEditable": c.isEditable.value,
//         };

//         /// Extra properties for label/image
//         if (c.text.value.isNotEmpty) {
//           itemData.addAll({
//             "text": c.text.value,
//             "textColor": c.textColor.value,
//             "size": c.textSize.value,
//             "fontURL": c.fontURL.value,
//           });
//         } else if (c.imageUrl.value.isNotEmpty) {
//           itemData["url"] = c.imageUrl.value;
//         }

//         itemList.add(itemData);
//       }

//       elements[pageKey] = itemList;
//     }

//     savedData["elements"] = elements;
//     final editorData = EditorDataModel.fromJson(savedData);
//     loadAllPages(editorData);
//   }
// }

// class BackgroundModel {
//   final String type;
//   final String url;
//   final double width;
//   final double height;
//   final String backGroundColor;

//   BackgroundModel({
//     required this.type,
//     required this.url,
//     required this.width,
//     required this.height,
//     required this.backGroundColor,
//   });
// }
