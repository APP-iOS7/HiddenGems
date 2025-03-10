import 'package:flutter/material.dart';
import 'package:hidden_gems/models/auction_work.dart';
import 'package:hidden_gems/models/works.dart';
import 'package:hidden_gems/providers/auction_works_provider.dart';
import 'package:hidden_gems/providers/work_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ProgressAuctions extends StatefulWidget {
  const ProgressAuctions({super.key});

  @override
  ProgressAuctionsState createState() => ProgressAuctionsState();
}

class ProgressAuctionsState extends State<ProgressAuctions> {
  Future<List<AuctionWork>> _fetchAuctionWorks() async {
    final auctionProvider =
        Provider.of<AuctionWorksProvider>(context, listen: false);
    await auctionProvider.fetchAllAuctionWorks();
    return auctionProvider.allAuctionWorks.cast<AuctionWork>();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AuctionWork>>(
        future: _fetchAuctionWorks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('데이터를 불러오는 중 오류 발생'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('진행중인 경매가 없습니다.'));
          }
          final auctionWorks = snapshot.data!;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 160,
                child: CustomScrollView(
                  scrollDirection: Axis.horizontal,
                  slivers: [
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          if (index >= auctionWorks.length) {
                            return SizedBox.shrink();
                          }
                          final auction = auctionWorks[index];
                          return FutureBuilder<Work?>(
                            future: Provider.of<WorkProvider>(context,
                                    listen: false)
                                .getWorkById(auction.workId),
                            builder: (context, workSnapshot) {
                              if (workSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              }
                              if (workSnapshot.hasError ||
                                  !workSnapshot.hasData) {
                                return Text(
                                  '작품 없음',
                                  style: TextStyle(fontSize: 9),
                                );
                              }
                              final work = workSnapshot.data!;
                              return Padding(
                                padding: EdgeInsets.fromLTRB(20, 8, 8, 8),
                                child: Container(
                                    width: 150,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color.fromARGB(
                                              255, 225, 225, 225),
                                          spreadRadius: 2,
                                          blurRadius: 2,
                                          offset: Offset(0, 4),
                                        )
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
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
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: 70,
                                                  child: Text(
                                                    work.title,
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w700),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    SizedBox(
                                                      width: 50,
                                                      child: Text(
                                                        work.artistNickName,
                                                        style: TextStyle(
                                                            fontSize: 14),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 50,
                                                      child: Text(
                                                        '${NumberFormat('###,###,###,###').format(auction.nowPrice)} 원',
                                                        style: TextStyle(
                                                            fontSize: 10),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                              );
                            },
                          );
                        },
                        childCount: auctionWorks.length,
                      ),
                    )
                  ],
                ),
              ),
            ],
          );
        });
  }
}
