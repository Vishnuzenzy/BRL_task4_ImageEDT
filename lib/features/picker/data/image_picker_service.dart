
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/errors/app_exception.dart';
import '../models/pick_result.dart';

class ImagePickerService {
  ImagePickerService({ImagePicker? picker})
      : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  /// Returns null if the user cancels.
  /// Throws AppException for denied permission or invalid file.
  Future<PickResult?> pickFromGallery() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      // Cancellation is normal; it is not an error.
      if (file == null) return null;

      final bytes = await file.readAsBytes();

      if (bytes.isEmpty) {
        throw const AppException(
          AppErrorType.invalidFile,
          'The selected image is empty or invalid.',
        );
      }

      return PickResult(
        bytes: bytes,
        name: file.name,
      );
    } on AppException {
      rethrow;
    } on PlatformException catch (error) {
      final code = error.code.toLowerCase();

      if (code.contains('denied') || code.contains('permission')) {
        throw const AppException(
          AppErrorType.permissionDenied,
          'Photo access was denied. Please allow access in your device settings.',
        );
      }

      throw AppException(
        AppErrorType.invalidFile,
        'Unable to open the selected image: ${error.message ?? error.code}',
      );
    } on Exception catch (error) {
      throw AppException(
        AppErrorType.invalidFile,
        'Unable to select or read the image: $error',
      );
    }
  }
}
