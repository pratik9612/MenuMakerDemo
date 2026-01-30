import 'package:flutter/material.dart';

enum EditorBottomSheetType {
  label,
  image,
  shape,
  labelSpace,
  move,
  shapeType,
  menuBox,
  addPage
}

EditorBottomSheetType? _currentType;
PersistentBottomSheetController? _controller;

class BottomSheetManager {
  void open({
    required GlobalKey<ScaffoldState> scaffoldKey,
    required EditorBottomSheetType type,
    required Widget sheet,
  }) {
    if (_currentType == type && _controller != null) {
      debugPrint("Same Type");
      return;
    }
    debugPrint("Different Type");
    close();
    _currentType = type;
    _controller = scaffoldKey.currentState?.showBottomSheet(
      (context) => sheet,
      backgroundColor: Colors.transparent,
    );
  }

  void close() {
    try {
      debugPrint("Step Try");
      _controller?.close();
      _controller = null;
      _currentType = null;
    } catch (_) {
      debugPrint("Step Catch");
    }
  }
}
