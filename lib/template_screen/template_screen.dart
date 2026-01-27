import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_maker_demo/editing_screen/editing_screen.dart';
import 'package:menu_maker_demo/template_screen/template_controller.dart';

class TemplateScreen extends StatefulWidget {
  const TemplateScreen({super.key});

  @override
  State<TemplateScreen> createState() => _TemplateScreenState();
}

class _TemplateScreenState extends State<TemplateScreen> {
  final TemplateController controller = TemplateController();
  final categories = ["All", "Restaurant", "Foldable", "Wedding"];

  @override
  void initState() {
    controller.templates.assignAll(controller.localTemplates);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Menu Maker"),
        backgroundColor: Colors.amber,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          /// Category Chips
          // SizedBox(
          //   height: 50,
          //   child: Obx(() {
          //     return ListView.separated(
          //       scrollDirection: Axis.horizontal,
          //       padding: const EdgeInsets.symmetric(horizontal: 16),
          //       itemCount: categories.length,
          //       separatorBuilder: (_, __) => const SizedBox(width: 8),
          //       itemBuilder: (_, i) {
          //         final cat = categories[i];
          //         final selected = controller.selectedCategory.value == cat;

          //         return ChoiceChip(
          //           label: Text(cat),
          //           selected: selected,
          //           onSelected: (_) => controller.selectedCategory.value = cat,
          //         );
          //       },
          //     );
          //   }),
          // ),
          const SizedBox(height: 10),

          /// Templates Grid
          Expanded(
            child: Obx(() {
              final items = controller.filteredTemplates;

              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.65,
                ),
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final item = items[i];
                  return GestureDetector(
                    onTap: () {
                      Get.to(() => EditingScreen(jsonPath: item.jsonPath));
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        item.previewImage,
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
