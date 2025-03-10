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
                padding: EdgeInsets.all(8),
                child: Container(
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 225, 225, 225),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 90,
                        child: Card(
                          child: Container(
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
                            SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                SizedBox(
                                  width: 50,
                                  child: Text(
                                    work.artistNickName,
                                    style: TextStyle(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),                
                                ),
                                SizedBox(
                                  width: 50,
                                  child: Text(
                                    '${NumberFormat('###,###,###,###').format(work.minPrice)} 원',
                                    style: TextStyle(fontSize: 10),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),                
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
