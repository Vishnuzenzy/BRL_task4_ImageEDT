import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/picker_viewmodel.dart';

class ImagePickerScreen extends ConsumerWidget {
  const ImagePickerScreen({super.key});

  static const Color primary = Color(0xFF4F46E5);
  static const Color background = Color(0xFFF7F7FF);
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF172033);
  static const Color secondary = Color(0xFF777D91);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pickerViewModelProvider);
    final viewModel = ref.read(pickerViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 21,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'PixelCraft',
              style: TextStyle(
                color: textColor,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _showComingSoon(context, 'History'),
            icon: const Icon(Icons.history_rounded),
            color: textColor,
          ),
          IconButton(
            onPressed: () => _showComingSoon(context, 'Settings'),
            icon: const Icon(Icons.tune_rounded),
            color: textColor,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
          children: [
            const Text(
              'Your creative space',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Choose a photo and make it yours.',
              style: TextStyle(
                color: secondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 22),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.photo_library_outlined,
                        color: primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Selected photo',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (state.selectedImage != null)
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: viewModel.clearImage,
                          icon: const Icon(Icons.close_rounded),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: AspectRatio(
                      aspectRatio: 1.05,
                      child: state.selectedImage == null
                          ? Container(
                        color: const Color(0xFFEEEEFF),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 76,
                              width: 76,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(23),
                              ),
                              child: const Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 42,
                                color: primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Your next masterpiece starts here',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Select an image from your gallery',
                              style: TextStyle(
                                color: secondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                          : Image.file(
                        File(state.selectedImage!.path),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: 48,
                            color: secondary,
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (state.selectedImage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      state.selectedImage!.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],

                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton.icon(
                      onPressed: state.isPicking
                          ? null
                          : viewModel.pickImage,
                      style: FilledButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      icon: state.isPicking
                          ? const SizedBox(
                        height: 19,
                        width: 19,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Icon(Icons.auto_awesome_rounded),
                      label: Text(
                        state.isPicking
                            ? 'Opening Gallery...'
                            : state.selectedImage == null
                            ? 'Open Gallery'
                            : 'Choose Another Photo',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  if (state.errorMessage != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      state.errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Quick tools',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _ToolCard(
                    icon: Icons.crop_rotate_rounded,
                    title: 'Crop & Rotate',
                    subtitle: 'Frame your photo',
                    onTap: () => _showComingSoon(context, 'Crop & Rotate'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ToolCard(
                    icon: Icons.tune_rounded,
                    title: 'Adjust',
                    subtitle: 'Light and color',
                    onTap: () => _showComingSoon(context, 'Adjust & Filters'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _ToolCard(
                    icon: Icons.palette_outlined,
                    title: 'Filters',
                    subtitle: 'Find your style',
                    onTap: () => _showComingSoon(context, 'Filters'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ToolCard(
                    icon: Icons.save_alt_rounded,
                    title: 'Export',
                    subtitle: 'Save your result',
                    onTap: () => _showComingSoon(context, 'Export'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: primary,
        unselectedItemColor: secondary,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        currentIndex: 0,
        elevation: 10,
        onTap: (index) {
          if (index != 0) {
            const labels = ['Import', 'Adjust', 'Crop', 'History'];
            _showComingSoon(context, labels[index]);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library_outlined),
            activeIcon: Icon(Icons.photo_library_rounded),
            label: 'Import',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tune_rounded),
            label: 'Adjust',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.crop_rounded),
            label: 'Crop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'History',
          ),
        ],
      ),
    );
  }

  static void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature will be connected in the next step.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEEFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: ImagePickerScreen.primary,
                  size: 22,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: ImagePickerScreen.textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: ImagePickerScreen.secondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}