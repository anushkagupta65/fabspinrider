import 'package:fabspinrider/widgets/image_picker_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagePickerCropper extends StatelessWidget {
  const ImagePickerCropper({
    Key? key,
    this.imagePath,
    this.deleteImage,
    this.openCamera,
    required this.showDelete,
    this.isCropperRequired,
    required this.removeDeleteOption,
  }) : super(key: const Key('image-picker-cropper'));

  final void Function(String?)?
      imagePath; // Changed from List<String> to String?
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
            // Camera Button
            CupertinoButton(
              padding: EdgeInsets.zero,
              key: const Key('camera-button'),
              onPressed: () async {
                final PermissionStatus status =
                    await Permission.camera.request();
                await _handlePermission(context, status, ImageSource.camera);
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
                  const SizedBox(height: 5),
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
            // Gallery Button (Added)
            CupertinoButton(
              padding: EdgeInsets.zero,
              key: const Key('gallery-button'),
              onPressed: () async {
                final PermissionStatus status =
                    await Permission.photos.request();
                await _handlePermission(context, status, ImageSource.gallery);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: 30,
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "From Gallery",
                    key: const Key('gallery'),
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
            // Delete Button (unchanged)
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
                    const SizedBox(height: 5),
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

  Future<void> _handlePermission(
    BuildContext context,
    PermissionStatus status,
    ImageSource source,
  ) async {
    if (status.isGranted) {
      if (openCamera != null && source == ImageSource.camera) {
        openCamera!();
      } else {
        final imageSrcPath = await ImagePickerUtil.instance.captureSingleImage(
          context: context,
          source: source,
          // isCropperRequired: isCropperRequired ?? true,
        );
        if (imageSrcPath != null) {
          imagePath!(imageSrcPath);
          Navigator.pop(context);
        }
      }
    } else if (status.isDenied) {
      // Request permission again
      source == ImageSource.camera
          ? await Permission.camera.request()
          : await Permission.photos.request();
    } else {
      // Show dialog to open settings
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
                child: const Text("Open settings"),
              ),
            ],
          );
        },
      );
    }
  }
}

// import 'package:fabspinrider/widgets/image_picker_util.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';

// class ImagePickerCropper extends StatelessWidget {
//   const ImagePickerCropper(
//       {Key? key,
//       this.imagePath,
//       this.deleteImage,
//       this.openCamera,
//       required this.showDelete,
//       this.isCropperRequired,
//       required this.removeDeleteOption})
//       : super(key: const Key('image-picker-cropper'));

//   final void Function(List<String>)? imagePath;
//   final VoidCallback? deleteImage;
//   final VoidCallback? openCamera;
//   final bool showDelete;
//   final bool? isCropperRequired;
//   final bool removeDeleteOption;

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       child: SizedBox(
//         height: 170,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             CupertinoButton(
//               padding: EdgeInsets.zero,
//               key: const Key('camera-button'),
//               onPressed: () async {
//                 final PermissionStatus status =
//                     await Permission.camera.request();
//                 if (status.isGranted) {
//                   if (openCamera != null) {
//                     openCamera!();
//                   } else {
//                     final imageSrcPath = await ImagePickerUtil.instance
//                         .captureMultipleImages(
//                             context: context,
//                             isCropperRequired: isCropperRequired ?? true);
//                     if (imageSrcPath.isNotEmpty) {
//                       imagePath!(imageSrcPath);
//                       Navigator.pop(context);
//                     }
//                   }
//                 } else if (status.isDenied) {
//                   await Permission.camera.request();
//                 } else {
//                   showDialog(
//                     context: context,
//                     builder: (context) {
//                       return AlertDialog(
//                         title: const Text("Enable Permission"),
//                         content: const Text(
//                             "Please allow permission manually to complete the operation."),
//                         actions: [
//                           TextButton(
//                               onPressed: () async {
//                                 await openAppSettings();
//                               },
//                               child: const Text("Open settings"))
//                         ],
//                       );
//                     },
//                   );
//                 }
//               },
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.camera_alt_outlined,
//                     size: 30,
//                     color: Theme.of(context).brightness == Brightness.light
//                         ? Colors.black
//                         : Colors.white,
//                   ),
//                   const SizedBox(
//                     height: 5,
//                   ),
//                   Text(
//                     "Tap to Capture",
//                     key: const Key('camera'),
//                     style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                           color:
//                               Theme.of(context).brightness == Brightness.light
//                                   ? Colors.black
//                                   : Colors.white,
//                         ),
//                   ),
//                 ],
//               ),
//             ),
//             if (!removeDeleteOption)
//               CupertinoButton(
//                 padding: EdgeInsets.zero,
//                 key: const Key('delete-image-button'),
//                 onPressed: !showDelete ? null : deleteImage,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.delete_outline,
//                       size: 30,
//                       color: Theme.of(context).brightness == Brightness.light
//                           ? Colors.black
//                           : Colors.white,
//                     ),
//                     const SizedBox(
//                       height: 5,
//                     ),
//                     Text(
//                       "Delete",
//                       style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                             color:
//                                 Theme.of(context).brightness == Brightness.light
//                                     ? Colors.black
//                                     : Colors.white,
//                           ),
//                     ),
//                   ],
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
