import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ruta_app/controllers/balance_controller.dart';
import 'package:ruta_app/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializar Google Mobile Ads SDK
  await MobileAds.instance.initialize();
  Get.put(BalanceController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Rutita',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 3, 136, 92)),
        useMaterial3: true,
      ),
      initialRoute: '/home',
      getPages: [
        GetPage(name: '/home', page: () => const MyHomePage(title: 'Rutita')),
      ],
    );
  }
}
