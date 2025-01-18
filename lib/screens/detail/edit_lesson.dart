import 'dart:io';

import 'package:brightminds_admin/screens/main_screen/web_home.dart';
import 'package:brightminds_admin/utils/buttons.dart';
import 'package:brightminds_admin/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
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

  Future<void> _updateCategory() async {
    setState(() {
      _isUpdating = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('letters')
          .doc(widget.id)
          .update({
        'categoryName': _categoryNameController.text,
        'audioURL': _selectedAudioPath ?? widget.audioURL,
        'characterName': _characterNameController.text,
        if (_selectedImagePath != null) 'image': _selectedImagePath,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Updated successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      print("Update error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating category.')),
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
            onTap: _updateCategory,
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
