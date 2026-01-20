import 'package:flutter/material.dart';
import 'package:menu_maker_demo/constant/color_utils.dart';
import 'package:menu_maker_demo/model/editing_element_model.dart';

class MenuOne extends StatelessWidget {
  final EditingElementModel editingElementModel;
  final double scaleX;
  final double scaleY;
  const MenuOne({
    super.key,
    required this.editingElementModel,
    required this.scaleX,
    required this.scaleY,
  });

  @override
  Widget build(BuildContext context) {
    if (editingElementModel.menuData == null) SizedBox.shrink();
    List<MenuItemModel> arrMenu = editingElementModel.menuData!;
    return ListView.builder(
      padding: EdgeInsets.all(0),
      itemCount: arrMenu.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return MenuItemWidget(
          item: arrMenu[index],
          editingElementModel: editingElementModel,
          scaleX: scaleX,
          scaleY: scaleY,
        );
      },
    );
  }
}

class MenuItemWidget extends StatelessWidget {
  final EditingElementModel editingElementModel;
  final MenuItemModel item;
  final double scaleX;
  final double scaleY;
  const MenuItemWidget({
    super.key,
    required this.item,
    required this.editingElementModel,
    required this.scaleX,
    required this.scaleY,
  });
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;

        // price column width (safe clamp)
        final priceColumnWidth =
            (editingElementModel.columnWidth ?? 40) * scaleX;

        final priceCount = item.values.length;
        final totalPriceWidth = priceColumnWidth * priceCount;

        final leftWidth = (maxWidth - totalPriceWidth)
            .clamp(0, maxWidth)
            .toDouble();

        // font scaling with clamp
        double scale = (scaleX < scaleY) ? scaleX : scaleY;

        double itemNameTextSize =
            ((editingElementModel.itemNameFontSize ?? 18) * scale).clamp(8, 40);

        double descriptionTextSize =
            ((editingElementModel.itemDescriptionFontSize ?? 14) * scale).clamp(
              6,
              30,
            );

        double itemValueFontSize =
            ((editingElementModel.itemValueFontSize ?? 16) * scale).clamp(
              8,
              30,
            );

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: leftWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.itemName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: itemNameTextSize,
                      color: ColorUtils.fromHex(
                        editingElementModel.itemNameTextColor ?? "#FFFFFFFF",
                      ),
                      fontFamily: editingElementModel.itemNameFontStyle,
                    ),
                  ),
                  if (item.description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: descriptionTextSize,
                        color: ColorUtils.fromHex(
                          editingElementModel.itemDescriptionTextColor ??
                              "#FFFFFFFF",
                        ),
                        fontFamily:
                            editingElementModel.itemDescriptionFontStyle,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            /// RIGHT SIDE (prices)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: item.values.values.map((price) {
                return SizedBox(
                  width: priceColumnWidth,
                  child: Text(
                    price,
                    maxLines: 1,
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: itemValueFontSize,
                      color: ColorUtils.fromHex(
                        editingElementModel.itemValueTextColor ?? "#FFFFFFFF",
                      ),
                      fontFamily: editingElementModel.itemValueFontStyle,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}
