import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/screens/login_screen.dart';
import 'style/app_theme.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getDarkTheme(),
      home: LoginScreen(),
      title: "novaTrack",
      navigatorKey: navigatorKey,
    );
  }
}
