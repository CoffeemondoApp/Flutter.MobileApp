import 'package:coffeemondo/pantallas/FirebaseMessaging.dart';
import 'package:coffeemondo/pantallas/user_logeado/variables_globales/varaibles_globales.dart';
import 'package:coffeemondo/widget_tree.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessagingService().setupFirebase();
  Get.put(GlobalController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('es', 'ES'), // Agregar el idioma que deseas utilizar
      ],
      title: "Coffeemondo",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      home: const WidgetTree(),
    );
  }
}
