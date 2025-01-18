import 'package:brightminds_admin/screens/deleteupdate/update_categories.dart';
import 'package:brightminds_admin/screens/detail/lesson_detail.dart';
import 'package:brightminds_admin/screens/main_screen/add/add_exercise.dart';
import 'package:brightminds_admin/utils/app_colors.dart';
import 'package:brightminds_admin/utils/buttons.dart';
import 'package:brightminds_admin/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ViewCategory extends StatefulWidget {
  String categoryName;
  String image;
  String id;
  String level;
  ViewCategory(
      {super.key,
      required this.id,
      required this.categoryName,
      required this.level,
      required this.image});

  @override
  State<ViewCategory> createState() => _ViewCategoryState();
}

class _ViewCategoryState extends State<ViewCategory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddExerciseScreen(
                          level: widget.level,
                          categoryName: widget.categoryName,
                        )));
          }),
      appBar: AppBar(),
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
                ImageSelection(
                  level: widget.level,
                  categoryName: widget.categoryName,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class FormSelection extends StatelessWidget {
  String categoryName;
  String image;
  String id;
  FormSelection(
      {super.key,
      required this.categoryName,
      required this.image,
      required this.id});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.neutral,
      width: 448,
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(image),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              categoryName,
              style: TextStyle(color: black),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SaveButton(
                title: "Update",
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UpdateCategories(
                              id: id,
                              categoryName: categoryName,
                              image: image)));
                },
                color: mainBtnColor),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SaveButton(
                title: "Delete",
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Confirm Delete'),
                        content: Text(
                            'Are you sure you want to delete this category?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Close dialog
                            },
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              try {
                                await FirebaseFirestore.instance
                                    .collection('categories')
                                    .doc(id)
                                    .delete();
                                Navigator.pop(context); // Close dialog
                                Navigator.pop(
                                    context); // Go back to previous screen
                              } catch (e) {
                                print("Error deleting category: $e");
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Failed to delete category')),
                                );
                              }
                            },
                            child: Text('Delete',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      );
                    },
                  );
                },
                color: Colors.red),
          ),
        ],
      ),
    );
  }
}

class ImageSelection extends StatefulWidget {
  final String categoryName;
  final String level;

  ImageSelection({super.key, required this.categoryName, required this.level});

  @override
  State<ImageSelection> createState() => _ImageSelectionState();
}

class _ImageSelectionState extends State<ImageSelection> {
  bool isCopyMode = false;
  List<Map<String, dynamic>> selectedExercises = [];
  String? selectedLevel;
  String? selectedCategoryName;
  List<String> levels = [];
  List<String> categoryNames = [];

  @override
  void initState() {
    super.initState();
    fetchDropdownData();
  }

