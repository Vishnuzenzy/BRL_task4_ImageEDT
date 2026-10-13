import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../models/picked_image.dart';

class PickerState {
  final PickedImage? selectedImage;
  final bool isPicking;
  final String? errorMessage;

  const PickerState({
    this.selectedImage,
    this.isPicking = false,
    this.errorMessage,
  });

  PickerState copyWith({
    PickedImage? selectedImage,
    bool? isPicking,
    String? errorMessage,
    bool clearImage = false,
    bool clearError = false,
  }) {
    return PickerState(
      selectedImage: clearImage ? null : selectedImage ?? this.selectedImage,
      isPicking: isPicking ?? this.isPicking,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

final pickerViewModelProvider =
NotifierProvider<PickerViewModel, PickerState>(
  PickerViewModel.new,
);

class PickerViewModel extends Notifier<PickerState> {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  PickerState build() => const PickerState();

  Future<void> pickImage() async {
    state = state.copyWith(
      isPicking: true,
      clearError: true,
    );

    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 95,
      );

      if (image == null) {
        state = state.copyWith(isPicking: false);
        return;
      }

      state = state.copyWith(
        selectedImage: PickedImage(file: image),
        isPicking: false,
      );
    } catch (e) {
      state = state.copyWith(
        isPicking: false,
        errorMessage: 'Unable to select the image. Please try again.',
      );
    }
  }

  void clearImage() {
    state = state.copyWith(
      clearImage: true,
      clearError: true,
    );
  }
}