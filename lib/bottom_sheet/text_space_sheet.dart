import 'package:flutter/material.dart';

class TextSpacingSheet extends StatefulWidget {
  final String title;
  final double min;
  final double max;
  final double initialValue;
  final ValueChanged<double> onPreview;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const TextSpacingSheet({
    super.key,
    required this.title,
    required this.min,
    required this.max,
    required this.initialValue,
    required this.onPreview,
    required this.onCancel,
    required this.onSave,
  });

  @override
  State<TextSpacingSheet> createState() => _TextSpacingSheetState();
}

class _TextSpacingSheetState extends State<TextSpacingSheet> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: widget.onCancel,
                icon: const Icon(Icons.close),
              ),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                onPressed: widget.onSave,
                icon: const Icon(Icons.check),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(_value.toStringAsFixed(2)),

          Slider(
            min: widget.min,
            max: widget.max,
            value: _value,
            onChanged: (v) {
              setState(() => _value = v);
              widget.onPreview(v);
            },
          ),
        ],
      ),
    );
  }
}
