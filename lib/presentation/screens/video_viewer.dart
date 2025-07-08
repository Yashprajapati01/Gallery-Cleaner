// import 'dart:io';
// import 'package:chewie/chewie.dart';
// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
//
// class FullVideoPlayerScreen extends StatefulWidget {
//   final String videoPath;
//
//   const FullVideoPlayerScreen({super.key, required this.videoPath});
//
//   @override
//   State<FullVideoPlayerScreen> createState() => _FullVideoPlayerScreenState();
// }
//
// class _FullVideoPlayerScreenState extends State<FullVideoPlayerScreen> {
//   final VideoPlayerController _videoController = VideoPlayerController.asset('');
//   ChewieController? _chewieController;
//
//   String? _errorMessage;
//   bool _isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeVideo();
//   }
//
//   Future<void> _initializeVideo() async {
//     try {
//       final file = File(widget.videoPath);
//       if (!await file.exists()) {
//         setState(() {
//           _errorMessage = 'Video file not found: ${widget.videoPath}';
//           _isLoading = false;
//         });
//         return;
//       }
//
//       final _videoController = VideoPlayerController.file(file);
//       await _videoController.initialize();
//
//
//        _chewieController = ChewieController(
//         videoPlayerController: _videoController,
//         autoPlay: true,
//         looping: true,
//       );
//
//       setState(() {
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to initialize video: $e';
//         _isLoading = false;
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     _videoController.dispose();
//     _chewieController?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: const Text('Video Player', style: TextStyle(color: Colors.white)),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _errorMessage != null
//           ? Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.video_file_outlined, size: 64, color: Colors.white.withOpacity(0.5)),
//             const SizedBox(height: 16),
//             Text(
//               'Video Error',
//               style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 18),
//             ),
//             const SizedBox(height: 8),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 32),
//               child: Text(
//                 _errorMessage!,
//                 style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ],
//         ),
//       )
//           : Chewie(controller: _chewieController!), // Just the Chewie widget - it handles everything
//     );
//   }
// }

import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FullVideoPlayerScreen extends StatefulWidget {
  final String videoPath;

  const FullVideoPlayerScreen({super.key, required this.videoPath});

  @override
  State<FullVideoPlayerScreen> createState() => _FullVideoPlayerScreenState();
}

class _FullVideoPlayerScreenState extends State<FullVideoPlayerScreen> {
  VideoPlayerController?
  _videoController; // Make it nullable and remove the invalid initialization
  ChewieController? _chewieController;

  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      final file = File(widget.videoPath);
      if (!await file.exists()) {
        setState(() {
          _errorMessage = 'Video file not found: ${widget.videoPath}';
          _isLoading = false;
        });
        return;
      }

      _videoController = VideoPlayerController.file(
        file,
      ); // Use the instance variable
      await _videoController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: true,
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize video: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // Dispose in the correct order: Chewie first, then VideoPlayer
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Video Player',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.video_file_outlined,
                    size: 64,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Video Error',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            )
          : Chewie(controller: _chewieController!),
    );
  }
}
