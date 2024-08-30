// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// class VideoCallScreen extends StatefulWidget {
//   const VideoCallScreen({super.key});
//
//   @override
//   State<VideoCallScreen> createState() => _VideoCallScreenState();
// }
//
// class _VideoCallScreenState extends State<VideoCallScreen> {
//   int? _remoteUid;
//   bool _localUserJoined = false;
//   bool _muted = false;
//   bool _cameraSwitched = false;
//   bool _isVideoEnabled = true;
//   late RtcEngine _engine;
//
//   @override
//   void initState() {
//     super.initState();
//     initAgora();
//   }
//
//   Future<void> initAgora() async {
//     await [Permission.microphone, Permission.camera].request();
//
//     _engine = createAgoraRtcEngine();
//     await _engine.initialize(const RtcEngineContext(
//       appId: "11333ff25ada480382a26488f4d53b84",
//       channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
//     ));
//
//     _engine.registerEventHandler(
//       RtcEngineEventHandler(
//         onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
//           debugPrint("local user ${connection.localUid} joined");
//           setState(() {
//             _localUserJoined = true;
//           });
//         },
//         onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
//           debugPrint("remote user $remoteUid joined");
//           setState(() {
//             _remoteUid = remoteUid;
//           });
//         },
//         onUserOffline: (RtcConnection connection, int remoteUid,
//             UserOfflineReasonType reason) {
//           debugPrint("remote user $remoteUid left channel");
//           setState(() {
//             _remoteUid = null;
//           });
//         },
//         onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
//           debugPrint(
//               '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
//         },
//       ),
//     );
//
//     await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
//     await _engine.enableVideo();
//     await _engine.startPreview();
//
//     await _engine.joinChannel(
//       token: "007eJxTYOgtbQt4sevdxLTF6x9LLvRM4Htslrw7henMy7ubZnzu0zqvwGBoaGxsnJZmZJqYkmhiYWBsYZRoZGZiYZFmkmJqnGRhMt3hQFpDICNDzsmbzIwMEAjiczAkZySWlGTmpTMwAACKzSN3",
//       channelId: "chatting",
//       uid: 0,
//       options: const ChannelMediaOptions(),
//     );
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     _dispose();
//   }
//
//   Future<void> _dispose() async {
//     await _engine.leaveChannel();
//     await _engine.release();
//   }
//
//   void _onCallEnd(BuildContext context) {
//     Navigator.pop(context);
//   }
//
//   void _onToggleMute() {
//     setState(() {
//       _muted = !_muted;
//     });
//     _engine.muteLocalAudioStream(_muted);
//   }
//
//   void _onSwitchCamera() {
//     setState(() {
//       _cameraSwitched = !_cameraSwitched;
//     });
//     _engine.switchCamera();
//   }
//
//   void _onToggleVideo() {
//     setState(() {
//       _isVideoEnabled = !_isVideoEnabled;
//     });
//     if (_isVideoEnabled) {
//       _engine.enableVideo();
//       _engine.startPreview();
//     } else {
//       _engine.disableVideo();
//     }
//   }
//
//   // Create UI with local view, remote view, and control buttons
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.black,  // Set background color to black
//         body: Stack(
//           children: [
//             Center(
//               child: _isVideoEnabled ? _remoteVideo() : _voiceCallWidget(),
//             ),
//             Align(
//               alignment: Alignment.topLeft,
//               child: SizedBox(
//                 width: 200,
//                 height: 250,
//                 child: Center(
//                   child: _localUserJoined && _isVideoEnabled
//                       ? AgoraVideoView(
//                     controller: VideoViewController(
//                       rtcEngine: _engine,
//                       canvas: const VideoCanvas(uid: 0),
//                     ),
//                   )
//                       : Stack(
//                     children: [
//                       Center(
//                         child: Container(
//                           width: 200,
//                           height:250,
//                           color: Colors.grey, // Background color
//                           child: const Center(
//                             child: CircularProgressIndicator(),
//                           ),
//                         ),
//                       ),
//                       Center(
//                         child: Container(
//                           width: 200,
//                           height: 250,
//                           alignment: Alignment.center,
//                           child: const Icon(
//                             Icons.cancel,
//                             color: Colors.white,
//                             size: 30,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//
//             _toolbar(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Display remote user's video
//   Widget _remoteVideo() {
//     if (_remoteUid != null) {
//       return AgoraVideoView(
//         controller: VideoViewController.remote(
//           rtcEngine: _engine,
//           canvas: VideoCanvas(uid: _remoteUid),
//           connection: const RtcConnection(channelId: "chatting"),
//         ),
//       );
//     } else {
//       return Stack(
//         children: [
//           Container(
//             color:Colors.grey.shade900,  // Background color black
//           ),
//           Container(
//             color: Colors.grey.shade900,  // Gray overlay
//             child: const Center(
//               child: Text(
//                 'Please wait for the remote user to join',
//                 style: TextStyle(color: Colors.white, fontSize: 18),  // Text color white
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ),
//         ],
//       );
//     }
//   }
//
//   // Display voice call widget (e.g., profile picture or icon)
//   Widget _voiceCallWidget() {
//     return const Icon(
//       Icons.account_circle,
//       size: 120,
//       color: Colors.blueAccent,
//     );
//   }
//
//   // Create toolbar with control buttons
//   Widget _toolbar() {
//     return Align(
//       alignment: Alignment.bottomCenter,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 48),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             RawMaterialButton(
//               onPressed: _onToggleMute,
//               shape: const CircleBorder(),
//               elevation: 2.0,
//               fillColor: _muted ? Colors.blueAccent : Colors.white,
//               padding: const EdgeInsets.all(12.0),
//               child: Icon(
//                 _muted ? Icons.mic_off : Icons.mic,
//                 color: _muted ? Colors.white : Colors.blueAccent,
//                 size: 20.0,
//               ),
//             ),
//             RawMaterialButton(
//               onPressed: () => _onCallEnd(context),
//               shape: const CircleBorder(),
//               elevation: 2.0,
//               fillColor: Colors.redAccent,
//               padding: const EdgeInsets.all(15.0),
//               child: const Icon(
//                 Icons.call_end,
//                 color: Colors.white,
//                 size: 35.0,
//               ),
//             ),
//             RawMaterialButton(
//               onPressed: _onToggleVideo,
//               shape: const CircleBorder(),
//               elevation: 2.0,
//               fillColor: Colors.white,
//               padding: const EdgeInsets.all(12.0),
//               child: Icon(
//                 _isVideoEnabled ? Icons.videocam_off : Icons.videocam,
//                 color: Colors.blueAccent,
//                 size: 20.0,
//               ),
//             ),
//             RawMaterialButton(
//               onPressed: _onSwitchCamera,
//               shape: const CircleBorder(),
//               elevation: 2.0,
//               fillColor: Colors.white,
//               padding: const EdgeInsets.all(12.0),
//               child: const Icon(
//                 Icons.switch_camera,
//                 color: Colors.blueAccent,
//                 size: 20.0,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}
class _VideoCallScreenState extends State<VideoCallScreen> {
  List<int> _remoteUids = [];  // Change to a list to handle multiple remote users
  bool _localUserJoined = false;
  bool _muted = false;
  bool _cameraSwitched = false;
  bool _isVideoEnabled = true;
  late RtcEngine _engine;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    await [Permission.microphone, Permission.camera].request();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: "8c94e430c4d54b8f8ecd6d7fbc1e76f0",
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("local user ${connection.localUid} joined");
          setState(() {
            _localUserJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("remote user $remoteUid joined");
          setState(() {
            if (!_remoteUids.contains(remoteUid)) {
              _remoteUids.add(remoteUid);
            }
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          debugPrint("remote user $remoteUid left channel");
          setState(() {
            _remoteUids.remove(remoteUid);
          });
        },
      ),
    );

    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.enableVideo();
    await _engine.startPreview();

    await _engine.joinChannel(
      token: "007eJxTYPDnUPy01sG+d2c7g/ktQ5mgED+p5HNe/nUrXO4FJbKvTlNgMDQ0NjZOSzMyTUxJNLEwMLYwSjQyM7GwSDNJMTVOsjDZ0X4grSGQkSHs3CpmRgYIBPE5GJIzEktKMvPSGRgAxs4eUw==",
      channelId: "chatting",
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _dispose();
  }

  Future<void> _dispose() async {
    await _engine.leaveChannel();
    await _engine.release();
  }

  void _onCallEnd(BuildContext context) {
    Navigator.pop(context);
  }

  void _onToggleMute() {
    setState(() {
      _muted = !_muted;
    });
    _engine.muteLocalAudioStream(_muted);
  }

  void _onSwitchCamera() {
    setState(() {
      _cameraSwitched = !_cameraSwitched;
    });
    _engine.switchCamera();
  }

  void _onToggleVideo() {
    setState(() {
      _isVideoEnabled = !_isVideoEnabled;
    });
    if (_isVideoEnabled) {
      _engine.enableVideo();
      _engine.startPreview();
    } else {
      _engine.disableVideo();
    }
  }

  // Create UI with local view, remote views, and control buttons
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            _isVideoEnabled ? _remoteVideos() : _voiceCallWidget(),
            Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 200,
                height: 250,
                child: Center(
                  child: _localUserJoined && _isVideoEnabled
                      ? AgoraVideoView(
                    controller: VideoViewController(
                      rtcEngine: _engine,
                      canvas: const VideoCanvas(uid: 0),
                    ),
                  )
                      : Stack(
                    children: [
                      Center(
                        child: Container(
                          width: 200,
                          height: 250,
                          color: Colors.grey,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          width: 200,
                          height: 250,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.cancel,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _toolbar(),
          ],
        ),
      ),
    );
  }

  // Display remote users' videos
  Widget _remoteVideos() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
      ),
      itemCount: _remoteUids.length,
      itemBuilder: (context, index) {
        final remoteUid = _remoteUids[index];
        return AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: _engine,
            canvas: VideoCanvas(uid: remoteUid),
            connection: const RtcConnection(channelId: "chatting"),
          ),
        );
      },
    );
  }

  // Display voice call widget (e.g., profile picture or icon)
  Widget _voiceCallWidget() {
    return const Icon(
      Icons.account_circle,
      size: 120,
      color: Colors.blueAccent,
    );
  }

  // Create toolbar with control buttons
  Widget _toolbar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RawMaterialButton(
              onPressed: _onToggleMute,
              shape: const CircleBorder(),
              elevation: 2.0,
              fillColor: _muted ? Colors.blueAccent : Colors.white,
              padding: const EdgeInsets.all(12.0),
              child: Icon(
                _muted ? Icons.mic_off : Icons.mic,
                color: _muted ? Colors.white : Colors.blueAccent,
                size: 20.0,
              ),
            ),
            RawMaterialButton(
              onPressed: () => _onCallEnd(context),
              shape: const CircleBorder(),
              elevation: 2.0,
              fillColor: Colors.redAccent,
              padding: const EdgeInsets.all(15.0),
              child: const Icon(
                Icons.call_end,
                color: Colors.white,
                size: 35.0,
              ),
            ),
            RawMaterialButton(
              onPressed: _onToggleVideo,
              shape: const CircleBorder(),
              elevation: 2.0,
              fillColor: Colors.white,
              padding: const EdgeInsets.all(12.0),
              child: Icon(
                _isVideoEnabled ? Icons.videocam_off : Icons.videocam,
                color: Colors.blueAccent,
                size: 20.0,
              ),
            ),
            RawMaterialButton(
              onPressed: _onSwitchCamera,
              shape: const CircleBorder(),
              elevation: 2.0,
              fillColor: Colors.white,
              padding: const EdgeInsets.all(12.0),
              child: const Icon(
                Icons.switch_camera,
                color: Colors.blueAccent,
                size: 20.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
