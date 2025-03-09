import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gems/models/user.dart';
import 'package:hidden_gems/models/works.dart';
import 'package:hidden_gems/providers/user_provider.dart';
import 'package:hidden_gems/screens/Works/workdetail_screen.dart';
import 'package:provider/provider.dart';

class ArtistDetailScreen extends StatefulWidget {
  const ArtistDetailScreen({super.key, required this.user});
  final AppUser user;

  @override
  State<ArtistDetailScreen> createState() => _ArtistDetailScreenState();
}

bool subscribing = false;

class _ArtistDetailScreenState extends State<ArtistDetailScreen> {
  @override
  void initState() {
    super.initState();
    subscribing = false;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.user!.subscribeUsers.contains(widget.user.id) ||
        userProvider.user!.id == widget.user.id) {
      setState(() {
        subscribing = true;
      });
    }
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
              onPressed: subscribing
                  ? null
                  : () {
                      setState(() {
                        subscribing = !subscribing;
                        final updatedSubscribeUsers = List<String>.from(
                            userProvider.user!.subscribeUsers);
                        updatedSubscribeUsers.add(widget.user.id);
                        userProvider
                            .updateUserSubscribeUsers(updatedSubscribeUsers);
                      });
                    },
              child: Text(userProvider.user!.id == widget.user.id
                  ? ''
                  : subscribing
                      ? '구독 중'
                      : '구독하기'))
        ],
        title: Text('${widget.user.nickName} 님의 작품'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: widget.user.myWorks.length,
          itemBuilder: (context, index) {
            final workId = widget.user.myWorks[index];
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('works')
                  .doc(workId)
                  .get(),
              builder: (context, workSnapshot) {
                if (workSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (workSnapshot.hasError ||
                    !workSnapshot.hasData ||
                    !workSnapshot.data!.exists) {
                  return const Center(child: Text('오류가 발생했습니다.'));
                }

                // Firestore 문서를 Work 객체로 변환
                final work = Work.fromFirestore(workSnapshot.data!);

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WorkdetailScreen(work: work),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: NetworkImage(
                          work.workPhotoURL.isNotEmpty
                              ? work.workPhotoURL
                              : 'https://picsum.photos/200/300',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Text(
                            work.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
