import 'dart:typed_data';
 
import 'package:gal/gal.dart';
 
import '../models/save_result.dart';
 
class ExportService {
  /// Saves [bytes] (an encoded image) to the phone's gallery.
  /// Never throws: every outcome is returned as a [SaveResult].
  Future<SaveResult> save(Uint8List bytes) async {
    try {
      if (!await Gal.hasAccess()) {
        final granted = await Gal.requestAccess();
        if (!granted) {
          return const SaveResult(
            success: false,
            message: 'Permission denied. Allow photo access to save images.',
          );
        }
      }
 
      await Gal.putImageBytes(bytes);
      return const SaveResult(
        success: true,
        message: 'Saved to your gallery',
      );
    } on GalException catch (e) {
      switch (e.type) {
        case GalExceptionType.accessDenied:
          return const SaveResult(
            success: false,
            message: 'Permission denied. Allow photo access to save images.',
          );
        case GalExceptionType.notEnoughSpace:
          return const SaveResult(
            success: false,
            message: 'Not enough storage space to save this image.',
          );
        default:
          return const SaveResult(
            success: false,
            message: 'Could not save the image. Please try again.',
          );
      }
    } catch (_) {
      return const SaveResult(
        success: false,
        message: 'Could not save the image. Please try again.',
      );
    }
  }
}
 