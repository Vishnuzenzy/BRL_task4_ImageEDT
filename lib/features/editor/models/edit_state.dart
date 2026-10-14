class EditState {
  final int quarterTurns; // 0 to 3, 90 degrees clockwise turn k liye
  final double brightness; // -1.0 to 1.0, 0 = same
  final double contrast; // 0.5 to 1.5, 1 = same
  final double saturation; // 0.0 to 2.0, 1 = same
  final bool grayscale;

  const EditState({
    this.quarterTurns = 0,
    this.brightness = 0,
    this.contrast = 1,
    this.saturation = 1,
    this.grayscale = false,
  });

  EditState copyWith({
    int? quarterTurns,
    double? brightness,
    double? contrast,
    double? saturation,
    bool? grayscale,
  }) {
    return EditState(
      quarterTurns: quarterTurns ?? this.quarterTurns,
      brightness: brightness ?? this.brightness,
      contrast: contrast ?? this.contrast,
      saturation: saturation ?? this.saturation,
      grayscale: grayscale ?? this.grayscale,
    );
  }

  bool get hasEdits =>
      quarterTurns != 0 ||
      brightness != 0 ||
      contrast != 1 ||
      saturation != 1 ||
      grayscale;
}