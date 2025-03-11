import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:hidden_gems/modal.dart';
import 'package:hidden_gems/providers/notification_provider.dart';
import 'package:hidden_gems/screens/Login/auth_wrapper.dart';
import 'package:hidden_gems/providers/auction_works_provider.dart';
import 'package:hidden_gems/providers/user_provider.dart';
import 'package:hidden_gems/providers/work_provider.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:provider/provider.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'screens/MyPage/mypage_screen.dart';
import '../screens/Works/works_screen.dart';
import 'screens/Auctions/auction_works_screen.dart';
import '../screens/home_screen.dart';
import '../screens/Works/addwork_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  KakaoSdk.init(
    nativeAppKey: '2564930daedf36a88773ed02c9ada1e6',
    javaScriptAppKey: '9ce33d7e4d669f4997dbf86f82f607ec',
  );

//Remove this method to stop OneSignal Debugging
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

  OneSignal.initialize("8f8cdaab-a211-4b80-ae3d-d196988e6a78");

// The promptForPushNotificationsWithUserResponse function will show the iOS or Android push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
  OneSignal.Notifications.requestPermission(true);
  Stripe.publishableKey =
      'pk_test_51NDpRJJinXpHIPsErkhbbskGYZltQGnig4OTsxAuRcrWPXCNvyI6Dc8ApCNL4ciBQz1LhIT76fingitKdFTdjztU00zgfNNsgk';
  // await Stripe.instance.applySettings();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => UserProvider()),
      ChangeNotifierProvider(create: (_) => WorkProvider()),
      ChangeNotifierProvider(create: (_) => AuctionWorksProvider()),
      ChangeNotifierProvider(create: (_) => NotificationProvider()),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: AuthWrapper(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;
  final List<Widget> _pages = [
    MyPageScreen(),
    MainScreen(),
    SizedBox(),
    WorkScreen(),
    AuctionWorksScreen(),
  ];

  final List<String> _titles = [
    "마이페이지",
    "Hidden Gems",
    "",
    "작품",
    "경매",
  ];

  void _onItemTapped(int index) {
    if (index == 2) return; // 가운데 버튼은 동작 X
    setState(() {
      _selectedIndex = index;
    });
    debugPrint('$_selectedIndex');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(_titles[_selectedIndex]),
        actions: [
          if (_selectedIndex == 0)
            IconButton(
                onPressed: () async {
                  AddModal(
                    context: context,
                    title: '로그아웃',
                    description: '로그아웃 하시겠습니까?',
                    whiteButtonText: '취소',
                    purpleButtonText: '확인',
                    function: () async {
                      FirebaseAuth.instance.signOut();
                    },
                  );
                },
                // onPressed: () {
                //   FirebaseAuth.instance.signOut();
                // },
                icon: Icon(Icons.logout)),
        ],
      ),
      body: _pages[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // final workProvider =
          //     Provider.of<WorkProvider>(context, listen: false);
          // final userProvider =
          //     Provider.of<UserProvider>(context, listen: false);
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AddWorkScreen()),
          );
        },
        shape: const CircleBorder(),
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.person, 0),
              _buildNavItem(Icons.home, 1),
              const SizedBox(width: 48),
              _buildNavItem(Icons.grid_view, 3),
              _buildNavItem(Icons.gavel_rounded, 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Icon(
        icon,
        color: _selectedIndex == index ? Colors.purple : Colors.grey,
        size: 28,
      ),
    );
  }
}
