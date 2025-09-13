import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:minimize_flutter_app/minimize_flutter_app.dart';
import 'package:video_player/video_player.dart';

class FullscreenLiveStreamPage extends StatefulWidget {
  const FullscreenLiveStreamPage({super.key});

  @override
  State<FullscreenLiveStreamPage> createState() =>
      _FullscreenLiveStreamPageState();
}

class _FullscreenLiveStreamPageState extends State<FullscreenLiveStreamPage>
    with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  final String streamUrl =
      "https://livestream.flameinfosys.com/n4news/news/playlist.m3u8";

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Force fullscreen landscape
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _initPlayer();
  }

  Future<void> _initPlayer() async {
    setState(() => _isLoading = true);

    // Dispose any existing controller
    await _controller?.dispose();

    final controller = VideoPlayerController.networkUrl(Uri.parse(streamUrl));

    try {
      await controller.initialize();
      controller.setLooping(true);
      controller.play();

      if (mounted) {
        setState(() {
          _controller = controller;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Video init failed: $e");
      if (mounted) setState(() => _isLoading = true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    // Restore portrait + system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _controller?.pause();
    } else if (state == AppLifecycleState.resumed) {
      // Re-initialize fresh when resuming
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _initPlayer();
      });
    }
  }


  Future<bool> _onWillPop() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Exit Stream?"),
        content: const Text("Do you want to minimize the app?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );

    if (shouldExit ?? false) {
      // 🔑 Works exactly like pressing the Home button on Android
      await MinimizeFlutterApp.minimizeApp();
      return false; // don’t pop Flutter route manually
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: _isLoading || _controller == null
              ? const CircularProgressIndicator(color: Colors.white)
              : AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          ),
        ),
      ),
    );
  }
}
