// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:menu_maker_demo/model/editing_element_model.dart';
// import 'editing_element_controller.dart';

// class EditingElement extends StatefulWidget {
//   final EditingElementController controller;
//   final Widget childWidget;
//   final TransformationController interactiveController;
//   final VoidCallback? onTap;
//   final EditingWidgetType widgetType;
//   final VoidCallback? onDelete;

//   const EditingElement({
//     super.key,
//     required this.controller,
//     required this.interactiveController,
//     this.onTap,
//     required this.childWidget,
//     required this.widgetType,
//     this.onDelete,
//   });

//   @override
//   State<EditingElement> createState() => _EditingElementState();
// }

// Widget _handle(IconData icon) {
//   return Center(
//     child: Container(
//       width: 24,
//       height: 24,
//       decoration: const BoxDecoration(
//         color: Colors.red,
//         shape: BoxShape.circle,
//       ),
//       child: Icon(icon, size: 16, color: Colors.white),
//     ),
//   );
// }

// class _EditingElementState extends State<EditingElement> {
//   double allSideMargin = 10;
//   final GlobalKey _boxKey = GlobalKey();

//   Offset _getBoxCenterGlobal() {
//     final box = _boxKey.currentContext!.findRenderObject() as RenderBox;
//     return box.localToGlobal(box.size.center(Offset.zero));
//   }

//   Offset _toScene(Offset global) {
//     final inverted = Matrix4.copy(widget.interactiveController.value)..invert();
//     return MatrixUtils.transformPoint(inverted, global);
//   }

//   // ------------------ ROTATE ------------------
//   Offset? _center;
//   double _startAngle = 0;
//   double _startRotation = 0;
//   void _startRotate(DragStartDetails d) {
//     _center = _toScene(_getBoxCenterGlobal());
//     final local = _toScene(d.globalPosition);
//     _startAngle = atan2(local.dy - _center!.dy, local.dx - _center!.dx);
//     _startRotation = widget.controller.rotation.value;
//   }

//   void _updateRotate(DragUpdateDetails d) {
//     if (_center == null) return;

//     final local = _toScene(d.globalPosition);
//     final currentAngle = atan2(local.dy - _center!.dy, local.dx - _center!.dx);
//     final delta = currentAngle - _startAngle;

//     widget.controller.rotation.value = _startRotation + delta;
//   }

//   // ------------------ PITCH TO ZOOM IN OUT ------------------

//   Offset? _scaleCenter;
//   double _startDistance = 0;
//   double _startWidth = 0;
//   double _startHeight = 0;
//   Offset? _startTopLeft;

//   double _distance(Offset a, Offset b) => (a - b).distance;

//   Offset? _startFocalScene;
//   Offset? _startTopLeftScale;
//   double _startWidthScale = 0;
//   double _startHeightScale = 0;

//   void _onScaleStartUnified(ScaleStartDetails details) {
//     widget.controller.isSelected.value = true;
//     widget.onTap?.call();

//     _startFocalScene = _toScene(details.focalPoint);

//     _startTopLeftScale = Offset(
//       widget.controller.x.value,
//       widget.controller.y.value,
//     );

//     _startWidthScale = widget.controller.boxWidth.value;
//     _startHeightScale = widget.controller.boxHeight.value;
//   }

//   void _onScaleUpdateUnified(ScaleUpdateDetails details) {
//     // TWO fingers → PINCH (resize box)
//     if (details.pointerCount >= 2) {
//       final scale = details.scale;

//       final newWidth = max(20, _startWidthScale * scale).toDouble();
//       final newHeight = max(20, _startHeightScale * scale).toDouble();

//       widget.controller.boxWidth.value = newWidth;
//       widget.controller.boxHeight.value = newHeight;

//       // Keep center fixed
//       final dx = (newWidth - _startWidthScale) / 2;
//       final dy = (newHeight - _startHeightScale) / 2;

//       widget.controller.x.value = _startTopLeftScale!.dx - dx;
//       widget.controller.y.value = _startTopLeftScale!.dy - dy;

//       return;
//     }

//     if(widget.controller.movable.value) return;

//     // ONE finger → MOVE
//     if (_startFocalScene == null) return;

//     final current = _toScene(details.focalPoint);
//     final delta = current - _startFocalScene!;

//     widget.controller.move(delta.dx, delta.dy);
//     _startFocalScene = current;
//   }

//   void _onScaleEndUnified(ScaleEndDetails details) {
//     _startFocalScene = null;
//   }

//   void _startScale(DragStartDetails d) {
//     widget.controller.isScaling.value = true;

