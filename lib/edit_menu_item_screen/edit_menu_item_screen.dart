import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_maker_demo/app_controller.dart';
import 'package:menu_maker_demo/edit_menu_item_screen/edit_menu_item_sheet.dart';
import 'package:menu_maker_demo/editing_element_controller.dart';
import 'package:menu_maker_demo/main.dart';
import 'package:menu_maker_demo/model/editing_element_model.dart';

class EditMenuItemsScreen extends StatefulWidget {
  final EditingElementController controller;

  const EditMenuItemsScreen({super.key, required this.controller});

  @override
  State<EditMenuItemsScreen> createState() => _EditMenuItemsScreenState();
}

class _EditMenuItemsScreenState extends State<EditMenuItemsScreen> {
  late List<MenuItemModel> originalItems;
  late List<MenuItemModel> editableItems;

  @override
  void initState() {
    super.initState();

    /// 🔐 Deep copy
    originalItems = widget.controller.arrMenu.map((e) => e.clone()).toList();

    editableItems = widget.controller.arrMenu.map((e) => e.clone()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text("Edit Menu"),
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: _addItem)],
      ),

      body: ListView.separated(
        itemCount: editableItems.length,
        separatorBuilder: (_, __) => const Divider(height: 1),

        itemBuilder: (_, index) {
          final item = editableItems[index];

          return Dismissible(
            key: ValueKey(item.hashCode),
            direction: DismissDirection.horizontal,
            background: _deleteBg(Alignment.centerLeft),
            secondaryBackground: _deleteBg(Alignment.centerRight),

            onDismissed: (_) {
              setState(() {
                editableItems.removeAt(index);
              });
            },

            child: MenuRow(item: item, onEdit: () => _editItem(item, index)),
          );
        },
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
          onPressed: _saveChanges,
          child: const Text("Save"),
        ),
      ),
    );
  }

  void _saveChanges() {
    appController.changeMenuItemsWithUndo(
      widget.controller,
      oldItems: originalItems,
      newItems: editableItems,
    );
    Get.back();
  }

  Widget _deleteBg(Alignment alignment) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: Colors.red,
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }

  void _addItem() {
    Get.bottomSheet(
      EditMenuItemSheet(
        onSave: (item) {
          setState(() => editableItems.add(item));
        },
      ),
      isScrollControlled: true,
    );
  }

  void _editItem(MenuItemModel item, int index) {
    Get.bottomSheet(
      EditMenuItemSheet(
        initialItem: item.clone(),
        onSave: (updated) {
          setState(() => editableItems[index] = updated);
        },
      ),
      isScrollControlled: true,
    );
  }
}

class MenuRow extends StatelessWidget {
  final MenuItemModel item;
  final VoidCallback onEdit;

  const MenuRow({super.key, required this.item, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        item.itemName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),

      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.description.isNotEmpty) Text(item.description),
          const SizedBox(height: 4),
          Row(
            children: item.values.entries.map((e) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text("${e.key}: ${e.value}"),
              );
            }).toList(),
          ),
        ],
      ),

      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
          const Icon(Icons.drag_handle),
        ],
      ),
    );
  }
}
