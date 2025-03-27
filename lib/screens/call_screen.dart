import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late RTCPeerConnection _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  bool _isMuted = false;
  bool _isVideoEnabled = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    final mediaConstraints = {
      'audio': true,
      'video': {'facingMode': 'user'},
    };

    _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    _localRenderer.srcObject = _localStream;

    _peerConnection = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'}
      ]
    });

    for (var track in _localStream!.getTracks()) {
      _peerConnection.addTrack(track, _localStream!);
    }

    _peerConnection.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        setState(() {
          _remoteStream = event.streams[0];
          _remoteRenderer.srcObject = _remoteStream;
        });
      }
    };

    _peerConnection.onConnectionState = (state) {
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
        _handleDisconnection();
      }
    };
  }

  Future<void> createOffer() async {
    RTCSessionDescription offer = await _peerConnection.createOffer();
    await _peerConnection.setLocalDescription(offer);
    // Send `offer` to the other peer using signaling
  }

  Future<void> createAnswer() async {
    RTCSessionDescription answer = await _peerConnection.createAnswer();
    await _peerConnection.setLocalDescription(answer);
    // Send `answer` to the other peer using signaling
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _localStream?.getAudioTracks().forEach((track) {
        track.enabled = !_isMuted;
      });
    });
  }

  void _toggleVideo() {
    setState(() {
      _isVideoEnabled = !_isVideoEnabled;
      _localStream?.getVideoTracks().forEach((track) {
        track.enabled = _isVideoEnabled;
      });
    });
  }

  void _handleDisconnection() {
    print("Call disconnected");
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _localStream?.dispose();
    _remoteStream?.dispose();
    _peerConnection.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Call')),
      body: Column(
        children: [
          Expanded(
              child: RTCVideoView(_localRenderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover)),
          Expanded(
              child: RTCVideoView(_remoteRenderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                  icon: Icon(_isMuted ? Icons.mic_off : Icons.mic),
                  onPressed: _toggleMute),
              IconButton(
                  icon: Icon(
                      _isVideoEnabled ? Icons.videocam : Icons.videocam_off),
                  onPressed: _toggleVideo),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              _peerConnection.close();
              _localStream?.dispose();
              Navigator.pop(context);
            },
            child: const Text('End Call'),
          ),
        ],
      ),
    );
  }
}
