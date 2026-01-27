import 'package:flutter/material.dart';
import 'package:menu_maker_demo/constant/app_constant.dart';
import 'package:menu_maker_demo/constant/color_utils.dart';
import 'package:menu_maker_demo/menu/menu_common_widgets.dart';
import 'package:menu_maker_demo/editing_element_controller.dart';
import 'package:menu_maker_demo/model/editing_element_model.dart';

class MenuStyleWidgets {
  static Widget style1(EditingElementController c, MenuItemModel item) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: MenuTextBuilders.title(
                  c,
                  item.itemName,
                  c.itemNameFontSize.value,
                ),
              ),

              MenuTextBuilders.values(
                c,
                item.values,
                c.itemValueFontSize.value,
              ),
            ],
          ),
          SizedBox(height: 4),
          MenuTextBuilders.description(
            c,
            item.description,
            c.itemDescriptionFontSize.value,
          ),
        ],
      );

  static Widget style2(EditingElementController c, MenuItemModel item) => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      MenuTextBuilders.title(c, item.itemName, c.itemNameFontSize.value),
      Spacer(),
      MenuTextBuilders.values(c, item.values, c.itemValueFontSize.value),
    ],
  );

  static Widget style3(EditingElementController c, MenuItemModel item) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MenuTextBuilders.title(c, item.itemName, c.itemNameFontSize.value),
            MenuTextBuilders.description(
              c,
              item.description,
              c.itemDescriptionFontSize.value,
            ),
          ],
        ),
      ),
      MenuTextBuilders.values(c, item.values, c.itemValueFontSize.value),
    ],
  );

  static Widget style4(EditingElementController c, MenuItemModel item) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: MenuTextBuilders.title(
                  c,
                  item.itemName,
                  c.itemNameFontSize.value,
                ),
              ),

              MenuTextBuilders.values(
                c,
                item.values,
                c.itemValueFontSize.value,
              ),
            ],
          ),
          SizedBox(height: 4),
          MenuTextBuilders.description(
            c,
            item.description,
            c.itemDescriptionFontSize.value,
          ),
        ],
      );

  static Widget style5(EditingElementController c, MenuItemModel item) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Expanded(
                child: MenuTextBuilders.title(
                  c,
                  item.itemName,
                  c.itemNameFontSize.value,
                ),
              ),

              MenuTextBuilders.values(
                c,
                item.values,
                c.itemValueFontSize.value,
              ),
            ],
          ),
          // SizedBox(height: 4),
          MenuTextBuilders.description(
            c,
            item.description,
            c.itemDescriptionFontSize.value,
          ),
        ],
      );

  static Widget style6(EditingElementController c, MenuItemModel item) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          MenuTextBuilders.title(c, item.itemName, c.itemNameFontSize.value),
          SizedBox(width: 4),
          MenuTextBuilders.description(
            c,
            item.description,
            c.itemDescriptionFontSize.value,
          ),
        ],
      ),
      MenuTextBuilders.values(c, item.values, c.itemValueFontSize.value),
    ],
  );

  static Widget style7(EditingElementController c, MenuItemModel item) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MenuTextBuilders.title(c, item.itemName, c.itemNameFontSize.value),
          SizedBox(height: 4),
          MenuTextBuilders.description(
            c,
            item.description,
            c.itemDescriptionFontSize.value,
          ),
          SizedBox(height: 4),
          _valuesWithDivider(c, item),
          SizedBox(height: 16),
        ],
      );

  static Widget style8(EditingElementController c, MenuItemModel item) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          MenuTextBuilders.title(c, item.itemName, c.itemNameFontSize.value),
          SizedBox(height: 4),
          MenuTextBuilders.description(
            c,
            item.description,
            c.itemDescriptionFontSize.value,
          ),
          SizedBox(height: 4),
          _valuesWithDivider(c, item),
        ],
      );

  static Widget style9(EditingElementController c, MenuItemModel item) => Row(
    children: [
      Expanded(
        child: MenuTextBuilders.title(
          c,
          item.itemName,
          c.itemNameFontSize.value,
        ),
      ),
      SizedBox(width: 8),
      Expanded(
        flex: 2,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final dotCount = (constraints.maxWidth / 6).floor();
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(dotCount, (_) {
                return const Text(".", style: TextStyle(color: Colors.black));
              }),
            );
          },
        ),
      ),
      SizedBox(width: 16),
      MenuTextBuilders.values(c, item.values, c.itemValueFontSize.value),
    ],
  );

  static Widget style10(EditingElementController c, MenuItemModel item) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MenuTextBuilders.title(c, item.itemName, c.itemNameFontSize.value),
          SizedBox(height: 6),
          _valuesWithDivider(c, item),
        ],
      );

  static Widget style11(EditingElementController c, MenuItemModel item) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MenuTextBuilders.title(c, item.itemName, c.itemNameFontSize.value),

          MenuTextBuilders.description(
            c,
            item.description,
            c.itemDescriptionFontSize.value,
          ),
          _valuesWithDivider(c, item),
        ],
      );

  static Widget style12(EditingElementController c, MenuItemModel item) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: MenuTextBuilders.title(
                  c,
                  item.itemName,
                  c.itemNameFontSize.value,
                ),
              ),

              MenuTextBuilders.values(
                c,
                item.values,
                c.itemValueFontSize.value,
              ),
            ],
          ),

          MenuTextBuilders.description(
            c,
            item.description,
            c.itemDescriptionFontSize.value,
          ),
        ],
      );

  static Widget style13(EditingElementController c, MenuItemModel item) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: MenuTextBuilders.title(
                  c,
                  item.itemName,
                  c.itemNameFontSize.value,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final dotCount = (constraints.maxWidth / 6).floor();
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(dotCount, (_) {
                        return const Text(
                          ".",
                          style: TextStyle(color: Colors.black),
                        );
                      }),
                    );
                  },
                ),
              ),
              SizedBox(width: 16),
              MenuTextBuilders.values(
                c,
                item.values,
                c.itemValueFontSize.value,
              ),
            ],
          ),
          SizedBox(width: 4),
          MenuTextBuilders.description(
            c,
            "item.description",
            c.itemDescriptionFontSize.value,
          ),
        ],
      );
  static Widget _valuesWithDivider(
    EditingElementController c,
    MenuItemModel item,
  ) {
    final entries = item.values.entries.toList();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(entries.length * 2 - 1, (index) {
        if (index.isOdd) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              "|",
              style: TextStyle(
                fontSize: c.itemValueFontSize.value,
                color: c.menuStyle.value != 10
                    ? ColorUtils.fromHex(c.itemValueTextColor.value)
                    : Colors.grey,
              ),
            ),
          );
        }

        final valueIndex = index ~/ 2;
        final entry = entries[valueIndex];

        return Text(
          entry.value,
          style: TextStyle(
            fontSize: c.itemValueFontSize.value,
            color: ColorUtils.fromHex(c.itemValueTextColor.value),
            fontFamily: AppConstant.resolve(
              c.itemValueFontStyle.value,
            ).fontFamily,
            fontWeight: AppConstant.resolve(
              c.itemValueFontStyle.value,
            ).fontWeight,
            fontStyle: AppConstant.resolve(
              c.itemValueFontStyle.value,
            ).fontStyle,
          ),
        );
      }),
    );
  }
}
