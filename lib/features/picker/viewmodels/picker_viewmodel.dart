
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
    bool clearError = false,
  }) {
    return PickerState(
      selectedImage: selectedImage ?? this.selectedImage,
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

  Future<PickedImage?> pickImage(ImageSource source) async {
    state = state.copyWith(
      isPicking: true,
      clearError: true,
    );

    try {
      final image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 95,
      );

      if (image == null) {
        state = state.copyWith(isPicking: false);
        return null;
      }

      final pickedImage = PickedImage(file: image);

      state = state.copyWith(
        selectedImage: pickedImage,
        isPicking: false,
      );

      return pickedImage;
    } catch (_) {
      state = state.copyWith(
        isPicking: false,
        errorMessage: source == ImageSource.camera
            ? 'Unable to open camera. Please try again.'
            : 'Unable to select the image. Please try again.',
      );

      return null;
    }
  }
}
