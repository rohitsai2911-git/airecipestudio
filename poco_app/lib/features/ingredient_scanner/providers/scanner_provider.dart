import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final scannedIngredientsProvider = StateNotifierProvider<ScannedIngredientsNotifier, List<String>>((ref) {
  return ScannedIngredientsNotifier();
});

class ScannedIngredientsNotifier extends StateNotifier<List<String>> {
  ScannedIngredientsNotifier() : super([]);

  void add(String ingredient) {
    if (!state.contains(ingredient)) state = [...state, ingredient];
  }

  void remove(String ingredient) {
    state = state.where((i) => i != ingredient).toList();
  }

  void clear() => state = [];
  bool get isEmpty => state.isEmpty;
}

final isCameraActiveProvider = StateProvider<bool>((ref) => false);

final capturedImageProvider = StateProvider<String?>((ref) => null);

final cameraNotifierProvider = Provider<CameraNotifier>((ref) {
  return CameraNotifier(ref);
});

class CameraNotifier {
  final Ref _ref;
  CameraNotifier(this._ref);

  Future<void> capture() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera, maxWidth: 1024, maxHeight: 1024);
    if (image == null) return;
    final bytes = await image.readAsBytes();
    final base64 = base64Encode(bytes);
    _ref.read(capturedImageProvider.notifier).state = base64;
    _ref.read(isCameraActiveProvider.notifier).state = true;
  }

  void clear() {
    _ref.read(capturedImageProvider.notifier).state = null;
    _ref.read(isCameraActiveProvider.notifier).state = false;
  }
}