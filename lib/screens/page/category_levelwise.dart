import 'package:brightminds_admin/screens/main_screen/add/add_categories.dart';
import 'package:brightminds_admin/screens/main_screen/view/view_category.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class CategoryLevelWise extends StatefulWidget {
  final String level;

  CategoryLevelWise({Key? key, required this.level}) : super(key: key);

  @override
  _CategoryLevelWiseState createState() => _CategoryLevelWiseState();
}

class _CategoryLevelWiseState extends State<CategoryLevelWise> {
  List<Map<String, dynamic>> copiedData = [];
  List<bool> selectedItems = [];
  QuerySnapshot? categorySnapshot;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            spacing: 18.0,
            children: [
              'Pre-Kindergarden',
              'Kindergarten',
              'Level 1',
              'Level 2',
              'Level 3',
              'Level 4',
              'Level 5',
              'Level 6',
            ].map((level) {
              return ElevatedButton(
                onPressed: () => pasteData(level),
                child: Text('$level'),
              );
            }).toList(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // Navigate to add new category screen
          Navigator.push(
              context, MaterialPageRoute(builder: (builder) => AddCategory()));
        },
      ),
      appBar: AppBar(
        title: Text("Category Level: ${widget.level}"),
      ),
      body: Column(
        children: [
          Scrollbar(
            interactive: true,
            trackVisibility: true,
            thickness: 10,
            thumbVisibility: true,
            child: SizedBox(
              height: 490,
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("categories")
                    .where("level", isEqualTo: widget.level)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No categories available.'));
                  }

                  var data = snapshot.data!.docs;
                  List<DocumentSnapshot> sortedData = List.from(data);
                  sortedData.sort((a, b) {
                    var aName =
                        (a.data() as Map<String, dynamic>)['categoryName'] ??
                            '';
                    var bName =
                        (b.data() as Map<String, dynamic>)['categoryName'] ??
                            '';
                    return aName
                        .toString()
                        .toLowerCase()
                        .compareTo(bName.toString().toLowerCase());
                  });

                  categorySnapshot = snapshot.data;

                  if (selectedItems.length != sortedData.length) {
                    selectedItems = List<bool>.filled(sortedData.length, false);
                  }

                  return ListView.builder(
                    itemCount: sortedData.length,
                    itemBuilder: (context, index) {
                      var documentData =
                          sortedData[index].data() as Map<String, dynamic>;

                      return Card(
                        margin: EdgeInsets.all(8.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(
                              documentData['photoURL'],
                            ),
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(documentData['categoryName'],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              Text("Level: ${documentData['level']}",
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                          trailing: TextButton(
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
                              child: Text("View Detail")),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Checkbox(
                                value: selectedItems[index],
                                onChanged: (bool? value) {
                                  setState(() {
                                    selectedItems[index] = value!;
                                    if (value) {
                                      copiedData.add(documentData);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Copied: ${documentData['categoryName']}'),
                                        ),
                                      );
                                    } else {
                                      copiedData.remove(documentData);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Removed: ${documentData['categoryName']} from copy'),
                                        ),
                                      );
                                    }
                                  });
                                },
                              ),
                              Text("Copy Select Data"), // Added text
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void pasteData(String targetLevel) async {
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
        'level': targetLevel
      }; // Update level
      await FirebaseFirestore.instance
          .collection('categories')
          .doc(uuid) // Use the new UUID as the document ID
          .set(newData);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Data pasted successfully to $targetLevel!')),
    );
  }
}
