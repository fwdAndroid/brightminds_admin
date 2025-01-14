import 'package:brightminds_admin/screens/main_screen/add/add_categories.dart';
import 'package:brightminds_admin/screens/main_screen/view/view_category.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CategoryLevelWise extends StatefulWidget {
  final String level;

  CategoryLevelWise({super.key, required this.level});

  @override
  State<CategoryLevelWise> createState() => _CategoryLevelWiseState();
}

class _CategoryLevelWiseState extends State<CategoryLevelWise> {
  List<Map<String, dynamic>> copiedData = [];
  List<bool> selectedItems = [];
  QuerySnapshot? categorySnapshot;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (builder) => AddCategory()));
        },
      ),
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: pasteData,
            child: Text("Paste"),
          ),
        ],
        title: Text("Category Level: ${widget.level}"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("categories")
            .where("level", isEqualTo: widget.level)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('Currently No Provider Available in Our System'),
            );
          }

          var data = snapshot.data!.docs;
          List<DocumentSnapshot> sortedData = List.from(data);
          sortedData.sort((a, b) {
            var aName =
                (a.data() as Map<String, dynamic>)['categoryName'] ?? '';
            var bName =
                (b.data() as Map<String, dynamic>)['categoryName'] ?? '';
            return aName
                .toString()
                .toLowerCase()
                .compareTo(bName.toString().toLowerCase());
          });

          categorySnapshot = snapshot.data;

          // Synchronize the size of selectedItems with the sortedData length
          if (selectedItems.length != sortedData.length) {
            selectedItems = List<bool>.filled(sortedData.length, false);
          }

          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              int columns = (constraints.maxWidth / 300).floor();

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: sortedData.length,
                itemBuilder: (BuildContext context, int index) {
                  var documentData =
                      sortedData[index].data() as Map<String, dynamic>;

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Checkbox(
                            value: selectedItems[index],
                            onChanged: (bool? value) {
                              setState(() {
                                selectedItems[index] = value!;
                                if (value) {
                                  copiedData.add(documentData);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Copied: ${documentData['categoryName']}'),
                                    ),
                                  );
                                } else {
                                  copiedData.remove(documentData);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Removed: ${documentData['categoryName']} from copy'),
                                    ),
                                  );
                                }
                              });
                            },
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                                child: Image.network(
                                  height: 80,
                                  width: 90,
                                  fit: BoxFit.cover,
                                  documentData['photoURL'],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "Level Name: " + documentData['level'],
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                documentData['categoryName'],
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (builder) => ViewCategory(
                                              id: documentData['uuid'],
                                              categoryName:
                                                  documentData['categoryName'],
                                              level: documentData['level'],
                                              image: documentData['photoURL'],
                                            )));
                              },
                              child: Text("View Detail"))
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

  void pasteData() async {
    if (copiedData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No data copied!')),
      );
      return;
    }

    for (var data in copiedData) {
      var uuid = Uuid().v4(); // Generate a new UUID for each document
      var newData = {
        ...data,
        'uuid': uuid,
        'level': widget.level, // Update the level field to the current level
      };
      await FirebaseFirestore.instance
          .collection('categories')
          .doc(uuid) // Use the new UUID as the document ID
          .set(newData);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text('Data pasted successfully into level ${widget.level}!')),
    );
  }
}
