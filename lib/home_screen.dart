import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'live_streaming_video_player.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Force portrait orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    // Allow all orientations when leaving
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'lijokv39@gmail.com',
      query: 'subject=Contact from N4TV App',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+91974688999');
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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Icon(
                Icons.live_tv,
                size: 120,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 32),
              const Text(
                'N4 TV Stream',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: 250,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    // Set landscape orientation before navigating
                    SystemChrome.setPreferredOrientations([
                      DeviceOrientation.landscapeLeft,
                      DeviceOrientation.landscapeRight,
                    ]);
                    // Small delay to ensure orientation is set
                    await Future.delayed(const Duration(milliseconds: 100));
                    
                    if (mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FullscreenLiveStreamPage(),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.play_arrow, size: 32),
                  label: const Text(
                    'Watch TV',
                    style: TextStyle(fontSize: 20),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              // Contact Information Card - Always Visible
              Card(
                elevation: 4,
                color: Colors.deepPurple.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.contact_mail, color: Colors.deepPurple),
                          const SizedBox(width: 8),
                          const Text(
                            'Contact Information',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.email, color: Colors.deepPurple, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: _launchEmail,
                              child: const Text(
                                'Email: lijokv39@gmail.com',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.phone, color: Colors.deepPurple, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: _launchPhone,
                              child: const Text(
                                'Phone: +91 9746889999',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

