import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_maker_demo/app_controller.dart';
import 'package:menu_maker_demo/constant/color_utils.dart';
import 'package:menu_maker_demo/main.dart';
import 'package:menu_maker_demo/model/editing_element_model.dart';
import 'package:menu_maker_demo/model/transform_snapshot.dart';
import 'editing_element_controller.dart';

class EditingElement extends StatefulWidget {
  final EditingElementController editingElementController;
  final TransformationController interactiveController;
  final Widget childWidget;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool isSelected;
  final bool isFirstItem;

  const EditingElement({
    super.key,
    required this.editingElementController,
    required this.interactiveController,
    required this.childWidget,
    required this.isSelected,
    this.onTap,
    this.onDelete,
    required this.isFirstItem,
  });

  @override
  State<EditingElement> createState() => _EditingElementState();
}

Widget _handle(IconData icon) {
  return Center(
    child: Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 16, color: Colors.white),
    ),
  );
}

class _EditingElementState extends State<EditingElement> {
  final GlobalKey _boxKey = GlobalKey();
  static const double kMinWidth = 20;
  static const double kMinHeight = 20;
  TransformSnapshot? _moveStartSnapshot;
  TransformSnapshot? _rotateStartSnapshot;
  TransformSnapshot? _scaleStartSnapshot;
  TransformSnapshot? _resizeStartSnapshot;

  Offset _getBoxCenterGlobal() {
    final box = _boxKey.currentContext!.findRenderObject() as RenderBox;
    return box.localToGlobal(box.size.center(Offset.zero));
  }

  Offset _toScene(Offset global) {
    final inverted = Matrix4.copy(widget.interactiveController.value)..invert();
    return MatrixUtils.transformPoint(inverted, global);
  }

  // ------------------ ROTATE ------------------
  Offset? _center;
  double _startAngle = 0;
  double _startRotation = 0;
  void _startRotate(DragStartDetails d) {
    _rotateStartSnapshot = TransformSnapshot.fromController(
      widget.editingElementController,
    );
    _center = _toScene(_getBoxCenterGlobal());
    final local = _toScene(d.globalPosition);
    _startAngle = atan2(local.dy - _center!.dy, local.dx - _center!.dx);
    _startRotation = widget.editingElementController.rotation.value;
  }

  void _updateRotate(DragUpdateDetails d) {
    if (_center == null) return;

    final local = _toScene(d.globalPosition);
    final currentAngle = atan2(local.dy - _center!.dy, local.dx - _center!.dx);
    final delta = currentAngle - _startAngle;

    widget.editingElementController.rotation.value = _startRotation + delta;
  }

  // ------------------ PITCH TO ZOOM IN OUT ------------------

  Offset? _scaleCenter;
  double _startDistance = 0;
  double _startWidth = 0;
  double _startHeight = 0;
  Offset? _startTopLeft;

  double _distance(Offset a, Offset b) => (a - b).distance;

  Offset? _startFocalScene;
  Offset? _startTopLeftScale;
  double _startWidthScale = 0;
  double _startHeightScale = 0;

  void _onScaleStartUnified(ScaleStartDetails details) {
    if (!widget.isSelected) return;

    _moveStartSnapshot = TransformSnapshot.fromController(
      widget.editingElementController,
    );

    _startFocalScene = _toScene(details.focalPoint);

    _startTopLeftScale = Offset(
      widget.editingElementController.x.value,
      widget.editingElementController.y.value,
    );

    _startWidthScale = widget.editingElementController.boxWidth.value;
    _startHeightScale = widget.editingElementController.boxHeight.value;
  }

  void _onScaleUpdateUnified(ScaleUpdateDetails details) {
    // TWO fingers → PINCH (resize box)
    if (!widget.isSelected) return;
    if (details.pointerCount >= 2) {
      final scale = details.scale;

      final newWidth = max(kMinWidth, _startWidthScale * scale).toDouble();
      final newHeight = max(kMinHeight, _startHeightScale * scale).toDouble();

      widget.editingElementController.boxWidth.value = newWidth;
      widget.editingElementController.boxHeight.value = newHeight;

      // Keep center fixed
      final dx = (newWidth - _startWidthScale) / 2;
      final dy = (newHeight - _startHeightScale) / 2;

      widget.editingElementController.x.value = _startTopLeftScale!.dx - dx;
      widget.editingElementController.y.value = _startTopLeftScale!.dy - dy;

      return;
    }

    if (!widget.editingElementController.movable.value) return;

    // ONE finger → MOVE
    if (_startFocalScene == null) return;

    final current = _toScene(details.focalPoint);
    final delta = current - _startFocalScene!;

    widget.editingElementController.move(delta.dx, delta.dy);
    _startFocalScene = current;
  }

