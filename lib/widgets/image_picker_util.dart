// // import 'dart:io';
// // import 'package:flutter/material.dart';
// // import 'package:image_cropper/image_cropper.dart';
// // import 'package:image_picker/image_picker.dart';
// // import 'package:path_provider/path_provider.dart';

// // class ImagePickerUtil {
// //   ImagePickerUtil._privateConstructor();

// //   static final ImagePickerUtil instance = ImagePickerUtil._privateConstructor();

// //   final _imagePicker = ImagePicker();

// //   Future<String> getImage(
// //       {ImageSource source = ImageSource.camera,
// //       CameraDevice cameraSide = CameraDevice.front,
// //       bool isCropperRequired = true}) async {
// //     debugPrint(
// //         "\n =======================Was this called? before pickimage========================== \n");
// //     final XFile? imageFile = await _imagePicker.pickImage(
// //         source: source,
// //         preferredCameraDevice: cameraSide,
// //         imageQuality: 75,
// //         maxHeight: 1024,
// //         maxWidth: 1024);
// //     debugPrint(
// //         "\n ===========================was this called? afetr pick image ============================ \n==================== this is image file $imageFile==============================\n");

// //     if (isCropperRequired) {
// //       debugPrint("\n==== isCroppedRequired: $isCropperRequired ====\n");

// //       if (imageFile != null) {
// //         debugPrint("\n==== Before cropping: $imageFile ====\n");

// //         final CroppedFile? cropped = await ImageCropper().cropImage(
// //           sourcePath: imageFile.path,
// //           uiSettings: [
// //             AndroidUiSettings(
// //               toolbarTitle: 'Cropper',
// //               toolbarColor: Colors.indigo[300],
// //               toolbarWidgetColor: Colors.white,
// //               activeControlsWidgetColor: Colors.indigo[300],
// //               lockAspectRatio: false,
// //               initAspectRatio: CropAspectRatioPreset.original,
// //             ),
// //             IOSUiSettings(
// //               title: 'Cropper',
// //               aspectRatioLockEnabled: false,
// //             ),
// //           ],
// //         );

// //         debugPrint("\n==== After cropping ====\n");

// //         if (cropped == null) {
// //           debugPrint("User cancelled cropping or crop failed.");
// //           return '';
// //         }

// //         return await getCachedImageFromDevice(image: XFile(cropped.path));
// //       }

// //       debugPrint("Error: Image is null or has an invalid path.");
// //     } else {
// //       debugPrint(
// //           "\n==================isCroppedRequired from else =======> $isCropperRequired");
// //       return await getCachedImageFromDevice(image: imageFile!);
// //     }

// //     return '';
// //   }

// //   Future<String> getCompressedImage(
// //       {ImageSource source = ImageSource.gallery,
// //       CameraDevice cameraSide = CameraDevice.front}) async {
// //     final image = await _imagePicker.pickImage(
// //       source: source,
// //       preferredCameraDevice: cameraSide,
// //       imageQuality: 75,
// //       maxHeight: 1280,
// //       maxWidth: 1280,
// //     );

// //     if (image != null) {
// //       return await getCachedImageFromDevice(image: image);
// //     } else {
// //       return "";
// //     }
// //   }

// //   Future<String> getCachedImageFromDevice({required XFile image}) async {
// //     debugPrint(
// //         "----------Image Picker Utils: Picked Image Path -------> ${image.path} ");
// //     late File img;
// //     late File imageFile;
// //     final Directory temp = await getApplicationDocumentsDirectory();
// //     final tempImageDirectory = Directory('${temp.path}/images');
// //     debugPrint("--------- Temporary Directory Path: --------> ${temp.path}");

// //     if (await tempImageDirectory.exists()) {
// //       img = File(image.path);
// //       imageFile = await img.copy('${temp.path}/images/${image.name}');
// //     } else {
// //       await Directory('${temp.path}/images').create();
// //       img = File(image.path);
// //       imageFile = await img.copy('${temp.path}/images/${image.name}');
// //     }

// //     debugPrint(
// //         "----------------Image Picker Utils : Cached Image Path -----> ${imageFile.path}");

// //     return imageFile.path;
// //   }

