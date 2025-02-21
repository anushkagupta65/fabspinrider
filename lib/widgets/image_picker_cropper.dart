import 'package:fabspinrider/widgets/image_picker_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagePickerCropper extends StatelessWidget {
  const ImagePickerCropper(
      {Key? key,
      this.imagePath,
      this.deleteImage,
      this.openCamera,
      required this.showDelete,
      this.isCropperRequired,
      required this.removeDeleteOption})
      : super(key: const Key('image-picker-cropper'));

  final void Function(List<String>)? imagePath;
  final VoidCallback? deleteImage;
  final VoidCallback? openCamera;
  final bool showDelete;
  final bool? isCropperRequired;
  final bool removeDeleteOption;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SizedBox(
        height: 170,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              key: const Key('camera-button'),
              onPressed: () async {
                final PermissionStatus status =
                    await Permission.camera.request();
                if (status.isGranted) {
                  debugPrint(
                      "\n =================inside if condition============== \n");
                  if (openCamera != null) {
                    openCamera!();
                    debugPrint("\n ======= HERE IN THIS CONDITION ======= \n");
                  } else {
                    debugPrint(
                        "\n =========inside else case and before getimage function========= \n");
                    final imageSrcPath = await ImagePickerUtil.instance
                        .captureMultipleImages(
                            context: context,
                            isCropperRequired: isCropperRequired ?? true);

                    debugPrint(
                        "\n---------------------after getImage is called-------------------\n");

                    debugPrint(
                        "\n----------Image Picker: Selected Image Path From Camera -----> $imageSrcPath\n");
                    if (imageSrcPath.isNotEmpty) {
                      imagePath!(imageSrcPath);
                      Navigator.pop(context);
                    }
                  }
                } else if (status.isDenied) {
                  debugPrint(
                      "\n =================inside else if condition============== \n");

                  await Permission.camera.request();
                } else {
                  debugPrint(
                      "\n =================inside else condition============== \n");

                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Enable Permission"),
                        content: const Text(
                            "Please allow permission manually to complete the operation."),
                        actions: [
                          TextButton(
                              onPressed: () async {
                                await openAppSettings();
                              },
                              child: const Text("Open settings"))
                        ],
                      );
                    },
                  );
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    size: 30,
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    "Tap to Capture",
                    key: const Key('camera'),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.black
                                  : Colors.white,
                        ),
                  ),
                ],
              ),
            ),
            if (!removeDeleteOption)
              CupertinoButton(
                padding: EdgeInsets.zero,
                key: const Key('delete-image-button'),
                onPressed: !showDelete ? null : deleteImage,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 30,
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : Colors.white,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      "Delete",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.black
                                    : Colors.white,
                          ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}






// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:image_cropper/image_cropper.dart';

// class ImagePickerUtil {
//   static final ImagePicker _picker = ImagePicker();

//   static Future<File?> pickImage({required ImageSource source}) async {
//     if (await _requestPermission(source)) {
//       final XFile? pickedFile = await _picker.pickImage(source: source);
//       if (pickedFile != null) {
//         return await _cropImage(File(pickedFile.path));
//       }
//     }
//     return null;
//   }

//   static Future<bool> _requestPermission(ImageSource source) async {
//     Permission permission =
//         source == ImageSource.camera ? Permission.camera : Permission.photos;
//     var status = await permission.status;

//     if (status.isGranted) {
//       return true;
//     } else if (status.isDenied) {
//       status = await permission.request();
//       return status.isGranted;
//     } else if (status.isPermanentlyDenied) {
//       openAppSettings();
//       return false;
//     }
//     return false;
//   }

//   static Future<File?> _cropImage(File imageFile) async {
//     CroppedFile? croppedFile = await ImageCropper().cropImage(
//       sourcePath: imageFile.path,
//       aspectRatioPresets: [
//         CropAspectRatioPreset.square,
//         CropAspectRatioPreset.ratio3x2,
//         CropAspectRatioPreset.original,
//         CropAspectRatioPreset.ratio4x3,
//         CropAspectRatioPreset.ratio16x9
//       ],
//       uiSettings: [
//         AndroidUiSettings(
//           toolbarTitle: 'Crop Image',
//           toolbarColor: Colors.black,
//           toolbarWidgetColor: Colors.white,
//           initAspectRatio: CropAspectRatioPreset.original,
//           lockAspectRatio: false,
//         ),
//         IOSUiSettings(
//           title: 'Crop Image',
//         ),
//       ],
//     );
//     return croppedFile != null ? File(croppedFile.path) : null;
//   }

//   static void showImagePicker(
//       BuildContext context, Function(File?) onImageSelected) {
//     showModalBottomSheet(
//       context: context,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
//       ),
//       builder: (BuildContext bc) {
//         return Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text('Select Image Source',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               SizedBox(height: 10),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   _imageSourceButton(context, Icons.camera_alt, 'Camera',
//                       ImageSource.camera, onImageSelected),
//                   _imageSourceButton(context, Icons.photo_library, 'Gallery',
//                       ImageSource.gallery, onImageSelected),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   static Widget _imageSourceButton(BuildContext context, IconData icon,
//       String label, ImageSource source, Function(File?) onImageSelected) {
//     return Column(
//       children: [
//         IconButton(
//           icon: Icon(icon, size: 40, color: Colors.blue),
//           onPressed: () async {
//             Navigator.pop(context);
//             if (await _requestPermission(source)) {
//               File? image = await pickImage(source: source);
//               onImageSelected(image);
//             }
//           },
//         ),
//         Text(label, style: TextStyle(fontSize: 16)),
//       ],
//     );
//   }
// }
