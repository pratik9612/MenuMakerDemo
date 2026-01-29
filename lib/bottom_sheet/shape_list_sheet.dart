import 'package:flutter/material.dart';
import 'package:menu_maker_demo/bottom_sheet/text_sheet.dart';

enum ShapeTypeToolAction {
  star,
  curvedCircle,
  circleFilled,
  circle,
  capsule,
  heartFilled,
  heart,
  line,
  lineBreaked,
  rectangleCircle,
  rectangleFilled,
  rectangle,
  square,
  arrowFilled,
  arrow,
  arrowThinFilled,
  arrowThin,
}

class ShapeDataModel {
  final ShapeTypeToolAction action;

  const ShapeDataModel({required this.action});

  String get shapeName => action.name;
}

final List<ShapeDataModel> shapeItems = ShapeTypeToolAction.values
    .map((action) => ShapeDataModel(action: action))
    .toList();

class ShapeTypeSheet extends StatelessWidget {
  final void Function(ShapeTypeToolAction action) onAction;

  const ShapeTypeSheet({required this.onAction, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 24, bottom: 16),
      child: SizedBox(
        height: 64,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: shapeItems.length,
          itemBuilder: (context, index) {
            final item = shapeItems[index];

            return SheetIcon(
              item.shapeName, // derived from enum
              onTap: () => onAction(item.action),
            );
          },
        ),
      ),
    );
  }
}
