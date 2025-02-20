import 'package:fabspinrider/booking/screen/after_splash.dart';
import 'package:fabspinrider/controller/controller.dart';
import 'package:fabspinrider/widgets/NotificationService.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Background message handler - must be a top-level function
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  RiderController controller = Get.put(RiderController());
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt('user_id');
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize notification service
  final NotificationService notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestNotificationPermissions();

  FirebaseMessaging.instance.getToken().then((token) {
    print("Firebase Token: $token");
    controller.updateFcm(userId.toString(), token.toString());
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      //home: SplashScreen()
      home: AfterSplash(),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// void main() {
//   runApp(MaterialApp(
//     home: PriceCounterDemo(),
//   ));
// }

// class PriceCounterDemo extends StatefulWidget {
//   @override
//   _PriceCounterDemoState createState() => _PriceCounterDemoState();
// }

// class _PriceCounterDemoState extends State<PriceCounterDemo> {
//   final TextEditingController _priceController = TextEditingController();

//   double pricePerItem = 60.0;
//   int quantity = 1;
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchDataFromAPI();
//   }

//   Future<void> _fetchDataFromAPI() async {
//     await Future.delayed(const Duration(seconds: 2));
//     setState(() {
//       pricePerItem = 60.0;
//       quantity = 1;
//       isLoading = false;
//       _updatePriceField();
//     });
//   }

//   void _updatePriceField() {
//     double totalPrice = pricePerItem * quantity;
//     _priceController.text = totalPrice.toString();
//   }

//   void _incrementQuantity() {
//     setState(() {
//       quantity++;
//       _updatePriceField();
//     });
//   }

//   void _decrementQuantity() {
//     if (quantity > 1) {
//       setState(() {
//         quantity--;
//         _updatePriceField();
//       });
//     }
//   }

//   void _onPriceChanged(String value) {
//     try {
//       String sanitizedValue = value.replaceAll(',', '');
//       double newTotalPrice = double.tryParse(sanitizedValue) ?? 0.0;

//       if (newTotalPrice > 0) {
//         setState(() {
//           pricePerItem = newTotalPrice / quantity;
//         });
//       }
//     } catch (e) {
//       // Handle parsing errors
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Price Counter Example")),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Card(
//                 color: Colors.grey.shade100,
//                 child: Padding(
//                   padding: const EdgeInsets.all(12.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text("Shirt",
//                           style: TextStyle(
//                               fontSize: 18, fontWeight: FontWeight.bold)),
//                       Text("Price per item: ₹${pricePerItem}"),
//                       SizedBox(height: 16),
//                       Row(
//                         children: [
//                           IconButton(
//                             onPressed: _decrementQuantity,
//                             icon: Icon(Icons.remove),
//                             style: IconButton.styleFrom(
//                               backgroundColor: Colors.grey.shade200,
//                             ),
//                           ),
//                           Text("$quantity", style: TextStyle(fontSize: 18)),
//                           IconButton(
//                             onPressed: _incrementQuantity,
//                             icon: Icon(Icons.add, color: Colors.white),
//                             style: IconButton.styleFrom(
//                               backgroundColor: Colors.black,
//                             ),
//                           ),
//                           Spacer(),
//                           SizedBox(
//                             width: 100,
//                             child: TextFormField(
//                               controller: _priceController,
//                               keyboardType: TextInputType.numberWithOptions(
//                                   decimal: true),
//                               inputFormatters: [
//                                 FilteringTextInputFormatter.allow(
//                                     RegExp(r'[\d,.]')),
//                               ],
//                               onChanged: _onPriceChanged,
//                               decoration: InputDecoration(
//                                 labelText: "Total",
//                                 border: OutlineInputBorder(),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//     );
//   }
// }
