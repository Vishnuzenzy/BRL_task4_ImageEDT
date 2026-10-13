import '../models/pick_result.dart';

class ImagePickerService {
  /// Returns null if the user cancels.
  /// Throws AppException for denied permission or invalid file.
  Future<PickResult?> pickFromGallery() async {
    throw UnimplementedError();
  }
}