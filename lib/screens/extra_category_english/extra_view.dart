import 'package:brightminds_admin/screens/detail/lesson_detail.dart';
import 'package:brightminds_admin/screens/greek/update_categories-extra.dart';
import 'package:brightminds_admin/screens/main_screen/web_home.dart';
import 'package:brightminds_admin/utils/app_colors.dart';
import 'package:brightminds_admin/utils/buttons.dart';
import 'package:brightminds_admin/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ExtraViews extends StatefulWidget {
  String categoryName;
  String image;
  String id;
  String level;
  ExtraViews(
      {super.key,
      required this.id,
      required this.categoryName,
      required this.level,
      required this.image});

  @override
  State<ExtraViews> createState() => _ExtraViewsState();
}

class _ExtraViewsState extends State<ExtraViews> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:
          FloatingActionButton(child: Icon(Icons.add), onPressed: () {}),
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
                          builder: (context) => UpdateCategoriesExtras(
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
                                    .collection('extras')
                                    .doc(id)
                                    .delete();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (builder) => WebHome()));
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

class ImageSelection extends StatelessWidget {
  final String categoryName;
  final String level;
  ImageSelection({super.key, required this.categoryName, required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.5,
      child: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('extraletters').snapshots(),
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
              if (exercise['levelSubCategory'] == categoryName &&
                  exercise['levelCategory'] == level) {
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
              int crossAxisCount = (constraints.maxWidth / itemWidth).floor();
              crossAxisCount = crossAxisCount < 4 ? 4 : crossAxisCount;

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount, // Minimum 4 items
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: filteredExercises.length,
                itemBuilder: (BuildContext context, int index) {
                  var exercise = filteredExercises[index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (builder) => LessonDetail(
                            mediaType: exercise['mediaType'] ?? "audio",
                            audio: exercise['audioURL'] ?? "No Audio",
                            categoryName:
                                exercise['levelCategory'] ?? "No Category",
                            image: exercise['photoURL'] ?? "No Image Available",
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
    );
  }
}
