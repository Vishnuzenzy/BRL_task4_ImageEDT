import 'package:image_picker/image_picker.dart';

class PickedImage {
  final XFile file;

  const PickedImage({required this.file});

  String get path => file.path;
  String get name => file.name;
}