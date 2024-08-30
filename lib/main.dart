import 'package:flashchat/routes/route_manager.dart';
import 'package:flashchat/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(FlashChat());
}

class FlashChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Chatting App',
      debugShowCheckedModeBanner: false,
      initialRoute: ChattingAppRoutes.loginRoute,
      onGenerateRoute: RouteManager.generateRoute,

    );
  }
}
