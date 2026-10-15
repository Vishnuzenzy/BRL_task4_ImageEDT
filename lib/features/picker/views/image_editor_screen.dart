
import 'dart:io';

import 'package:flutter/material.dart';

class ImageEditorScreen extends StatelessWidget {
  final String imagePath;

  const ImageEditorScreen({
    super.key,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FF),
      appBar: AppBar(
        title: const Text('Edit Photo'),
        backgroundColor: const Color(0xFFF7F7FF),
        foregroundColor: const Color(0xFF30216F),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Save feature coming soon'),
                ),
              );
            },
            child: const Text('Done'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4,
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text('Unable to display this image.');
                  },
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 12,
            ),
            color: Colors.white,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _EditorTool(
                  icon: Icons.crop,
                  label: 'Crop',
                ),
                _EditorTool(
                  icon: Icons.tune,
                  label: 'Adjust',
                ),
                _EditorTool(
                  icon: Icons.filter_vintage,
                  label: 'Filters',
                ),
                _EditorTool(
                  icon: Icons.rotate_right,
                  label: 'Rotate',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditorTool extends StatelessWidget {
  final IconData icon;
  final String label;

  const _EditorTool({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF4F46E5), size: 27),
        const SizedBox(height: 7),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF30216F),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
