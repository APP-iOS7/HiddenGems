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

class _ArtistDetailScreenState extends State<ArtistDetailScreen> {
  bool subscribing = false;
  int subscriberCount = 0;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.user != null) {
      setState(() {
        subscribing =
            userProvider.user!.subscribeUsers.contains(widget.user.id);
      });
    }
    _fetchSubscriberCount();
  }

  Future<void> _fetchSubscriberCount() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('users').get();

    int count = querySnapshot.docs.where((doc) {
      final List<dynamic> subscribeUsers = doc['subscribeUsers'] ?? [];
      return subscribeUsers.contains(widget.user.id);
    }).length;

    setState(() {
      subscriberCount = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        actions: [
        ],
        title: Text('${widget.user.nickName}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: widget.user.profileURL.isNotEmpty
                        ? NetworkImage(widget.user.profileURL)
                        : const NetworkImage('https://via.placeholder.com/100'),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                            widget.user.nickName,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            "작품 ${widget.user.myWorks.length}",
                            style: const TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          const SizedBox(width: 10),
                          
                          Text(
                            "팔로워 $subscriberCount",
                            style: const TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "팔로잉 ${widget.user.subscribeUsers.length}",
                            style: const TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (userProvider.user!.id != widget.user.id)
                        Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: TextButton(
                          onPressed: subscribing
                              ? () {
                                  // 구독 취소 로직
                                  setState(() {
                                    subscribing = !subscribing;
                                    final updatedSubscribeUsers = List<String>.from(
                                        userProvider.user!.subscribeUsers);
                                    updatedSubscribeUsers.remove(widget.user.id);
                                    userProvider
                                        .updateUserSubscribeUsers(updatedSubscribeUsers);
                                  });
                                  debugPrint(subscribing.toString());
                                  _fetchSubscriberCount();
                                }
                              : () {
                                  // 구독 로직
                                  setState(() {
                                    subscribing = !subscribing;
                                    final updatedSubscribeUsers = List<String>.from(
                                        userProvider.user!.subscribeUsers);
                                    updatedSubscribeUsers.add(widget.user.id);
                                    userProvider
                                        .updateUserSubscribeUsers(updatedSubscribeUsers);
                                  });
                                  debugPrint(subscribing.toString());
                                  _fetchSubscriberCount();
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 10), // 높이 조절
                                  backgroundColor: subscribing ? Colors.grey[300] : Colors.blue, // 배경색 변경
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10), // 모서리 둥글게
                                  ),
                                ),
                            child: Text(
                              subscribing ? '구독 중' : '구독하기',
                              style: TextStyle(color: subscribing? Colors.black : Colors.white),
                            ),
                          ),
                          )
                        )
                    ],
                  ),
                ],
              ),
            ),
          ),
          Divider(),
          Expanded(
            child: Padding(
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
                                  style: const TextStyle(
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
          )
        ],
      )
    );
  }
}
