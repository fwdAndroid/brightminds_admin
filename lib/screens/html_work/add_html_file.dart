import 'package:brightminds_admin/screens/main_screen/web_home.dart';
import 'package:brightminds_admin/utils/app_colors.dart';
import 'package:brightminds_admin/utils/buttons.dart';
import 'package:brightminds_admin/utils/colors.dart';
import 'package:brightminds_admin/utils/input_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class AddHtmlFile extends StatefulWidget {
  const AddHtmlFile({super.key});

  @override
  State<AddHtmlFile> createState() => _AddHtmlFileState();
}

class _AddHtmlFileState extends State<AddHtmlFile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
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
  @override
  State<_FormSection> createState() => _FormSectionState();
}

class _FormSectionState extends State<_FormSection> {
  TextEditingController serviceNameController = TextEditingController();

  bool isUploading = false;
  String? htmlFileUrl;
  String? cssFileUrl;
  String? jsFileUrl;
  double _uploadProgress = 0.0; // Progress tracking
  bool isAdded = false;
  @override
  void initState() {
    super.initState();
  }

  // Initial Selected Value
  String dropdownvalue = 'Pre-Kindergarden';

  // List of items in our dropdown menu
  var items = [
    'Pre-Kindergarden',
    'Kindergarden',
    'Level 1',
    'Level 2',
    'Level 3',
    'Level 4',
    'Level 5',
    'Level 6',
    'Προνήπιο',
    'Νηπιαγωγείο',
    'Επίπεδο 1',
    'Επίπεδο 2',
    'Επίπεδο 3',
    'Επίπεδο 4',
    'Επίπεδο 5',
    'Επίπεδο 6'
  ];
  Future<void> uploadFile(String fileType) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [fileType],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        isUploading = true;
      });

      try {
        final file = result.files.first;
        final storageRef =
            FirebaseStorage.instance.ref().child('$fileType/${file.name}');
        final uploadTask = storageRef.putData(file.bytes!);

        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();

        // Update the appropriate file URL
        setState(() {
          if (fileType == 'html') {
            htmlFileUrl = downloadUrl;
          } else if (fileType == 'css') {
            cssFileUrl = downloadUrl;
          } else if (fileType == 'js') {
            jsFileUrl = downloadUrl;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$fileType file uploaded successfully!'),
        ));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error uploading $fileType file: $e'),
        ));
      } finally {
        setState(() {
          isUploading = false;
        });
      }
    }
  }

  var uuid = Uuid().v4();
  Future<void> saveFilesToFirestore() async {
    if (htmlFileUrl == null || cssFileUrl == null || jsFileUrl == null) {
      String missingFiles = '';
      if (htmlFileUrl == null) missingFiles += 'HTML file is required.\n';
      if (cssFileUrl == null) missingFiles += 'CSS file is required.\n';
      if (jsFileUrl == null) missingFiles += 'JS file is required.\n';

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(missingFiles),
        backgroundColor: Colors.red,
      ));
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('webFiles').doc(uuid).set({
        'html': htmlFileUrl,
        'css': cssFileUrl,
        'js': jsFileUrl,
        'excercise': serviceNameController.text,
        'level': dropdownvalue,
        'uuid': uuid,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Files saved successfully!'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error saving files: $e'),
        backgroundColor: Colors.red,
      ));
    }
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
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InputText(
                controller: serviceNameController,
                labelText: "Exercise Name",
                keyboardType: TextInputType.text,
                onChanged: (value) {},
                onSaved: (val) {},
                textInputAction: TextInputAction.done,
                isPassword: false,
                enabled: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton(
                // Initial Value
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
            TextButton(
              onPressed: () => uploadFile('html'),
              child: Text('Upload HTML File'),
            ),
            if (htmlFileUrl != null)
              Text('HTML file uploaded!',
                  style: TextStyle(color: Colors.green)),
            SizedBox(height: 10),
            TextButton(
              onPressed: () => uploadFile('css'),
              child: Text('Upload CSS File'),
            ),
            if (cssFileUrl != null)
              Text('CSS file uploaded!', style: TextStyle(color: Colors.green)),
            SizedBox(height: 10),
            TextButton(
              onPressed: () => uploadFile('js'),
              child: Text('Upload JS File'),
            ),
            if (jsFileUrl != null)
              Text('JS file uploaded!', style: TextStyle(color: Colors.green)),
            SizedBox(height: 20),
            if (isUploading) CircularProgressIndicator(),
            isAdded
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SaveButton(
                      color: mainBtnColor,
                      title: "Publish",
                      onTap: () async {
                        if (serviceNameController.text.isEmpty) {
                          showMessageBar("All fields are required!", context);
                        } else {
                          setState(() {
                            isAdded = true;
                          });

                          // Track upload progress
                          saveFilesToFirestore();

                          setState(() {
                            isAdded = false;
                            _uploadProgress = 0.0;
                          });
                          showMessageBar("HTML Added Successfully", context);
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
