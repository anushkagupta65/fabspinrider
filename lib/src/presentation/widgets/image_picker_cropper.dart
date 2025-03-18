import 'package:fabspinrider/src/presentation/widgets/image_picker_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http show MediaType;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

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

  final void Function(String?)? imagePath;
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
        );
        if (imageSrcPath != null) {
          imagePath!(imageSrcPath);
          Navigator.pop(context);
        }
      }
    } else if (status.isDenied) {
      source == ImageSource.camera
          ? await Permission.camera.request()
          : await Permission.photos.request();
    } else {
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

  static Future<void> uploadImage({
    required BuildContext context,
    required ImageSource source,
    required String barcodeId,
    required String imageKey,
    void Function(String?)? imagePathCallback,
  }) async {
    try {
      final PermissionStatus status = await (source == ImageSource.camera
          ? Permission.camera.request()
          : Permission.photos.request());

      if (status.isGranted) {
        final imageSrcPath = await ImagePickerUtil.instance.captureSingleImage(
          context: context,
          source: source,
        );

        if (imageSrcPath != null) {
          if (!imageSrcPath.endsWith('.jpg') &&
              !imageSrcPath.endsWith('.png')) {
            Get.snackbar('Error', 'Please upload a JPG or PNG image');
            return;
          }

          final file = File(imageSrcPath);
          if (!await file.exists()) {
            return;
          }

          var headers = {'Accept': 'application/json'};
          var request = http.MultipartRequest(
            'POST',
            Uri.parse('https://fabspin.org/api/barcode-image-upload'),
          );

          request.fields.addAll({
            'barcode_id': barcodeId,
          });

          String uploadKey = imageKey == 'booking_image' ? 'image' : imageKey;

          var multipartFile = await http.MultipartFile.fromPath(
            uploadKey,
            imageSrcPath,
            contentType: http.MediaType(
                'image', imageSrcPath.endsWith('.jpg') ? 'jpeg' : 'png'),
          );
          request.files.add(multipartFile);

          request.headers.addAll(headers);

          http.StreamedResponse response = await request.send();
          final responseBody = await response.stream.bytesToString();

          if (response.statusCode == 200) {
            imagePathCallback?.call(imageSrcPath);
            Get.snackbar(
              'Success',
              'Image uploaded successfully',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.green,
              colorText: Colors.white,
              duration: const Duration(seconds: 2),
            );
          } else {
            Get.snackbar('Error', 'Failed to upload image: $responseBody');
          }
        }
      } else if (status.isDenied) {
        source == ImageSource.camera
            ? await Permission.camera.request()
            : await Permission.photos.request();
      } else {
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
    } catch (e) {
      Get.snackbar('Error', 'Error uploading image: $e');
    }
  }
}
