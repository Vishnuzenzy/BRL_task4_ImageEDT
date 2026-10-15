import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
 
import '../../editor/data/color_matrix.dart';
import '../../editor/models/edit_state.dart';
 
/// Applies rotation, brightness, contrast, saturation, grayscale and the
/// selected filter to the image and returns PNG bytes ready to save.
class ImageRenderer {
  /// Longest side of the saved image. Bigger photos are scaled down so the
  /// phone does not run out of memory.
  static const int maxSide = 4096;
 
  Future<Uint8List> render(Uint8List source, EditState edits) async {
    final codec = await ui.instantiateImageCodec(source);
    final frame = await codec.getNextFrame();
    final image = frame.image;
 
    try {
      final turns = edits.quarterTurns % 4;
      final swap = turns.isOdd;
      final rotatedW = (swap ? image.height : image.width).toDouble();
      final rotatedH = (swap ? image.width : image.height).toDouble();
 
      final scale = math.min(1.0, maxSide / math.max(rotatedW, rotatedH));
      final outW = (rotatedW * scale).round();
      final outH = (rotatedH * scale).round();
 
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
 
      canvas.translate(outW / 2, outH / 2);
      canvas.scale(scale, scale);
      canvas.rotate(turns * math.pi / 2);
      canvas.translate(-image.width / 2, -image.height / 2);
 
      final paint = ui.Paint()
        ..filterQuality = ui.FilterQuality.high
        ..colorFilter = ui.ColorFilter.matrix(buildColorMatrix(edits));
      canvas.drawImage(image, ui.Offset.zero, paint);
 
      final picture = recorder.endRecording();
      final output = await picture.toImage(outW, outH);
      try {
        final data = await output.toByteData(format: ui.ImageByteFormat.png);
        if (data == null) {
          throw StateError('Could not encode the edited image.');
        }
        return data.buffer.asUint8List();
      } finally {
        output.dispose();
        picture.dispose();
      }
    } finally {
      image.dispose();
      codec.dispose();
    }
  }
}
 