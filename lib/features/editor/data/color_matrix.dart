import '../models/edit_state.dart';
 
const _lumR = 0.213;
const _lumG = 0.715;
const _lumB = 0.072;
 
/// 4x5 matrix (20 values) for ColorFilter.matrix.
List<double> buildColorMatrix(EditState e) {
  final saturation = e.grayscale ? 0.0 : e.saturation;
 
  var m = _presetMatrix(e.filter);
  m = _then(m, _saturationMatrix(saturation));
  m = _then(m, _contrastMatrix(e.contrast));
  m = _then(m, _brightnessMatrix(e.brightness));
  return m;
}
 
List<double> _presetMatrix(FilterPreset p) {
  switch (p) {
    case FilterPreset.original:
      return [
        1, 0, 0, 0, 0,
        0, 1, 0, 0, 0,
        0, 0, 1, 0, 0,
        0, 0, 0, 1, 0,
      ];
    case FilterPreset.warm:
      return [
        1.1, 0, 0, 0, 10,
        0, 1, 0, 0, 0,
        0, 0, 0.9, 0, -10,
        0, 0, 0, 1, 0,
      ];
    case FilterPreset.cool:
      return [
        0.9, 0, 0, 0, -10,
        0, 1, 0, 0, 0,
        0, 0, 1.1, 0, 10,
        0, 0, 0, 1, 0,
      ];
    case FilterPreset.vintage:
      return [
        0.393, 0.769, 0.189, 0, 0,
        0.349, 0.686, 0.168, 0, 0,
        0.272, 0.534, 0.131, 0, 0,
        0, 0, 0, 1, 0,
      ];
  }
}
 
List<double> _saturationMatrix(double s) {
  final inv = 1 - s;
  return [
    _lumR * inv + s, _lumG * inv, _lumB * inv, 0, 0,
    _lumR * inv, _lumG * inv + s, _lumB * inv, 0, 0,
    _lumR * inv, _lumG * inv, _lumB * inv + s, 0, 0,
    0, 0, 0, 1, 0,
  ];
}
 
List<double> _contrastMatrix(double c) {
  final t = 128 * (1 - c);
  return [
    c, 0, 0, 0, t,
    0, c, 0, 0, t,
    0, 0, c, 0, t,
    0, 0, 0, 1, 0,
  ];
}
 
List<double> _brightnessMatrix(double b) {
  final t = b * 255;
  return [
    1, 0, 0, 0, t,
    0, 1, 0, 0, t,
    0, 0, 1, 0, t,
    0, 0, 0, 1, 0,
  ];
}
 
/// Returns the matrix that applies [first] and then [second].
List<double> _then(List<double> first, List<double> second) {
  final out = List<double>.filled(20, 0);
  for (var row = 0; row < 4; row++) {
    for (var col = 0; col < 5; col++) {
      var sum = 0.0;
      for (var k = 0; k < 4; k++) {
        sum += second[row * 5 + k] * first[k * 5 + col];
      }
      if (col == 4) sum += second[row * 5 + 4];
      out[row * 5 + col] = sum;
    }
  }
  return out;
}