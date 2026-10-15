import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
 
import '../../export/data/export_service.dart';
import '../../export/data/image_renderer.dart';
import '../data/color_matrix.dart';
import '../data/crop_rotate_service.dart';
import '../viewmodels/editor_notifier.dart';
import 'panels/adjust_panel.dart';
import 'panels/filter_panel.dart';
 
class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key});
 
  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}
 
class _EditorScreenState extends ConsumerState<EditorScreen> {
  static const Color _bg = Color(0xFF232323);
  static const Color _bar = Color(0xFF242424);
 
  final CropRotateService _cropService = CropRotateService();
  final ImageRenderer _renderer = ImageRenderer();
  final ExportService _exportService = ExportService();
 
  bool _isCropping = false;
  bool _isExporting = false;
 
  Future<void> _cropImage() async {
    final imageBytes = ref.read(editorProvider).current;
 
    if (imageBytes == null || _isCropping) return;
 
    setState(() => _isCropping = true);
 
    try {
      final croppedBytes = await _cropService.crop(
        imageBytes,
        context: context,
      );
 
      if (!mounted) return;
 
      if (croppedBytes != null) {
        ref.read(editorProvider.notifier).applyCrop(croppedBytes);
 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image cropped successfully')),
        );
      }
    } catch (error) {
      if (!mounted) return;
 
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not crop image: $error')));
    } finally {
      if (mounted) {
        setState(() => _isCropping = false);
      }
    }
  }
 
  void _resetImage() {
    ref.read(editorProvider.notifier).reset();
 
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Image reset to original')));
  }
 
  Future<void> _export() async {
    final state = ref.read(editorProvider);
    final bytes = state.current;
 
    if (bytes == null || _isExporting) return;
 
    setState(() => _isExporting = true);
 
    try {
      final rendered = await _renderer.render(bytes, state.edits);
      final result = await _exportService.save(rendered);
 
      if (!mounted) return;
 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor:
              result.success ? Colors.green.shade700 : Colors.red.shade700,
        ),
      );
    } catch (error) {
      if (!mounted) return;
 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not process the image: $error'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }
 
  @override
  Widget build(BuildContext context) {
    final editorState = ref.watch(editorProvider);
    final imageBytes = editorState.current;
    final edits = editorState.edits;
    final busy = _isCropping || _isExporting;
 
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Reset image',
            onPressed: imageBytes == null || busy ? null : _resetImage,
            icon: const Icon(Icons.restart_alt),
          ),
          TextButton(
            onPressed: imageBytes == null || busy ? null : _export,
            child: const Text(
              'Export',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      ),
      body: imageBytes == null
          ? const Center(
              child: Text(
                'No image selected. Return and choose an image.',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: InteractiveViewer(
                          minScale: 0.5,
                          maxScale: 4,
                          child: RotatedBox(
                            quarterTurns: edits.quarterTurns,
                            child: ColorFiltered(
                              colorFilter: ColorFilter.matrix(
                                buildColorMatrix(edits),
                              ),
                              child: Image.memory(
                                imageBytes,
                                fit: BoxFit.contain,
                                gaplessPlayback: true,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Padding(
                                    padding: EdgeInsets.all(24),
                                    child: Text(
                                      'Unable to display this image.',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (busy)
                        Container(
                          color: Colors.black38,
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(
                                color: Colors.white,
                              ),
                              if (_isExporting) ...[
                                const SizedBox(height: 12),
                                const Text(
                                  'Saving…',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  color: _bar,
                  padding: const EdgeInsets.fromLTRB(8, 14, 8, 8),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _ToolButton(
                          icon: Icons.crop,
                          label: 'Crop',
                          onTap: busy ? null : _cropImage,
                        ),
                        _ToolButton(
                          icon: Icons.tune,
                          label: 'Adjust',
                          onTap: busy ? null : () => showAdjustPanel(context),
                        ),
                        _ToolButton(
                          icon: Icons.filter_vintage,
                          label: 'Filters',
                          onTap: busy ? null : () => showFilterPanel(context),
                        ),
                        _ToolButton(
                          icon: Icons.rotate_left,
                          label: 'Left',
                          onTap: busy
                              ? null
                              : () => ref
                                  .read(editorProvider.notifier)
                                  .rotateLeft(),
                        ),
                        _ToolButton(
                          icon: Icons.rotate_right,
                          label: 'Right',
                          onTap: busy
                              ? null
                              : () => ref
                                  .read(editorProvider.notifier)
                                  .rotateRight(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
 
class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
 
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
 
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Opacity(
        opacity: onTap == null ? 0.4 : 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
 