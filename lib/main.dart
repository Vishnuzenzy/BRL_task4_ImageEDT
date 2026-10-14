
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/picker/views/image_picker_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: ImageEDTApp(),
    ),
  );
}

class ImageEDTApp extends StatelessWidget {
  const ImageEDTApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PixelCraft',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFEDE9FF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
          brightness: Brightness.light,
        ),
      ),
      home: const ImagePickerScreen(),
    );
  }
}