//     _scaleCenter = _toScene(_getBoxCenterGlobal());
//     _startTopLeft = Offset(
//       widget.controller.x.value,
//       widget.controller.y.value,
//     );
//     _startWidth = widget.controller.boxWidth.value;
//     _startHeight = widget.controller.boxHeight.value;

//     final local = _toScene(d.globalPosition);
//     _startDistance = _distance(_scaleCenter!, local);
//   }

//   void _updateScale(DragUpdateDetails d) {
//     if (_scaleCenter == null) return;

//     final local = _toScene(d.globalPosition);
//     final currentDistance = _distance(_scaleCenter!, local);

//     // Scaling factor
//     double scale = currentDistance / _startDistance;

//     // Minimum size to avoid negative or zero dimensions
//     double newWidth = max(20, _startWidth * scale);
//     double newHeight = max(20, _startHeight * scale);

//     // Update box size
//     widget.controller.boxWidth.value = newWidth;
//     widget.controller.boxHeight.value = newHeight;

//     // Keep the element centered
//     final dx = (_startWidth - newWidth) / 2;
//     final dy = (_startHeight - newHeight) / 2;
//     widget.controller.x.value = _startTopLeft!.dx + dx;
//     widget.controller.y.value = _startTopLeft!.dy + dy;
//   }

//   // ------------------ RIGHT-SIDE RESIZE (Rotation-aware) ------------------
//   Offset? _rightResizeStart;
//   Offset? _centerAtStartRight;

//   void _startRightResize(DragStartDetails d) {
//     widget.controller.isScaling.value = true;
//     _rightResizeStart = _toScene(d.globalPosition);
//     _startWidth = widget.controller.boxWidth.value;

//     final rotation = widget.controller.rotation.value;

//     if (rotation != 0) {
//       _centerAtStartRight = Offset(
//         widget.controller.x.value + widget.controller.boxWidth.value / 2,
//         widget.controller.y.value + widget.controller.boxHeight.value / 2,
//       ); // center in local scene coordinates
//     } else {
//       _centerAtStartRight = null;
//     }
//   }

//   void _updateRightResize(DragUpdateDetails d) {
//     if (_rightResizeStart == null) return;

//     final current = _toScene(d.globalPosition);
//     final deltaScene = current - _rightResizeStart!;
//     final rotation = widget.controller.rotation.value;

//     double newWidth = _startWidth;

//     if (rotation == 0) {
//       newWidth = max(20, _startWidth + deltaScene.dx);
//     } else {
//       final localDx =
//           deltaScene.dx * cos(-rotation) - deltaScene.dy * sin(-rotation);
//       newWidth = max(20, _startWidth + localDx);
//     }

//     widget.controller.boxWidth.value = newWidth;

//     // fix center in **scene coordinates**, not global
//     if (rotation != 0 && _centerAtStartRight != null) {
//       final currentCenter = Offset(
//         widget.controller.x.value + widget.controller.boxWidth.value / 2,
//         widget.controller.y.value + widget.controller.boxHeight.value / 2,
//       );
//       final delta = _centerAtStartRight! - currentCenter;
//       widget.controller.x.value += delta.dx;
//       widget.controller.y.value += delta.dy;
//     }
//   }

//   void _endRightResize() {
//     widget.controller.isScaling.value = false;
//     _rightResizeStart = null;
//     _centerAtStartRight = null;
//   }

//   // ------------------ BOTTOM-SIDE RESIZE (Rotation-aware) ------------------
//   Offset? _bottomResizeStart;
//   Offset? _centerAtStartBottom;

//   void _startBottomResize(DragStartDetails d) {
//     widget.controller.isScaling.value = true;
//     _bottomResizeStart = _toScene(d.globalPosition);
//     _startHeight = widget.controller.boxHeight.value;

//     final rotation = widget.controller.rotation.value;

//     if (rotation != 0) {
//       // Use scene coordinates, not global
//       _centerAtStartBottom = Offset(
//         widget.controller.x.value + widget.controller.boxWidth.value / 2,
//         widget.controller.y.value + widget.controller.boxHeight.value / 2,
//       );
//     } else {
//       _centerAtStartBottom = null;
//     }
//   }

//   void _updateBottomResize(DragUpdateDetails d) {
//     if (_bottomResizeStart == null) return;

//     final rotation = widget.controller.rotation.value;
//     final currentScene = _toScene(d.globalPosition);
//     final deltaScene = currentScene - _bottomResizeStart!;

//     double newHeight = _startHeight;

