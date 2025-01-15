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
          )
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
  Map<String, dynamic> selectedExercise = {};

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.5,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('letters').snapshots(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          List<Map<String, dynamic>> filteredExercises = [];

          for (var doc in snapshot.data!.docs) {
            var data = doc.data() as Map<String, dynamic>;
            if (data.containsKey('exercises')) {
              var exercises = data['exercises'];
              if (exercises is List) {
                for (var exercise in exercises) {
                  if (exercise['levelSubCategory'] == widget.categoryName &&
                      exercise['levelCategory'] == widget.level) {
                    filteredExercises.add({
                      'docId': doc.id,
                      'exercise': exercise,
                    });
                  }
                }
              }
            }
          }

          if (filteredExercises.isEmpty) {
            return const Center(
              child: Text('No Exercises Found'),
            );
          }
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

          if (filteredExercises.isEmpty) {
            return const Center(
              child: Text('No Exercises Found'),
            );
          }

          return Column(
            children: [
              SizedBox(
                height: 500,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemCount: filteredExercises.length,
                  itemBuilder: (BuildContext context, int index) {
                    var item = filteredExercises[index];
                    var exercise = item['exercise'];
                    String exerciseId = exercise['uuid'] ?? '';
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (builder) => LessonDetail(
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
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                exercise['photoURL'] ??
                                    'https://via.placeholder.com/90',
                                height: 50,
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
                            Text(
                              "Lesson: ${exercise['characterName'] ?? 'Unknown Lesson'}",
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Checkbox(
                              value: selectedExercise.containsKey(exerciseId),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    selectedExercise['docId'] = item['docId'];
                                    selectedExercise['exercise'] = exercise;

                                    // Print the details of the selected exercise
                                    print("Exercise copied:");
                                    exercise.forEach((key, value) {
                                      print("$key: $value");
                                    });

                                    // Show confirmation in a SnackBar
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Exercise copied: ${exercise['characterName']}'),
                                        duration: Duration(seconds: 5),
                                      ),
                                    );
                                  } else {
                                    selectedExercise.clear();
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (selectedExercise.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('No exercise selected')),
                    );
                    return;
                  }

                  try {
                    if (selectedExercise['exercise'] == null ||
                        selectedExercise['exercise'] is! Map) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Invalid exercise data')),
                      );
                      return;
                    }

                    var uuid = Uuid();
                    String newDocId =
                        uuid.v4(); // Generate a new UUID for the new document
                    String newUuid =
                        uuid.v4(); // Generate a new UUID for the exercise

                    var newExercise =
                        Map<String, dynamic>.from(selectedExercise['exercise']);
                    newExercise['uuid'] = newUuid;

                    await FirebaseFirestore.instance
                        .collection('letters')
                        .doc(
                            newDocId) // Create a new document with the new UUID
                        .set({
                      'exercises': [
                        newExercise
                      ], // Add the duplicated exercise in an array
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Exercise duplicated with UUID: $newUuid'),
                        duration: Duration(seconds: 5),
                      ),
                    );
                    print("Exercise pasted with UUID: $newUuid");

                    setState(() {
                      selectedExercise.clear();
                    });
                  } catch (e) {
                    print("Error duplicating exercise: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Failed to duplicate exercise $e')),
                    );
                  }
                },
                child: Text("Paste"),
              ),
            ],
          );
        },
      ),
    );
  }
}
