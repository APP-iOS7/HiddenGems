import 'package:flutter/material.dart';
import 'package:hidden_gems/providers/user_provider.dart';
import 'package:hidden_gems/screens/MyPage/auctioned_works_list_screen.dart';
import 'package:hidden_gems/screens/MyPage/my_works_screen.dart';
import 'package:hidden_gems/screens/MyPage/profile_edit_screen.dart';
import 'package:hidden_gems/screens/MyPage/subscribe_users_screen.dart';
import 'package:provider/provider.dart';

import 'liked_work_list_screen.dart';
import 'my_bidding_screen.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String? profileImageUrl;
    String? nickName;
    final userProvider = Provider.of<UserProvider>(context, listen: true);
    if (userProvider.user != null) {
      profileImageUrl = userProvider.user!.profileURL;
      nickName = userProvider.user!.nickName;
    }
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: profileImageUrl != null
                      ? NetworkImage(profileImageUrl)
                      : AssetImage("lib/assets/person.png"),
                ),
                Text(
                  '${nickName!} 님 반갑습니다!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            SizedBox(height: 10),
            Divider(),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.favorite_outline,
                        color: Color(0xFF9800CB),
                        size: 22,
                      ),
                      SizedBox(width: 18),
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        LikedWorkListScreen()));
                          },
                          child: Text('좋아요한 작품 보기',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ))),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(
                        Icons.notifications_active,
                        color: Color(0xFF9800CB),
                        size: 22,
                      ),
                      SizedBox(width: 18),
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        SubscribeUsersScreen()));
                          },
                          child: Text('구독한 작가 보기',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ))),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        color: Color(0xFF9800CB),
                        size: 22,
                      ),
                      SizedBox(width: 18),
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MyWorksScreen()));
                          },
                          child: Text('등록한 작품 보기',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ))),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(
                        Icons.gavel_rounded,
                        color: Color(0xFF9800CB),
                        size: 22,
                      ),
                      SizedBox(width: 18),
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MyBiddingScreen()));
                          },
                          child: Text('참여 중인 경매 보기',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ))),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        color: Color(0xFF9800CB),
                        size: 22,
                      ),
                      SizedBox(width: 18),
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        AuctionedWorksListScreen()));
                          },
                          child: Text('낙찰내역 보기',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ))),
                    ],
                  ),
                  SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProfileEditScreen()));
                          },
                          child: Text('프로필 수정하기',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.w700,
                              ))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
