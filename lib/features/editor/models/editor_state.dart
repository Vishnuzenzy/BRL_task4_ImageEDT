import 'dart:typed_data';

import 'edit_state.dart';

class EditorState {
  final Uint8List? original; // untouched picked image, used for reset
  final Uint8List? current; // original after crop
  final EditState edits;

  const EditorState({
    this.original,
    this.current,
    this.edits = const EditState(),
  });

  bool get hasImage => current != null;

  EditorState copyWith({Uint8List? current, EditState? edits}) {
    return EditorState(
      original: original,
      current: current ?? this.current,
      edits: edits ?? this.edits,
    );
  }
}