// //   Future<File> saveImageToDevice(String fileName) async {
// //     final Directory temp = await getApplicationDocumentsDirectory();
// //     final tempImageDirectory = Directory('${temp.path}/images');

// //     final imagePath = tempImageDirectory.path + fileName;

// //     return File(imagePath);
// //   }
// // }

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_cropper/image_cropper.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:path_provider/path_provider.dart';

// class ImagePickerUtil {
//   ImagePickerUtil._privateConstructor();

//   static final ImagePickerUtil instance = ImagePickerUtil._privateConstructor();

//   final _imagePicker = ImagePicker();

//   Future<List<String>> getImages({
//     ImageSource source = ImageSource.camera,
//     bool isCropperRequired = true,
//   }) async {
//     debugPrint("\n === Picking multiple images === \n");

//     final List<XFile>? imageFiles = await _imagePicker.pickMultiImage(
//       imageQuality: 75,
//       maxHeight: 1024,
//       maxWidth: 1024,
//     );

//     if (imageFiles == null || imageFiles.isEmpty) {
//       debugPrint("No images selected.");
//       return [];
//     }

//     List<String> imagePaths = [];

//     for (XFile imageFile in imageFiles) {
//       String? finalPath;

//       if (isCropperRequired) {
//         final CroppedFile? cropped = await ImageCropper().cropImage(
//           sourcePath: imageFile.path,
//           uiSettings: [
//             AndroidUiSettings(
//               toolbarTitle: 'Crop Image',
//               toolbarColor: Colors.indigo[300],
//               toolbarWidgetColor: Colors.white,
//               activeControlsWidgetColor: Colors.indigo[300],
//               lockAspectRatio: false,
//               initAspectRatio: CropAspectRatioPreset.original,
//             ),
//             IOSUiSettings(
//               title: 'Crop Image',
//               aspectRatioLockEnabled: false,
//             ),
//           ],
//         );

//         if (cropped != null) {
//           finalPath =
//               await getCachedImageFromDevice(image: XFile(cropped.path));
//         } else {
//           debugPrint("User skipped cropping.");
//           finalPath = await getCachedImageFromDevice(image: imageFile);
//         }
//       } else {
//         finalPath = await getCachedImageFromDevice(image: imageFile);
//       }

//       if (finalPath.isNotEmpty) {
//         imagePaths.add(finalPath);
//       }
//     }

//     return imagePaths;
//   }

//   Future<String> getCachedImageFromDevice({required XFile image}) async {
//     final Directory temp = await getApplicationDocumentsDirectory();
//     final tempImageDirectory = Directory('${temp.path}/images');

//     if (!await tempImageDirectory.exists()) {
//       await tempImageDirectory.create();
//     }

//     final File img = File(image.path);
//     final File imageFile =
//         await img.copy('${tempImageDirectory.path}/${image.name}');

//     return imageFile.path;
//   }
// }
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImagePickerUtil {
  ImagePickerUtil._privateConstructor();
  static final ImagePickerUtil instance = ImagePickerUtil._privateConstructor();

  final ImagePicker _imagePicker = ImagePicker();

  /// Function to capture multiple images using the camera
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

        // Crop the image if required
        if (isCropperRequired) {
          finalPath = await _cropImage(imageFile.path, context) ?? finalPath;
        }

        // Store the image and get the cached path
        final String storedPath = await _saveImageToStorage(File(finalPath));
        imagePaths.add(storedPath);
      }

      // Ask user if they want to take another photo
      takeAnother = await _askUserForMorePhotos(context);
    }

    return imagePaths;
  }

  /// Function to crop an image
  Future<String?> _cropImage(String imagePath, BuildContext context) async {
    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imagePath,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.indigo,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: Colors.indigo,
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

  /// Function to save image to device storage
  Future<String> _saveImageToStorage(File image) async {
    final Directory tempDir = await getApplicationDocumentsDirectory();
    final Directory imageDir = Directory('${tempDir.path}/images');

    // Create directory if it doesn't exist
    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }

    final String newPath =
        '${imageDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final File savedImage = await image.copy(newPath);

    return savedImage.path;
  }

  /// Function to ask the user if they want to take more photos
  Future<bool> _askUserForMorePhotos(BuildContext context) async {
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
        false; // Default to false if the dialog is dismissed
  }
}
