import 'package:flutter/material.dart';

class ProgressAuctions extends StatelessWidget {
  const ProgressAuctions({super.key});

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
                                  Container(
                                    width: 70,
                                    child: Text(
                                      '작품 제목',
                                      style: TextStyle(fontSize: 18),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '작가',
                                        style: TextStyle(fontSize: 9),
                                      ),
                                      Text(
                                        '현재가',
                                        style: TextStyle(fontSize: 9),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: 20,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
