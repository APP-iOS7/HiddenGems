import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gems/models/works.dart';
import 'package:hidden_gems/providers/user_provider.dart';
import 'package:hidden_gems/screens/Works/workdetail_screen.dart';
import 'package:provider/provider.dart';

import '../providers/work_provider.dart';

class LikedWorkListScreen extends StatelessWidget {
  const LikedWorkListScreen({super.key});

  Future<List<Work>> fetchLikedWorks(List<String> likedWorkIds) async {
    List<Work> likedWorks = [];
    final firestore = FirebaseFirestore.instance;

    // Firestore의 whereIn 연산자는 한 번의 쿼리에서 최대 10개의 값만 처리할 수 있음
    for (var i = 0; i < likedWorkIds.length; i += 10) {
      var end = (i + 10 < likedWorkIds.length) ? i + 10 : likedWorkIds.length;
      var chunk = likedWorkIds.sublist(i, end);

      var querySnapshot = await firestore
          .collection('works')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      var works =
          querySnapshot.docs.map((doc) => Work.fromFirestore(doc)).toList();
      likedWorks.addAll(works);
    }

    return likedWorks;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final likedWorkIds = userProvider.user?.likedWorks ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('내가 좋아요한 작품'),
      ),
      body: FutureBuilder<List<Work>>(
        future: fetchLikedWorks(likedWorkIds),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('오류가 발생했습니다.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text('좋아요한 작품이 없습니다.', style: TextStyle(fontSize: 18)));
          } else {
            var likedWorks = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: likedWorks.length,
                itemBuilder: (context, index) {
                  final work = likedWorks[index];
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
                      // 이미지 위에 오버레이나 텍스트를 추가하려면 여기에 작성
                    ),
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
