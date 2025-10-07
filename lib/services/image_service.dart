import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gal/gal.dart';
import '../constants/app_constants.dart';
import '../models/app_exception.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: AppConstants.imageMaxWidth.toDouble(),
        maxHeight: AppConstants.imageMaxHeight.toDouble(),
        imageQuality: AppConstants.imageQuality,
      );

      if (image == null) return null;

      return await _convertToBase64(image.path);
    } catch (error) {
      if (error is ImageException) rethrow;
      throw ImageException(
        message: 'Error picking image: $error',
        userMessage: 'Failed to select image',
        originalError: error,
      );
    }
  }

  Future<List<String>> pickMultipleImagesFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: AppConstants.imageMaxWidth.toDouble(),
        maxHeight: AppConstants.imageMaxHeight.toDouble(),
        imageQuality: AppConstants.imageQuality,
      );

      final List<String> base64Images = [];
      for (final image in images) {
        final base64 = await _convertToBase64(image.path);
        if (base64 != null) {
          base64Images.add(base64);
        }
      }

      return base64Images;
    } catch (error) {
      if (error is ImageException) rethrow;
      throw ImageException(
        message: 'Error picking multiple images: $error',
        userMessage: 'Failed to select images',
        originalError: error,
      );
    }
  }

  Future<String?> pickImageFromCamera({bool preferFrontCamera = false}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: AppConstants.imageMaxWidth.toDouble(),
        maxHeight: AppConstants.imageMaxHeight.toDouble(),
        imageQuality: AppConstants.imageQuality,
        preferredCameraDevice:
            preferFrontCamera ? CameraDevice.front : CameraDevice.rear,
      );

      if (image == null) return null;

      return await _convertToBase64(image.path);
    } catch (error) {
      if (error is ImageException) rethrow;
      throw ImageException(
        message: 'Error taking photo: $error',
        userMessage: 'Failed to take photo',
        originalError: error,
      );
    }
  }

  Future<String?> takePhotoWithCamera(bool useFrontCamera) async {
    return pickImageFromCamera(preferFrontCamera: useFrontCamera);
  }

  Future<String?> _convertToBase64(String imagePath) async {
    try {
      // For web, use XFile directly without compression
      if (kIsWeb) {
        final xFile = XFile(imagePath);
        final bytes = await xFile.readAsBytes();
        if (bytes.isEmpty) {
          throw Exception('Файл изображения пуст');
        }
        return base64Encode(bytes);
      }

      // For mobile platforms
      final File imageFile = File(imagePath);

      // Try to compress image, if it fails, use original
      try {
        final Uint8List? compressedBytes =
            await FlutterImageCompress.compressWithFile(
          imageFile.absolute.path,
          minWidth: AppConstants.imageCompressionMinWidth,
          minHeight: AppConstants.imageCompressionMinHeight,
          quality: AppConstants.imageCompressionQuality,
          format: CompressFormat.png,
        );

        if (compressedBytes != null && compressedBytes.isNotEmpty) {
          return base64Encode(compressedBytes);
        }
      } catch (compressionError) {
        // If compression fails, fall through to use original bytes
      }

      // Fallback: use original file bytes
      final bytes = await imageFile.readAsBytes();
      if (bytes.isEmpty) {
        throw ImageInvalidException();
      }
      return base64Encode(bytes);
    } catch (error) {
      if (error is ImageException) rethrow;
      throw ImageException(
        message: 'Error converting image: $error',
        userMessage: 'Failed to process image',
        originalError: error,
      );
    }
  }

  Uint8List base64ToImage(String base64String) {
    return base64Decode(base64String);
  }

  String imageToBase64(Uint8List imageBytes) {
    return base64Encode(imageBytes);
  }

  Future<bool> saveImageToGallery(Uint8List imageBytes) async {
    try {
      if (kIsWeb) {
        throw UnimplementedError(
            'Сохранение в галерею не поддерживается в web');
      }

      // Save directly to gallery using gal package
      final tempPath =
          '${Directory.systemTemp.path}/virtual_try_on_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(tempPath);
      await file.writeAsBytes(imageBytes);

      // Save to gallery
      await Gal.putImage(file.path, album: AppConstants.galleryAlbumName);

      // Clean up temp file
      try {
        await file.delete();
      } catch (_) {}

      return true;
    } catch (error) {
      throw ImageSaveException(
        message: 'Failed to save image to gallery: $error',
        originalError: error,
      );
    }
  }
}
