import 'package:brightminds_admin/screens/detail/edit_lesson.dart';
import 'package:just_audio/just_audio.dart';
import 'package:brightminds_admin/utils/buttons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LessonDetail extends StatefulWidget {
  final String audio;
  final String categoryName;
  final String image;
  final String letter;
  final String id;

  const LessonDetail({
    Key? key,
    required this.audio,
    required this.categoryName,
    required this.image,
    required this.letter,
    required this.id,
  }) : super(key: key);

  @override
  _LessonDetailState createState() => _LessonDetailState();
}

class _LessonDetailState extends State<LessonDetail> {
  late AudioPlayer _audioPlayer;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playPauseAudio() async {
    if (isPlaying) {
      await _audioPlayer.pause();
      setState(() {
        isPlaying = false;
      });
    } else {
      try {
        await _audioPlayer.setUrl(widget.audio);
        await _audioPlayer.play();
        setState(() {
          isPlaying = true;
        });

        // Listen for completion
        _audioPlayer.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            setState(() {
              isPlaying = false;
            });
          }
        });
      } catch (e) {
        print("Error playing audio: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: Could not play the audio')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _playPauseAudio,
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                label: Text(isPlaying ? "Pause Audio" : "Play Audio"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32.0, vertical: 12.0),
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
                                          content: Text(
                                              'Failed to delete category')),
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
        ),
      ),
    );
  }
}
