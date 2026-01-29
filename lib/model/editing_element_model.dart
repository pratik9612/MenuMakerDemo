enum EditingWidgetType { image, hex, label, shape, menuBox }

class EditingElementModel {
  /// Required (never null)
  final String type;
  final double x;
  final double y;
  final double width;
  final double height;
  final double rotation;
  final double alpha;

  final String? url;
  final String? text;
  final String? textColor;
  final String? tintColor;
  final double? textSize;
  final String? fontURL;
  final double? letterSpace;
  final double? lineSpace;

  /// Behavior flags (default false)
  final bool isUserInteractionEnabled;
  final bool isRemovable;
  final bool movable;
  final bool isDuplicatable;
  final bool isEditable;

  final int? contentMode;
  final String? backGroundColor;
  final double? blurAlpha;

  // Menu
  final int? menuStyle;
  final double? columnWidth;
  final double? itemNameFontSize;
  final String? itemNameFontStyle;
  final String? itemNameTextColor;

  final double? itemValueFontSize;
  final String? itemValueFontStyle;
  final String? itemValueTextColor;

  final double? itemDescriptionFontSize;
  final String? itemDescriptionFontStyle;
  final String? itemDescriptionTextColor;
  final List<MenuItemModel>? menuData;

  const EditingElementModel({
    required this.type,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.url,
    this.text,
    this.textColor,
    this.textSize,
    this.fontURL,
    this.rotation = 0.0,
    this.alpha = 1.0,
    this.isUserInteractionEnabled = true,
    this.isRemovable = true,
    this.movable = true,
    this.isDuplicatable = true,
    this.isEditable = true,
    this.contentMode,
    this.backGroundColor,
    this.menuStyle,
    this.columnWidth,
    this.menuData,
    this.itemNameFontSize,
    this.itemNameFontStyle,
    this.itemNameTextColor,
    this.itemValueFontSize,
    this.itemValueFontStyle,
    this.itemValueTextColor,
    this.itemDescriptionFontSize,
    this.itemDescriptionFontStyle,
    this.itemDescriptionTextColor,
    this.letterSpace = 0.0,
    this.lineSpace = 0.0,
    this.blurAlpha = 0.0,
    this.tintColor,
  });

  EditingElementModel copyWith({
    String? type,
    double? x,
    double? y,
    double? width,
    double? height,
    double? rotation,
    double? alpha,
    bool? isUserInteractionEnabled,
    bool? isRemovable,
    bool? movable,
    bool? isDuplicatable,
    bool? isEditable,
    String? url,
    String? text,
    String? textColor,
    String? backGroundColor,
    String? tintColor,
    double? textSize,
    String? fontURL,
    double? letterSpace,
    double? lineSpace,
    int? contentMode,
    double? blurAlpha,
    int? menuStyle,
    double? columnWidth,
    double? itemNameFontSize,
    String? itemNameFontStyle,
    String? itemNameTextColor,
    double? itemValueFontSize,
    String? itemValueFontStyle,
    String? itemValueTextColor,
    double? itemDescriptionFontSize,
    String? itemDescriptionFontStyle,
    String? itemDescriptionTextColor,
    List<MenuItemModel>? menuData,
  }) {
    return EditingElementModel(
      type: type ?? this.type,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      rotation: rotation ?? this.rotation,
      alpha: alpha ?? this.alpha,
      isUserInteractionEnabled:
          isUserInteractionEnabled ?? this.isUserInteractionEnabled,
      isRemovable: isRemovable ?? this.isRemovable,
      movable: movable ?? this.movable,
      isDuplicatable: isDuplicatable ?? this.isDuplicatable,
      isEditable: isEditable ?? this.isEditable,
      url: url ?? this.url,
      text: text ?? this.text,
      textColor: textColor ?? this.textColor,
      backGroundColor: backGroundColor ?? this.backGroundColor,
      tintColor: tintColor ?? this.tintColor,
      textSize: textSize ?? this.textSize,
      fontURL: fontURL ?? this.fontURL,
      letterSpace: letterSpace ?? this.letterSpace,
      lineSpace: lineSpace ?? this.lineSpace,
      contentMode: contentMode ?? this.contentMode,
      blurAlpha: blurAlpha ?? this.blurAlpha,
      menuStyle: menuStyle ?? this.menuStyle,
      columnWidth: columnWidth ?? this.columnWidth,
      itemNameFontSize: itemNameFontSize ?? this.itemNameFontSize,
      itemNameFontStyle: itemNameFontStyle ?? this.itemNameFontStyle,
      itemNameTextColor: itemNameTextColor ?? this.itemNameTextColor,
      itemValueFontSize: itemValueFontSize ?? this.itemValueFontSize,
      itemValueFontStyle: itemValueFontStyle ?? this.itemValueFontStyle,
      itemValueTextColor: itemValueTextColor ?? this.itemValueTextColor,
      itemDescriptionFontSize:
          itemDescriptionFontSize ?? this.itemDescriptionFontSize,
      itemDescriptionFontStyle:
          itemDescriptionFontStyle ?? this.itemDescriptionFontStyle,
      itemDescriptionTextColor:
          itemDescriptionTextColor ?? this.itemDescriptionTextColor,
      menuData: menuData ?? this.menuData,
    );
  }