  void _onScaleEndUnified(ScaleEndDetails details) {
    if (_moveStartSnapshot == null) return;

    final after = TransformSnapshot.fromController(
      widget.editingElementController,
    );

    if (_moveStartSnapshot!.x != after.x || _moveStartSnapshot!.y != after.y) {
      appController.registerTransformUndo(
        controller: widget.editingElementController,
        before: _moveStartSnapshot!,
        after: after,
      );
    }

    _moveStartSnapshot = null;
  }

  void _startScale(DragStartDetails d) {
    if (!widget.isSelected) return;
    _scaleStartSnapshot = TransformSnapshot.fromController(
      widget.editingElementController,
    );

    widget.editingElementController.isScaling.value = true;

    _scaleCenter = _toScene(_getBoxCenterGlobal());
    _startTopLeft = Offset(
      widget.editingElementController.x.value,
      widget.editingElementController.y.value,
    );
    _startWidth = widget.editingElementController.boxWidth.value;
    _startHeight = widget.editingElementController.boxHeight.value;

    final local = _toScene(d.globalPosition);
    _startDistance = _distance(_scaleCenter!, local);
  }

  void _updateScale(DragUpdateDetails d) {
    if (!widget.isSelected) return;
    if (_scaleCenter == null) return;

    final local = _toScene(d.globalPosition);
    final currentDistance = _distance(_scaleCenter!, local);

    // Scaling factor
    double scale = currentDistance / _startDistance;

    // Minimum size to avoid negative or zero dimensions
    double newWidth = max(kMinWidth, _startWidth * scale);
    double newHeight = max(kMinHeight, _startHeight * scale);

    // Update box size
    widget.editingElementController.boxWidth.value = newWidth;
    widget.editingElementController.boxHeight.value = newHeight;

    // Keep the element centered
    final dx = (_startWidth - newWidth) / 2;
    final dy = (_startHeight - newHeight) / 2;
    widget.editingElementController.x.value = _startTopLeft!.dx + dx;
    widget.editingElementController.y.value = _startTopLeft!.dy + dy;
  }

  // ------------------ RIGHT-SIDE RESIZE (Rotation-aware) ------------------
  Offset? _rightResizeStart;
  Offset? _centerAtStartRight;

  void _startRightResize(DragStartDetails d) {
    widget.editingElementController.isScaling.value = true;
    _resizeStartSnapshot = TransformSnapshot.fromController(
      widget.editingElementController,
    );

    _rightResizeStart = _toScene(d.globalPosition);
    _startWidth = widget.editingElementController.boxWidth.value;

    final rotation = widget.editingElementController.rotation.value;

    if (rotation != 0) {
      _centerAtStartRight = Offset(
        widget.editingElementController.x.value +
            widget.editingElementController.boxWidth.value / 2,
        widget.editingElementController.y.value +
            widget.editingElementController.boxHeight.value / 2,
      ); // center in local scene coordinates
    } else {
      _centerAtStartRight = null;
    }
  }

  void _updateRightResize(DragUpdateDetails d) {
    if (_rightResizeStart == null) return;

    final current = _toScene(d.globalPosition);
    final deltaScene = current - _rightResizeStart!;
    final rotation = widget.editingElementController.rotation.value;

    double newWidth = _startWidth;

    if (rotation == 0) {
      newWidth = max(kMinWidth, _startWidth + deltaScene.dx);
    } else {
      final localDx =
          deltaScene.dx * cos(-rotation) - deltaScene.dy * sin(-rotation);
      newWidth = max(kMinWidth, _startWidth + localDx);
    }

    widget.editingElementController.boxWidth.value = newWidth;

    // fix center in **scene coordinates**, not global
    if (rotation != 0 && _centerAtStartRight != null) {
      final currentCenter = Offset(
        widget.editingElementController.x.value +
            widget.editingElementController.boxWidth.value / 2,
        widget.editingElementController.y.value +
            widget.editingElementController.boxHeight.value / 2,
      );
      final delta = _centerAtStartRight! - currentCenter;
      widget.editingElementController.x.value += delta.dx;
      widget.editingElementController.y.value += delta.dy;
    }
  }

