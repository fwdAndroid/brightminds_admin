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
  const AddExerciseScreen({super.key});

  @override
  State<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: const [
          Expanded(
            child: Row(
              children: [
                _FormSection(),
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
  const _FormSection({Key? key}) : super(key: key);

  @override
  State<_FormSection> createState() => _FormSectionState();
}

class _FormSectionState extends State<_FormSection> {
  TextEditingController serviceNameController = TextEditingController();
  Uint8List? _image;
  Uint8List? _audio;
  bool isAdded = false;

  String? selectedLevel;
  String? selectedCategory;

  Future<void> selectAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _audio = result.files.single.bytes;
      });
      print("Audio Selected: ${result.files.single.name}");
    } else {
      print("No audio file selected.");
    }
  }

  Future<void> selectImage() async {
    Uint8List ui = await pickImage(ImageSource.gallery);
    setState(() {
      _image = ui;
    });
  }

  List<String> categories = [];

  Future<void> fetchCategories() async {
    try {
      // Fetch categories from Firestore
      final snapshot =
          await FirebaseFirestore.instance.collection('categories').get();

      // Extract category names
      List<String> fetchedCategories =
          snapshot.docs.map((doc) => doc['categoryName'] as String).toList();

      setState(() {
        categories = fetchedCategories;
      });
    } catch (e) {
      showMessageBar("Failed to fetch categories: $e", context);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCategories();
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
              onPressed: selectAudio,
              child: Text(_audio == null ? "Add Audio" : "Audio Selected"),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: categories.isEmpty
                        ? Center(child: Text("No Categories Found"))
                        : DropdownButton<String>(
                            hint: const Text('Select Category'),
                            value: selectedCategory,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedCategory = newValue;
                              });
                            },
                            items: categories.map((String category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
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
                            _audio == null) {
                          showMessageBar("All fields are required!", context);
                        } else {
                          setState(() {
                            isAdded = true;
                          });

                          await Database().addExercise(
                            levelSubCategory: selectedCategory!,
                            levelCategory: "Level 3",
                            characterName: serviceNameController.text.trim(),
                            file: _image!,
                            audioFile: _audio!,
                          );

                          setState(() {
                            isAdded = false;
                          });
                          showMessageBar(
                              "Exercise Added Successfully", context);
                                                     Navigator.pop(context);

                        }
                      },
                    ),
                  ),
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
