import 'package:get/get.dart';

class MenuTemplate {
  final String title;
  final String previewImage;
  final String jsonPath;
  final String category;

  MenuTemplate({
    required this.title,
    required this.previewImage,
    required this.jsonPath,
    required this.category,
  });
}

class TemplateController extends GetxController {
  final templates = <MenuTemplate>[].obs;
  final selectedCategory = "All".obs;

  @override
  void onInit() {
    super.onInit();
    loadTemplates();
  }

  final localTemplates = [
    MenuTemplate(
      title: "Traditional Menu",
      previewImage: "assets/images/menu_image_1.webp",
      jsonPath: "assets/json/editor_data_1.json",
      category: "Restaurant",
    ),
    MenuTemplate(
      title: "Neon Pink",
      previewImage: "assets/images/menu_image_2.webp",
      jsonPath: "assets/json/editor_data_2.json",
      category: "Restaurant",
    ),
    MenuTemplate(
      title: "Neon Pink",
      previewImage: "assets/images/menu_image_3.webp",
      jsonPath: "assets/json/editor_data_3.json",
      category: "Restaurant",
    ),
    MenuTemplate(
      title: "Floral Menu",
      previewImage: "assets/images/menu_image_4.webp",
      jsonPath: "assets/json/editor_data_4.json",
      category: "Wedding",
    ),
    MenuTemplate(
      title: "Floral Menu",
      previewImage: "assets/images/menu_image_1.webp",
      jsonPath: "assets/json/editor_data_5.json",
      category: "Wedding",
    ),
    MenuTemplate(
      title: "Floral Menu",
      previewImage: "assets/images/menu_image_6.webp",
      jsonPath: "assets/json/editor_data_6.json",
      category: "Wedding",
    ),
    MenuTemplate(
      title: "Floral Menu",
      previewImage: "assets/images/menu_image_7.webp",
      jsonPath: "assets/json/editor_data_7.json",
      category: "Wedding",
    ),
    MenuTemplate(
      title: "Floral Menu",
      previewImage: "assets/images/menu_image_8.webp",
      jsonPath: "assets/json/editor_data_8.json",
      category: "Wedding",
    ),
    MenuTemplate(
      title: "Floral Menu",
      previewImage: "assets/images/menu_image_9.webp",
      jsonPath: "assets/json/editor_data_9.json",
      category: "Wedding",
    ),
    MenuTemplate(
      title: "Floral Menu",
      previewImage: "assets/images/menu_image_10.webp",
      jsonPath: "assets/json/editor_data_10.json",
      category: "Wedding",
    ),
    MenuTemplate(
      title: "Floral Menu",
      previewImage: "assets/images/menu_image_11.webp",
      jsonPath: "assets/json/editor_data_11.json",
      category: "Wedding",
    ),
    MenuTemplate(
      title: "Floral Menu",
      previewImage: "assets/images/menu_image_12.webp",
      jsonPath: "assets/json/editor_data_12.json",
      category: "Wedding",
    ),
    MenuTemplate(
      title: "Floral Menu",
      previewImage: "assets/images/menu_image_13.webp",
      jsonPath: "assets/json/editor_data_13.json",
      category: "Wedding",
    ),
    MenuTemplate(
      title: "Floral Menu",
      previewImage: "assets/images/menu_image_14.webp",
      jsonPath: "assets/json/editor_data_14_shape.json",
      category: "Wedding",
    ),
    MenuTemplate(
      title: "Floral Menu",
      previewImage: "assets/images/menu_image_14.webp",
      jsonPath: "assets/json/json15.json",
      category: "Wedding",
    ),
  ];
  void loadTemplates() {
    templates.assignAll([]);
  }

  List<MenuTemplate> get filteredTemplates {
    if (selectedCategory.value == "All") return templates;
    return templates
        .where((e) => e.category == selectedCategory.value)
        .toList();
  }
}