//     if (rotation == 0) {
//       // Simple vertical drag
//       newHeight = max(20, _startHeight + deltaScene.dy);
//     } else {
//       // Rotation: project drag onto local Y axis
//       final localDeltaY =
//           deltaScene.dx * sin(-rotation) + deltaScene.dy * cos(-rotation);
//       newHeight = max(20, _startHeight + localDeltaY);
//     }

//     widget.controller.boxHeight.value = newHeight;

//     // Fix center in scene coordinates
//     if (rotation != 0 && _centerAtStartBottom != null) {
//       final currentCenter = Offset(
//         widget.controller.x.value + widget.controller.boxWidth.value / 2,
//         widget.controller.y.value + widget.controller.boxHeight.value / 2,
//       );
//       final deltaCenter = _centerAtStartBottom! - currentCenter;
//       widget.controller.x.value += deltaCenter.dx;
//       widget.controller.y.value += deltaCenter.dy;
//     }
//   }

//   void _endBottomResize() {
//     widget.controller.isScaling.value = false;
//     _bottomResizeStart = null;
//     _centerAtStartBottom = null;
//   }

//   // ------------------ BUILD ------------------
//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       final width = widget.controller.boxWidth.value;
//       final height = widget.controller.boxHeight.value;
//       return Positioned(
//         left: widget.controller.x.value,
//         top: widget.controller.y.value,
//         child: Transform(
//           alignment: Alignment.center,
//           transform: Matrix4.identity()
//             ..rotateZ(widget.controller.rotation.value),
//           child: Stack(
//             clipBehavior: Clip.none,
//             children: [
//               GestureDetector(
//                 onTap: () {
//                   debugPrint("IMAGE onTap");
//                   widget.controller.isSelected.value = true;
//                   widget.onTap?.call();
//                 },
//                 onScaleStart: _onScaleStartUnified,
//                 onScaleUpdate: _onScaleUpdateUnified,
//                 onScaleEnd: _onScaleEndUnified,
//                 child: Container(
//                   key: _boxKey,
//                   width: width,
//                   height: height,
//                   padding: EdgeInsets.all(8),
//                   child: Container(
//                     decoration: BoxDecoration(
//                       border: Border.all(
//                         color: widget.controller.isSelected.value
//                             ? Colors.blueAccent
//                             : Colors.transparent,
//                         width: 2,
//                       ),
//                     ),
//                     child: widget.childWidget,
//                   ),
//                 ),
//               ),

//               // -------- ROTATE HANDLE (NOT SCALED) --------
//               if (widget.controller.isSelected.value)
//                 Positioned(
//                   right: 0,
//                   top: 0,
//                   child: GestureDetector(
//                     behavior: HitTestBehavior.translucent,
//                     onPanStart: (d) {
//                       debugPrint("ROTATE onPanStart");
//                       widget.controller.isRotating.value = true;
//                       _startRotate(d);
//                     },
//                     onPanUpdate: (d) {
//                       debugPrint("ROTATE onPanUpdate");
//                       _updateRotate(d);
//                     },
//                     onPanEnd: (_) {
//                       debugPrint("ROTATE onPanEnd");
//                       widget.controller.isRotating.value = false;
//                     },
//                     onPanCancel: () {
//                       debugPrint("ROTATE onPanCancel");
//                       widget.controller.isRotating.value = false;
//                     },
//                     child: _handle(Icons.rotate_90_degrees_ccw),
//                   ),
//                 ),

//               // -------- SCALE HANDLE (NOT SCALED) --------
//               if (widget.controller.isSelected.value)
//                 Positioned(
//                   right: 0,
//                   bottom: 0,
//                   child: GestureDetector(
//                     behavior: HitTestBehavior.translucent,
//                     onPanStart: (d) {
//                       debugPrint("SCALE onPanStart");
//                       _startScale(d);
//                     },
//                     onPanUpdate: (d) {
//                       debugPrint("SCALE onPanUpdate");
//                       _updateScale(d);
//                     },
//                     onPanEnd: (_) {
//                       debugPrint("SCALE onPanEnd");
//                       widget.controller.isScaling.value = false;
//                       _scaleCenter = null;
//                     },
//                     onPanCancel: () {
//                       debugPrint("SCALE onPanCancel");
//                       widget.controller.isScaling.value = false;
//                       _scaleCenter = null;
//                     },

//                     child: _handle(Icons.open_in_full),
//                   ),
//                 ),
//               if (widget.controller.isSelected.value &&
//                   widget.controller.isRemovable.value)
//                 Positioned(
//                   top: 0,
//                   left: 0,
//                   child: GestureDetector(
//                     behavior: HitTestBehavior.translucent,
//                     onTap: () {
//                       widget.onDelete?.call();
//                     },
//                     child: _handle(Icons.delete),
//                   ),
//                 ),

