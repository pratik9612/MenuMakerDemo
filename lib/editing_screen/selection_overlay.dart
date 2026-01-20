import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:menu_maker_demo/editing_element_controller.dart';

class CustomSelectionOverlay extends StatefulWidget {
  final EditingElementController controller;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;
  const CustomSelectionOverlay({
    super.key,
    required this.controller,
    required this.onDelete,
    required this.onDuplicate,
  });

  @override
  State<CustomSelectionOverlay> createState() => _CustomSelectionOverlayState();
}

class _CustomSelectionOverlayState extends State<CustomSelectionOverlay> {
  Offset? _center;
  double _startAngle = 0;
  double _startRotation = 0;

  void _startRotate(DragStartDetails details) {
    // Get center of the widget in global coordinates
    final renderBox = context.findRenderObject() as RenderBox;
    _center = renderBox.localToGlobal(
      Offset(
        widget.controller.boxWidth.value / 2,
        widget.controller.boxHeight.value / 2,
      ),
    );

    final touchPosition = details.globalPosition;
    _startAngle = atan2(
      touchPosition.dy - _center!.dy,
      touchPosition.dx - _center!.dx,
    );
    _startRotation = widget.controller.rotation.value;
  }

  void _updateRotate(DragUpdateDetails details) {
    if (_center == null) return;

    final touchPosition = details.globalPosition;
    final currentAngle = atan2(
      touchPosition.dy - _center!.dy,
      touchPosition.dx - _center!.dx,
    );
    final delta = currentAngle - _startAngle;

    widget.controller.rotation.value = _startRotation + delta;
  }

  Widget _handle(IconData icon) {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 16, color: Colors.black),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      const handleSize = 8.0;

      return Positioned(
        left: widget.controller.x.value - handleSize,
        top: widget.controller.y.value - handleSize,
        child: Transform.rotate(
          alignment: Alignment.center,
          angle: widget.controller.rotation.value,
          child: SizedBox(
            width: widget.controller.boxWidth.value + (handleSize * 2),
            height: widget.controller.boxHeight.value + (handleSize * 2),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: handleSize,
                  top: handleSize,
                  child: Container(
                    width: widget.controller.boxWidth.value,
                    height: widget.controller.boxHeight.value,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),

                // ROTATE
                Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                    onTap: () {
                      debugPrint("Rotate");
                    },
                    onPanStart: _startRotate,
                    onPanUpdate: _updateRotate,
                    child: _handle(Icons.rotate_right),
                  ),
                ),

                // SCALE (corner)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: () {
                      debugPrint("Scale");
                    },
                    onPanUpdate: (d) {
                      widget.controller.boxWidth.value += d.delta.dx;
                      widget.controller.boxHeight.value += d.delta.dy;
                    },
                    child: _handle(Icons.open_in_full),
                  ),
                ),

                // DELETE
                Positioned(
                  left: 0,
                  top: 0,
                  child: GestureDetector(
                    onTap: widget.onDelete,
                    child: _handle(Icons.delete),
                  ),
                ),

                // DUPLICATE
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: widget.onDuplicate,
                    child: _handle(Icons.copy),
                  ),
                ),

                Positioned(
                  left: 24,
                  bottom: 0,
                  right: 24,
                  child: GestureDetector(
                    onTap: widget.onDuplicate,
                    child: Container(
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
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

                Positioned(
                  top: 24,
                  right: 0,
                  bottom: 24,
                  child: GestureDetector(
                    child: Container(
                      width: 18,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
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
              ],
            ),
          ),
        ),
      );
    });
  }
}