  void _endRightResize() {
    widget.editingElementController.isScaling.value = false;

    final after = TransformSnapshot.fromController(
      widget.editingElementController,
    );

    if (_resizeStartSnapshot != null) {
      appController.registerTransformUndo(
        controller: widget.editingElementController,
        before: _resizeStartSnapshot!,
        after: after,
      );
    }

    _resizeStartSnapshot = null;
    _rightResizeStart = null;
    _centerAtStartRight = null;
  }

  // ------------------ BOTTOM-SIDE RESIZE (Rotation-aware) ------------------
  Offset? _bottomResizeStart;
  Offset? _centerAtStartBottom;

  void _startBottomResize(DragStartDetails d) {
    widget.editingElementController.isScaling.value = true;
    _resizeStartSnapshot = TransformSnapshot.fromController(
      widget.editingElementController,
    );

    _bottomResizeStart = _toScene(d.globalPosition);
    _startHeight = widget.editingElementController.boxHeight.value;

    final rotation = widget.editingElementController.rotation.value;

    if (rotation != 0) {
      // Use scene coordinates, not global
      _centerAtStartBottom = Offset(
        widget.editingElementController.x.value +
            widget.editingElementController.boxWidth.value / 2,
        widget.editingElementController.y.value +
            widget.editingElementController.boxHeight.value / 2,
      );
    } else {
      _centerAtStartBottom = null;
    }
  }

  void _updateBottomResize(DragUpdateDetails d) {
    if (_bottomResizeStart == null) return;

    final rotation = widget.editingElementController.rotation.value;
    final currentScene = _toScene(d.globalPosition);
    final deltaScene = currentScene - _bottomResizeStart!;

    double newHeight = _startHeight;

    if (rotation == 0) {
      // Simple vertical drag
      newHeight = max(kMinHeight, _startHeight + deltaScene.dy);
    } else {
      // Rotation: project drag onto local Y axis
      final localDeltaY =
          deltaScene.dx * sin(-rotation) + deltaScene.dy * cos(-rotation);
      newHeight = max(kMinHeight, _startHeight + localDeltaY);
    }

    widget.editingElementController.boxHeight.value = newHeight;

    // Fix center in scene coordinates
    if (rotation != 0 && _centerAtStartBottom != null) {
      final currentCenter = Offset(
        widget.editingElementController.x.value +
            widget.editingElementController.boxWidth.value / 2,
        widget.editingElementController.y.value +
            widget.editingElementController.boxHeight.value / 2,
      );
      final deltaCenter = _centerAtStartBottom! - currentCenter;
      widget.editingElementController.x.value += deltaCenter.dx;
      widget.editingElementController.y.value += deltaCenter.dy;
    }
  }

  void _endBottomResize() {
    widget.editingElementController.isScaling.value = false;

    final after = TransformSnapshot.fromController(
      widget.editingElementController,
    );

    if (_resizeStartSnapshot != null) {
      appController.registerTransformUndo(
        controller: widget.editingElementController,
        before: _resizeStartSnapshot!,
        after: after,
      );
    }

    _resizeStartSnapshot = null;
    _bottomResizeStart = null;
    _centerAtStartBottom = null;
  }

