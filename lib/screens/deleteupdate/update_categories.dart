import 'dart:typed_data';

import 'package:brightminds_admin/screens/main_screen/web_home.dart';
import 'package:brightminds_admin/utils/buttons.dart';
import 'package:brightminds_admin/utils/colors.dart';
import 'package:brightminds_admin/utils/image_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UpdateCategories extends StatefulWidget {
  String categoryName;
  String image;
  String id;
  String levelCategory; // ✅ Add this

  UpdateCategories({
    super.key,
    required this.id,
    required this.categoryName,
    required this.image,
    required this.levelCategory, // ✅ Pass levelCategory
  });

  @override
  State<UpdateCategories> createState() => _UpdateCategoriesState();
}

class _UpdateCategoriesState extends State<UpdateCategories> {
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
                  categoryName: widget.categoryName,
                  image: widget.image,
                  levelCategory: widget.levelCategory, // ✅ Pass it here
                ),
                ImageSelection(),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class FormSelection extends StatefulWidget {
  String categoryName;
  String image;
  String id;
  String levelCategory; // ✅ Include levelCategory

  FormSelection({
    super.key,
    required this.categoryName,
    required this.image,
    required this.id,
    required this.levelCategory, // ✅ Receive levelCategory
  });

  @override
  State<FormSelection> createState() => _FormSelectionState();
}

class _FormSelectionState extends State<FormSelection> {
  TextEditingController _categoryNameController = TextEditingController();
  bool _isUpdating = false;
  String? imageUrl;
  Uint8List? _image;

  @override
  void initState() {
    super.initState();
    fetchData();
    print(widget.levelCategory);
  }

  void fetchData() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('categories')
        .doc(widget.id)
        .get();

    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    setState(() {
      _categoryNameController.text = data['categoryName'] ?? '';
      imageUrl = data['photoURL'];
    });
  }

  Future<void> selectImage() async {
    Uint8List ui = await pickImage(ImageSource.gallery);
    setState(() {
      _image = ui;
    });
  }

  Future<String> uploadImageToStorage(Uint8List image) async {
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('categories')
        .child('${widget.id}.jpg');
    UploadTask uploadTask = ref.putData(image);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _updateCategory() async {
    setState(() {
      _isUpdating = true;
    });

    String oldCategoryName = widget.categoryName; // Store old category name
    String newCategoryName = _categoryNameController.text;

    try {
      // Upload new image if available
      String? downloadUrl;
      if (_image != null) {
        downloadUrl = await uploadImageToStorage(_image!);
      } else {
        downloadUrl = imageUrl;
      }

      // Update Firestore categories collection
      await FirebaseFirestore.instance
          .collection('categories')
          .doc(widget.id)
          .update({
        'categoryName': newCategoryName,
        "photoURL": downloadUrl,
      });

      // Fetch all letters documents
      QuerySnapshot lettersSnapshot =
          await FirebaseFirestore.instance.collection('letters').get();

      int updatedCount = 0;

      for (var doc in lettersSnapshot.docs) {
        List<dynamic> exercises =
            List.from(doc['exercises']); // Get exercises array
        bool updated = false;

        for (int i = 0; i < exercises.length; i++) {
          Map<String, dynamic> exercise =
              Map<String, dynamic>.from(exercises[i]);

          if (exercise['levelSubCategory'] == oldCategoryName) {
            exercise['levelSubCategory'] = newCategoryName; // Update value
            updated = true;
          }
          if (exercise['levelCategory'] == oldCategoryName) {
            exercise['levelCategory'] = newCategoryName; // Update value
            updated = true;
          }

          exercises[i] = exercise; // Save updated map back to the list
        }

        if (updated) {
          await doc.reference.update({'exercises': exercises});
          updatedCount++;
        }
      }

      print("Updated $updatedCount documents in letters collection.");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Category and related letters updated successfully!')),
      );
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (builder) => WebHome()));
    } catch (e) {
      print("Update error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating category and letters.')),
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
                            child: Image.asset("assets/logo.png"),
                          ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _categoryNameController,
                style: TextStyle(color: black),
                decoration: InputDecoration(labelText: 'Category Name'),
              ),
            ),
            SaveButton(
              title: "Update",
              onTap: _updateCategory,
              color: mainBtnColor,
            ),
            if (_isUpdating) CircularProgressIndicator(),
          ],
        ));
  }
}

class ImageSelection extends StatelessWidget {
  const ImageSelection({super.key});

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
