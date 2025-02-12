import 'dart:typed_data';
import 'package:brightminds_admin/database/database.dart';
import 'package:brightminds_admin/screens/main_screen/web_home.dart';
import 'package:brightminds_admin/utils/app_colors.dart';
import 'package:brightminds_admin/utils/buttons.dart';
import 'package:brightminds_admin/utils/colors.dart';
import 'package:brightminds_admin/utils/image_utils.dart';
import 'package:brightminds_admin/utils/input_text.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class AddGreekSubject extends StatefulWidget {
  const AddGreekSubject({super.key});

  @override
  State<AddGreekSubject> createState() => _AddGreekSubjectState();
}

class _AddGreekSubjectState extends State<AddGreekSubject> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: const [
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
  var uuid = Uuid().v4();
  Uint8List? _image;
  bool isAdded = false;
  String dropdownvalue = 'Προνήπιο';

  // List of items in our dropdown menu
  var items = [
    'Προνήπιο',
    'Νηπιαγωγείο',
    'Επίπεδο 1',
    'Επίπεδο 2',
    'Επίπεδο 3',
    'Επίπεδο 4',
    'Επίπεδο 5',
    'Επίπεδο 6'
  ];

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
              "Add Levels Category",
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
              child: DropdownButton(
                // Initial Value
                isExpanded: true,
                value: dropdownvalue,

                // Down Arrow Icon
                icon: const Icon(Icons.keyboard_arrow_down),

                // Array list of items
                items: items.map((String items) {
                  return DropdownMenuItem(
                    value: items,
                    child: Text(items),
                  );
                }).toList(),
                // After selecting the desired option,it will
                // change button value to selected value
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownvalue = newValue!;
                  });
                },
              ),
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
                              level: dropdownvalue,
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
