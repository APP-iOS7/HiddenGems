import 'package:flutter/material.dart';
import 'package:hidden_gems/models/works.dart';
import 'package:hidden_gems/providers/work_provider.dart';
import 'package:hidden_gems/screens/Works/workdetail_screen.dart';

class PopularWorks extends StatelessWidget {
  const PopularWorks({super.key});

  Future<List<Work>> fetchPopularWorks() async {
    final workProvider = WorkProvider();
    final works = await workProvider.loadPopularWorks();
    works.sort((a, b) => b.likedUsers.length.compareTo(a.likedUsers.length));

    return works;
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
          height: 450,
          child: ListView.separated(
            padding: EdgeInsets.only(left: 20.0),
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(
              color: Colors.grey,
              thickness: 1,
              height: 10,
            ),
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
                child: Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Container(
                    //color: const Color(0xFFF3EDF7),
                    height: 80,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            //padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 50,
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          "${index + 1}",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.purple,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(4),
                                      child: SizedBox(
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                child: Text(
                                                  work.title,
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w700),
                                                  overflow: TextOverflow.fade,
                                                ),
                                              ),
                                              Text(
                                                work.artistNickName,
                                                style: TextStyle(fontSize: 12),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                work.doAuction
                                                    ? '경매 진행 중'
                                                    : '경매 시작 전',
                                                style: TextStyle(fontSize: 10),
                                                overflow: TextOverflow.visible,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: EdgeInsets.all(5),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.network(
                                        work.workPhotoURL,
                                        height: 80,
                                        width: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
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
