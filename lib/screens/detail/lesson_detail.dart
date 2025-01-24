import 'package:brightminds_admin/screens/detail/edit_lesson.dart';
import 'package:brightminds_admin/utils/buttons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart'; // For video playback
import 'package:just_audio/just_audio.dart'; // For audio playback

class LessonDetail extends StatefulWidget {
  final String mediaType; // Either "video" or "audio"
  final String audio; // URL of the media file
  final String categoryName;
  final String image;
  final String id;
  final String letter;

  LessonDetail({
    required this.mediaType,
    required this.audio,
    required this.categoryName,
    required this.image,
    required this.id,
    required this.letter,
  });

  @override
  _LessonDetailState createState() => _LessonDetailState();
}

class _LessonDetailState extends State<LessonDetail> {
  late VideoPlayerController _videoController;
  late AudioPlayer _audioPlayer;
  bool isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.mediaType == "video") {
      _videoController = VideoPlayerController.network(widget.audio)
        ..initialize().then((_) {
          setState(() {
            isVideoInitialized = true;
          });
          _videoController.play();
        });
    } else if (widget.mediaType == "audio") {
      _audioPlayer = AudioPlayer();
      _audioPlayer.setUrl(widget.audio);
      _audioPlayer.play();
    }
  }

  @override
  void dispose() {
    if (widget.mediaType == "video") {
      _videoController.dispose();
    } else if (widget.mediaType == "audio") {
      _audioPlayer.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.letter),
      ),
      body: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              widget.image,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Lesson: ${widget.letter}",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Center(
            child: widget.mediaType == "video"
                ? isVideoInitialized
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 400,
                          height: 100,
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: VideoPlayer(_videoController),
                          ),
                        ),
                      )
                    : CircularProgressIndicator()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(widget.image),
                        radius: 50,
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Playing audio for ${widget.letter}",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Icon(Icons.music_note, size: 50, color: Colors.blue),
                    ],
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SaveButton(
                title: "Delete",
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Confirm Delete'),
                        content: Text(
                            'Are you sure you want to delete this lesson?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Close dialog
                            },
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              try {
                                await FirebaseFirestore.instance
                                    .collection('letters')
                                    .doc(widget.id)
                                    .delete();
                                Navigator.pop(context); // Close dialog
                                Navigator.pop(
                                    context); // Go back to previous screen
                              } catch (e) {
                                print("Error deleting category: $e");
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Failed to delete category')),
                                );
                              }
                            },
                            child: Text('Delete',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      );
                    },
                  );
                },
                color: Colors.red),
          ),
          Padding(
              padding: EdgeInsets.all(8),
              child: SaveButton(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (builder) => EditLesson(
                                mediaType: widget.mediaType,
                                id: widget.id,
                                levelSubCategory: widget.categoryName,
                                image: widget.image,
                                characterName: widget.letter,
                                audioURL: widget.audio,
                              )));
                },
                title: "Edit",
                color: Colors.green,
              )),
        ],
      ),
      floatingActionButton: widget.mediaType == "video"
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  if (_videoController.value.isPlaying) {
                    _videoController.pause();
                  } else {
                    _videoController.play();
                  }
                });
              },
              child: Icon(
                _videoController.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
              ),
            )
          : null,
    );
  }
}
