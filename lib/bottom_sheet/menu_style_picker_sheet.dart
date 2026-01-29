import 'package:flutter/material.dart';
import 'package:menu_maker_demo/model/editing_element_model.dart';

class MenuStylePickerSheet extends StatelessWidget {
  final Function(int) onStyleSelected;

  const MenuStylePickerSheet({super.key, required this.onStyleSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        itemCount: 13,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (_, index) {
          final styleIndex = index + 1;

          return GestureDetector(
            onTap: () {
              onStyleSelected(styleIndex);
              Navigator.pop(context);
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(
                "assets/images/menu_image_$styleIndex.png",
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }
}

({
  double itemNameFontSize,
  double itemDescriptionFontSize,
  double itemValueFontSize,
  String itemNameFontStyle,
  String itemDescriptionFontStyle,
  String itemValueFontStyle,
  List<MenuItemModel> menuItems,
})
resolveItem(int menuStyle) {
  // 🔹 Default menu builder

  switch (menuStyle) {
    case 1:
      return (
        itemNameFontSize: 16,
        itemDescriptionFontSize: 12,
        itemValueFontSize: 12,
        itemNameFontStyle: "Lato-Regular",
        itemDescriptionFontStyle: "Lato-Regular",
        itemValueFontStyle: "Lato-Black",
        menuItems: [
          MenuItemModel(
            itemName: "Margherita",
            description: "Tomato sauce, mozzarella, basil",
            values: {"1": "\$2", "2": "\$5", "3": "\$7"},
          ),
          MenuItemModel(
            itemName: "Pepperoni",
            description: "Tomato sauce, mozzarella, pepperoni",
            values: {"1": "\$5", "2": "\$5", "3": "\$7"},
          ),
          MenuItemModel(
            itemName: "Hawaiian",
            description: "Tomato sauce, mozzarella, ham, pineapple",
            values: {"1": "\$7", "2": "\$8", "3": "\$9"},
          ),
          MenuItemModel(
            itemName: "Four Cheese",
            description:
                "Tomato sauce, mozzarella, parmesan, gorgonzola, provolone",
            values: {"1": "\$1", "2": "\$1", "3": "\$1"},
          ),
          MenuItemModel(
            itemName: "Mediterranean",
            description:
                "Olive oil, mozzarella, feta, olives, artichokes, spinach",
            values: {"1": "\$1", "2": "\$1", "3": "\$1"},
          ),
        ],
      );

    case 2:
      return (
        itemNameFontSize: 24,
        itemDescriptionFontSize: 12,
        itemValueFontSize: 24,
        itemNameFontStyle: "InriaSans-Light",
        itemDescriptionFontStyle: "Lato-Regular",
        itemValueFontStyle: "InriaSans-Regular",
        menuItems: [
          MenuItemModel(
            itemName: "Margherita",
            description: "Tomato sauce, mozzarella, basil",
            values: {"1": "\$2", "2": "\$5", "3": "\$7"},
          ),
          MenuItemModel(
            itemName: "Pepperoni",
            description: "Tomato sauce, mozzarella, pepperoni",
            values: {"1": "\$5", "2": "\$5", "3": "\$7"},
          ),
          MenuItemModel(
            itemName: "Hawaiian",
            description: "Tomato sauce, mozzarella, ham, pineapple",
            values: {"1": "\$7", "2": "\$8", "3": "\$9"},
          ),
          MenuItemModel(
            itemName: "Four Cheese",
            description:
                "Tomato sauce, mozzarella, parmesan, gorgonzola, provolone",
            values: {"1": "\$1", "2": "\$1", "3": "\$1"},
          ),
          MenuItemModel(
            itemName: "Mediterranean",
            description:
                "Olive oil, mozzarella, feta, olives, artichokes, spinach",
            values: {"1": "\$1", "2": "\$1", "3": "\$1"},
          ),
        ],
      );

    case 3:
      return (
        itemNameFontSize: 8.73,
        itemDescriptionFontSize: 7.24,
        itemValueFontSize: 11.64,
        itemNameFontStyle: "Lora-Regular",
        itemDescriptionFontStyle: "Lato-Regular",
        itemValueFontStyle: "Lora-Regular",
        menuItems: [
          MenuItemModel(
            itemName: "Margherita",
            description: "Tomato sauce, mozzarella, basil",
            values: {"1": "\$2", "2": "\$5", "3": "\$7"},
          ),
          MenuItemModel(
            itemName: "Pepperoni",
            description: "Tomato sauce, mozzarella, pepperoni",
            values: {"1": "\$5", "2": "\$5", "3": "\$7"},
          ),
          MenuItemModel(
            itemName: "Hawaiian",
            description: "Tomato sauce, mozzarella, ham, pineapple",
            values: {"1": "\$7", "2": "\$8", "3": "\$9"},
          ),
          MenuItemModel(
            itemName: "Four Cheese",
            description:
                "Tomato sauce, mozzarella, parmesan, gorgonzola, provolone",
            values: {"1": "\$1", "2": "\$1", "3": "\$1"},
          ),
          MenuItemModel(
            itemName: "Mediterranean",
            description:
                "Olive oil, mozzarella, feta, olives, artichokes, spinach",
            values: {"1": "\$1", "2": "\$1", "3": "\$1"},
          ),
        ],
      );

    case 4:
      return (
        itemNameFontSize: 20,
        itemDescriptionFontSize: 20,
        itemValueFontSize: 16,
        itemNameFontStyle: "Lora-Regular_Bold",
        itemDescriptionFontStyle: "Lato-Regular",
        itemValueFontStyle: "Lora-Regular_Bold",
        menuItems: [
          MenuItemModel(
            itemName: "Combo 1",
            description: "Stuffed Mushrooms Roast Turkey",
            values: {"1": "\$32"},
          ),
          MenuItemModel(
            itemName: "Combo 2",
            description: "Stuffed Mushrooms Roast Turkey",
            values: {"1": "\$32"},
          ),
          MenuItemModel(
            itemName: "Combo 3",
            description: "Stuffed Mushrooms Roast Turkey",
            values: {"1": "\$32"},
          ),
        ],
      );

    case 5:
      return (
        itemNameFontSize: 20,
        itemDescriptionFontSize: 20,
        itemValueFontSize: 16,
        itemNameFontStyle: "Lora-Regular_Bold",
        itemDescriptionFontStyle: "Lato-Regular",
        itemValueFontStyle: "Lora-Regular_Bold",
        menuItems: [
          MenuItemModel(
            itemName: "Combo 1",
            description: "Stuffed Mushrooms Roast Turkey",
            values: {"1": "\$32"},
          ),
          MenuItemModel(
            itemName: "Combo 2",
            description: "Stuffed Mushrooms Roast Turkey",
            values: {"1": "\$32"},
          ),
          MenuItemModel(
            itemName: "Combo 3",
            description: "Stuffed Mushrooms Roast Turkey",
            values: {"1": "\$32"},
          ),
        ],
      );

    case 6:
      return (
        itemNameFontSize: 10.62,
        itemDescriptionFontSize: 5.31,
        itemValueFontSize: 10.62,
        itemNameFontStyle: "Lato-Regular",
        itemDescriptionFontStyle: "Lato-Regular",
        itemValueFontStyle: "Lato-Bold",
        menuItems: [
          MenuItemModel(
            itemName: "Margherita",
            description: "Tomato sauce",
            values: {"1": "\$2", "2": "\$5", "3": "\$7"},
          ),
          MenuItemModel(
            itemName: "Pepperoni",
            description: "Tomato sauce",
            values: {"1": "\$5", "2": "\$5", "3": "\$7"},
          ),
          MenuItemModel(
            itemName: "Hawaiian",
            description: "Tomato sauce",
            values: {"1": "\$7", "2": "\$8", "3": "\$9"},
          ),
          MenuItemModel(
            itemName: "Four Cheese",
            description: "Tomato sauce",
            values: {"1": "\$1", "2": "\$1", "3": "\$1"},
          ),
          MenuItemModel(
            itemName: "Mediterranean",
            description: "Olive oil",
            values: {"1": "\$1", "2": "\$1", "3": "\$1"},
          ),
        ],
      );

    case 7:
      return (
        itemNameFontSize: 24,
        itemDescriptionFontSize: 16,
        itemValueFontSize: 16,
        itemNameFontStyle: "Lora-Regular_Medium",
        itemDescriptionFontStyle: "Lora-Regular",
        itemValueFontStyle: "Lora-Regular_Bold",
        menuItems: [
          MenuItemModel(
            itemName: "Vanila Milkshake",
            description: "Tomato sauce, mozzarella, basil",
            values: {"1": "200ml", "2": "\$25"},
          ),
          MenuItemModel(
            itemName: "Chocolate Milkshake",
            description: "Tomato sauce, mozzarella, pepperoni",
            values: {"1": "200ml", "2": "\$30"},
          ),
          MenuItemModel(
            itemName: "Strawberry Milkshake",
            description: "Tomato sauce, mozzarella, ham, pineapple",
            values: {"1": "200ml", "2": "\$35"},
          ),
        ],
      );

    case 8:
      return (
        itemNameFontSize: 24,
        itemDescriptionFontSize: 16,
        itemValueFontSize: 16,
        itemNameFontStyle: "Lora-Regular_Medium",
        itemDescriptionFontStyle: "Lora-Regular",
        itemValueFontStyle: "Lora-Regular_Bold",
        menuItems: [
          MenuItemModel(
            itemName: "Vanila Milkshake",
            description: "Tomato sauce, mozzarella, basil",
            values: {"1": "200ml", "2": "\$25"},
          ),
          MenuItemModel(
            itemName: "Chocolate Milkshake",
            description: "Tomato sauce, mozzarella, pepperoni",
            values: {"1": "200ml", "2": "\$30"},
          ),
          MenuItemModel(
            itemName: "Strawberry Milkshake",
            description: "Tomato sauce, mozzarella, ham, pineapple",
            values: {"1": "200ml", "2": "\$35"},
          ),
        ],
      );

    case 9:
      return (
        itemNameFontSize: 20,
        itemDescriptionFontSize: 12,
        itemValueFontSize: 20,
        itemNameFontStyle: "InriaSans-Bold",
        itemDescriptionFontStyle: "Lato-Regular",
        itemValueFontStyle: "InriaSans-Bold",
        menuItems: [
          MenuItemModel(
            itemName: "Margherita",
            description: "Tomato sauce, mozzarella, basil",
            values: {"1": "\$2", "2": "\$5", "3": "\$7"},
          ),
          MenuItemModel(
            itemName: "Pepperoni",
            description: "Tomato sauce, mozzarella, pepperoni",
            values: {"1": "\$5", "2": "\$5", "3": "\$7"},
          ),
          MenuItemModel(
            itemName: "Hawaiian",
            description: "Tomato sauce, mozzarella, ham, pineapple",
            values: {"1": "\$7", "2": "\$8", "3": "\$9"},
          ),
          MenuItemModel(
            itemName: "Four Cheese",
            description:
                "Tomato sauce, mozzarella, parmesan, gorgonzola, provolone",
            values: {"1": "\$1", "2": "\$1", "3": "\$1"},
          ),
          MenuItemModel(
            itemName: "Mediterranean",
            description:
                "Olive oil, mozzarella, feta, olives, artichokes, spinach",
            values: {"1": "\$1", "2": "\$1", "3": "\$1"},
          ),
        ],
      );

    case 10:
      return (
        itemNameFontSize: 32,
        itemDescriptionFontSize: 12,
        itemValueFontSize: 24,
        itemNameFontStyle: "Inter-Regular_Medium",
        itemDescriptionFontStyle: "Lato-Regular",
        itemValueFontStyle: "Inter-Regular_Medium",
        menuItems: [
          MenuItemModel(
            itemName: "Margherita",
            description: "",
            values: {"1": "S \$2", "2": "M \$5", "3": "L \$7"},
          ),
          MenuItemModel(
            itemName: "Pepperoni",
            description: "Cheesy hot pizza",
            values: {"1": "S \$5", "2": "M \$5", "3": "L \$7"},
          ),
          MenuItemModel(
            itemName: "Hawaiian",
            description: "Cheesy hot pizza",
            values: {"1": "S \$7", "2": "M \$8", "3": "L \$9"},
          ),
        ],
      );

    case 11:
      return (
        itemNameFontSize: 32,
        itemDescriptionFontSize: 16,
        itemValueFontSize: 16,
        itemNameFontStyle: "InriaSans-Bold",
        itemDescriptionFontStyle: "InriaSans-Regular",
        itemValueFontStyle: "InriaSans-Regular",
        menuItems: [
          MenuItemModel(
            itemName: "Vanila Milkshake",
            description: "Tomato sauce, mozzarella, basil",
            values: {"1": "200ml", "2": "\$25"},
          ),
          MenuItemModel(
            itemName: "Chocolate Milkshake",
            description: "Tomato sauce, mozzarella, pepperoni",
            values: {"1": "200ml", "2": "\$30"},
          ),
          MenuItemModel(
            itemName: "Strawberry Milkshake",
            description: "Tomato sauce, mozzarella, ham, pineapple",
            values: {"1": "200ml", "2": "\$35"},
          ),
        ],
      );

    case 12:
      return (
        itemNameFontSize: 20,
        itemDescriptionFontSize: 14,
        itemValueFontSize: 20,
        itemNameFontStyle: "Poppins-Regular",
        itemDescriptionFontStyle: "Poppins-Regular",
        itemValueFontStyle: "Poppins-Medium",
        menuItems: [
          MenuItemModel(
            itemName: "Margherita",
            description: "Tomato sauce, mozzarella, basil",
            values: {"1": "\$2", "2": "\$5", "3": "\$7"},
          ),
          MenuItemModel(
            itemName: "Pepperoni",
            description: "Tomato sauce, mozzarella, pepperoni",
            values: {"1": "\$5", "2": "\$5", "3": "\$7"},
          ),
          MenuItemModel(
            itemName: "Hawaiian",
            description: "Tomato sauce, mozzarella, ham, pineapple",
            values: {"1": "\$7", "2": "\$8", "3": "\$9"},
          ),
          MenuItemModel(
            itemName: "Four Cheese",
            description:
                "Tomato sauce, mozzarella, parmesan, gorgonzola, provolone",
            values: {"1": "\$1", "2": "\$1", "3": "\$1"},
          ),
          MenuItemModel(
            itemName: "Mediterranean",
            description:
                "Olive oil, mozzarella, feta, olives, artichokes, spinach",
            values: {"1": "\$1", "2": "\$1", "3": "\$1"},
          ),
        ],
      );

    case 13:
      return (
        itemNameFontSize: 20,
        itemDescriptionFontSize: 12,
        itemValueFontSize: 20,
        itemNameFontStyle: "InriaSans-Bold",
        itemDescriptionFontStyle: "Lato-Regular",
        itemValueFontStyle: "InriaSans-Bold",
        menuItems: [
          MenuItemModel(
            itemName: "Margherita",
            description: "Tomato sauce, mozzarella, basil",
            values: {"1": "\$2", "2": "\$5", "3": "\$7"},
          ),
          MenuItemModel(
            itemName: "Pepperoni",
            description: "Tomato sauce, mozzarella, pepperoni",
            values: {"1": "\$5", "2": "\$5", "3": "\$7"},
          ),
          MenuItemModel(
            itemName: "Hawaiian",
            description: "Tomato sauce, mozzarella, ham, pineapple",
            values: {"1": "\$7", "2": "\$8", "3": "\$9"},
          ),
          MenuItemModel(
            itemName: "Four Cheese",
            description:
                "Tomato sauce, mozzarella, parmesan, gorgonzola, provolone",
            values: {"1": "\$1", "2": "\$1", "3": "\$1"},
          ),
          MenuItemModel(
            itemName: "Mediterranean",
            description:
                "Olive oil, mozzarella, feta, olives, artichokes, spinach",
            values: {"1": "\$1", "2": "\$1", "3": "\$1"},
          ),
        ],
      );

    default:
      return (
        itemNameFontSize: 16,
        itemDescriptionFontSize: 12,
        itemValueFontSize: 12,
        itemNameFontStyle: "Lato-Regular",
        itemDescriptionFontStyle: "Lato-Regular",
        itemValueFontStyle: "Lato-Black",
        menuItems: [
          MenuItemModel(
            itemName: "Margherita",
            description: "Tomato sauce, mozzarella, basil",
            values: {"1": "\$2", "2": "\$5", "3": "\$7"},
          ),
          MenuItemModel(
            itemName: "Pepperoni",
            description: "Tomato sauce, mozzarella, pepperoni",
            values: {"1": "\$5", "2": "\$5", "3": "\$7"},
          ),
          MenuItemModel(
            itemName: "Hawaiian",
            description: "Tomato sauce, mozzarella, ham, pineapple",
            values: {"1": "\$7", "2": "\$8", "3": "\$9"},
          ),
          MenuItemModel(
            itemName: "Four Cheese",
            description:
                "Tomato sauce, mozzarella, parmesan, gorgonzola, provolone",
            values: {"1": "\$1", "2": "\$1", "3": "\$1"},
          ),
          MenuItemModel(
            itemName: "Mediterranean",
            description:
                "Olive oil, mozzarella, feta, olives, artichokes, spinach",
            values: {"1": "\$1", "2": "\$1", "3": "\$1"},
          ),
        ],
      );
  }
}
