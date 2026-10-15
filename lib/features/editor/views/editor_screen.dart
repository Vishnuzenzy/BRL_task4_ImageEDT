import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/crop_rotate_service.dart';
import '../viewmodels/editor_notifier.dart';

class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  final CropRotateService _cropService = CropRotateService();

  bool _isCropping = false;

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

  @override
  Widget build(BuildContext context) {
    final editorState = ref.watch(editorProvider);
    final imageBytes = editorState.current;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Editor'),
        actions: [
          IconButton(
            tooltip: 'Reset image',
            onPressed: imageBytes == null || _isCropping ? null : _resetImage,
            icon: const Icon(Icons.restart_alt),
          ),
        ],
      ),
      body: imageBytes == null
          ? const Center(
              child: Text('No image selected. Return and choose an image.'),
            )
          : Column(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Center(
                      child: RotatedBox(
                        quarterTurns: editorState.edits.quarterTurns,
                        child: Image.memory(
                          imageBytes,
                          fit: BoxFit.contain,
                          gaplessPlayback: true,
                          errorBuilder: (context, error, stackTrace) {
                            return const Padding(
                              padding: EdgeInsets.all(24),
                              child: Text('Unable to display this image.'),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FilledButton.icon(
                        onPressed: _isCropping ? null : _cropImage,
                        icon: _isCropping
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.crop),
                        label: Text(
                          _isCropping ? 'Opening crop toolâ€¦' : 'Crop Image',
                        ),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(

                        onPressed: _isCropping
    ? null
    : () {
        ref.read(editorProvider.notifier).rotateRight();
      },
                        icon: const Icon(Icons.rotate_right),
                        label: const Text('Rotate Right'),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose Crop Image to adjust the frame. '
                        'Cancel keeps the current image unchanged.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
