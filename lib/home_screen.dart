import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'live_streaming_video_player.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  VideoPlayerController? _videoController;
  final String _streamUrl = "https://livestream.flameinfosys.com/n4news/news/playlist.m3u8";
  bool _isVideoLoading = true;
  bool _showControls = true;
  Timer? _controlsTimer;
  bool _lastActionWasPlay = true; // true => show play icon, false => show pause icon

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Force portrait orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _initVideoPlayer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controlsTimer?.cancel();
    // Pause and dispose video controller
    _videoController?.pause();
    _videoController?.dispose();
    // Disable wakelock to allow screen to sleep again
    WakelockPlus.disable();
    // Allow all orientations when leaving
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
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

  Future<void> _initVideoPlayer() async {
    try {
      // Dispose any existing controller
      await _videoController?.dispose();
      
      final controller = VideoPlayerController.networkUrl(Uri.parse(_streamUrl));
      await controller.initialize();
      controller.setLooping(true);
      
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
          _videoController = controller;
          _isVideoLoading = false;
        });
        controller.play();
        _showControlsTemporarily();
      }
    } catch (e) {
      debugPrint("Video init failed: $e");
      if (mounted) setState(() => _isVideoLoading = false);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _videoController?.pause();
      // Disable wakelock when app goes to background
      WakelockPlus.disable();
    } else if (state == AppLifecycleState.resumed) {
      // Re-initialize fresh when resuming
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          // Re-enable wakelock when app resumes
          WakelockPlus.enable();
          _initVideoPlayer();
        }
      });
    }
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'n4newstcr@gmail.com',
      query: 'subject=Contact from N4TV App',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+919895070239');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('N4 TV'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Video Player Section
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (!_isVideoLoading && _videoController != null) {
                        // Always toggle play/pause when tapping
                        if (_videoController!.value.isPlaying) {
                          _videoController!.pause();
                          _lastActionWasPlay = false; // show pause icon briefly
                          // Disable wakelock when video is paused
                          WakelockPlus.disable();
                        } else {
                          _videoController!.play();
                          _lastActionWasPlay = true; // show play icon briefly
                          // Enable wakelock when video is playing
                          WakelockPlus.enable();
                        }
                        setState(() {});
                        // Show controls temporarily
                        _showControlsTemporarily();
                      }
                    },
                    child: Container(
                      color: Colors.black,
                      child: _isVideoLoading || _videoController == null
                          ? const Center(
                              child: CircularProgressIndicator(color: Colors.white),
                            )
                          : VideoPlayer(_videoController!),
                    ),
                  ),
                  // Play/Pause Button Overlay (Auto-hiding)
                  if (!_isVideoLoading && _videoController != null)
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
                  // Fullscreen Button Overlay - Always visible
                  if (!_isVideoLoading && _videoController != null)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: FloatingActionButton(
                        onPressed: () async {
                          // Pause home video before navigating
                          _videoController?.pause();
                          
                          // Set landscape orientation before navigating
                          SystemChrome.setPreferredOrientations([
                            DeviceOrientation.landscapeLeft,
                            DeviceOrientation.landscapeRight,
                          ]);
                          // Small delay to ensure orientation is set
                          await Future.delayed(const Duration(milliseconds: 100));
                          
                          if (mounted) {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const FullscreenLiveStreamPage(),
                              ),
                            );
                            
                            // Resume home video after returning from fullscreen
                            if (mounted && _videoController != null) {
                              _videoController!.play();
                            }
                          }
                        },
                        heroTag: "fullscreen",
                        mini: true,
                        backgroundColor: Colors.deepPurple.withOpacity(0.9),
                        child: const Icon(Icons.fullscreen),
                      ),
                    ),
                ],
              ),
            ),
            // Content Section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  const Text(
                    'N4 TV Stream',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
              // Contact Information
              const Text(
                'Contact Us',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 16),
              // Email Card
              Card(
                elevation: 3,
                color: Colors.white,
                child: InkWell(
                  onTap: _launchEmail,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.email,
                            color: Colors.deepPurple,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Email',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const Text(
                                'n4newstcr@gmail.com',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: Colors.deepPurple,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Phone Card
              Card(
                elevation: 3,
                color: Colors.white,
                child: InkWell(
                  onTap: _launchPhone,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.phone,
                            color: Colors.deepPurple,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Phone',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const Text(
                                '+919895070239',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: Colors.deepPurple,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

