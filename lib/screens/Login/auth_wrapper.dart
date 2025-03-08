// 로그인 상태에 따라 화면을 전환하는 위젯
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gems/main.dart';
import 'package:hidden_gems/providers/user_provider.dart';
import 'package:hidden_gems/screens/Login/login_screen.dart';
import 'package:hidden_gems/screens/Login/profile_update_screen.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
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
              if (userProvider.user == null) {
                userProvider.loadUser();
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (userProvider.user!.nickName.isEmpty) {
                return const ProfileUpdateScreen();
              }
              return const HomeScreen();
            },
          );
        }
        return Loginscreen();
      },
    );
  }
}
