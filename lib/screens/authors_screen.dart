import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AuthorsScreen extends StatelessWidget {
  AuthorsScreen({super.key});

  final List dummyUserData = List.generate(
    20,
    (index) => {
      'id': 'user_${index.toString().padLeft(3, '0')}',
      'signupDate':
          DateTime.now().subtract(Duration(days: Random().nextInt(365))),
      'profileURL': 'https://i.pravatar.cc/150?img=$index',
      'nickName': [
        '예술이${index + 1}',
        '그림쟁이${index + 1}',
        '미술러버${index + 1}',
        '아트마스터${index + 1}',
        '컬렉터${index + 1}'
      ][Random().nextInt(5)],
      'myWorks': List.generate(
        Random().nextInt(10) + 1,
        (i) => 'work_${(index * 10 + i).toString().padLeft(3, '0')}',
      ),
      'likedWorks': List.generate(
        Random().nextInt(15) + 1,
        (i) => 'work_${Random().nextInt(100).toString().padLeft(3, '0')}',
      ),
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          '작가',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                //  검색 기능
              },
              icon: Icon(
                Icons.search,
                color: Colors.black87,
              ))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12),
          itemCount: dummyUserData.length,
          itemBuilder: (BuildContext context, int index) {
            final user = dummyUserData[index];
            final worksCount = user['myWorks'].length;
            final likesCount = user['likedWorks'].length;

            return GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${user['nickName']}의 프로필'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    width: 1,
                    color: Color(0xB2B2B2B2),
                  ),
                  borderRadius: BorderRadius.circular(15),
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: Colors.grey,
                  //     spreadRadius: 2,
                  //     blurRadius: 5,
                  //     offset: Offset(0, 3),
                  //   )
                  // ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(user['profileURL']),
                      backgroundColor: Colors.grey[200],
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Text(
                      user['nickName'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStatItem(Icons.palette, '$worksCount 작품'),
                        SizedBox(
                          width: 12,
                        ),
                        _buildStatItem(Icons.favorite, '$likesCount 좋아요'),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${DateFormat('yyyy.MM.dd').format(user['signupDate'])} 가입',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        SizedBox(
          width: 4,
        ),
        Text(
          text,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
