import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gems/models/works.dart';
import 'package:hidden_gems/providers/user_provider.dart';
import 'package:hidden_gems/screens/Works/workdetail_screen.dart';
import 'package:provider/provider.dart';

class MyWorksScreen extends StatelessWidget {
  const MyWorksScreen({super.key});

  Future<List<String>> myWorksIds(String userId) async {
    final firestore = FirebaseFirestore.instance;
    DocumentSnapshot userDoc =
        await firestore.collection('users').doc(userId).get();

    if (userDoc.exists) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      List<String> myWorksIds = List<String>.from(userData['myWorks'] ?? []);
      return myWorksIds;
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('내가 등록한 작품'),
      ),
      body: FutureBuilder<List<String>>(
        future: myWorksIds(userProvider.user!.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('오류가 발생했습니다.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('등록한 작품이 없습니다.', style: TextStyle(fontSize: 18)));
          } else {
            var myWorksIds = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: myWorksIds.length,
                itemBuilder: (context, index) {
                  final workId = myWorksIds[index];

                  // 각 workId에 대해 Firestore에서 작업 상세 정보를 가져옴
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('works')
                        .doc(workId)
                        .get(),
                    builder: (context, workSnapshot) {
                      if (workSnapshot.connectionState ==
                          ConnectionState.waiting) {
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
                              builder: (context) =>
                                  WorkdetailScreen(work: work),
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
                        ),
                      );
                    },
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
