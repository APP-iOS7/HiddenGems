import 'package:flutter/material.dart';
import 'package:hidden_gems/screens/authors_screen.dart';
import 'package:hidden_gems/widgets/popular_auction.dart';
import 'package:hidden_gems/widgets/popular_works.dart';
import 'package:hidden_gems/widgets/progress_auctions.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '실시간 진행 중인 경매',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            ProgressAuctions(),
            SizedBox(),
            Text(
              '인기 작품들',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            PopularWorks(),
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
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 14),
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
            PopularAuction()
          ],
        ),
      ),
    );
  }
}
