import 'package:flutter/material.dart';
import 'package:menu_maker_demo/constant/color_utils.dart';
import 'package:menu_maker_demo/editing_element_controller.dart';

class MenuTextBuilders {
  static Widget title(
    EditingElementController c,
    String title, {
    GlobalKey? titleKey,
  }) {
    return Text(
      key: titleKey,
      title,
      softWrap: true,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: c.itemNameFontSize.value,
        fontFamily: c.itemNameFontStyle.value,
        color: ColorUtils.fromHex(c.itemNameTextColor.value),
        height: c.lineSpace.value,
      ),
    );
  }

  static Widget description(
    EditingElementController c,
    String description, {
    GlobalKey? descriptionKey,
    TextAlign? textAlign,
  }) {
    if (description.isEmpty) return const SizedBox.shrink();
    return Text(
      key: descriptionKey,
      description,
      softWrap: true,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: c.itemDescriptionFontSize.value,
        fontFamily: c.itemDescriptionFontStyle.value,
        color: ColorUtils.fromHex(c.itemDescriptionTextColor.value),
        height: c.lineSpace.value,
      ),
    );
  }

  static Widget values(
    EditingElementController c,
    Map<String, String> values,
    Map<String, GlobalKey> valuesKey,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: values.entries.map((entry) {
        final keyName = entry.key;
        final price = entry.value;
        return SizedBox(
          width: c.columnWidth.value,
          child: Text(
            key: valuesKey[keyName],
            price,
            softWrap: true,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: c.itemValueFontSize.value,
              fontFamily: c.itemValueFontStyle.value,
              color: ColorUtils.fromHex(c.itemValueTextColor.value),
              height: c.lineSpace.value,
            ),
          ),
        );
      }).toList(),
    );
  }
}
