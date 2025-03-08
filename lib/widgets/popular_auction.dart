import 'package:flutter/material.dart';

class PopularAuction extends StatelessWidget {
  const PopularAuction({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: CustomScrollView(
            scrollDirection: Axis.horizontal,
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return Column(
                      children: [
                        SizedBox(
                          width: 150,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Center(child: Text('Item $index')),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '작품 제목',
                              style: TextStyle(fontSize: 15),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Column(
                                children: [
                                  Text('작가'),
                                  Text('현재가'),
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    );
                  },
                  childCount: 20,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
