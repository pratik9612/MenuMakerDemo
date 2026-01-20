import 'package:flutter/material.dart';
import 'package:menu_maker_demo/constant/app_constant.dart';
import 'package:menu_maker_demo/constant/color_utils.dart';
import 'package:menu_maker_demo/editing_element_controller.dart';
import 'package:menu_maker_demo/model/editing_element_model.dart';

class MenuOne extends StatelessWidget {
  final EditingElementController editingElementController;
  final double scaleX;
  final double scaleY;
  const MenuOne({
    super.key,
    required this.editingElementController,
    required this.scaleX,
    required this.scaleY,
  });

  @override
  Widget build(BuildContext context) {
    if (editingElementController.arrMenu.isEmpty) SizedBox.shrink();
    List<MenuItemModel> arrMenu = editingElementController.arrMenu;
    return ListView.builder(
      itemCount: arrMenu.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return MenuItemWidget(
          item: arrMenu[index],
          editingElementController: editingElementController,
          scaleX: scaleX,
          scaleY: scaleY,
        );
      },
    );
  }
}

class MenuItemWidget extends StatelessWidget {
  final EditingElementController editingElementController;
  final MenuItemModel item;
  final double scaleX;
  final double scaleY;
  const MenuItemWidget({
    super.key,
    required this.item,
    required this.editingElementController,
    required this.scaleX,
    required this.scaleY,
  });
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // price column width (safe clamp)
        final priceColumnWidth = editingElementController.columnWidth.value;

        double itemNameTextSize =
            editingElementController.itemNameFontSize.value;

        double descriptionTextSize =
            editingElementController.itemDescriptionFontSize.value;

        double itemValueFontSize =
            editingElementController.itemValueFontSize.value;
        final nameFont = AppConstant.resolve(
          editingElementController.itemNameFontStyle.value,
        );
        final discriptionFont = AppConstant.resolve(
          editingElementController.itemDescriptionFontStyle.value,
        );
        final priceFont = AppConstant.resolve(
          editingElementController.itemValueFontStyle.value,
        );

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: itemNameTextSize,
                    fontFamily: nameFont.fontFamily,
                    fontWeight: nameFont.fontWeight,
                    fontStyle: nameFont.fontStyle,
                    color: ColorUtils.fromHex(
                      editingElementController.itemNameTextColor.value,
                    ),
                  ),
                ),
                if (item.description.isNotEmpty) ...[
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: descriptionTextSize,
                      fontFamily: discriptionFont.fontFamily,
                      fontWeight: discriptionFont.fontWeight,
                      fontStyle: discriptionFont.fontStyle,

                      color: ColorUtils.fromHex(
                        editingElementController.itemDescriptionTextColor.value,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Spacer(),

            /// RIGHT SIDE (prices)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: item.values.values.map((price) {
                return SizedBox(
                  width: priceColumnWidth,
                  child: Text(
                    price,
                    maxLines: 1,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: itemValueFontSize,
                      color: ColorUtils.fromHex(
                        editingElementController.itemValueTextColor.value,
                      ),
                      fontFamily: priceFont.fontFamily,
                      fontWeight: priceFont.fontWeight,
                      fontStyle: priceFont.fontStyle,
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
