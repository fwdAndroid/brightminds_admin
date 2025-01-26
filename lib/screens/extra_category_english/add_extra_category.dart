import 'package:brightminds_admin/screens/html_work/add_html_file.dart';
import 'package:brightminds_admin/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddExtraCategory extends StatefulWidget {
  String level;
  AddExtraCategory({super.key, required this.level});

  @override
  State<AddExtraCategory> createState() => _AddExtraCategoryState();
}

class _AddExtraCategoryState extends State<AddExtraCategory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: mainBtnColor,
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (builder) => AddHtmlFile()));
        },
        child: Icon(Icons.add),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("webFiles")
              .where("level", isEqualTo: widget.level)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            var data = snapshot.data!.docs;
            if (data.isEmpty) {
              // No records found
              return Center(
                child: Text('Currently Extra Avaialble'),
              );
            }
            return LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                // Calculate the number of columns based on available width
                int columns = (constraints.maxWidth / 300)
                    .floor(); // Assuming each item has a width of 200

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: data.length,
                  itemBuilder: (BuildContext context, int index) {
                    var documentData =
                        data[index].data() as Map<String, dynamic>;
                    return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () {
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (builder) => ExtraViews(
                            //             level: documentData['level'],
                            //             id: documentData['uuid'],
                            //             categoryName:
                            //                 documentData['categoryName'],
                            //             image: documentData['photoURL'])));
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
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
                                      documentData['excercise'],
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ));
                  },
                );
              },
            );
          }),
    );
  }
}
