import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:list_it/ChangeNotifiers/client.dart';
import 'package:list_it/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:list_it/utils/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Prefs.init();
  var determinedRoute = await Prefs.determineRoute();
  runApp(MyApp(landingPage: determinedRoute));
}

class MyApp extends StatelessWidget {
  final Widget landingPage;

  const MyApp({super.key, required this.landingPage});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => Client(),
      child: Consumer<Client>(
        builder: (context, client, child) => MaterialApp(
          theme: kAppThemeDataLight,
          darkTheme: kAppThemeDataDark,
          themeMode: ThemeMode.system,
          title: 'Shopping List App',
          home: landingPage,
        ),
      ),
    );
  }
}
