import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/errors/app_exception.dart';

class CropRotateService {
  CropRotateService({ImageCropper? cropper})
    : _cropper = cropper ?? ImageCropper();

  final ImageCropper _cropper;

  /// Opens the native crop editor.
  ///
  /// Returns cropped image bytes when the user confirms,
  /// or null if the user cancels.
  Future<Uint8List?> crop(
    Uint8List bytes, {
    required BuildContext context,
  }) async {
    if (bytes.isEmpty) {
      throw const AppException(
        AppErrorType.invalidFile,
        'Cannot crop an empty image.',
      );
    }

    // Read the theme before any asynchronous operation.
    final colorScheme = Theme.of(context).colorScheme;

    File? sourceFile;

    try {
      final tempDirectory = await getTemporaryDirectory();

      sourceFile = File(
        '${tempDirectory.path}/imageedt_crop_'
        '${DateTime.now().microsecondsSinceEpoch}.jpg',
      );

      await sourceFile.writeAsBytes(bytes, flush: true);

      final croppedFile = await _cropper.cropImage(
        sourcePath: sourceFile.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 95,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: colorScheme.surface,
            toolbarWidgetColor: colorScheme.primary,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioLockEnabled: false,
            resetAspectRatioEnabled: true,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
        ],
      );

      // Cancellation is normal, not an error.
      if (croppedFile == null) {
        return null;
      }

      final croppedBytes = await croppedFile.readAsBytes();

      if (croppedBytes.isEmpty) {
        throw const AppException(
          AppErrorType.processingFailed,
          'The cropped image could not be read.',
        );
      }

      return croppedBytes;
    } on AppException {
      rethrow;
    } catch (error) {
      throw AppException(
        AppErrorType.processingFailed,
        'Unable to crop the image: $error',
      );
    } finally {
      // Clean up the temporary source file.
      try {
        if (sourceFile != null && await sourceFile.exists()) {
          await sourceFile.delete();
        }
      } catch (_) {
        // Cleanup failures should not hide the crop result.
      }
    }
  }
}