//               if (widget.controller.isSelected.value)
//                 Positioned(
//                   top: 24 / widget.controller.scale.value,
//                   bottom: 24 / widget.controller.scale.value,
//                   right: 0,
//                   child: GestureDetector(
//                     onPanStart: (details) {
//                       debugPrint("_startRightResize");
//                       _startRightResize(details);
//                     },
//                     onPanUpdate: (details) {
//                       debugPrint("_updateRightResize");
//                       _updateRightResize(details);
//                     },
//                     onPanEnd: (_) => _endRightResize(),
//                     onPanCancel: _endRightResize,
//                     child: Container(
//                       width: 18,
//                       decoration: BoxDecoration(
//                         color: Colors.transparent,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       alignment: Alignment.center,
//                       child: Container(
//                         width: 6,
//                         decoration: BoxDecoration(
//                           color: Colors.yellow,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),

//               if (widget.controller.isSelected.value)
//                 Positioned(
//                   left: 24 / widget.controller.scale.value,
//                   bottom: 0,
//                   right: 24 / widget.controller.scale.value,
//                   child: GestureDetector(
//                     onPanStart: _startBottomResize,
//                     onPanUpdate: _updateBottomResize,
//                     onPanEnd: (_) => _endBottomResize(),
//                     onPanCancel: _endBottomResize,
//                     child: Container(
//                       height: 18,
//                       decoration: BoxDecoration(
//                         color: Colors.transparent,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       alignment: Alignment.center,
//                       child: Container(
//                         height: 6,
//                         decoration: BoxDecoration(
//                           color: Colors.yellow,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       );
//     });
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:menu_maker_demo/model/editing_element_model.dart';

// class EditingElementController extends GetxController {
//   var x = 0.0.obs;
//   var y = 0.0.obs;

//   RxDouble boxWidth = 0.0.obs;
//   RxDouble boxHeight = 0.0.obs;

//   RxBool isUserInteractionEnabled = true.obs;
//   RxBool isDuplicatable = true.obs;
//   RxBool isRemovable = true.obs; // used
//   RxBool movable = true.obs; // used
//   RxBool isEditable = true.obs;

//   var scale = 1.0.obs;
//   var rotation = 0.0.obs;

//   var isSelected = false.obs;
//   var isRotating = false.obs;
//   var isScaling = false.obs;

//   final RxString imageUrl = "".obs;
//   final RxString text = ''.obs;
//   final RxString textColor = '#FF00FF00'.obs;
//   final RxDouble textSize = 36.0.obs;
//   final RxString fontURL = "Roboto".obs;

//   EditingElementController({
//     required double initX,
//     required double initY,
//     required double initWidth,
//     required double initHeight,
//     required bool isUserInteractionEnabled,
//     required bool isDuplicatable,
//     required bool isRemovable,
//     required bool movable,
//     required bool isEditable,
//     double initScale = 1,
//     double initRotation = 0,
//   }) {
//     x.value = initX;
//     y.value = initY;
//     boxWidth.value = initWidth;
//     boxHeight.value = initHeight;
//     rotation.value = initRotation;
//     scale.value = initScale;
//     rotation.value = initRotation;
//     this.isUserInteractionEnabled.value = isUserInteractionEnabled;
//     this.isDuplicatable.value = isDuplicatable;
//     this.isRemovable.value = isRemovable;
//     this.movable.value = movable;
//     this.isEditable.value = isEditable;
//   }

//   void move(double dx, double dy) {
//     x.value += dx;
//     y.value += dy;
//   }

//   void deselect() => isSelected.value = false;
// }

// // SINGLE extension — only one now
// extension EditingElementExport on EditingElementController {
//   EditingElementModel toModel({required EditingWidgetType type}) {
//     return EditingElementModel(
//       type: type.name,
//       x: x.value,
//       y: y.value,
//       width: boxWidth.value,
//       height: boxHeight.value,
//       rotation: rotation.value,
//       scale: scale.value,
//       textSize: textSize.value,
//       textColor: textColor.value,
//       text: text.value,
//       fontURL: fontURL.value,
//       url: imageUrl.value,
//     );
//   }
// }

// class EditingItem {
//   final EditingElementController controller;
//   final Widget child;
//   final EditingWidgetType widgetType;

//   EditingItem({
//     required this.controller,
//     required this.child,
//     required this.widgetType,
//   });
// }
