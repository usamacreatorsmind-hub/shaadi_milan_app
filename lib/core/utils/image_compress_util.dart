import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Compresses image files before upload to drastically reduce network payload size
/// and speed up Firebase Storage uploads & subsequent network loading.
Future<String> compressAndGetImageFile(String originalPath, {int maxWidth = 1080, int maxHeight = 1080, int quality = 70}) async {
  try {
    final file = File(originalPath);
    if (!file.existsSync()) return originalPath;

    final originalBytes = file.lengthSync();
    // Skip if already under 200 KB
    if (originalBytes < 200 * 1024) {
      return originalPath;
    }

    final tempDir = Directory.systemTemp;
    final fileName = originalPath.split('/').last.split('\\').last;
    final targetPath = '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}_$fileName.jpg';

    final compressedResult = await FlutterImageCompress.compressAndGetFile(
      originalPath,
      targetPath,
      minWidth: maxWidth,
      minHeight: maxHeight,
      quality: quality,
      format: CompressFormat.jpeg,
    );

    if (compressedResult != null) {
      final compressedFile = File(compressedResult.path);
      final newBytes = compressedFile.lengthSync();
      debugPrint(
        '🗜️ Image compressed: ${(originalBytes / 1024).toStringAsFixed(1)} KB ➔ ${(newBytes / 1024).toStringAsFixed(1)} KB (${((1 - (newBytes / originalBytes)) * 100).toStringAsFixed(0)}% reduction)',
      );
      return compressedFile.path;
    }
  } catch (e) {
    debugPrint('⚠️ Error compressing image file: $e');
  }
  return originalPath;
}
