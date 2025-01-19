import 'dart:io';

import 'package:brightminds_admin/screens/main_screen/view/view_category.dart';
import 'package:brightminds_admin/screens/main_screen/web_home.dart';
import 'package:brightminds_admin/utils/buttons.dart';
import 'package:brightminds_admin/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class EditLesson extends StatefulWidget {
  final String levelSubCategory;
  final String image;
  final String id;
  final String characterName;
  final String audioURL;

  EditLesson({
    super.key,
    required this.id,
    required this.levelSubCategory,
    required this.image,
    required this.characterName,
    required this.audioURL,
  });

  @override
  State<EditLesson> createState() => _EditLessonState();
}

class _EditLessonState extends State<EditLesson> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                FormSelection(
                  id: widget.id,
                  categoryName: widget.levelSubCategory,
                  image: widget.image,
                  characterName: widget.characterName,
                  audioURL: widget.audioURL,
                ),
                ImageSelection(imagePath: widget.image),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FormSelection extends StatefulWidget {
  final String categoryName;
  final String image;
  final String id;
  final String audioURL;
  final String characterName;

  FormSelection({
    super.key,
    required this.categoryName,
    required this.image,
    required this.characterName,
    required this.id,
    required this.audioURL,
  });

  @override
  State<FormSelection> createState() => _FormSelectionState();
}

class _FormSelectionState extends State<FormSelection> {
  late TextEditingController _categoryNameController;
  late TextEditingController _characterNameController;

  bool _isUpdating = false;
  String? _selectedImagePath;
  String? _selectedAudioPath;

  @override
  void initState() {
    super.initState();
    _categoryNameController = TextEditingController(text: widget.categoryName);
    _characterNameController =
        TextEditingController(text: widget.characterName);

    print(widget.id);
  }

  Future<void> _pickImage() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _selectedImagePath = result.files.single.path;
      });
      // Implement image upload logic here
    }
  }

  Future<void> _pickAudio() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null) {
      setState(() {
        _selectedAudioPath = result.files.single.path;
      });
      // Implement audio upload logic here
    }
  }

  Future<void> _updateExercise() async {
    setState(() {
      _isUpdating = true;
    });

    try {
      // Step 1: Fetch the current document containing the exercises array
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('letters')
          .doc(widget.id)
          .get();

      List<dynamic> exercises =
          doc['exercises'] ?? []; // Get the exercises array

      // Step 2: Update the specific object inside the array
      for (int i = 0; i < exercises.length; i++) {
        var exercise = exercises[i];
        // Identify the object to update (example: match by 'characterName')
        if (exercise['characterName'] == widget.characterName) {
          // Update fields as needed
          if (_selectedAudioPath != null) {
            exercise['audioURL'] = _selectedAudioPath; // Update audioURL
          }
          if (_selectedImagePath != null) {
            exercise['photoURL'] = _selectedImagePath; // Update image
          }
          exercise['characterName'] =
              _characterNameController.text; // Update characterName
          exercises[i] = exercise; // Update the object in the array
        }
      }

      // Step 3: Write the updated array back to Firestore
      await FirebaseFirestore.instance
          .collection('letters')
          .doc(widget.id)
          .update({
        'exercises': exercises,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exercise updated successfully!')),
      );
      Navigator.push(
          context, MaterialPageRoute(builder: (builder) => WebHome()));
    } catch (e) {
      print("Error updating exercise: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update exercise.')),
      );
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _categoryNameController,
              decoration: InputDecoration(labelText: 'Category Name'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              radius: 50,
              backgroundImage: _selectedImagePath != null
                  ? FileImage(File(_selectedImagePath!))
                  : NetworkImage(widget.image) as ImageProvider,
            ),
          ),
          ElevatedButton(
            onPressed: _pickImage,
            child: Text("Change Image"),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _characterNameController,
              decoration: InputDecoration(labelText: 'Character Name'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Audio Path: ${_selectedAudioPath ?? widget.audioURL}"),
          ),
          ElevatedButton(
            onPressed: _pickAudio,
            child: Text("Change Audio"),
          ),
          SaveButton(
            title: "Update",
            onTap: _updateExercise,
            color: mainBtnColor,
          ),
          if (_isUpdating) CircularProgressIndicator(),
        ],
      ),
    );
  }
}

class ImageSelection extends StatelessWidget {
  final String imagePath;

  const ImageSelection({super.key, required this.imagePath});

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
              height: 150,
            ),
          ),
        ],
      ),
    );
  }
}
