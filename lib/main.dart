import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gems/providers/user_provider.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:provider/provider.dart';

import 'providers/work_provider.dart';
import '../screens/mypage_screen.dart';
import '../screens/works_screen.dart';
import '../screens/auctionpage_screen.dart';
import '../screens/home_screen.dart';
import 'screens/Login/login_screen.dart';
import 'screens/profile_update_screen.dart';

import 'package:hidden_gems/models/works.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  KakaoSdk.init(
    nativeAppKey: '2564930daedf36a88773ed02c9ada1e6',
    javaScriptAppKey: '9ce33d7e4d669f4997dbf86f82f607ec',
  );
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => UserProvider()),
      ChangeNotifierProvider(create: (_) => WorkProvider()),
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
    AuctionPageScreen(),
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
    print(_selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(_titles[_selectedIndex]),
        actions: [
          IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Provider.of<UserProvider>(context, listen: false).clearUser();
              },
              icon: Icon(Icons.logout))
        ],
      ),
      body: _pages[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final workProvider = Provider.of<WorkProvider>(context, listen: false);
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          _addDummyWork(workProvider, userProvider);
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
              _buildNavItem(Icons.attach_money, 4),
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
  void _addDummyWork(WorkProvider workProvider, UserProvider userProvider) {
    if (userProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("로그인된 사용자 정보가 없습니다.")),
      );
      return;
    }
    final dummyWork = Work(
      artistID: userProvider.user!.id,
      selling: true,
      title: '랜덤 작품 #${DateTime.now().millisecondsSinceEpoch % 1000}',
      description: '이것은 자동 생성된 더미 데이터입니다.',
      createDate: DateTime.now(),
      workPhotoURL: 'https://via.placeholder.com/150',
      minPrice: (10 + (DateTime.now().millisecondsSinceEpoch % 100) * 5)
          .toDouble(),
      likedUsers: [],
      doAuction: false,
    );

    workProvider.addWork(dummyWork);
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final userProvider = Provider.of<UserProvider>(context);

    // 로그인되지 않은 경우 로그인 화면 표시
    if (firebaseUser == null) {
      return Loginscreen();
    }

    // 데이터 로딩 중이면 로딩 인디케이터 표시
    if (userProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 사용자 데이터가 없으면 프로필 업데이트 화면 표시
    if (userProvider.user == null) {
      return const ProfileUpdateScreen();
    }

    // 사용자 데이터가 있으면 홈 화면 표시
    return const HomeScreen();
  }
}

