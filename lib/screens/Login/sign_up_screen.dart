import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class SignUpScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _password2Controller = TextEditingController();

  SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: '이메일'),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      obscureText: true,
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: '비밀번호'),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      obscureText: true,
                      controller: _password2Controller,
                      decoration: const InputDecoration(labelText: '비밀번호 확인'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () async {
                  bool success = await signUp(context);
                  if (success) {
                    Navigator.pop(context);
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 330,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF9800CB).withAlpha(166),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.account_circle,
                        color: Colors.white,
                        size: 28,
                      ),
                      SizedBox(
                        width: 280,
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "이메일/비밀번호로 회원가입",
                            style: TextStyle(
                              fontSize: 17,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Future signUp(BuildContext context) async {
    // 비밀번호 확인 로직 추가
    if (_passwordController.text != _password2Controller.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
      );
      return false;
    }

    try {
      // Firebase 회원가입
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (userCredential.user != null) {
        // OneSignal External ID 설정
        try {
          await OneSignal.login(userCredential.user!.uid);
          debugPrint(
              'OneSignal External ID 설정 성공: ${userCredential.user!.uid}');
        } catch (oneSignalError) {
          debugPrint('OneSignal 설정 실패: $oneSignalError');
          // OneSignal 설정 실패는 회원가입 실패로 처리하지 않음
        }

        debugPrint('회원가입 성공: ${userCredential.user}');
        return true;
      }
      return false;
    } catch (e) {
      String errorMessage = '회원가입 실패';

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = '이미 사용 중인 이메일입니다.';
            break;
          case 'weak-password':
            errorMessage = '비밀번호가 너무 약합니다.';
            break;
          case 'invalid-email':
            errorMessage = '유효하지 않은 이메일 형식입니다.';
            break;
          default:
            errorMessage = '회원가입 중 오류가 발생했습니다.';
        }
      }

      debugPrint('회원가입 실패: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      return false;
    }
  }
}
