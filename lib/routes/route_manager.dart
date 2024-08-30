import 'package:flashchat/routes/routes.dart';
import 'package:flashchat/screen/audio_call.dart';
import 'package:flashchat/screen/chat.dart';
import 'package:flashchat/screen/login.dart';
import 'package:flashchat/screen/registration.dart';
import 'package:flashchat/screen/video_call.dart';
import 'package:flutter/material.dart';


class InstantPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  InstantPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return child;
          },
        );
}

class RouteManager {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case ChattingAppRoutes.loginRoute:
        return InstantPageRoute(page:  LoginScreen());
      case ChattingAppRoutes.registrationRoute:
        return InstantPageRoute(page: RegistrationScreen());
      case ChattingAppRoutes.chattingRoute:
        return InstantPageRoute(page: ChatScreen());
      case ChattingAppRoutes.videoRoute:
        return InstantPageRoute(page: const VideoCallScreen());
      case ChattingAppRoutes.audioRoute:
        return InstantPageRoute(page: const AudioCallScreen());
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Unknown Route')),
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
