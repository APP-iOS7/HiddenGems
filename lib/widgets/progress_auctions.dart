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
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: CustomScrollView(
            scrollDirection: Axis.horizontal,
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
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
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Center(child: Text('Item $index')),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 70,
                                    child: Text(
                                      '작품 제목',
                                      style: TextStyle(fontSize: 18),
                                      overflow: TextOverflow.ellipsis,
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
