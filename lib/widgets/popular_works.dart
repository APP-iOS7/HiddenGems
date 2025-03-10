import 'package:flutter/material.dart';
import 'package:hidden_gems/models/works.dart';
import 'package:hidden_gems/providers/work_provider.dart';
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
          height: 160,
          child: ListView.separated(
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(width: 10),
            scrollDirection: Axis.horizontal,
            itemCount: works.length,
            itemBuilder: (context, index) {
              final work = works[index];

              return Padding(
                padding: EdgeInsets.only(
                  right: 12.0,
                  left: index == 0 ? 0.0 : 0.0,
                ),
                child: SizedBox(
                  width: 150,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 90,
                        child: Card(
                          child: Container(
                            decoration: BoxDecoration(boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.7),
                                spreadRadius: 8,
                                blurRadius: 10,
                                offset:
                                    Offset(0, 5), // changes position of shadow
                              )
                            ]),
                            child: Image.network(
                              work.workPhotoURL,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  style: TextStyle(fontSize: 14),
                                ),
                                Text(
                                  '${NumberFormat('###,###,###,###').format(work.minPrice)} 원',
                                  style: TextStyle(fontSize: 10),
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
