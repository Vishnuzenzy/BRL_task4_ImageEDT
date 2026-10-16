import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:image_cropper/image_cropper.dart';

class ImageEditorScreen extends StatefulWidget {
  final String imagePath;

  const ImageEditorScreen({
    super.key,
    required this.imagePath,
  });

  @override
  State<ImageEditorScreen> createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> {
  bool isPreview = false;
  bool isExporting = false;

  final GlobalKey _exportKey = GlobalKey();

  String selectedFilter = 'Original';
  String selectedEffect = 'None';
  String? croppedImagePath;
  int rotationTurns = 0;

  double brightness = 0;
  double contrast = 1;
  double saturation = 1;
  double exposure = 0;
  double warmth = 0;
  double sharpness = 0;

  final Map<String, List<double>> filterMatrices = {
    'Original': [
      1, 0, 0, 0, 0,
      0, 1, 0, 0, 0,
      0, 0, 1, 0, 0,
      0, 0, 0, 1, 0,
    ],
    'B&W': [
      0.213, 0.715, 0.072, 0, 0,
      0.213, 0.715, 0.072, 0, 0,
      0.213, 0.715, 0.072, 0, 0,
      0, 0, 0, 1, 0,
    ],
    'Vintage': [
      0.9, 0.2, 0.1, 0, 10,
      0.1, 0.8, 0.1, 0, 5,
      0.1, 0.2, 0.7, 0, 0,
      0, 0, 0, 1, 0,
    ],
    'Warm': [
      1.1, 0, 0, 0, 10,
      0, 1, 0, 0, 0,
      0, 0, 0.8, 0, 0,
      0, 0, 0, 1, 0,
    ],
    'Cool': [
      0.9, 0, 0, 0, 0,
      0, 1, 0, 0, 0,
      0, 0, 1.1, 0, 10,
      0, 0, 0, 1, 0,
    ],
    'Sepia': [
      0.393, 0.769, 0.189, 0, 0,
      0.349, 0.686, 0.168, 0, 0,
      0.272, 0.534, 0.131, 0, 0,
      0, 0, 0, 1, 0,
    ],
  };

  static const List<String> effects = [
    'None',
    'Noise',
    'TV',
    'RGB',
    'Ghost',
    'Glitch',
    'VHS',
    'Neon',
  ];

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> exportImage() async {
    if (isExporting) return;

    setState(() {
      isExporting = true;
    });

    try {
      if (!await Gal.hasAccess()) {
        final granted = await Gal.requestAccess();

        if (!granted) {
          throw Exception('Gallery permission denied');
        }
      }

      await WidgetsBinding.instance.endOfFrame;

      final boundary = _exportKey.currentContext?.findRenderObject()
      as RenderRepaintBoundary?;

      if (boundary == null) {
        throw Exception('Unable to capture image');
      }

      final image = await boundary.toImage(pixelRatio: 3);

      try {
        final byteData = await image.toByteData(
          format: ui.ImageByteFormat.png,
        );

        if (byteData == null) {
          throw Exception('Unable to create image');
        }

        await Gal.putImageBytes(
          byteData.buffer.asUint8List(),
          name: 'ImageEDT_${DateTime.now().millisecondsSinceEpoch}',
        );
      } finally {
        image.dispose();
      }

      if (mounted) {
        showMessage('Image saved to gallery!');
      }
    } catch (e) {
      if (mounted) {
        showMessage('Export failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          isExporting = false;
        });
      }
    }
  }

  void resetAdjustments() {
    setState(() {
      brightness = 0;
      contrast = 1;
      saturation = 1;
      exposure = 0;
      warmth = 0;
      sharpness = 0;
    });
  }

