import 'package:flutter/material.dart';
import 'package:hidden_gems/models/works.dart';
import 'package:hidden_gems/providers/work_provider.dart';
import 'package:hidden_gems/screens/Works/workdetail_screen.dart';
import 'package:intl/intl.dart';

class PopularWorks extends StatelessWidget {
  const PopularWorks({super.key});

  Future<List<Work>> fetchPopularWorks() async {
    final workProvider = WorkProvider();
    return await workProvider.loadPopularWorks();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Work>>(
      future: fetchPopularWorks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('데이터를 불러오는 중 오류 발생'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('인기 작품이 없습니다.'));
        }

        final works = snapshot.data!;

        return SizedBox(
          height: 180,
          child: ListView.separated(
            padding: EdgeInsets.only(left: 20.0),
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(width: 40),
            scrollDirection: Axis.horizontal,
            itemCount: works.length,
            itemBuilder: (context, index) {
              final work = works[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => WorkdetailScreen(work: work)));
                },
                child: SizedBox(
                  width: 160,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 120,
                        child: Card(
                          child: Container(
                            // width: 160,
                            decoration: BoxDecoration(boxShadow: [
                              BoxShadow(
                                color: Colors.purple.withValues(alpha: 0.2),
                                spreadRadius: 5,
                                blurRadius: 12,
                                offset:
                                    Offset(0, 5), // changes position of shadow
                              )
                            ]),
                            child: Image.network(
                              work.workPhotoURL,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 70,
                              child: Text(
                                work.title,
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w700),
                                overflow: TextOverflow.fade,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  work.artistNickName,
                                  style: TextStyle(fontSize: 13),
                                ),
                                Text(
                                  '${NumberFormat('###,###,###,###').format(work.minPrice)} 원',
                                  style: TextStyle(fontSize: 10),
                                  overflow: TextOverflow.visible,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
