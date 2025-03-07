import 'package:flutter/material.dart';
import 'package:hidden_gems/screens/authors_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '실시간 진행 중인 경매',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),
          SizedBox(
            height: 100,
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
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '인기 작품들',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),
          SizedBox(
            height: 100,
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
          Row(
            children: [
              Text(
                '인기 작가들',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              Spacer(),
              TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AuthorsScreen(),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Text(
                        '더보기',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: Colors.grey[600],
                      )
                    ],
                  ))
            ],
          ),
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
      ),
    );
  }
}
