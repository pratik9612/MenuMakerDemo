import 'package:flutter/material.dart';
import 'package:menu_maker_demo/bottom_sheet/text_sheet.dart';

enum AddPageToolAction { addPage, copy, delete, cancel, save }

class PageAddSheet extends StatelessWidget {
  final void Function(AddPageToolAction action) onAction;
  const PageAddSheet({super.key, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              SheetIcon(
                "Add Page",
                onTap: () => onAction(AddPageToolAction.addPage),
              ),
              SheetIcon("Copy", onTap: () => onAction(AddPageToolAction.copy)),
              SheetIcon(
                "Delete",
                onTap: () => onAction(AddPageToolAction.delete),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => onAction(AddPageToolAction.cancel),
                  child: const Text("Cancel"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => onAction(AddPageToolAction.save),
                  child: const Text("Apply"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
