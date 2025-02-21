import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImagePickerUtil {
  ImagePickerUtil._privateConstructor();
  static final ImagePickerUtil instance = ImagePickerUtil._privateConstructor();

  final ImagePicker _imagePicker = ImagePicker();

  Future<List<String>> captureMultipleImages(
      {bool isCropperRequired = true, required BuildContext context}) async {
    List<String> imagePaths = [];

    bool takeAnother = true;
    while (takeAnother) {
      final XFile? imageFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 75,
        maxHeight: 1024,
        maxWidth: 1024,
      );

      if (imageFile != null) {
        String finalPath = imageFile.path;

        if (isCropperRequired) {
          finalPath = await cropImage(imageFile.path, context) ?? finalPath;
        }

        final String storedPath = await saveImageToStorage(File(finalPath));
        imagePaths.add(storedPath);
      }

      takeAnother = await askUserForMorePhotos(context);
    }

    return imagePaths;
  }

  Future<String?> cropImage(String imagePath, BuildContext context) async {
    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imagePath,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: const Color.fromARGB(255, 118, 63, 181),
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: const Color.fromARGB(255, 118, 63, 181),
          lockAspectRatio: false,
          initAspectRatio: CropAspectRatioPreset.original,
        ),
        IOSUiSettings(
          title: 'Crop Image',
          aspectRatioLockEnabled: false,
        ),
      ],
    );

    return croppedFile?.path;
  }

  Future<String> saveImageToStorage(File image) async {
    final Directory tempDir = await getApplicationDocumentsDirectory();
    final Directory imageDir = Directory('${tempDir.path}/images');

    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }

    final String newPath =
        '${imageDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final File savedImage = await image.copy(newPath);

    return savedImage.path;
  }

  Future<bool> askUserForMorePhotos(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Take another picture?"),
              content: const Text("Do you want to take another photo?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("No"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Yes"),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
