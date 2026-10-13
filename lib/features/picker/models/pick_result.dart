import 'dart:typed_data';

class PickResult {
  final Uint8List bytes;
  final String name;

  const PickResult({required this.bytes, required this.name});
}