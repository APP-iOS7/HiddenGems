import 'package:flutter/material.dart';

class Loginscreen extends StatelessWidget {
  const Loginscreen({super.key});

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
              Text('Hidden Gems'),
              Spacer(),
              TextField(),
              TextField(),
              ElevatedButton(onPressed: () {}, child: Text('이메일/비밀번호로 로그인')),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(onPressed: () {}, child: Text('카카오 로그인')),
                  ElevatedButton(onPressed: () {}, child: Text('구글 로그인')),
                ],
              ),
              Spacer()
            ],
          ),
        ),
      ),
    );
  }
}
