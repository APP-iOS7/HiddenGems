import 'package:flutter/material.dart';
import 'package:hidden_gems/screens/Works/workdetail_screen.dart';
import 'package:provider/provider.dart';

import '../providers/work_provider.dart';

class LikedWorkListScreen extends StatelessWidget {
  const LikedWorkListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workProvider = Provider.of<WorkProvider>(context, listen: false);

    final works = workProvider.works;

    return Scaffold(
      appBar: AppBar(
        title: Text('내가 등록한 작품'),
      ),
      body: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: works.isEmpty
                  ? Center(
                      child: Text('작품이 없습니다.', style: TextStyle(fontSize: 18)),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: works.length,
                        itemBuilder: (context, index) {
                          final work = works[index];

                          return GestureDetector(
                            onTap: () {
                              debugPrint(
                                  "Navigating to WorkdetailScreen with work: ${work.title}");
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        WorkdetailScreen(work: work),
                                  ));
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      work.workPhotoURL.isNotEmpty
                                          ? work.workPhotoURL
                                          : 'https://picsum.photos/200/300', // 기본 이미지 대체
                                    ),
                                    fit: BoxFit.cover, // 이미지를 꽉 차게 표시
                                  ),
                                ),
                                child: Text('test')),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
