import 'package:brightminds_admin/screens/detail/lesson_detail.dart';
import 'package:brightminds_admin/screens/main_screen/add/add_exercise.dart';
import 'package:brightminds_admin/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ExcersiceWeb extends StatefulWidget {
  String level;
  String categoryName;
  ExcersiceWeb({super.key, required this.level, required this.categoryName});

  @override
  State<ExcersiceWeb> createState() => _ExcersiceWebState();
}

class _ExcersiceWebState extends State<ExcersiceWeb> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: mainBtnColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (builder) => AddExerciseScreen(
                      level: widget.level,
                      categoryName: widget.categoryName,
                    )),
          );
        },
        child: Icon(
          Icons.add,
          color: Colors.black,
        ),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('letters').get(),
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
          List<Map<String, dynamic>> allExercises = [];

          for (var doc in snapshot.data!.docs) {
            // Access 'exercises' array field
            var exercises = doc['exercises'] as List<dynamic>? ?? [];
            for (var exercise in exercises) {
              if (exercise is Map<String, dynamic>) {
                allExercises.add(exercise);
              }
            }
          }

          // Sort the exercises alphabetically by 'characterName'
          allExercises.sort((a, b) {
            String nameA = a['characterName']?.toString().toLowerCase() ?? '';
            String nameB = b['characterName']?.toString().toLowerCase() ?? '';
            return nameA.compareTo(nameB);
          });

          // If no exercises are found
          if (allExercises.isEmpty) {
            return const Center(
              child: Text('No Exercises Found'),
            );
          }
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              // Dynamically calculate the number of columns based on screen width
              int columns = (constraints.maxWidth / 300).floor();

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns > 0 ? columns : 1,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: allExercises.length,
                itemBuilder: (BuildContext context, int index) {
                  var exercise = allExercises[index];

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
                              height: 80,
                              width: 90,
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
