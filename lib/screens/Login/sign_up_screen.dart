import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _password2Controller = TextEditingController();

  SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
                  SizedBox(height: 20),
                  TextField(
                    obscureText: true,
                    controller: _password2Controller,
                    decoration: const InputDecoration(labelText: '비밀번호 확인'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            InkWell(
                onTap: signUp,
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
                            "이메일/비밀번호로 회원가입",
                            style: TextStyle(
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            Spacer(),
            Spacer(),
          ],
        ),
      ),
    );
  }

  Future<void> signUp() async {
    try {
      if (_passwordController.text == _password2Controller.text) {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        debugPrint('회원가입 성공 : ${userCredential.user}');
      }
    } catch (e) {
      debugPrint('회원가입 실패 : ${e.toString()}');
    }
  }
}
