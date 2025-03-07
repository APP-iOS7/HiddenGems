import 'package:flutter/material.dart';
import 'package:hidden_gems/models/works.dart';

class WorkdetailScreen extends StatelessWidget {
  final Work work;

  const WorkdetailScreen({super.key, required this.work});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(work.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(work.workPhotoURL, fit: BoxFit.cover),
            SizedBox(height: 10),
            Text(
              work.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(work.description),
          ],
        ),
      ),
    );
  }
}