  // ---------------- JSON ----------------

  factory EditingElementModel.fromJson(Map<String, dynamic> json) {
    return EditingElementModel(
      type: json['type']?.toString() ?? EditingWidgetType.label.name,

      x: (json['x'] as num?)?.toDouble() ?? 0.0,
      y: (json['y'] as num?)?.toDouble() ?? 0.0,
      width: (json['width'] as num?)?.toDouble() ?? 0.0,
      height: (json['height'] as num?)?.toDouble() ?? 0.0,

      url: json['url'] as String?,
      text: json['text'] as String?,
      textColor: json['textColor'] as String?,
      tintColor: json['tintColor'] as String?,
      textSize: (json['size'] as num?)?.toDouble(),
      fontURL: json['fontURL'] as String?,
      rotation: (json['rotationAngle'] as num?)?.toDouble() ?? 0.0,
      alpha: (json['alpha'] as num?)?.toDouble() ?? 1.0,
      letterSpace: (json['letterSpace'] as num?)?.toDouble() ?? 0.0,
      lineSpace: (json['lineSpace'] as num?)?.toDouble() ?? 0.0,
      blurAlpha: (json['blurAlpha'] as num?)?.toDouble() ?? 0.0,
      isUserInteractionEnabled:
          json['isUserInteractionEnabled'] as bool? ?? true,
      isRemovable: json['isRemovable'] as bool? ?? true,
      movable: json['movable'] as bool? ?? true,
      isDuplicatable: json['isDuplicatable'] as bool? ?? true,
      isEditable: json['isEditable'] as bool? ?? true,

      contentMode: json['contentMode'] as int?,
      backGroundColor: json['backGroundColor'] as String?,

      menuStyle: json['menuStyle'] as int?,
      columnWidth: (json['columnWidth'] as num?)?.toDouble(),

      itemNameFontStyle: json['itemNameFontStyle'] as String?,
      itemNameTextColor: json['itemNameTextColor'] as String?,
      itemNameFontSize: (json['itemNameFontSize'] as num?)?.toDouble(),
      itemValueFontStyle: json['itemValueFontStyle'] as String?,
      itemValueTextColor: json['itemValueTextColor'] as String?,
      itemValueFontSize: (json['itemValueFontSize'] as num?)?.toDouble(),
      itemDescriptionFontStyle: json['itemDescriptionFontStyle'] as String?,
      itemDescriptionTextColor: json['itemDescriptionTextColor'] as String?,
      itemDescriptionFontSize: (json['itemDescriptionFontSize'] as num?)
          ?.toDouble(),

      menuData: (json['menuData'] as List?)
          ?.map((e) => MenuItemModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    "type": type,
    "x": x,
    "y": y,
    "width": width,
    "height": height,

    if (url != null) "url": url,
    if (text != null) "text": text,
    if (textColor != null) "textColor": textColor,
    if (tintColor != null) "tintColor": tintColor,
    if (textSize != null) "size": textSize,
    if (fontURL != null) "fontURL": fontURL,
    if (rotation != 0) "rotation": rotation,
    if (alpha != 1) "alpha": alpha,
    if (letterSpace != 0.0) "letterSpace": letterSpace,
    if (lineSpace != 0.0) "lineSpace": lineSpace,
    if (blurAlpha != 0.0) "blurAlpha": blurAlpha,

    if (!isUserInteractionEnabled)
      "isUserInteractionEnabled": isUserInteractionEnabled,
    if (!isRemovable) "isRemovable": isRemovable,
    if (!movable) "movable": movable,
    if (!isDuplicatable) "isDuplicatable": isDuplicatable,
    if (!isEditable) "isEditable": isEditable,

    if (contentMode != null) "contentMode": contentMode,
    if (backGroundColor != null) "backGroundColor": backGroundColor,

    // menu
    if (menuStyle != null) "menuStyle": menuStyle,
    if (columnWidth != null) "columnWidth": columnWidth,
    if (itemNameFontStyle != null) "itemNameFontStyle": itemNameFontStyle,
    if (itemNameTextColor != null) "itemNameTextColor": itemNameTextColor,
    if (itemNameFontSize != null) "itemNameFontSize": itemNameFontSize,
    if (itemValueFontStyle != null) "itemValueFontStyle": itemValueFontStyle,
    if (itemValueTextColor != null) "itemValueTextColor": itemValueTextColor,
    if (itemValueFontSize != null) "itemValueFontSize": itemValueFontSize,
    if (itemDescriptionFontStyle != null)
      "itemDescriptionFontStyle": itemDescriptionFontStyle,
    if (itemDescriptionTextColor != null)
      "itemDescriptionTextColor": itemDescriptionTextColor,
    if (itemDescriptionFontSize != null)
      "itemDescriptionFontSize": itemDescriptionFontSize,
    if (menuData != null) "menuData": menuData!.map((e) => e.toJson()).toList(),
  };
}

class MenuItemModel {
  final String itemName;
  final String description;
  final Map<String, String> values;

  const MenuItemModel({
    required this.itemName,
    required this.description,
    required this.values,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    print(json['values']);
    return MenuItemModel(
      itemName: json['itemName'] as String? ?? "",
      description: json['description'] as String? ?? '',
      values: Map<String, String>.from(json['values'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    "itemName": itemName,
    "description": description,
    "values": values,
  };

  MenuItemModel clone() {
    return MenuItemModel(
      itemName: itemName,
      description: description,
      values: Map<String, String>.from(values),
    );
  }
}

class EditorDataModel {
  final String? previewImg;
  final double superViewWidth;
  final double superViewHeight;
  final Map<String, List<EditingElementModel>> elements;

  const EditorDataModel({
    this.previewImg,
    required this.superViewWidth,
    required this.superViewHeight,
    required this.elements,
  });

  factory EditorDataModel.fromJson(Map<String, dynamic> json) {
    final elementsJson = json['elements'] as Map<String, dynamic>? ?? {};

    return EditorDataModel(
      previewImg: json['preview_img'] as String?,
      superViewWidth: (json['superViewWidth'] as num?)?.toDouble() ?? 0.0,
      superViewHeight: (json['superViewHeight'] as num?)?.toDouble() ?? 0.0,
      elements: elementsJson.map(
        (key, value) => MapEntry(
          key,
          (value as List).map((e) => EditingElementModel.fromJson(e)).toList(),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    if (previewImg != null) "preview_img": previewImg,
    "superViewWidth": superViewWidth,
    "superViewHeight": superViewHeight,
    "elements": elements.map(
      (k, v) => MapEntry(k, v.map((e) => e.toJson()).toList()),
    ),
  };
}
