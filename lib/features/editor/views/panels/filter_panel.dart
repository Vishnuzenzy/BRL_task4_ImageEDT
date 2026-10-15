import 'dart:typed_data';
 
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
 
import '../../data/color_matrix.dart';
import '../../models/edit_state.dart';
import '../../viewmodels/editor_notifier.dart';
 
/// Opens the Filters panel (Original, Warm, Cool, Vintage).
void showFilterPanel(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFF242424),
    barrierColor: Colors.transparent,
    builder: (_) => const FilterPanel(),
  );
}
 
class FilterPanel extends ConsumerWidget {
  const FilterPanel({super.key});
 
  static const _names = {
    FilterPreset.original: 'Original',
    FilterPreset.warm: 'Warm',
    FilterPreset.cool: 'Cool',
    FilterPreset.vintage: 'Vintage',
  };
 
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(editorProvider);
    final notifier = ref.read(editorProvider.notifier);
    final bytes = state.current;
 
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 110,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final preset in FilterPreset.values)
                    _FilterTile(
                      label: _names[preset]!,
                      selected: state.edits.filter == preset,
                      matrix: buildColorMatrix(EditState(filter: preset)),
                      bytes: bytes,
                      onTap: () => notifier.setFilter(preset),
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
 
class _FilterTile extends StatelessWidget {
  const _FilterTile({
    required this.label,
    required this.selected,
    required this.matrix,
    required this.bytes,
    required this.onTap,
  });
 
  final String label;
  final bool selected;
  final List<double> matrix;
  final Uint8List? bytes;
  final VoidCallback onTap;
 
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 78,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? const Color(0xFF9B8CFF) : Colors.transparent,
                  width: 3,
                ),
                color: Colors.black26,
              ),
              clipBehavior: Clip.antiAlias,
              child: bytes == null
                  ? null
                  : ColorFiltered(
                      colorFilter: ColorFilter.matrix(matrix),
                      child: Image.memory(
                        bytes!,
                        fit: BoxFit.cover,
                        cacheWidth: 160, // small thumbnail, saves memory
                      ),
                    ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.white70,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 