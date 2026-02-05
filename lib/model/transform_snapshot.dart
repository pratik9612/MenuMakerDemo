import 'package:menu_maker_demo/editing_element_controller.dart';

class TransformSnapshot {
  final double x;
  final double y;
  final double width;
  final double height;
  final double rotation;
  final double columnWidth;

  TransformSnapshot({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.rotation,
    required this.columnWidth,
  });

  factory TransformSnapshot.fromController(EditingElementController c) {
    return TransformSnapshot(
      x: c.x.value,
      y: c.y.value,
      width: c.boxWidth.value,
      height: c.boxHeight.value,
      rotation: c.rotation.value,
      columnWidth: c.columnWidth.value,
    );
  }

  void applyTo(EditingElementController c) {
    c.x.value = x;
    c.y.value = y;
    c.boxWidth.value = width;
    c.boxHeight.value = height;
    c.rotation.value = rotation;
    c.columnWidth.value = columnWidth;
  }
}