  void resetEditor() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF242424),
          title: const Text(
            'Reset Editor?',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to remove all edits and restore the original image?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD8B4FE),
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                setState(() {
                  isPreview = false;
                  selectedFilter = 'Original';
                  selectedEffect = 'None';
                  croppedImagePath = null;
                  rotationTurns = 0;
                  brightness = 0;
                  contrast = 1;
                  saturation = 1;
                  exposure = 0;
                  warmth = 0;
                  sharpness = 0;
                });

                Navigator.pop(dialogContext);
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  Future<void> cropImage() async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: croppedImagePath ?? widget.imagePath,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: const Color(0xFF242424),
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: const Color(0xFFD8B4FE),
            backgroundColor: const Color(0xFF232323),
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioLockEnabled: false,
          ),
        ],
      );

      if (!mounted) return;

      if (croppedFile != null) {
        setState(() {
          croppedImagePath = croppedFile.path;
          isPreview = false;
        });
      }
    } catch (e) {
      if (mounted) {
        showMessage('Unable to crop image');
      }
    }
  }

  void openAdjustPanel() {
    String activeAdjustment = 'Brightness';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: const Color(0xFF242424),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final screenHeight = MediaQuery.of(sheetContext).size.height;

            final adjustments = <String, Map<String, dynamic>>{
              'Brightness': {
                'icon': Icons.brightness_6_outlined,
                'value': brightness,
                'min': -1.0,
                'max': 1.0,
                'display': '${(brightness * 100).round()}%',
              },
              'Contrast': {
                'icon': Icons.contrast,
                'value': contrast,
                'min': 0.0,
                'max': 2.0,
                'display': '${(contrast * 100).round()}%',
              },
              'Saturation': {
                'icon': Icons.color_lens_outlined,
                'value': saturation,
                'min': 0.0,
                'max': 2.0,
                'display': '${(saturation * 100).round()}%',
              },
              'Exposure': {
                'icon': Icons.exposure,
                'value': exposure,
                'min': -1.0,
                'max': 1.0,
                'display': exposure.toStringAsFixed(2),
              },
              'Warmth': {
                'icon': Icons.thermostat,
                'value': warmth,
                'min': -1.0,
                'max': 1.0,
                'display': warmth.toStringAsFixed(2),
              },
              'Sharpness': {
                'icon': Icons.details,
                'value': sharpness,
                'min': 0.0,
                'max': 1.0,
                'display': '${(sharpness * 100).round()}%',
              },
            };

            void changeAdjustment(String name, double value) {
              setState(() {
                switch (name) {
                  case 'Brightness':
                    brightness = value;
                    break;
                  case 'Contrast':
                    contrast = value;
                    break;
                  case 'Saturation':
                    saturation = value;
                    break;
                  case 'Exposure':
                    exposure = value;
                    break;
                  case 'Warmth':
                    warmth = value;
                    break;
                  case 'Sharpness':
                    sharpness = value;
                    break;
                }
                isPreview = false;
              });

              setSheetState(() {});
            }

            void resetOneAdjustment(String name) {
              setState(() {
                switch (name) {
                  case 'Brightness':
                    brightness = 0;
                    break;
                  case 'Contrast':
                    contrast = 1;
                    break;
                  case 'Saturation':
                    saturation = 1;
                    break;
                  case 'Exposure':
                    exposure = 0;
                    break;
                  case 'Warmth':
                    warmth = 0;
                    break;
                  case 'Sharpness':
                    sharpness = 0;
                    break;
                }
              });

              setSheetState(() {});
            }

            final current = adjustments[activeAdjustment]!;

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white30,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Adjust Image',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          resetAdjustments();
                          setSheetState(() {});
                        },
                        child: const Text(
                          'Reset All',
                          style: TextStyle(
                            color: Color(0xFFD8B4FE),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(
                          Icons.check,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: screenHeight * 0.27,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF181818),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Center(
                      child: InteractiveViewer(
                        minScale: 1,
                        maxScale: 3,
                        child: _buildImagePreview(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 76,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: adjustments.entries.map((entry) {
                        final selected = activeAdjustment == entry.key;

                        return GestureDetector(
                          onTap: () {
                            setSheetState(() {
                              activeAdjustment = entry.key;
                            });
                          },
                          child: SizedBox(
                            width: 76,
                            child: Column(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? const Color(0xFFD8B4FE)
                                        : const Color(0xFF383838),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: selected
                                          ? const Color(0xFFD8B4FE)
                                          : Colors.white12,
                                    ),
                                  ),
                                  child: Icon(
                                    entry.value['icon'] as IconData,
                                    color: selected
                                        ? Colors.black
                                        : Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  entry.key,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: selected
                                        ? const Color(0xFFD8B4FE)
                                        : Colors.white70,
                                    fontWeight: selected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          activeAdjustment,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        current['display'] as String,
                        style: const TextStyle(
                          color: Color(0xFFD8B4FE),
                          fontSize: 13,
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Reset $activeAdjustment',
                        onPressed: () {
                          resetOneAdjustment(activeAdjustment);
                        },
                        icon: const Icon(
                          Icons.restart_alt,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: (current['value'] as double).clamp(
                      current['min'] as double,
                      current['max'] as double,
                    ),
                    min: current['min'] as double,
                    max: current['max'] as double,
                    activeColor: const Color(0xFFD8B4FE),
                    inactiveColor: Colors.white12,
                    onChanged: (value) {
                      changeAdjustment(activeAdjustment, value);
                    },
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void openRotatePanel() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF242424),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Rotate Image',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              rotationTurns = (rotationTurns - 1) % 4;
                              isPreview = false;
                            });
                            setSheetState(() {});
                          },
                          icon: const Icon(
                            Icons.rotate_left,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 32),
                        Text(
                          '${(rotationTurns % 4) * 90}°',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 32),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              rotationTurns = (rotationTurns + 1) % 4;
                              isPreview = false;
                            });
                            setSheetState(() {});
                          },
                          icon: const Icon(
                            Icons.rotate_right,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD8B4FE),
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () => Navigator.pop(sheetContext),
                        child: const Text('Done'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void openFilterPanel() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF242424),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choose a filter for your image',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: filterMatrices.keys.map((filter) {
                    final isSelected = selectedFilter == filter;

                    return ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (!selected) return;
                        setState(() {
                          selectedFilter = filter;
                          isPreview = false;
                        });
                        Navigator.pop(sheetContext);
                      },
                      selectedColor: const Color(0xFFD8B4FE),
                      backgroundColor: const Color(0xFF383838),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFFD8B4FE)
                            : Colors.white24,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void openEffectPanel() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF242424),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Effects',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choose a creative effect for your image',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: effects.map((effect) {
                    final isSelected = selectedEffect == effect;

                    return ChoiceChip(
                      avatar: Icon(
                        _effectIcon(effect),
                        size: 17,
                        color: isSelected ? Colors.black : Colors.white70,
                      ),
                      label: Text(effect),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (!selected) return;
                        setState(() {
                          selectedEffect = effect;
                          isPreview = false;
                        });
                        Navigator.pop(sheetContext);
                      },
                      selectedColor: const Color(0xFFD8B4FE),
                      backgroundColor: const Color(0xFF383838),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFFD8B4FE)
                            : Colors.white24,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _effectIcon(String effect) {
    switch (effect) {
      case 'Noise':
        return Icons.grain;
      case 'TV':
        return Icons.tv;
      case 'RGB':
        return Icons.color_lens;
      case 'Ghost':
        return Icons.blur_on;
      case 'Glitch':
        return Icons.broken_image;
      case 'VHS':
        return Icons.videocam;
      case 'Neon':
        return Icons.flare;
      default:
        return Icons.image_outlined;
    }
  }

  Widget _image() {
    return Image.file(
      File(croppedImagePath ?? widget.imagePath),
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return const Center(
          child: Text(
            'Unable to display this image.',
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _tintedImage(List<double> matrix) {
    return ColorFiltered(
      colorFilter: ColorFilter.matrix(matrix),
      child: _image(),
    );
  }

  List<double> _adjustmentMatrix() {
    final exposureMultiplier = math.pow(2, exposure).toDouble();
    final c = contrast * exposureMultiplier;
    final s = saturation;
    final b = brightness * 255;
    final w = warmth * 35;

    const rLum = 0.213;
    const gLum = 0.715;
    const bLum = 0.072;

    final sr = (1 - s) * rLum;
    final sg = (1 - s) * gLum;
    final sb = (1 - s) * bLum;
    final offset = 128 * (1 - c) + b;

    return [
      (sr + s) * c,
      sg * c,
      sb * c,
      0,
      offset + w,
      sr * c,
      (sg + s) * c,
      sb * c,
      0,
      offset,
      sr * c,
      sg * c,
      (sb + s) * c,
      0,
      offset - w,
      0, 0, 0, 1, 0,
    ];
  }

  Widget _buildEffectImage() {
    switch (selectedEffect) {
      case 'Noise':
        return Stack(
          fit: StackFit.passthrough,
          children: [
            _image(),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _NoisePainter()),
              ),
            ),
          ],
        );

      case 'TV':
        return Stack(
          fit: StackFit.passthrough,
          children: [
            _image(),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _ScanlinePainter()),
              ),
            ),
          ],
        );

      case 'RGB':
        return Stack(
          fit: StackFit.passthrough,
          children: [
            _image(),
            Transform.translate(
              offset: const Offset(-4, 0),
              child: Opacity(
                opacity: 0.35,
                child: _tintedImage([
                  1, 0, 0, 0, 0,
                  0, 0, 0, 0, 0,
                  0, 0, 0, 0, 0,
                  0, 0, 0, 1, 0,
                ]),
              ),
            ),
            Transform.translate(
              offset: const Offset(4, 0),
              child: Opacity(
                opacity: 0.35,
                child: _tintedImage([
                  0, 0, 0, 0, 0,
                  0, 0, 0, 0, 0,
                  0, 0, 1, 0, 0,
                  0, 0, 0, 1, 0,
                ]),
              ),
            ),
          ],
        );

      case 'Ghost':
        return Stack(
          fit: StackFit.passthrough,
          children: [
            _image(),
            Transform.translate(
              offset: const Offset(8, -3),
              child: Opacity(
                opacity: 0.35,
                child: _image(),
              ),
            ),
          ],
        );

      case 'Glitch':
        return Stack(
          fit: StackFit.passthrough,
          children: [
            _image(),
            Transform.translate(
              offset: const Offset(-5, 2),
              child: Opacity(
                opacity: 0.5,
                child: _tintedImage([
                  1, 0, 0, 0, 0,
                  0, 0, 0, 0, 0,
                  0, 0, 0, 0, 0,
                  0, 0, 0, 1, 0,
                ]),
              ),
            ),
            Transform.translate(
              offset: const Offset(5, -2),
              child: Opacity(
                opacity: 0.5,
                child: _tintedImage([
                  0, 0, 0, 0, 0,
                  0, 0, 1, 0, 0,
                  0, 0, 0, 0, 0,
                  0, 0, 0, 1, 0,
                ]),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _ScanlinePainter(
                    spacing: 6,
                    opacity: 0.25,
                  ),
                ),
              ),
            ),
          ],
        );

      case 'VHS':
        return Stack(
          fit: StackFit.passthrough,
          children: [
            _image(),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _VhsPainter()),
              ),
            ),
          ],
        );

      case 'Neon':
        return Stack(
          fit: StackFit.passthrough,
          children: [
            ImageFiltered(
              imageFilter: ui.ImageFilter.blur(
                sigmaX: 5,
                sigmaY: 5,
              ),
              child: Opacity(
                opacity: 0.8,
                child: _tintedImage([
                  0, 0, 0, 0, 0,
                  0, 0.4, 0, 0, 0,
                  0, 0, 1, 0, 40,
                  0, 0, 0, 1, 0,
                ]),
              ),
            ),
            _image(),
          ],
        );

      default:
        return _image();
    }
  }

  Widget _buildImagePreview() {
    if (isPreview) {
      return RotatedBox(
        quarterTurns: rotationTurns,
        child: _image(),
      );
    }

    return RotatedBox(
      quarterTurns: rotationTurns,
      child: ColorFiltered(
        colorFilter: ColorFilter.matrix(
          filterMatrices[selectedFilter]!,
        ),
        child: ColorFiltered(
          colorFilter: ColorFilter.matrix(_adjustmentMatrix()),
          child: _buildEffectImage(),
        ),
      ),
    );
  }

  Widget _buildSharpnessOverlay() {
    if (sharpness <= 0 || isPreview) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: Opacity(
        opacity: sharpness * 0.12,
        child: ColorFiltered(
          colorFilter: const ColorFilter.matrix([
            1.5, 0, 0, 0, -45,
            0, 1.5, 0, 0, -45,
            0, 0, 1.5, 0, -45,
            0, 0, 0, 1, 0,
          ]),
          child: _buildImagePreview(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232323),
      appBar: AppBar(
        backgroundColor: const Color(0xFF232323),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: isExporting ? null : exportImage,
            child: Text(
              isExporting ? 'Saving...' : 'Export',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
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
                child: RepaintBoundary(
                  key: _exportKey,
                  child: Stack(
                    fit: StackFit.passthrough,
                    children: [
                      _buildImagePreview(),
                      _buildSharpnessOverlay(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            color: const Color(0xFF242424),
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _RoundToolButton(
                  icon: isPreview
                      ? Icons.visibility_off
                      : Icons.visibility,
                  tooltip: isPreview ? 'Exit Preview' : 'Preview',
                  onTap: () {
                    setState(() {
                      isPreview = !isPreview;
                    });
                  },
                ),
                const SizedBox(width: 8),
                _RoundToolButton(
                  icon: Icons.restart_alt,
                  tooltip: 'Reset',
                  onTap: resetEditor,
                ),
              ],
            ),
          ),

          // Feature icons remain visible in Preview mode.
          Container(
            color: const Color(0xFF242424),
            padding: const EdgeInsets.only(
              top: 12,
              bottom: 24,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _EditorTool(
                    icon: Icons.filter_vintage,
                    label: 'Filter',
                    onTap: openFilterPanel,
                  ),
                  _EditorTool(
                    icon: Icons.tune,
                    label: 'Adjust',
                    onTap: openAdjustPanel,
                  ),
                  _EditorTool(
                    icon: Icons.auto_awesome,
                    label: 'Effect',
                    onTap: openEffectPanel,
                  ),
                  _EditorTool(
                    icon: Icons.crop,
                    label: 'Crop',
                    onTap: cropImage,
                  ),
                  _EditorTool(
                    icon: Icons.rotate_right,
                    label: 'Rotate',
                    onTap: openRotatePanel,
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

class _NoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final paint = Paint();

    for (int i = 0; i < 1200; i++) {
      paint.color = random.nextBool()
          ? Colors.white.withValues(alpha: 0.35)
          : Colors.black.withValues(alpha: 0.3);

      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final dotSize = random.nextDouble() * 1.8 + 0.4;

      canvas.drawRect(
        Rect.fromLTWH(x, y, dotSize, dotSize),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScanlinePainter extends CustomPainter {
  final double spacing;
  final double opacity;

  const _ScanlinePainter({
    this.spacing = 4,
    this.opacity = 0.3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: opacity)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ScanlinePainter oldDelegate) {
    return spacing != oldDelegate.spacing ||
        opacity != oldDelegate.opacity;
  }
}

class _VhsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scanlinePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        scanlinePaint,
      );
    }

    final redPaint = Paint()
      ..color = Colors.red.withValues(alpha: 0.08)
      ..blendMode = BlendMode.screen;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      redPaint,
    );

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..strokeWidth = 2;

    final random = math.Random(7);

    for (int i = 0; i < 5; i++) {
      final y = random.nextDouble() * size.height;

      canvas.drawLine(
        Offset(0, y),
        Offset(size.width * 0.3, y),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RoundToolButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _RoundToolButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24),
      ),
      child: IconButton(
        onPressed: onTap,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        icon: Icon(icon, size: 20),
        color: Colors.white,
        tooltip: tooltip,
      ),
    );
  }
}

class _EditorTool extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _EditorTool({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 76,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 26,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}