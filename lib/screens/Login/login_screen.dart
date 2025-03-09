import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hidden_gems/screens/Login/sign_up_screen.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class Loginscreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Loginscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Spacer(),
                Text(
                  'Hidden Gems',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: '이메일'),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        obscureText: true,
                        controller: _passwordController,
                        decoration: const InputDecoration(labelText: '비밀번호'),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 60),
                InkWell(
                    onTap: signIn,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 330,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF9800CB).withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.account_circle,
                            color: Colors.white,
                            size: 28,
                          ),
                          // 오른쪽 텍스트
                          SizedBox(
                            width: 280,
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                "이메일/비밀번호로 로그인",
                                style: TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: loginWithKakao,
                      child: Image.asset(
                        'lib/assets/kakaoLogin.png',
                        width: 160,
                      ),
                    ),
                    SizedBox(width: 10),
                    InkWell(
                      onTap: loginWithGoogle,
                      child: Image.asset(
                        'lib/assets/googleLogin.png',
                        width: 160,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => SignUpScreen()));
                  },
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade700,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.grey),
                  ),
                ),
                Spacer(),
              ],
            ),
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
