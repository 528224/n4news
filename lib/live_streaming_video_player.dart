import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'home_screen.dart';
import 'main.dart';

class FullscreenLiveStreamPage extends StatefulWidget {
  const FullscreenLiveStreamPage({super.key});

  @override
  State<FullscreenLiveStreamPage> createState() =>
      _FullscreenLiveStreamPageState();
}

class _FullscreenLiveStreamPageState extends State<FullscreenLiveStreamPage>
    with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  bool _isLoading = true;
  bool _showControls = true;
  Timer? _controlsTimer;
  bool _lastActionWasPlay = true; // true => show play icon, false => show pause icon

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

      // Add listener to update UI when video playing state changes
      controller.addListener(() {
        if (mounted) {
          setState(() {});
        }
      });

      // Enable wakelock to prevent screen from sleeping during streaming
      await WakelockPlus.enable();

      if (mounted) {
        setState(() {
          _controller = controller;
          _isLoading = false;
        });
        _showControlsTemporarily();
      }
    } catch (e) {
      debugPrint("Video init failed: $e");
      if (mounted) setState(() => _isLoading = true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controlsTimer?.cancel();

    // Pause and dispose video controller
    _controller?.pause();
    _controller?.dispose();

    // Disable wakelock to allow screen to sleep again
    WakelockPlus.disable();

    // Restore portrait + system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.dispose();
  }

  void _showControlsTemporarily() {
    setState(() {
      _showControls = true;
    });
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _controller?.pause();
      // Disable wakelock when app goes to background
      WakelockPlus.disable();
    } else if (state == AppLifecycleState.resumed) {
      // Re-initialize fresh when resuming
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          // Re-enable wakelock when app resumes
          WakelockPlus.enable();
          _initPlayer();
        }
      });
    }
  }


  Future<bool> _onWillPop() async {
    // Show system UI temporarily
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    // Restore portrait for home screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // Navigate back to home screen
    Navigator.of(context).pop();
    return false; // Return false to prevent the default pop behavior from executing
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Video Player - Full Screen
            GestureDetector(
              onTap: () {
                if (!_isLoading && _controller != null) {
                  // Always toggle play/pause when tapping
                  if (_controller!.value.isPlaying) {
                    _controller!.pause();
                    _lastActionWasPlay = false; // show pause icon briefly
                  } else {
                    _controller!.play();
                    _lastActionWasPlay = true; // show play icon briefly
                  }
                  setState(() {});
                  // Show controls temporarily
                  _showControlsTemporarily();
                }
              },
              child: SizedBox.expand(
                child: _isLoading || _controller == null
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : Center(
                        child: AspectRatio(
                          aspectRatio: _controller!.value.aspectRatio,
                          child: VideoPlayer(_controller!),
                        ),
                      ),
              ),
            ),
            // Back Button - Always visible and prominent
            if (!_isLoading && _controller != null)
              Positioned(
                left: 16,
                top: 16,
                child: FloatingActionButton(
                  onPressed: () {
                    // Show system UI temporarily
                    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
                    // Restore portrait for home screen
                    SystemChrome.setPreferredOrientations([
                      DeviceOrientation.portraitUp,
                      DeviceOrientation.portraitDown,
                    ]);
                    // Navigate back to home screen
                    Navigator.of(context).pop();
                  },
                  heroTag: "back",
                  backgroundColor: Colors.black87,
                  elevation: 6,
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
            // Play/Pause Button Overlay (Auto-hiding with animation)
            if (!_isLoading && _controller != null)
              AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: IgnorePointer(
                  ignoring: !_showControls,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Icon(
                        _lastActionWasPlay
                            ? Icons.play_arrow
                            : Icons.pause,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
