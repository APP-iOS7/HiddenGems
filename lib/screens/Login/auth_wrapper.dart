// 로그인 상태에 따라 화면을 전환하는 위젯
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gems/main.dart';
import 'package:hidden_gems/providers/user_provider.dart';
import 'package:hidden_gems/screens/Login/login_screen.dart';
import 'package:hidden_gems/screens/Login/profile_update_screen.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  AuthWrapperState createState() => AuthWrapperState();
}

class AuthWrapperState extends State<AuthWrapper> {
  Future<void>? _userFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null && _userFuture == null) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      _userFuture = userProvider.loadUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (authSnapshot.hasData) {
          return Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              // 로딩 중이면 로딩 인디케이터 표시
              if (!userProvider.isLoaded) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              // 로딩 완료 후, user 데이터가 없거나 닉네임이 비어있으면 ProfileUpdateScreen으로 이동
              if (userProvider.user == null ||
                  userProvider.user!.nickName.isEmpty) {
                return const ProfileUpdateScreen();
              }
              return const HomeScreen();
            },
          );
        }
        return LoginScreen();
      },
    );
  }
}
