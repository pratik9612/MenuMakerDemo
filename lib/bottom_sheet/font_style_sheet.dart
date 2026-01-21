import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FontStyleSheet extends StatefulWidget {
  final List<String> fonts;
  final String initialFont;
  final ValueChanged<String> onPreview;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const FontStyleSheet({
    super.key,
    required this.fonts,
    required this.initialFont,
    required this.onPreview,
    required this.onCancel,
    required this.onSave,
  });

  @override
  State<FontStyleSheet> createState() => _FontStyleSheetState();
}

class _FontStyleSheetState extends State<FontStyleSheet> {
  final RxString _search = ''.obs;
  late RxString _selectedFont;

  @override
  void initState() {
    super.initState();
    _selectedFont = widget.initialFont.obs;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 80),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            /// Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onCancel,
                ),
                const Text(
                  "Choose Font",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: widget.onSave,
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// Search
            TextField(
              decoration: const InputDecoration(
                hintText: "Search",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _search.value = value.toLowerCase(),
            ),

            const SizedBox(height: 12),

            /// Font List
            Expanded(
              child: SingleChildScrollView(
                child: Obx(
                  () => Column(
                    children: widget.fonts.map((font) {
                      final isSelected = font == _selectedFont.value;

                      return GestureDetector(
                        onTap: () {
                          _selectedFont.value = font;
                          widget.onPreview(font);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.blue.withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.blue
                                  : Colors.grey.shade300,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  font,
                                  style: TextStyle(
                                    fontFamily: font,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check, color: Colors.blue),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