  @override
  Widget build(BuildContext context) {
    Widget buildByType(EditingElementController controller) {
      if (widget.editingElementController.type.value ==
          EditingWidgetType.image.name) {
        return FittedBox(fit: BoxFit.fill, child: widget.childWidget);
      } else if (widget.editingElementController.type.value ==
          EditingWidgetType.label.name) {
        return Container(
          color: ColorUtils.fromHex(controller.backGroundColor.value),
          alignment: Alignment.center,
          child: widget.childWidget,
        );
      } else if (widget.editingElementController.type.value ==
          EditingWidgetType.shape.name) {
        return FittedBox(fit: BoxFit.fill, child: widget.childWidget);
      } else {
        return Container(
          color: ColorUtils.fromHex(controller.backGroundColor.value),
          alignment: Alignment.center,
          child: widget.childWidget,
        );
      }
    }

    return Obx(() {
      final width = widget.editingElementController.boxWidth.value;
      final height = widget.editingElementController.boxHeight.value;

      final x = widget.editingElementController.x.value;
      final y = widget.editingElementController.y.value;
      final rotation = widget.editingElementController.rotation.value;

      return Stack(
        children: [
          Positioned(
            left: x,
            top: y,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..rotateZ(rotation),
              child: SizedBox(
                key: _boxKey,
                width: width,
                height: height,
                child: GestureDetector(
                  onTap: () {
                    widget.onTap?.call();
                  },
                  behavior: HitTestBehavior.translucent,
                  child: buildByType(widget.editingElementController),
                ),
              ),
            ),
          ),

          if (widget.isSelected)
            Positioned(
              left: x - 12,
              top: y - 12,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..rotateZ(rotation),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    GestureDetector(
                      onScaleStart: _onScaleStartUnified,
                      onScaleUpdate: _onScaleUpdateUnified,
                      onScaleEnd: _onScaleEndUnified,
                      child: SizedBox(
                        width: width + 24,
                        height: height + 24,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.blueAccent,
                                width: widget.isFirstItem ? 0 : 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onPanStart: (d) {
                          widget.editingElementController.isRotating.value =
                              true;
                          _startRotate(d);
                        },
                        onPanUpdate: (d) {
                          _updateRotate(d);
                        },
                        onPanEnd: (_) {
                          final after = TransformSnapshot.fromController(
                            widget.editingElementController,
                          );

                          if (_scaleStartSnapshot != null) {
                            appController.registerTransformUndo(
                              controller: widget.editingElementController,
                              before: _scaleStartSnapshot!,
                              after: after,
                            );
                          }
                          _scaleStartSnapshot = null;

                          if (_rotateStartSnapshot != null &&
                              _rotateStartSnapshot!.rotation !=
                                  after.rotation) {
                            appController.registerTransformUndo(
                              controller: widget.editingElementController,
                              before: _rotateStartSnapshot!,
                              after: after,
                            );
                          }

                          _rotateStartSnapshot = null;
                          widget.editingElementController.isRotating.value =
                              false;
                        },
                        onPanCancel: () {
                          widget.editingElementController.isRotating.value =
                              false;
                        },
                        child: _handle(Icons.rotate_90_degrees_ccw),
                      ),
                    ),

                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onPanStart: (d) {
                          _startScale(d);
                        },
                        onPanUpdate: (d) {
                          _updateScale(d);
                        },
                        onPanEnd: (_) {
                          widget.editingElementController.isScaling.value =
                              false;
                          _scaleCenter = null;
                        },
                        onPanCancel: () {
                          widget.editingElementController.isScaling.value =
                              false;
                          _scaleCenter = null;
                        },
                        child: _handle(Icons.open_in_full),
                      ),
                    ),

                    if (widget.editingElementController.isRemovable.value)
                      Positioned(
                        top: 0,
                        left: 0,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            widget.onDelete?.call();
                          },
                          child: _handle(Icons.delete),
                        ),
                      ),

                    if (widget.editingElementController.isDuplicatable.value)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          child: _handle(Icons.copy),
                        ),
                      ),

                    Positioned(
                      top: 24 / widget.editingElementController.scale.value,
                      bottom: 24 / widget.editingElementController.scale.value,
                      right: 0,
                      child: GestureDetector(
                        onPanStart: (details) {
                          _startRightResize(details);
                        },
                        onPanUpdate: (details) {
                          _updateRightResize(details);
                        },
                        onPanEnd: (_) => _endRightResize(),
                        onPanCancel: _endRightResize,
                        child: Container(
                          width: 18,
                          alignment: Alignment.center,
                          child: Container(
                            width: 6,
                            decoration: BoxDecoration(
                              color: Colors.yellow,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      left: 24 / widget.editingElementController.scale.value,
                      right: 24 / widget.editingElementController.scale.value,
                      bottom: 0,
                      child: GestureDetector(
                        onPanStart: _startBottomResize,
                        onPanUpdate: _updateBottomResize,
                        onPanEnd: (_) => _endBottomResize(),
                        onPanCancel: _endBottomResize,
                        child: Container(
                          height: 18,
                          alignment: Alignment.center,
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.yellow,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    });
  }
}
