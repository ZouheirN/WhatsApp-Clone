import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:whatsapp_clone/colors.dart';

class SenderImageMessageCard extends StatelessWidget {
  final String imageUrl;
  final String? caption;
  final String time;

  const SenderImageMessageCard({
    super.key,
    required this.imageUrl,
    this.caption,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 45,
          minWidth: 120,
        ),
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          color: senderMessageColor,
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: 5,
                      right: 5,
                      top: 5,
                      bottom: caption == null ? 25 : 0,
                    ),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      imageBuilder: (context, imageProvider) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image(
                            image: imageProvider,
                            fit: BoxFit.fitHeight,
                          ),
                        );
                      },
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  if (caption != null)
                    Container(
                      padding: const EdgeInsets.only(
                        left: 10,
                        right: 30,
                        top: 5,
                        bottom: 25,
                      ),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        caption!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: textColor,
                        ),
                      ),
                    ),
                ],
              ),
              Positioned(
                bottom: 4,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
