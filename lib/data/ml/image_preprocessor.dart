import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Image preprocessor for the MeatFresh AI classification pipeline.
///
/// Currently handles file storage only. When the real TFLite model is ready,
/// add actual preprocessing (resize, normalize) to match training pipeline.
class ImagePreprocessor {
  /// Copy the source image to app-private storage so it persists
  /// independently of the gallery/camera temp file.
  ///
  /// Returns the new file path in app documents directory.
  static Future<String> copyToAppStorage(String sourcePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(p.join(appDir.path, 'scan_images'));
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ext = p.extension(sourcePath).isNotEmpty ? p.extension(sourcePath) : '.jpg';
    final destPath = p.join(imagesDir.path, 'scan_$timestamp$ext');

    final sourceFile = File(sourcePath);
    await sourceFile.copy(destPath);
    return destPath;
  }

  /// TODO: Actual preprocessing for TFLite model:
  /// 1. Decode image (JPEG/PNG) to raw pixel buffer
  /// 2. Resize to model input size (e.g. 224×224) — match training interpolation
  /// 3. Normalize pixel values (confirm /255.0 vs mean/std from training)
  /// 4. Convert to Float32List in NHWC order [1, H, W, 3]
  ///
  /// ```dart
  /// static Future<Float32List> prepare(String imagePath) async {
  ///   final bytes = await File(imagePath).readAsBytes();
  ///   final image = img.decodeImage(bytes);
  ///   final resized = img.copyResize(image, width: 224, height: 224);
  ///   final Float32List input = Float32List(1 * 224 * 224 * 3);
  ///   int idx = 0;
  ///   for (int y = 0; y < 224; y++) {
  ///     for (int x = 0; x < 224; x++) {
  ///       final pixel = resized.getPixel(x, y);
  ///       input[idx++] = pixel.r / 255.0;
  ///       input[idx++] = pixel.g / 255.0;
  ///       input[idx++] = pixel.b / 255.0;
  ///     }
  ///   }
  ///   return input;
  /// }
  /// ```
}
