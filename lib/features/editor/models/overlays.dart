import 'dart:ui';

class TextOverlay {
  final String id;
  final String text;
  final Offset position; // 0..1, relative to the image
  final double fontScale; // font size as a fraction of image width
  final int colorValue;

  const TextOverlay({
    required this.id,
    required this.text,
    this.position = const Offset(0.5, 0.5),
    this.fontScale = 0.06,
    this.colorValue = 0xFFFFFFFF,
  });

  TextOverlay copyWith({
    String? text,
    Offset? position,
    double? fontScale,
    int? colorValue,
  }) {
    return TextOverlay(
      id: id,
      text: text ?? this.text,
      position: position ?? this.position,
      fontScale: fontScale ?? this.fontScale,
      colorValue: colorValue ?? this.colorValue,
    );
  }
}

class DoodleStroke {
  final List<Offset> points; // each 0..1, relative to the image
  final int colorValue;
  final double widthScale; // brush width as a fraction of image width

  const DoodleStroke({
    required this.points,
    this.colorValue = 0xFFFF0000,
    this.widthScale = 0.01,
  });
}