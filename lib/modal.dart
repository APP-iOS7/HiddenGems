import 'package:flutter/material.dart';

class AddModal {
  final BuildContext context;
  final String title;
  final String description;
  final String whiteButtonText;
  final String purpleButtonText;
  final Function function;

  AddModal({
    required this.context,
    required this.title,
    required this.description,
    required this.whiteButtonText,
    required this.purpleButtonText,
    required this.function,
  }) {
    _startAuctionModal(context, title, description, whiteButtonText,
        purpleButtonText, function);
  }
}

void _startAuctionModal(
  BuildContext context,
  String title,
  String description,
  String whiteButtonText,
  String purpleButtonText,
  Function function,
) {
  showModalBottomSheet(
    backgroundColor: Colors.white,
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 120,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.purple),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: Text(whiteButtonText,
                        style: TextStyle(color: Colors.purple)),
                  ),
                ),
                SizedBox(width: 16),
                SizedBox(
                  width: 120,
                  child: ElevatedButton(
                    onPressed: () async {
                      await function();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: Text(purpleButtonText),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
          ],
        ),
      );
    },
  );
}
