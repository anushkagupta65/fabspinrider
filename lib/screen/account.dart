// import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:ionicons/ionicons.dart';
// import 'package:permission_handler/permission_handler.dart';
import '../controller/controller.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  final RiderController profileController = Get.put(RiderController());

  // File? _image;  // Variable to store the selected image

  // final ImagePicker _picker = ImagePicker();  // Image picker instance

  // // Function to request permissions

  // Future<void> _requestPermission() async {
  //   var status = await Permission.photos.request();

  //   if (status.isGranted) {
  //     print('Permission granted');
  //   } else if (status.isDenied) {
  //     print('Permission denied');
  //   } else if (status.isPermanentlyDenied) {
  //     print('Permission permanently denied');
  //     openAppSettings();  // Opens app settings if the permission is permanently denied
  //   }
  // }

  // // Image picking function
  // Future<void> _pickImage() async {
  //   // Request permission to manage external storage
  //   if (await Permission.manageExternalStorage.isGranted) {
  //     // Proceed with image picking if permission is granted
  //     final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

  //     if (image != null) {
  //       setState(() {
  //         _image = File(image.path); // Set the picked image
  //       });
  //     }
  //   } else {
  //     // Request permission to manage external storage
  //     Permission.manageExternalStorage.request();
  //   }
  // }

  @override
  void initState() {
    super.initState();
    profileController.getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Center(
            child: Text(
          'Account',
          style: TextStyle(color: Colors.white),
        )),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Container(
        child: Column(
          children: [
            SizedBox(height: 25),
            // Stack(
            //   children: [
            //     CircleAvatar(
            //       radius: 70,
            //       backgroundColor: Colors.transparent,
            //       child: ClipOval(
            //         child: _image != null
            //             ? Image.file(
            //           _image!,
            //           fit: BoxFit.cover,
            //           width: 140,
            //           height: 140,
            //         )
            //             : Icon(
            //           Icons.person, // Placeholder icon
            //           size: 140,
            //           color: Colors.grey,
            //         ),
            //       ),
            //     ),
            //     Positioned(
            //       right: 10,
            //       bottom: 10,
            //       child: InkWell(
            //         onTap: _pickImage, // Triggers image picking
            //         child: Container(
            //           decoration: BoxDecoration(
            //             color: Colors.grey,
            //             borderRadius: BorderRadius.circular(10),
            //           ),
            //           child: Icon(Icons.add),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            const Expanded(
              child: CircleAvatar(
                radius: 70,
                backgroundColor: Colors.black,
                child: ClipOval(
                  child:
                      // _image != null
                      //     ? Image.file(
                      //   _image!,
                      //   fit: BoxFit.cover,
                      //   width: 140,
                      //   height: 140,
                      // )
                      //     :
                      Icon(
                    Icons.person, // Placeholder icon
                    size: 140,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black)),
                    child: Row(
                      children: [
                        SizedBox(width: 8),
                        Icon(Ionicons.person_outline),
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Obx(
                            () => Text(
                              profileController.name.value,
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w400),
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black)),
                    child: Row(
                      children: [
                        SizedBox(width: 8),
                        Icon(Ionicons.phone_portrait_outline),
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Obx(() => Text(profileController.mobile.value,
                              style: TextStyle(
                                  fontWeight: FontWeight.w400, fontSize: 12))),
                        )),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black)),
                    child: Row(
                      children: [
                        SizedBox(width: 8),
                        Icon(Ionicons.storefront_outline),
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Obx(() => Text(
                              profileController.storedAddress.value,
                              style: TextStyle(
                                  fontWeight: FontWeight.w400, fontSize: 12))),
                        )),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black)),
                    child: Row(
                      children: [
                        SizedBox(width: 8),
                        Icon(Ionicons.mail_open_outline),
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Obx(
                            () => Text(
                              profileController.email.value,
                              style: TextStyle(
                                  fontWeight: FontWeight.w400, fontSize: 12),
                            ),
                          ),
                        )),
                        SizedBox(width: 15),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  // Container(
                  //   decoration: BoxDecoration(
                  //       borderRadius: BorderRadius.circular(8),
                  //       border: Border.all(color: Colors.black)),
                  //   child: Row(
                  //     children: [
                  //       SizedBox(width: 8),
                  //       Icon(Ionicons.location_outline),
                  //       SizedBox(width: 15),
                  //       Expanded(
                  //           child: Text(
                  //             profileController.,
                  //             style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
                  //           )),
                  //       SizedBox(width: 15),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          height: 60,
                          color: Colors.black,
                          child: Center(
                              child: Text(
                            'Back',
                            style: TextStyle(color: Colors.white),
                          )),
                        ),
                      ),
                    ),
                    // Flexible(
                    //   child: InkWell(
                    //     onTap: () {
                    //       //_updateProfile();
                    //     },
                    //     child: Container(
                    //       height: 60,
                    //       color: Colors.black,
                    //       child: Center(
                    //           child: Text(
                    //             'Update',
                    //             style: TextStyle(color: Colors.white),
                    //           )),
                    //     ),
                    //   ),
                    // )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
