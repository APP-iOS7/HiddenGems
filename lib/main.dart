import 'package:flutter/material.dart';

import 'screens/loginScreen.dart';

void main() {
  runApp(const MyApp());
}

class Routes {
  static const String home = '/';
  static const String signUp = '/signup';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (context) => const HomeScreen());
      case signUp:
        return MaterialPageRoute(builder: (context) => const Loginscreen());
      default:
        throw Exception('Invalid route: ${settings.name}');
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        // initialRoute 속성을 사용하여 초기 경로를 지정
        // initialRoute: Routes.home,
        initialRoute: Routes.signUp,
        // onGenerateRoute 속성을 사용하여 경로를 생성
        onGenerateRoute: Routes.generateRoute);
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hidden Gems'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'hidden gems',
            ),
          ],
        ),
      ),
    );
  }
}
