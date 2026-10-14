import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/editor_state.dart';

class EditorNotifier extends Notifier<EditorState> {
  @override
  EditorState build() => const EditorState();

  void loadImage(Uint8List bytes) {
    state = EditorState(original: bytes, current: bytes);
  }

  void setBrightness(double value) {
    state = state.copyWith(edits: state.edits.copyWith(brightness: value));
  }

  void setContrast(double value) {
    state = state.copyWith(edits: state.edits.copyWith(contrast: value));
  }

  void setSaturation(double value) {
    state = state.copyWith(edits: state.edits.copyWith(saturation: value));
  }

  void toggleGrayscale() {
    state = state.copyWith(
      edits: state.edits.copyWith(grayscale: !state.edits.grayscale),
    );
  }

  void rotateRight() {
    final turns = (state.edits.quarterTurns + 1) % 4;
    state = state.copyWith(edits: state.edits.copyWith(quarterTurns: turns));
  }

  void rotateLeft() {
    final turns = (state.edits.quarterTurns + 3) % 4;
    state = state.copyWith(edits: state.edits.copyWith(quarterTurns: turns));
  }

  void applyCrop(Uint8List cropped) {
    state = state.copyWith(current: cropped);
  }

  /// Discards crop, rotation and adjustments.
  void reset() {
    state = EditorState(original: state.original, current: state.original);
  }
}

final editorProvider = NotifierProvider<EditorNotifier, EditorState>(
  EditorNotifier.new,
);