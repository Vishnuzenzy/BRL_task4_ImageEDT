import 'overlays.dart';

enum FilterPreset { original, warm, cool, vintage }

class EditState {
  final int quarterTurns; // 0 to 3, each is 90 degrees clockwise
  final double brightness; // -1.0 to 1.0, 0 = unchanged
  final double contrast; // 0.5 to 1.5, 1 = unchanged
  final double saturation; // 0.0 to 2.0, 1 = unchanged
  final bool grayscale;
  final FilterPreset filter;
  final List<TextOverlay> texts;
  final List<DoodleStroke> strokes;
  final int backgroundColorValue;
  final double framePadding; // 0..0.3, fraction of image width

  const EditState({
    this.quarterTurns = 0,
    this.brightness = 0,
    this.contrast = 1,
    this.saturation = 1,
    this.grayscale = false,
    this.filter = FilterPreset.original,
    this.texts = const [],
    this.strokes = const [],
    this.backgroundColorValue = 0xFF000000,
    this.framePadding = 0,
  });

  EditState copyWith({
    int? quarterTurns,
    double? brightness,
    double? contrast,
    double? saturation,
    bool? grayscale,
    FilterPreset? filter,
    List<TextOverlay>? texts,
    List<DoodleStroke>? strokes,
    int? backgroundColorValue,
    double? framePadding,
  }) {
    return EditState(
      quarterTurns: quarterTurns ?? this.quarterTurns,
      brightness: brightness ?? this.brightness,
      contrast: contrast ?? this.contrast,
      saturation: saturation ?? this.saturation,
      grayscale: grayscale ?? this.grayscale,
      filter: filter ?? this.filter,
      texts: texts ?? this.texts,
      strokes: strokes ?? this.strokes,
      backgroundColorValue: backgroundColorValue ?? this.backgroundColorValue,
      framePadding: framePadding ?? this.framePadding,
    );
  }

  bool get hasEdits =>
      quarterTurns != 0 ||
      brightness != 0 ||
      contrast != 1 ||
      saturation != 1 ||
      grayscale ||
      filter != FilterPreset.original ||
      texts.isNotEmpty ||
      strokes.isNotEmpty ||
      framePadding != 0;
}