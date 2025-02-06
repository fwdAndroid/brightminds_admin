import 'dart:io';
import 'dart:typed_data';
import 'package:brightminds_admin/screens/main_screen/web_home.dart';
import 'package:brightminds_admin/utils/image_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as path;

class EditLesson extends StatefulWidget {
  final String id;

  const EditLesson({super.key, required this.id});

  @override
  State<EditLesson> createState() => _EditLessonState();
}

class _EditLessonState extends State<EditLesson> {
  TextEditingController _characterName = TextEditingController();
  String? imageUrl, mediaUrl, mediaType;
  Uint8List? newImage;
  final AudioPlayer _audioPlayer = AudioPlayer();
  VideoPlayerController? _videoController;
  bool isPlaying = false;
  bool isLoading = false;
  Uint8List? _media;
  Uint8List? _image;
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> selectImage() async {
    Uint8List ui = await pickImage(ImageSource.gallery);
    setState(() {
      _image = ui;
    });
  }

  /// ✅ Fetch Data from Firestore
  void fetchData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("letters")
          .doc(widget.id)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        if (data.containsKey('exercises') && data['exercises'] is List) {
          List exercises = data['exercises'];

          if (exercises.isNotEmpty) {
            Map<String, dynamic> firstExercise = exercises[0];

            setState(() {
              _characterName.text = firstExercise['characterName'] ?? '';
              imageUrl = firstExercise['photoURL'];
              mediaUrl = firstExercise['audioURL'];
              mediaType = firstExercise['mediaType'];

              if (mediaType == "video" && mediaUrl != null) {
                _videoController = VideoPlayerController.network(mediaUrl!)
                  ..initialize().then((_) {
                    setState(() {});
                  });
              }
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
    }
  }

  /// ✅ Show Media Selection Dialog
  Future<void> showMediaDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Media Type"),
          content: const Text("Choose whether to upload audio or video."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, 'audio');
              },
              child: const Text("Upload Audio"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, 'video');
              },
              child: const Text("Upload Video"),
            ),
          ],
        );
      },
    ).then((selection) {
      if (selection == 'audio') {
        selectMedia(FileType.custom, ['mp3'], 'audio');
      } else if (selection == 'video') {
        selectMedia(FileType.video, null, 'video');
      }
    });
  }

  /// ✅ Select Audio or Video
  Future<void> selectMedia(
      FileType type, List<String>? extensions, String selectedMediaType) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: type,
      allowedExtensions: extensions,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _media = result.files.single.bytes;
        mediaType = selectedMediaType;
        mediaUrl = result.files.single.name; // ✅ Display selected file name
      });
      print(
          "${mediaType!.toUpperCase()} Selected: ${result.files.single.name}");
    } else {
      print("No $mediaType file selected.");
    }
  }

  /// ✅ Upload File to Firebase Storage
  Future<String> uploadFile(Uint8List file, String path) async {
    try {
      Reference ref = FirebaseStorage.instance.ref().child(path);
      UploadTask uploadTask = ref.putData(file);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading file: $e");
      return "";
    }
  }

  /// ✅ Update Lesson Data
  void updateLesson() async {
    setState(() => isLoading = true);

    Map<String, dynamic> updatedData = {};

    if (_characterName.text.isNotEmpty) {
      updatedData['characterName'] = _characterName.text;
    }

    if (_image != null) {
      String newImageUrl = await uploadFile(_image!, "images/${widget.id}.jpg");
      if (newImageUrl.isNotEmpty) updatedData['photoURL'] = newImageUrl;
    }

    if (_media != null) {
      String extension = mediaType == "audio" ? "mp3" : "mp4";
      String newMediaUrl =
          await uploadFile(_media!, "media/${widget.id}.$extension");

      if (newMediaUrl.isNotEmpty) {
        updatedData['audioURL'] = newMediaUrl;
        updatedData['mediaType'] = mediaType;
      }
    }

    if (updatedData.isNotEmpty) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("letters")
          .doc(widget.id)
          .get();

      if (doc.exists) {
        List exercises = doc['exercises'] ?? [];

        int exerciseIndex = exercises.indexWhere(
          (exercise) =>
              exercise.containsKey('uuid') && exercise['uuid'] == widget.id,
        );

        if (exerciseIndex != -1) {
          exercises[exerciseIndex] = {
            ...exercises[exerciseIndex],
            ...updatedData,
          };

          await FirebaseFirestore.instance
              .collection("letters")
              .doc(widget.id)
              .update({'exercises': exercises});
        } else {
          print("Exercise not found in Firestore!");
        }
      }
    }

    setState(() => isLoading = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Lesson updated successfully!")));
    Navigator.push(context, MaterialPageRoute(builder: (builder) => WebHome()));
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Lesson")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _characterName,
              decoration: InputDecoration(labelText: "Character Name"),
            ),
            SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () => selectImage(),
                child: _image != null
                    ? CircleAvatar(
                        radius: 59, backgroundImage: MemoryImage(_image!))
                    : imageUrl != null
                        ? CircleAvatar(
                            radius: 59,
                            backgroundImage: NetworkImage(imageUrl!))
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              "assets/Front view of beautiful man.png",
                              height: 100,
                            ),
                          ),
              ),
            ),

            /// ✅ Show Selected Media Name
            TextButton(
              onPressed: showMediaDialog,
              child: Text("Change Media"),
            ),
            // ✅ Display Selected Media Type Below Button
            if (mediaType != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "Selected Media Type: ${mediaType!.toUpperCase()}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            SizedBox(height: 30),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: updateLesson,
                    child: Text("Update Lesson"),
                  ),
          ],
        ),
      ),
    );
  }
}
