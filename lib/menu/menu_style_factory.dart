import 'package:flutter/material.dart';
import 'package:menu_maker_demo/menu/menu_style_widgets.dart';

class MenuStyleFactory {
  static Widget build(int style, controller, item) {
    switch (style) {
      case 1:
        return MenuStyleWidgets.style1(controller, item);
      case 2:
        return MenuStyleWidgets.style2(controller, item);
      case 3:
        return MenuStyleWidgets.style3(controller, item);
      case 4:
        return MenuStyleWidgets.style4(controller, item);
      case 5:
        return MenuStyleWidgets.style5(controller, item);
      case 6:
        return MenuStyleWidgets.style6(controller, item);
      case 7:
        return MenuStyleWidgets.style7(controller, item);
      case 8:
        return MenuStyleWidgets.style8(controller, item);
      case 9:
        return MenuStyleWidgets.style9(controller, item);
      case 10:
        return MenuStyleWidgets.style10(controller, item);
      case 11:
        return MenuStyleWidgets.style11(controller, item);
      case 12:
        return MenuStyleWidgets.style12(controller, item);
      case 13:
        return MenuStyleWidgets.style13(controller, item);
      default:
        return MenuStyleWidgets.style1(controller, item);
    }
  }
}
