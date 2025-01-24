import 'package:brightminds_admin/database/database.dart';
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

  ImageSelection({
    super.key,
    required this.categoryName,
    required this.level,
  });

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
    // TODO: implement initState
    super.initState();
    fetchDropdownData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.6,
      child: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: Database().fetchFilteredExercises(
                  level: widget.level, categoryName: widget.categoryName),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No matching exercises found.'));
                }
                List<Map<String, dynamic>> filteredExercises = [];
                allExercises.clear();

                // Process each document in 'letters'
                // Process each document in 'letters'
                for (var exercise in snapshot.data!) {
                  // Match levelSubCategory and levelCategory
                  if (exercise['levelSubCategory'] == widget.categoryName &&
                      exercise['levelCategory'] == widget.level) {
                    filteredExercises.add(exercise);
                    allExercises.add(exercise);
                  }
                }
                // Sort the filtered exercises alphabetically by 'characterName'
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

                return ListView.builder(
                  itemCount: filteredExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = filteredExercises[index];
                    bool isSelected = selectedExercises
                        .any((e) => e['uuid'] == exercise['uuid']);
                    return ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (builder) => LessonDetail(
                              mediaType: exercise['mediaType'] ?? "audio",
                              audio: exercise['audioURL'] ?? "No Audio",
                              categoryName:
                                  exercise['levelCategory'] ?? "No Category",
                              image:
                                  exercise['photoURL'] ?? "No Image Available",
                              id: exercise['uuid'] ?? "No ID",
                              letter: exercise['characterName'] ?? "Unknown",
                            ),
                          ),
                        );
                      },
                      trailing: isCopyMode
                          ? Checkbox(
                              value: isSelected,
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    selectedExercises.add(exercise);
                                  } else {
                                    selectedExercises.removeWhere(
                                        (e) => e['uuid'] == exercise['uuid']);
                                  }
                                });
                              },
                            )
                          : SizedBox(),
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          exercise['photoURL'] ??
                              'https://via.placeholder.com/150',
                        ),
                      ),
                      title: Text(
                          "Subject: ${exercise['levelSubCategory'] ?? 'N/A'}"),
                      subtitle: Text(
                        "Lesson: ${exercise['characterName'] ?? 'Unknown Lesson'}",
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 200,
                  child: SaveButton(
                    color: mainBtnColor,
                    onTap: toggleCopyMode,
                    title: isCopyMode ? 'Cancel Copy' : 'Copy',
                  ),
                ),
                const SizedBox(width: 16),
                if (isCopyMode && selectedExercises.isNotEmpty)
                  SizedBox(
                    width: 200,
                    child: SaveButton(
                      color: mainBtnColor,
                      onTap: openPasteDialog,
                      title: 'Paste',
                    ),
                  ),
                const SizedBox(width: 16),
                if (isCopyMode)
                  SizedBox(
                    width: 200,
                    child: SaveButton(
                      color: mainBtnColor,
                      onTap: copyAllExercises,
                      title: 'Copy All',
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> allExercises = [];
  void copyAllExercises() {
    setState(() {
      selectedExercises = List.from(allExercises);
    });
  }

  void toggleCopyMode() {
    setState(() {
      isCopyMode = !isCopyMode;
      if (!isCopyMode) {
        selectedExercises.clear(); // Clear selection when exiting copy mode
      }
    });
  }

  //Open Copy Paste
  void openPasteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String? tempSelectedLevel;
        String? tempSelectedCategoryName;
        List<String> filteredCategories = [];

        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            // Function to update filtered categories when level is selected
            void filterCategories(String? level) {
              if (level != null && levelCategoryMapping.containsKey(level)) {
                filteredCategories = levelCategoryMapping[level]!;
              } else {
                filteredCategories = [];
              }
              setState(() {});
            }

            return AlertDialog(
              title: const Text('Paste Exercises'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: tempSelectedLevel,
                    hint: const Text('Select Level'),
                    onChanged: (value) {
                      setState(() {
                        tempSelectedLevel = value;
                        tempSelectedCategoryName = null; // Reset category
                        filterCategories(
                            tempSelectedLevel); // Filter categories
                      });
                    },
                    items: levels
                        .map((level) => DropdownMenuItem(
                              value: level,
                              child: Text(level),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: tempSelectedCategoryName,
                    hint: const Text('Select Category Name'),
                    onChanged: (value) {
                      setState(() {
                        tempSelectedCategoryName = value;
                      });
                    },
                    items: filteredCategories.isNotEmpty
                        ? filteredCategories
                            .map((categoryName) => DropdownMenuItem(
                                  value: categoryName,
                                  child: Text(categoryName),
                                ))
                            .toList()
                        : [
                            DropdownMenuItem(
                              value: null,
                              child: Text(
                                'No subjects available. Please add subjects and try again.',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    duplicateExercises(
                      context,
                      tempSelectedLevel,
                      tempSelectedCategoryName,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Paste'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void duplicateExercises(
    BuildContext context,
    String? selectedLevel,
    String? selectedCategoryName,
  ) async {
    if (selectedLevel == null || selectedCategoryName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both Level and Category')),
      );
      return;
    }

    for (var exercise in selectedExercises) {
      String newDocumentId = Uuid().v4();

      Map<String, dynamic> newExercise = {
        'audioURL': exercise['audioURL'],
        'photoURL': exercise['photoURL'],
        'characterName': exercise['characterName'],
        'levelSubCategory': selectedCategoryName,
        'levelCategory': selectedLevel,
        'uuid': newDocumentId,
      };

      try {
        await FirebaseFirestore.instance
            .collection('letters')
            .doc(newDocumentId)
            .set({
          'exercises': [newExercise],
        });

        print('Exercise duplicated with new ID: $newDocumentId');
      } catch (e) {
        print('Failed to duplicate exercise: $e');
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exercises duplicated successfully!')),
    );
  }

  Map<String, List<String>> levelCategoryMapping = {};
  void fetchDropdownData() async {
    try {
      var querySnapshot =
          await FirebaseFirestore.instance.collection('categories').get();

      Map<String, List<String>> levelCategoryMapping = {};
      Set<String> fetchedLevels = {};

      for (var doc in querySnapshot.docs) {
        String level =
            doc['level'].toString(); // Ensure level is treated as a string
        String categoryName = doc['categoryName'];

        // Collect levels into a Set to avoid duplicates
        fetchedLevels.add(level);

        // Collect categories per level
        if (!levelCategoryMapping.containsKey(level)) {
          levelCategoryMapping[level] = [];
        }

        // Allow duplicates in the same level's categories if needed
        levelCategoryMapping[level]?.add(categoryName);
      }

      setState(() {
        this.levelCategoryMapping = levelCategoryMapping;
        this.levels = fetchedLevels.toList()..sort(); // Sort levels if needed
      });

      print("Fetched Levels: $levels"); // Debug print to check fetched levels
      print(
          "Level Category Mapping: $levelCategoryMapping"); // Debug print for mapping
    } catch (e) {
      print("Error fetching dropdown data: $e");
    }
  }
}
