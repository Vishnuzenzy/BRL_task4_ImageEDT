import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/editor_state.dart';
import '../models/edit_state.dart';
import '../models/overlays.dart';

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

    void setFilter(FilterPreset filter) {
    state = state.copyWith(edits: state.edits.copyWith(filter: filter));
  }

  void addText(TextOverlay overlay) {
    state = state.copyWith(
      edits: state.edits.copyWith(texts: [...state.edits.texts, overlay]),
    );
  }

  void updateText(TextOverlay overlay) {
    final list = [
      for (final t in state.edits.texts) t.id == overlay.id ? overlay : t,
    ];
    state = state.copyWith(edits: state.edits.copyWith(texts: list));
  }

  void removeText(String id) {
    final list = state.edits.texts.where((t) => t.id != id).toList();
    state = state.copyWith(edits: state.edits.copyWith(texts: list));
  }

  void addStroke(DoodleStroke stroke) {
    state = state.copyWith(
      edits: state.edits.copyWith(strokes: [...state.edits.strokes, stroke]),
    );
  }

  void undoStroke() {
    final strokes = state.edits.strokes;
    if (strokes.isEmpty) return;
    state = state.copyWith(
      edits: state.edits.copyWith(
        strokes: strokes.sublist(0, strokes.length - 1),
      ),
    );
  }

  void setBackground({int? colorValue, double? padding}) {
    state = state.copyWith(
      edits: state.edits.copyWith(
        backgroundColorValue: colorValue,
        framePadding: padding,
      ),
    );
  }

  /// Discards crop, rotation and adjustments.
  void reset() {
    state = EditorState(original: state.original, current: state.original);
  }
}

final editorProvider = NotifierProvider<EditorNotifier, EditorState>(
  EditorNotifier.new,
);