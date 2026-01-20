// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:menu_maker_demo/editing_element.dart';
// import 'package:menu_maker_demo/editing_screen/editing_screen_controller.dart';
// import 'package:menu_maker_demo/editing_screen/editing_screen_widget.dart';
// import 'package:menu_maker_demo/model/editing_element_model.dart';

// class EditingScreen extends StatefulWidget {
//   const EditingScreen({super.key});

//   @override
//   State<EditingScreen> createState() => _EditingScreenState();
// }

// class _EditingScreenState extends State<EditingScreen> {
//   final TransformationController _controller = TransformationController();
//   final GlobalKey _imageKey = GlobalKey();

//   final EditingScreenController _editingController = Get.put(
//     EditingScreenController(),
//   );

//   @override
//   void initState() {
//     super.initState();
//     addAllWidget();
//   }

//   void addAllWidget() async {
//     final jsonString = await rootBundle.loadString(
//       'assets/json/editor_json_original.json',
//     );

//     final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
//     final editorData = EditorDataModel.fromJson(jsonMap);

//     _editingController.loadAllPages(editorData);
//   }

//   Size getImageSize() {
//     final box = _imageKey.currentContext!.findRenderObject() as RenderBox;
//     return box.size;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Column(
//         children: [
//           Container(color: Colors.red, height: 60, width: double.infinity),
//           Expanded(
//             child: LayoutBuilder(
//               builder: (context, constraints) {
//                 _editingController.editorViewWidth = constraints.maxWidth;
//                 _editingController.editorViewHeight = constraints.maxHeight;
//                 _editingController.calculateChildScale();
//                 if (_editingController.pageKeys.isEmpty) {
//                   return const SizedBox();
//                 }
//                 return Obx(() {
//                   return PageView.builder(
//                     physics: _editingController.selectedController.value != null
//                         ? NeverScrollableScrollPhysics()
//                         : ScrollPhysics(),
//                     itemCount: _editingController.pageKeys.length,
//                     itemBuilder: (context, index) {
//                       final pageKey = _editingController.pageKeys[index];
//                       final bg = _editingController.backgrounds[pageKey];
//                       if (bg == null) return const SizedBox();
//                       return Obx(() {
//                         final items = _editingController.pageItems[pageKey];
//                         return InteractiveViewer(
//                           transformationController: _controller,
//                           minScale: 1,
//                           maxScale: 6,
//                           panEnabled: true,
//                           child: Center(
//                             child: Stack(
//                               clipBehavior: Clip.hardEdge,
//                               children: [
//                                 BackgroundWidget(backgroundModel: bg),
//                                 if (items != null)
//                                   ...items.map((item) {
//                                     return EditingElement(
//                                       editingElementController: item.controller,
//                                       interactiveController: _controller,
//                                       isSelected: _editingController.isSelected(
//                                         item.controller,
//                                       ),
//                                       childWidget: item.child,
//                                       onTap: () {
//                                         _editingController.selectItem(
//                                           item.controller,
//                                         );
//                                       },
//                                       onDelete: () {
//                                         _editingController.deleteChildWidget(
//                                           pageKey,
//                                           item.controller,
//                                         );
//                                       },
//                                     );
//                                   }),
//                               ],
//                             ),
//                           ),
//                         );
//                       });
//                     },
//                   );
//                 });
//               },
//             ),
//           ),
//           SizedBox(
//             height: 60,
//             width: double.infinity,
//             child: Row(
//               children: [
//                 GestureDetector(
//                   onTap: () {
//                     _editingController.moveSelectedLeft(10);
//                   },
//                   child: Container(
//                     color: Colors.amber,
//                     child: Text(
//                       "LeftDrag",
//                       style: TextStyle(fontSize: 24, color: Colors.white),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 4),
//                 GestureDetector(
//                   onTap: () {
//                     _editingController.moveSelectedRight(10);
//                   },
//                   child: Container(
//                     color: Colors.amber,
//                     child: Text(
//                       "RightDrag",
//                       style: TextStyle(fontSize: 24, color: Colors.white),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 4),
//                 GestureDetector(
//                   onTap: () {
//                     _editingController.changeApha(0.4);
//                   },
//                   child: Container(
//                     color: Colors.amber,
//                     child: Text(
//                       "Alpha",
//                       style: TextStyle(fontSize: 24, color: Colors.white),
//                     ),
//                   ),
//                 ),

//                 GestureDetector(
//                   onTap: () {
//                     _editingController.saveMenu();
//                   },
//                   child: Container(
//                     color: Colors.amber,
//                     child: Text(
//                       "Save Menu",
//                       style: TextStyle(fontSize: 24, color: Colors.white),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
