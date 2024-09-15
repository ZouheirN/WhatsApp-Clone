import 'package:flutter/material.dart';
import 'package:whatsapp_clone/colors.dart';

class SenderGroupMessageCard extends StatelessWidget {
  final String message;
  final String time;
  final String senderProfileUrl;

  const SenderGroupMessageCard({
    super.key,
    required this.message,
    required this.time,
    required this.senderProfileUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 45,
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundImage: NetworkImage(senderProfileUrl),
              ),
              Expanded(
                child: Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  color: senderMessageColor,
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 10, right: 30, top: 5, bottom: 20),
                        child: Text(
                          message,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Positioned(
                        bottom: 2,
                        right: 10,
                        child: Row(
                          children: [
                            Text(
                              time.toString(),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white60,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
