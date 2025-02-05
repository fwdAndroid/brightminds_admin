import 'dart:typed_data';

import 'package:brightminds_admin/screens/main_screen/web_home.dart';
import 'package:brightminds_admin/utils/app_colors.dart';
import 'package:brightminds_admin/utils/buttons.dart';
import 'package:brightminds_admin/utils/colors.dart';
import 'package:brightminds_admin/utils/image_utils.dart';
import 'package:brightminds_admin/utils/input_text.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../database/database.dart';

class AddCatgoryWidgetLevelWise extends StatefulWidget {
  String level;
  AddCatgoryWidgetLevelWise({super.key, required this.level});

  @override
  State<AddCatgoryWidgetLevelWise> createState() =>
      _AddCatgoryWidgetLevelWiseState();
}

class _AddCatgoryWidgetLevelWiseState extends State<AddCatgoryWidgetLevelWise> {
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
  String level;
  _FormSection({Key? key, required this.level}) : super(key: key);

  @override
  State<_FormSection> createState() => _FormSectionState();
}

class _FormSectionState extends State<_FormSection> {
  TextEditingController serviceNameController = TextEditingController();
  var uuid = Uuid().v4();
  Uint8List? _image;
  bool isAdded = false;

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
              "Add Levels Subject",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 25.63),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () => selectImage(),
                child: _image != null
                    ? CircleAvatar(
                        radius: 59, backgroundImage: MemoryImage(_image!))
                    : GestureDetector(
                        onTap: () => selectImage(),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset("assets/Choose Image.png"),
                        ),
                      ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                  // Initial Value
                  widget.level),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InputText(
                controller: serviceNameController,
                labelText: "Category Name",
                keyboardType: TextInputType.visiblePassword,
                onChanged: (value) {},
                onSaved: (val) {},
                textInputAction: TextInputAction.done,
                isPassword: false,
                enabled: true,
              ),
            ),
            isAdded
                ? Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SaveButton(
                        color: mainBtnColor,
                        title: "Publish",
                        onTap: () async {
                          print("click");
                          if (serviceNameController.text.isEmpty) {
                            showMessageBar(
                                "Category Name is Required", context);
                          } else {
                            setState(() {
                              isAdded = true;
                            });

                            await Database().addServices(
                              categoryName: serviceNameController.text.trim(),
                              level: widget.level,
                              file: _image!,
                            );
                            setState(() {
                              isAdded = false;
                            });
                            // Handle the result accordingly
                            showMessageBar(
                                "Category Added Successfully", context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (builder) => WebHome()));
                          }
                        }),
                  ),
          ],
        ),
      ),
    );
  }

  selectImage() async {
    Uint8List ui = await pickImage(ImageSource.gallery);
    setState(() {
      _image = ui;
    });
  }
}

// Functions
/// Select Image From Gallery

void showMessageBar(String message, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
    ),
  );
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
