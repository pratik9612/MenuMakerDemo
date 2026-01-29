import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_maker_demo/model/editing_element_model.dart';

class EditMenuItemSheet extends StatefulWidget {
  final MenuItemModel? initialItem;
  final ValueChanged<MenuItemModel> onSave;

  const EditMenuItemSheet({super.key, this.initialItem, required this.onSave});

  @override
  State<EditMenuItemSheet> createState() => _EditMenuItemSheetState();
}

class _EditMenuItemSheetState extends State<EditMenuItemSheet> {
  late TextEditingController nameCtrl;
  late TextEditingController descCtrl;
  late List<TextEditingController> costCtrls;

  @override
  void initState() {
    super.initState();

    nameCtrl = TextEditingController(text: widget.initialItem?.itemName ?? "");
    descCtrl = TextEditingController(
      text: widget.initialItem?.description ?? "",
    );

    final costs = widget.initialItem?.values.values.toList() ?? [''];
    costCtrls = costs.map((e) => TextEditingController(text: e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _header(),
            _field("Item Name", nameCtrl),
            _field("Item Description", descCtrl, maxLines: 2),
            _costSection(),
            const SizedBox(height: 16),
            _saveButton(),
          ],
        ),
      ),
    );
  }

  Widget _header() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        widget.initialItem == null ? "Add Item" : "Edit Item",
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      IconButton(icon: const Icon(Icons.close), onPressed: Get.back),
    ],
  );

  Widget _field(String label, TextEditingController c, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _costSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Item Costs",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...List.generate(costCtrls.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: costCtrls[i],
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: "Add cost",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  if (i == costCtrls.length - 1)
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          costCtrls.add(TextEditingController());
                        });
                      },
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _saveButton() => SizedBox(
    width: double.infinity,
    height: 48,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
      onPressed: _onSave,
      child: const Text("Save", style: TextStyle(fontWeight: FontWeight.bold)),
    ),
  );

  void _onSave() {
    final Map<String, String> values = {};

    for (int i = 0; i < costCtrls.length; i++) {
      final v = costCtrls[i].text.trim();
      if (v.isNotEmpty) {
        values['${i + 1}'] = v;
      }
    }

    widget.onSave(
      MenuItemModel(
        itemName: nameCtrl.text.trim(),
        description: descCtrl.text.trim(),
        values: values,
      ),
    );

    Get.back();
  }
}
