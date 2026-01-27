import 'package:flutter/material.dart';

class ChangeImageSheet extends StatelessWidget {
  final VoidCallback onGallery;
  final VoidCallback onFile;
  final VoidCallback onCamera;

  const ChangeImageSheet({
    super.key,
    required this.onGallery,
    required this.onFile,
    required this.onCamera,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Choose Image", style: TextStyle(fontSize: 18)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildItem(Icons.image, "Gallery", onGallery),
              _buildItem(Icons.folder, "File", onFile),
              _buildItem(Icons.camera_alt, "Camera", onCamera),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItem(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 32),
          const SizedBox(height: 6),
          Text(title),
        ],
      ),
    );
  }
}
