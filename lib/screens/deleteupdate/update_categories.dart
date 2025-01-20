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
  UpdateCategories(
      {super.key,
      required this.id,
      required this.categoryName,
      required this.image});

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

  FormSelection({
    super.key,
    required this.categoryName,
    required this.image,
    required this.id,
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
  }

  void fetchData() async {
    // Fetch data from Firestore
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('categories')
        .doc(widget.id)
        .get();

    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Update the controllers with the fetched data
    setState(() {
      _categoryNameController.text =
          data['categoryName'] ?? ''; // Convert int to string
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
    Reference ref =
        FirebaseStorage.instance.ref().child('users').child('${widget.id}.jpg');
    UploadTask uploadTask = ref.putData(image);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _updateCategory() async {
    setState(() {
      _isUpdating = true;
    });

    try {
      // Upload new image if available
      String? downloadUrl;
      if (_image != null) {
        downloadUrl = await uploadImageToStorage(_image!);
      } else {
        downloadUrl = imageUrl;
      }
      // Update Firestore
      await FirebaseFirestore.instance
          .collection('categories')
          .doc(widget.id)
          .update({
        'categoryName': _categoryNameController.text,
        "photoURL": downloadUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Category updated successfully!')),
      );
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (builder) => WebHome()));
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
