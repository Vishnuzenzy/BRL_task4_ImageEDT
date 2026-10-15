import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../auth/data/auth_service.dart';
import '../../auth/views/welcome_screen.dart';
import '../../editor/viewmodels/editor_notifier.dart';
import '../../editor/views/editor_screen.dart';
import '../viewmodels/picker_viewmodel.dart';

class ImagePickerScreen extends ConsumerWidget {
  const ImagePickerScreen({super.key});

  static const Color primary = Color(0xFF4F46E5);
  static const Color background = Color(0xFFEDE9FF);
  static const Color darkText = Color(0xFF30216F);
  static const Color mutedText = Color(0xFF7776AD);

  Future<void> _selectAndEditImage(
    BuildContext context,
    WidgetRef ref,
    ImageSource source,
  ) async {
    try {
      final image = await ref
          .read(pickerViewModelProvider.notifier)
          .pickImage(source);

      if (!context.mounted || image == null) return;

      final bytes = await image.file.readAsBytes();

      if (!context.mounted) return;

      ref.read(editorProvider.notifier).loadImage(bytes);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const EditorScreen()),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Unable to select image: $e')));
    }
  }

  // Account menu: shows the signed-in email and a Log out button.
  void _showAccountSheet(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? 'Signed in';
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(email),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log out'),
              onTap: () async {
                Navigator.pop(sheetContext);
                await AuthService().signOut();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pickerViewModelProvider);
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          // Decorative background circles
          Positioned(
            top: -100,
            left: -100,
            child: _circle(250, const Color(0xFFD4C5FF)),
          ),
          Positioned(
            right: -120,
            top: 280,
            child: _circle(240, const Color(0xFFDAD0FF)),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: _circle(220, const Color(0xFFDCD2FF)),
          ),

          // Scrollable content prevents vertical overflow
          SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'ImageEDT',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: size.width * 0.073,
                                    fontWeight: FontWeight.w800,
                                    color: darkText,
                                    letterSpacing: -1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 7),
                              const Icon(
                                Icons.auto_awesome,
                                color: Color(0xFF9B68FF),
                                size: 30,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => _showAccountSheet(context),
                          icon: const Icon(
                            Icons.settings,
                            color: darkText,
                            size: 31,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Subtitle
                    const Text(
                      'Turn your moments\ninto something beautiful ✨',
                      style: TextStyle(
                        fontSize: 20,
                        height: 1.5,
                        color: mutedText,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Create New
                    const Text(
                      'CREATE NEW',
                      style: TextStyle(
                        fontSize: 22,
                        color: darkText,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Camera, Photo and Collage panel
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(12, 28, 12, 24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.82),
                        borderRadius: BorderRadius.circular(34),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _createOption(
                              icon: Icons.camera_alt_outlined,
                              label: 'Camera',
                              color: const Color(0xFFBA8AFF),
                              onTap: state.isPicking
                                  ? null
                                  : () => _selectAndEditImage(
                                      context,
                                      ref,
                                      ImageSource.camera,
                                    ),
                            ),
                          ),
                          Expanded(
                            child: _createOption(
                              icon: Icons.image_outlined,
                              label: 'Photo',
                              color: const Color(0xFFF46D9B),
                              onTap: state.isPicking
                                  ? null
                                  : () => _selectAndEditImage(
                                      context,
                                      ref,
                                      ImageSource.gallery,
                                    ),
                            ),
                          ),
                          Expanded(
                            child: _createOption(
                              icon: Icons.dashboard_customize_outlined,
                              label: 'Collage',
                              color: const Color(0xFFFF9865),
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Collage feature coming soon!',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Show picker errors without adding a permanent section
                    if (state.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        state.errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ],

                    const SizedBox(height: 44),

                    // What's New heading
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Flexible(
                          child: Text(
                            'WHAT’S NEW',
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 22,
                              color: darkText,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('More features coming soon'),
                              ),
                            );
                          },
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'ALL',
                                style: TextStyle(
                                  fontSize: 19,
                                  color: mutedText,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: mutedText,
                                size: 28,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Equal-width feature cards
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _featureCard(
                            title: 'Filters',
                            subtitle: 'Give your photos\na new vibe',
                            color: const Color(0xFFDCE6FF),
                            illustration: const Icon(
                              Icons.tune,
                              size: 52,
                              color: Color(0xFF7866EF),
                            ),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Filters coming soon'),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _featureCard(
                            title: 'Stickers',
                            subtitle: 'Add fun to\nyour pictures',
                            color: const Color(0xFFFFF0D7),
                            illustration: const Icon(
                              Icons.emoji_emotions,
                              size: 52,
                              color: Color(0xFFFFA62B),
                            ),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Stickers coming soon'),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _featureCard(
                            title: 'Templates',
                            subtitle: 'Ready to use\ncreative layouts',
                            color: const Color(0xFFFFDFF2),
                            illustration: const Icon(
                              Icons.photo_library_outlined,
                              size: 52,
                              color: Color(0xFFDC65C2),
                            ),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Templates coming soon'),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),

          // Loading spinner overlays the screen instead of
          // increasing the height of the main Column.
          if (state.isPicking)
            Positioned.fill(
              child: Container(
                color: Colors.white.withValues(alpha: 0.15),
                child: const Center(
                  child: CircularProgressIndicator(color: primary),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Decorative circle
  Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.42),
        shape: BoxShape.circle,
      ),
    );
  }

  // Create New option button
  Widget _createOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return Opacity(
      opacity: onTap == null ? 0.6 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color.withValues(alpha: 0.78), color],
                ),
              ),
              child: Icon(icon, color: Colors.white, size: 51),
            ),
            const SizedBox(height: 20),
            Text(
              label,
              style: const TextStyle(
                fontSize: 19,
                color: mutedText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Equal-sized feature cards
  Widget _featureCard({
    required String title,
    required String subtitle,
    required Color color,
    required Widget illustration,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 180,
      child: Material(
        color: color.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: Center(child: illustration),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    color: darkText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: mutedText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
