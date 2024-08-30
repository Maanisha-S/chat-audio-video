import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioCallScreen extends StatefulWidget {
  const AudioCallScreen({super.key});

  @override
  State<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> {
  int? _remoteUid;
  bool _localUserJoined = false;
  bool _muted = false;
  late RtcEngine _engine;
  Timer? _timer;
  int _callDuration = 0; // Duration in seconds

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    // Retrieve permissions
    await [Permission.microphone].request();

    // Create the engine
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
            _remoteUid = remoteUid;
            _startTimer();
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          debugPrint("remote user $remoteUid left channel");
          setState(() {
            _remoteUid = null;
            _stopTimer();
          });
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint(
              '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
        },
      ),
    );

    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

    await _engine.joinChannel(
      token: "007eJxTYPDnUPy01sG+d2c7g/ktQ5mgED+p5HNe/nUrXO4FJbKvTlNgMDQ0NjZOSzMyTUxJNLEwMLYwSjQyM7GwSDNJMTVOsjDZ0X4grSGQkSHs3CpmRgYIBPE5GJIzEktKMvPSGRgAxs4eUw==",
      channelId: "chatting",
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  @override
  void dispose() {
    _stopTimer();
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

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        _callDuration++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _callDuration = 0;
  }

  String _formatDuration(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Create UI for the audio call with control buttons
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _greyBackground(),
          _callDurationDisplay(),
          _toolbar(),
        ],
      ),
    );
  }

  // Replace black background with grey screen
  Widget _greyBackground() {
    return Container(
      color: Colors.grey.shade900, // Grey background color
      child: Center(
        child: _remoteUserIcon(),
      ),
    );
  }

  // Display an icon or avatar for the remote user or a waiting message
  Widget _remoteUserIcon() {
    return _remoteUid != null
        ? const Icon(
      Icons.account_circle,
      size: 120,
      color: Colors.blueAccent,
    )
        : const Text(
      'Waiting for remote user to join...',
      style: TextStyle(
        color: Colors.white,
        fontSize: 18,
      ),
      textAlign: TextAlign.center,
    );
  }

  // Display the call duration
  Widget _callDurationDisplay() {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: _remoteUid != null
            ? Text(
          _formatDuration(_callDuration),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        )
            : const SizedBox.shrink(), // No timer if remote user hasn't joined
      ),
    );
  }

  // Create toolbar with control buttons
  Widget _toolbar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.only(bottom: 48),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            RawMaterialButton(
              onPressed: _onToggleMute,
              shape: const CircleBorder(),
              elevation: 2.0,
              fillColor: _muted ? Colors.blueAccent : Colors.white,
              padding: const EdgeInsets.all(15.0),
              child: Icon(
                _muted ? Icons.mic_off : Icons.mic,
                color: _muted ? Colors.white : Colors.blueAccent,
                size: 28.0,
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
                size: 28.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
