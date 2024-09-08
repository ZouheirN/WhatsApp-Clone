import 'package:flutter/material.dart';
import 'package:whatsapp_clone/colors.dart';

class WebProfileBar extends StatelessWidget {
  const WebProfileBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.077,
      width: MediaQuery.of(context).size.width * 0.25,
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(
            color: dividerColor,
          ),
        ),
        color: webAppBarColor,
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(
                'https://media.cntraveler.com/photos/60596b398f4452dac88c59f8/16:9/w_3999,h_2249,c_limit/MtFuji-GettyImages-959111140.jpg'),
          ),
          const Spacer(),
          IconButton(
              onPressed: () {},
              icon: const Icon(Icons.comment, color: Colors.grey)),
          IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert, color: Colors.grey)),
        ],
      ),
    );
  }
}
