import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
 
import '../../viewmodels/editor_notifier.dart';
 
/// Opens the Adjust panel (brightness, contrast, saturation, grayscale).
/// The barrier is transparent so the photo stays visible while sliding.
void showAdjustPanel(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFF242424),
    barrierColor: Colors.transparent,
    builder: (_) => const AdjustPanel(),
  );
}
 
class AdjustPanel extends ConsumerWidget {
  const AdjustPanel({super.key});
 
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final edits = ref.watch(editorProvider).edits;
    final notifier = ref.read(editorProvider.notifier);
 
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text(
                  'Adjust',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    notifier.setBrightness(0);
                    notifier.setContrast(1);
                    notifier.setSaturation(1);
                    if (edits.grayscale) notifier.toggleGrayscale();
                  },
                  child: const Text('Reset'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ],
            ),
            _SliderRow(
              icon: Icons.wb_sunny_outlined,
              label: 'Brightness',
              value: edits.brightness,
              min: -1,
              max: 1,
              onChanged: notifier.setBrightness,
            ),
            _SliderRow(
              icon: Icons.contrast,
              label: 'Contrast',
              value: edits.contrast,
              min: 0.5,
              max: 1.5,
              onChanged: notifier.setContrast,
            ),
            _SliderRow(
              icon: Icons.color_lens_outlined,
              label: 'Saturation',
              value: edits.saturation,
              min: 0,
              max: 2,
              onChanged: notifier.setSaturation,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Grayscale',
                style: TextStyle(color: Colors.white),
              ),
              secondary:
                  const Icon(Icons.filter_b_and_w, color: Colors.white70),
              value: edits.grayscale,
              onChanged: (_) => notifier.toggleGrayscale(),
            ),
          ],
        ),
      ),
    );
  }
}
 
class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });
 
  final IconData icon;
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
 
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 22),
        const SizedBox(width: 10),
        SizedBox(
          width: 82,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
        Expanded(
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
 