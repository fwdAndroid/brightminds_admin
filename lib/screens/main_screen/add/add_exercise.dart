import 'dart:typed_data';
import 'package:brightminds_admin/database/database.dart';
import 'package:brightminds_admin/screens/main_screen/web_home.dart';
import 'package:brightminds_admin/utils/app_colors.dart';
import 'package:brightminds_admin/utils/buttons.dart';
import 'package:brightminds_admin/utils/colors.dart';
import 'package:brightminds_admin/utils/image_utils.dart';
import 'package:brightminds_admin/utils/input_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class AddExerciseScreen extends StatefulWidget {
  final String categoryName;
  final String level;

  AddExerciseScreen({
    super.key,
    required this.categoryName,
    required this.level,
  });

  @override
  State<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                _FormSection(
                  categoryName: widget.categoryName,
                  level: widget.level,
                ),
                _ImageSection(),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _FormSection extends StatefulWidget {
  final String categoryName;
  final String level;

  _FormSection({
    super.key,
    required this.categoryName,
    required this.level,
  });

  @override
  State<_FormSection> createState() => _FormSectionState();
}

class _FormSectionState extends State<_FormSection> {
  TextEditingController serviceNameController = TextEditingController();
  Uint8List? _image;
  Uint8List? _media; // Used for both audio and video
  bool isAdded = false;
  String? _mediaType; // To track if it's audio or video
  double _uploadProgress = 0.0; // Progress tracking

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

  Future<void> selectMedia(
      FileType type, List<String>? extensions, String mediaType) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: type,
      allowedExtensions: extensions,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _media = result.files.single.bytes;
        _mediaType = mediaType;
      });
      print("${mediaType.toUpperCase()} Selected: ${result.files.single.name}");
    } else {
      print("No $mediaType file selected.");
    }
  }

  Future<void> selectImage() async {
    Uint8List ui = await pickImage(ImageSource.gallery);
    setState(() {
      _image = ui;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.neutral,
      width: 500,
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Add Exercise",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 25.63),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: selectImage,
                child: _image != null
                    ? CircleAvatar(
                        radius: 59, backgroundImage: MemoryImage(_image!))
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset("assets/Choose Image.png"),
                      ),
              ),
            ),
            TextButton(
              onPressed: showMediaDialog,
              child: Text(
                _media == null
                    ? "Add Media"
                    : _mediaType == 'audio'
                        ? "Audio Selected"
                        : "Video Selected",
              ),
            ),
            const SizedBox(height: 10),
            Text("Level : ${widget.level}"),
            Text("Subject: ${widget.categoryName} "),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InputText(
                controller: serviceNameController,
                labelText: "Character Name",
                keyboardType: TextInputType.text,
                onChanged: (value) {},
                onSaved: (val) {},
                textInputAction: TextInputAction.done,
                isPassword: false,
                enabled: true,
              ),
            ),
            if (_uploadProgress > 0 && _uploadProgress < 1)
              Column(
                children: [
                  LinearProgressIndicator(value: _uploadProgress),
                  Text("${(_uploadProgress * 100).toStringAsFixed(1)}%"),
                ],
              ),
            isAdded
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SaveButton(
                      color: mainBtnColor,
                      title: "Publish",
                      onTap: () async {
                        if (serviceNameController.text.isEmpty ||
                            _image == null ||
                            _media == null) {
                          showMessageBar("All fields are required!", context);
                        } else {
                          setState(() {
                            isAdded = true;
                          });

                          // Track upload progress
                          await Database().addExercise(
                            levelSubCategory: widget.categoryName,
                            levelCategory: widget.level,
                            characterName: serviceNameController.text.trim(),
                            file: _image!,
                            audioFile: _media!,
                            mediaType: _mediaType!,
                            onProgress: (progress) {
                              setState(() {
                                _uploadProgress = progress;
                              });
                            },
                          );

                          setState(() {
                            isAdded = false;
                            _uploadProgress = 0.0;
                          });
                          showMessageBar(
                              "Exercise Added Successfully", context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => WebHome()));
                        }
                      },
                    )),
          ],
        ),
      ),
    );
  }
}

class _ImageSection extends StatelessWidget {
  const _ImageSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
              child: Image.asset(
            "assets/logo.png",
            height: 300,
          ))
        ],
      ),
    );
  }
}

void showMessageBar(String message, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ),
  );
}
