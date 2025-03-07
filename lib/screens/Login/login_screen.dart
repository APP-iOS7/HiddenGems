import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hidden_gems/screens/Login/sign_up_screen.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(),
              Text('Hidden Gems'),
              Spacer(),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                obscureText: true,
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              Spacer(),
              ElevatedButton(onPressed: signIn, child: Text('이메일/비밀번호로 로그인')),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: loginWithKakao,
                    child: Text('카카오 로그인'),
                  ),
                  ElevatedButton(
                    onPressed: loginWithGoogle,
                    child: Text('구글 로그인'),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => SignUpScreen()));
                },
                child: Text('Sign Up'),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> signIn() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      debugPrint('로그인 성공 : ${userCredential.user}');
    } catch (e) {
      debugPrint('로그인 실패 : ${e.toString()}');
    }
  }

  void loginWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint('Google 로그인 취소됨');
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      debugPrint("구글 로그인 성공: ${userCredential.user?.uid}");
    } catch (error) {
      debugPrint("구글 로그인 실패: $error");
    }
  }

  void loginWithKakao() async {
    if (await AuthApi.instance.hasToken()) {
      try {
        AccessTokenInfo tokenInfo = await UserApi.instance.accessTokenInfo();
        debugPrint('토큰 유효성 체크 성공 ${tokenInfo.id} ${tokenInfo.expiresIn}');
        OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
        var provider = OAuthProvider("oidc.hiddengems");
        var credential = provider.credential(
          idToken: token.idToken,
          accessToken: token.accessToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
        debugPrint('Firebase 로그인 성공 ${token.accessToken}');
      } catch (error) {
        if (error is KakaoException && error.isInvalidTokenError()) {
          debugPrint('토큰 만료 $error');
        } else {
          debugPrint('토큰 정보 조회 실패 $error');
        }
        // 에러 발생 시 재로그인 처리
        try {
          OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
          var provider = OAuthProvider("oidc.hiddengems");
          var credential = provider.credential(
            idToken: token.idToken,
            accessToken: token.accessToken,
          );
          await FirebaseAuth.instance.signInWithCredential(credential);
          debugPrint('Firebase 로그인 성공 ${token.accessToken}');
        } catch (error) {
          debugPrint('로그인 실패 $error');
        }
      }
    } else {
      debugPrint('발급된 토큰 없음');
      try {
        OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
        debugPrint('로그인 성공 ${token.accessToken}');
      } catch (error) {
        debugPrint('로그인 실패 $error');
      }
    }
  }
}
