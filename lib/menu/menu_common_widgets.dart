import 'package:flutter/material.dart';
import 'package:menu_maker_demo/constant/app_constant.dart';
import 'package:menu_maker_demo/constant/color_utils.dart';
import 'package:menu_maker_demo/editing_element_controller.dart';

class MenuTextBuilders {
  static Widget title(
    EditingElementController c,
    String text, {
    int? maxLines,
    bool? softWrap,
    TextOverflow? overflow,
  }) {
    final font = AppConstant.resolve(c.itemNameFontStyle.value);
    return Text(
      text,
      softWrap: softWrap ?? true,
      overflow: overflow ?? TextOverflow.ellipsis,
      maxLines: maxLines,
      style: TextStyle(
        fontSize: c.itemNameFontSize.value,
        fontFamily: font.fontFamily,
        fontWeight: font.fontWeight,
        fontStyle: font.fontStyle,
        color: ColorUtils.fromHex(c.itemNameTextColor.value),
        height: c.lineSpace.value,
      ),
    );
  }

  static Widget description(
    EditingElementController c,
    String text, {
    TextAlign? textAlign,
  }) {
    if (text.isEmpty) return const SizedBox.shrink();
    final font = AppConstant.resolve(c.itemDescriptionFontStyle.value);
    return Text(
      text,
      softWrap: true,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: c.itemDescriptionFontSize.value,
        fontFamily: font.fontFamily,
        fontWeight: font.fontWeight,
        fontStyle: font.fontStyle,
        color: ColorUtils.fromHex(c.itemDescriptionTextColor.value),
        height: c.lineSpace.value,
      ),
    );
  }

  static Widget values(
    EditingElementController c,
    Map<String, String> values, {
    TextAlign? textAlign,
    int? maxLines,
    bool? softWrap,
    TextOverflow? overflow,
  }) {
    final font = AppConstant.resolve(c.itemValueFontStyle.value);
    return Wrap(
      children: values.values.map((price) {
        return SizedBox(
          width: c.columnWidth.value,
          child: Text(
            price,
            softWrap: softWrap ?? true,
            maxLines: maxLines,
            overflow: overflow,
            textAlign: textAlign ?? TextAlign.left,
            style: TextStyle(
              fontSize: c.itemValueFontSize.value,
              fontFamily: font.fontFamily,
              fontWeight: font.fontWeight,
              fontStyle: font.fontStyle,
              color: ColorUtils.fromHex(c.itemValueTextColor.value),
              height: c.lineSpace.value,
            ),
          ),
        );
      }).toList(),
    );
  }
}
