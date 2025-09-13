import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class FullscreenLiveStreamPage extends StatefulWidget {
  const FullscreenLiveStreamPage({super.key});

  @override
  State<FullscreenLiveStreamPage> createState() =>
      _FullscreenLiveStreamPageState();
}

class _FullscreenLiveStreamPageState extends State<FullscreenLiveStreamPage>
    with WidgetsBindingObserver {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Force landscape + immersive mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _controller = VideoPlayerController.networkUrl(
      Uri.parse("https://livestream.flameinfosys.com/n4news/news/playlist.m3u8"),
    )
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      })
      ..setLooping(true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    // Reset orientation + UI overlays when leaving
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _controller.pause();
    } else if (state == AppLifecycleState.resumed) {
      _controller.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        )
            : const CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
