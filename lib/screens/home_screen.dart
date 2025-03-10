import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hidden_gems/screens/Artist/artist_screen.dart';
import 'package:hidden_gems/widgets/popular_artist.dart';
import 'package:hidden_gems/widgets/popular_works.dart';
import 'package:hidden_gems/widgets/progress_auctions.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../providers/notification_provider.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                    onPressed: () {
                      // context.read<NotificationProvider>().sendNotification();
                    },
                    child: Text('notificationTest')),
                _buildSectionHeader(
                    context, 'Live Auctions', Icons.gavel_rounded, null, null),
                const SizedBox(height: 15),
                const ProgressAuctions(),

                _buildDivider(),

                _buildSectionHeader(
                    context, 'Popular Works', Icons.star_rounded, null, null),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                  child: const PopularWorks(),
                ),

                // 섹션 구분선
                _buildDivider(),

                // 인기 작가 섹션
                _buildSectionHeader(
                    context, 'Famous Artists', Icons.person_rounded, 'More',
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ArtistScreen(),
                    ),
                  );
                }),
                const SizedBox(height: 15),
                const PopularArtist(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 섹션 헤더 위젯
  Widget _buildSectionHeader(BuildContext context, String title, IconData icon,
      String? buttonText, VoidCallback? onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.purple,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          const Spacer(),
          if (buttonText != null && onPressed != null)
            TextButton(
              onPressed: onPressed,
              style: TextButton.styleFrom(
                backgroundColor:
                    Theme.of(context).primaryColor.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    buttonText,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // 섹션 구분선 위젯
  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Container(
        height: 8,
        color: const Color(0xFFF3EDF7),
      ),
    );
  }
}
