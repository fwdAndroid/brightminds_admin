import 'package:brightminds_admin/screens/extra_category_english/add_extra_subkect.dart';
import 'package:brightminds_admin/screens/extra_category_english/extra_view.dart';
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
              context,
              MaterialPageRoute(
                  builder: (builder) => AddExtraSubject(level: widget.level)));
        },
        child: Icon(Icons.add),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("extras")
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
                child: Text('Currently No Provider Available in Our System'),
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
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (builder) => ExtraViews(
                                        level: documentData['level'],
                                        id: documentData['uuid'],
                                        categoryName:
                                            documentData['categoryName'],
                                        image: documentData['photoURL'])));
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8, right: 8),
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
