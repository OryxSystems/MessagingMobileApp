import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PlayVideo extends StatefulWidget {
  final File vidFile;
  final String vidUrl;
  PlayVideo({this.vidFile, this.vidUrl});

  PlayVideoState createState() =>
      PlayVideoState(vidFile: vidFile, vidUrl: vidUrl);
}

class PlayVideoState extends State<PlayVideo> {
  final File vidFile;
  final String vidUrl;
  VideoPlayerController videoPlayerController;
  Future<void> _initializeVideoPlayerFuture;

  PlayVideoState({this.vidFile, this.vidUrl});

  void initState() {
    if (vidFile != null) {
      // Initialize the controller and store the Future for later use.
      videoPlayerController = VideoPlayerController.file(vidFile);
      _initializeVideoPlayerFuture =
          videoPlayerController.initialize().then((value) {
        setState(() {});
      });
      // Use the controller to loop the video.
      videoPlayerController.setLooping(true);
    } else {
      if (vidUrl != null) {
        // Initialize the controller and store the Future for later use.
        videoPlayerController = VideoPlayerController.network(vidUrl);
        _initializeVideoPlayerFuture =
            videoPlayerController.initialize().then((value) {
          setState(() {});
        });
        // Use the controller to loop the video.
        videoPlayerController.setLooping(true);
      } else {
        Navigator.pop(context);
      }
    }
    super.initState();
  }

  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Player'),
      ),
      // Use a FutureBuilder to display a loading spinner while waiting for the
      // VideoPlayerController to finish initializing.
      body: Center(
        child: FutureBuilder(
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // If the VideoPlayerController has finished initialization, use
              // the data it provides to limit the aspect ratio of the video.
              return AspectRatio(
                aspectRatio: videoPlayerController.value.aspectRatio,
                // Use the VideoPlayer widget to display the video.
                child: VideoPlayer(videoPlayerController),
              );
            } else {
              // If the VideoPlayerController is still initializing, show a
              // loading spinner.
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Wrap the play or pause in a call to `setState`. This ensures the
          // correct icon is shown.
          setState(() {
            // If the video is playing, pause it.
            if (videoPlayerController.value.isPlaying) {
              videoPlayerController.pause();
            } else {
              // If the video is paused, play it.
              videoPlayerController.play();
            }
          });
        },
        // Display the correct icon depending on the state of the player.
        child: Icon(
          videoPlayerController.value.isPlaying
              ? Icons.pause
              : Icons.play_arrow,
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void dispose() {
    super.dispose();
    videoPlayerController?.dispose();
  }
}
