import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gems/providers/auction_works_provider.dart';
import 'package:hidden_gems/providers/user_provider.dart';
import 'package:hidden_gems/providers/work_provider.dart';
import 'package:hidden_gems/screens/profile_update_screen.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:provider/provider.dart';

import 'screens/Login/login_screen.dart';
import '../screens/mypage_screen.dart';
import '../screens/Works/works_screen.dart';
import 'screens/auction_works_screen.dart';
import '../screens/home_screen.dart';

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
      ChangeNotifierProvider(
        create: (_) => UserProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => AuctionWorksProvider(),
      )
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
              },
              icon: Icon(Icons.logout))
        ],
      ),
      body: _pages[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final workProvider =
              Provider.of<WorkProvider>(context, listen: false);
          final userProvider =
              Provider.of<UserProvider>(context, listen: false);
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
      workPhotoURL: 'https://picsum.photos/200/300',
      minPrice:
          (10 + (DateTime.now().millisecondsSinceEpoch % 100) * 5).toDouble(),
      likedUsers: [],
      doAuction: true,
    );

    workProvider.addWork(dummyWork);
  }
}

// 로그인 상태에 따라 화면을 전환하는 위젯
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  Future<void>? _userFuture;

  @override
  void initState() {
    super.initState();
    // Provider에서 한 번만 사용자 데이터를 불러오기 위해 future를 초기화합니다.
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _userFuture = userProvider.loadUser();
  }

  @override
  Widget build(BuildContext context) {
    // listen: true로 변경하여 Provider의 상태변화를 감지합니다.
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    print("AuthWrapper 호출됨");
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (authSnapshot.hasData) {
          return FutureBuilder(
            future: _userFuture,
            builder: (context, AsyncSnapshot loadSnapshot) {
              if (loadSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              // user 정보가 없거나 닉네임이 비어있으면 ProfileUpdateScreen으로 이동
              if (userProvider.user == null ||
                  userProvider.user!.nickName.isEmpty) {
                return const ProfileUpdateScreen();
              }
              // user 정보가 완전하면 HomeScreen으로 이동
              return const HomeScreen();
            },
          );
        }
        return Loginscreen();
      },
    );
  }
}
