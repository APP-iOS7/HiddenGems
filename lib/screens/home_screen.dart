import 'package:flutter/material.dart';
import 'package:hidden_gems/screens/Artist/artist_screen.dart';
import 'package:hidden_gems/widgets/popular_artist.dart';
import 'package:hidden_gems/widgets/popular_works.dart';
import 'package:hidden_gems/widgets/progress_auctions.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 24, 0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 20.0),
                child: Text(
                  '실시간 진행 중인 경매',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
              ),
              ProgressAuctions(),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.only(left: 20.0),
                child: Text(
                  '인기 작품들',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
              ),
              SizedBox(height: 10),
              PopularWorks(),
              Padding(
                padding: EdgeInsets.only(left: 20.0),
                child: Row(
                  children: [
                    Text(
                      '인기 작가들',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                    Spacer(),
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ArtistScreen(),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Text(
                              '더보기',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 14),
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
              ),
              SizedBox(height: 10),
              PopularArtist()
            ],
          ),
        ),
      ),
    );
  }
}