  void toggleCopyMode() {
    setState(() {
      isCopyMode = !isCopyMode;
      if (!isCopyMode) {
        selectedExercises.clear(); // Clear selection when exiting copy mode
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.5,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: toggleCopyMode,
                child: Text(isCopyMode ? 'Cancel Copy' : 'Copy'),
              ),
              if (isCopyMode && selectedExercises.isNotEmpty)
                ElevatedButton(
                  onPressed: openPasteDialog,
                  child: Text('Paste'),
                ),
            ],
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('letters').snapshots(),
              builder: (BuildContext context, snapshot) {
                // Error handling
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                // Show loading spinner
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // If no data is found
                List<Map<String, dynamic>> filteredExercises = [];

                // Process each document in 'letters'
                for (var doc in snapshot.data!.docs) {
                  var exercises = doc['exercises'] as List<dynamic>? ?? [];
                  for (var exercise in exercises) {
                    // Match levelSubCategory with categoryName
                    if (exercise['levelSubCategory'] == widget.categoryName &&
                        exercise['levelCategory'] == widget.level) {
                      filteredExercises.add(exercise);
                    }
                  }
                }

                // Sort the exercises by numeric and alphabetic sequence
                filteredExercises.sort((a, b) {
                  int parseOrder(String? characterName) {
                    // Extract number from the beginning of the string
                    final numberMatch =
                        RegExp(r'^\d+').firstMatch(characterName ?? '');
                    if (numberMatch != null) {
                      return int.parse(
                          numberMatch.group(0)!); // Return the number if found
                    }
                    // Non-numeric strings are treated as very large numbers
                    return double.maxFinite.toInt();
                  }

                  String parseString(String? characterName) {
                    // Return the string part in lowercase for sorting
                    return characterName?.toLowerCase() ?? '';
                  }

                  // Compare numeric order first
                  int orderA = parseOrder(a['characterName']);
                  int orderB = parseOrder(b['characterName']);
                  if (orderA != orderB) {
                    return orderA.compareTo(orderB);
                  }

                  // If numeric values are equal, compare alphabetically
                  return parseString(a['characterName'])
                      .compareTo(parseString(b['characterName']));
                });

                // If no exercises are found
                if (filteredExercises.isEmpty) {
                  return const Center(
                    child: Text('No Exercises Found'),
                  );
                }

                return LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    // Dynamically calculate the number of columns based on screen width
                    double itemWidth = 200; // Set your desired item width
                    int crossAxisCount =
                        (constraints.maxWidth / itemWidth).floor();
                    crossAxisCount = crossAxisCount < 4 ? 4 : crossAxisCount;

                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount, // Minimum 4 items
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        // childAspectRatio: 1, // Adjust to control height/width ratio
                      ),
                      itemCount: filteredExercises.length,
                      itemBuilder: (BuildContext context, int index) {
                        var exercise = filteredExercises[index];
                        bool isSelected = selectedExercises
                            .any((e) => e['uuid'] == exercise['uuid']);
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (builder) => LessonDetail(
                                  audio: exercise['audioURL'] ?? "No Audio",
                                  categoryName: exercise['levelCategory'] ??
                                      "No Category",
                                  image: exercise['photoURL'] ??
                                      "No Image Available",
                                  id: exercise['uuid'] ?? "No ID",
                                  letter:
                                      exercise['characterName'] ?? "Unknown",
                                ),
                              ),
                            );
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Display image from photoURL
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    exercise['photoURL'] ??
                                        'https://via.placeholder.com/90', // Placeholder image
                                    height: 70,
                                    width: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Subject: ${exercise['levelSubCategory'] ?? 'N/A'}",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // Character Name
                                Text(
                                  "Lesson: ${exercise['characterName'] ?? 'Unknown Lesson'}",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (isCopyMode)
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: Checkbox(
                                      value: isSelected,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          if (value == true) {
                                            selectedExercises.add(exercise);
                                          } else {
                                            selectedExercises.removeWhere((e) =>
                                                e['uuid'] == exercise['uuid']);
                                          }
                                        });
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void fetchDropdownData() async {
    // Fetch distinct levels and categoryNames from Firestore
    var querySnapshot =
        await FirebaseFirestore.instance.collection('categories').get();

    Set<String> levelSet = {};
    Set<String> categoryNameSet = {};

    for (var doc in querySnapshot.docs) {
      levelSet.add(doc['level']);
      categoryNameSet.add(doc['categoryName']);
    }

    setState(() {
      levels = levelSet.toList();
      categoryNames = categoryNameSet.toList();
    });
  }

  void openPasteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String? tempSelectedLevel;
        String? tempSelectedCategoryName;
        List<String> filteredCategoryNames = [];

        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            Future<void> fetchAndFilterCategoryNames(String? level) async {
              if (level == null) {
                setState(() {
                  filteredCategoryNames = [];
                });
                return;
              }

              var querySnapshot = await FirebaseFirestore.instance
                  .collection('categories')
                  .where('level', isEqualTo: level)
                  .get();

              List<String> categoryNameList = querySnapshot.docs
                  .map((doc) => doc['categoryName'] as String)
                  .toList();

              setState(() {
                filteredCategoryNames = categoryNameList;
              });
            }

            return AlertDialog(
              title: Text('Paste Exercises'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: tempSelectedLevel,
                    hint: Text('Select Level'),
                    onChanged: (value) async {
                      setState(() {
                        tempSelectedLevel = value;
                        tempSelectedCategoryName = null;
                      });
                      await fetchAndFilterCategoryNames(value);
                    },
                    items: levels
                        .map((level) => DropdownMenuItem(
                              value: level,
                              child: Text(level),
                            ))
                        .toList(),
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: tempSelectedCategoryName,
                    hint: Text('Select Category Name'),
                    onChanged: (value) {
                      setState(() {
                        tempSelectedCategoryName = value;
                      });
                    },
                    items: filteredCategoryNames
                        .map((categoryName) => DropdownMenuItem(
                              value: categoryName,
                              child: Text(categoryName),
                            ))
                        .toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    print('Selected Level: $tempSelectedLevel');
                    print('Selected Category Name: $tempSelectedCategoryName');
                    print('Selected Exercises Details:');

                    for (var exercise in selectedExercises) {
                      print('ID: ${exercise['uuid']}');
                      print('Audio URL: ${exercise['audioURL']}');
                      print('Photo URL: ${exercise['photoURL']}');
                      print(
                          'Level SubCategory: ${exercise['levelSubCategory']}');
                      print('Level Category: ${exercise['levelCategory']}');
                      print('Character Name: ${exercise['characterName']}');
                      print('---');
                    }

                    // Implement your paste logic here
                    duplicateExercises(context);
                    Navigator.pop(context); // Close dialog after action
                  },
                  child: Text('Paste'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void duplicateExercises(BuildContext context) async {
    for (var exercise in selectedExercises) {
      // Create a new document ID
      String newDocumentId = Uuid().v4();

      // Prepare the new data with a unique ID
      Map<String, dynamic> newExercise = {
        'audioURL': exercise['audioURL'],
        'photoURL': exercise['photoURL'],
        'characterName': exercise['characterName'],
        'levelSubCategory': exercise['levelSubCategory'],
        'levelCategory': exercise['levelCategory'],
        'uuid': newDocumentId, // Assign new unique ID
      };

      try {
        // Set new document to the 'letters' collection with the new unique ID
        await FirebaseFirestore.instance
            .collection('letters')
            .doc(newDocumentId)
            .set({
          'exercises': [newExercise]
        });

        print('Exercise duplicated with new ID: $newDocumentId');
      } catch (e) {
        print('Failed to duplicate exercise: $e');
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exercises duplicated successfully!')),
    );
  }
}
