import 'package:flutter/material.dart';
 
import '../../picker/views/image_picker_screen.dart';
 
/// Home dashboard shown when the app opens.
/// Later: show the signed-in user's name here (Firebase login).
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
 
  static const Color primary = Color(0xFF4F46E5);
  static const Color background = Color(0xFFEDE9FF);
  static const Color darkText = Color(0xFF30216F);
  static const Color mutedText = Color(0xFF7776AD);
 
  void _openEditor(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ImagePickerScreen()),
    );
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            // Header
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, creator 👋',
                        style: TextStyle(fontSize: 14, color: mutedText),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'ImageEDT',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: darkText,
                        ),
                      ),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.person_outline, color: primary),
                ),
              ],
            ),
            const SizedBox(height: 24),
 
            // Primary action
            Material(
              color: primary,
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => _openEditor(context),
                child: const Padding(
                  padding: EdgeInsets.all(22),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Start a new edit',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Pick a photo from your gallery',
                              style: TextStyle(color: Color(0xFFD9D6FF)),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.add_photo_alternate_outlined,
                          color: Colors.white, size: 40),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
 
            // Quick tools
            const Text(
              'Quick tools',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: darkText,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _ToolCard(
                  icon: Icons.crop,
                  label: 'Crop',
                  color: const Color(0xFFDCE6FF),
                  iconColor: const Color(0xFF7866EF),
                  onTap: () => _openEditor(context),
                ),
                _ToolCard(
                  icon: Icons.rotate_right,
                  label: 'Rotate',
                  color: const Color(0xFFFFF0D7),
                  iconColor: const Color(0xFFFFA62B),
                  onTap: () => _openEditor(context),
                ),
                _ToolCard(
                  icon: Icons.tune,
                  label: 'Adjust',
                  color: const Color(0xFFFFDFF2),
                  iconColor: const Color(0xFFDC65C2),
                  onTap: () => _openEditor(context),
                ),
                _ToolCard(
                  icon: Icons.filter_b_and_w,
                  label: 'Grayscale',
                  color: const Color(0xFFE3F5E8),
                  iconColor: const Color(0xFF3BA55D),
                  onTap: () => _openEditor(context),
                ),
              ],
            ),
            const SizedBox(height: 28),
 
            // Recent edits (empty state for now)
            const Text(
              'Recent edits',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: darkText,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                children: [
                  Icon(Icons.photo_library_outlined,
                      size: 36, color: mutedText),
                  SizedBox(height: 8),
                  Text(
                    'No edits yet',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: darkText),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Your saved photos will appear here',
                    style: TextStyle(color: mutedText, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 
class _ToolCard extends StatelessWidget {
  const _ToolCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });
 
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;
 
  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: iconColor, size: 30),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: DashboardScreen.darkText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
 s