import 'package:flutter/material.dart';
import 'package:flutter_tawkto/flutter_tawk.dart';



class LiveSupport extends StatelessWidget {
  const LiveSupport({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Climax IT live support'),
          backgroundColor: Colors.blueAccent,
          centerTitle: true,
        ),
        body: Tawk(
          directChatLink: 'https://tawk.to/chat/67c9dee70e9db7190b881a09/1ilm8te6m',
          visitor: TawkVisitor(
            name: 'Climax IT',
            email: 'climaxit@gmail.com',
          ),
          onLoad: () {
            print('Hello Tawk!');
          },
          onLinkTap: (String url) {
            print(url);
          },
          placeholder: const Center(
            child: Text('Loading...'),
          ),
        ),
      ),
    );
  }
}