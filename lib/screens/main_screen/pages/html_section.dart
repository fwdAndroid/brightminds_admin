import 'package:brightminds_admin/screens/html_work/add_html_file.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HtmlSection extends StatefulWidget {
  const HtmlSection({super.key});

  @override
  State<HtmlSection> createState() => _HtmlSectionState();
}

class _HtmlSectionState extends State<HtmlSection> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (builder) => AddHtmlFile()));
          }),
      body: SizedBox(
        height: 440,
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection("webFiles").snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No webFiles available.'));
            }

            var data = snapshot.data!.docs;
            List<DocumentSnapshot> sortedData = List.from(data);
            sortedData.sort((a, b) {
              var aName = (a.data() as Map<String, dynamic>)['excercise'] ?? '';
              var bName = (b.data() as Map<String, dynamic>)['excercise'] ?? '';
              return aName
                  .toString()
                  .toLowerCase()
                  .compareTo(bName.toString().toLowerCase());
            });

            return ListView.builder(
              itemCount: sortedData.length,
              itemBuilder: (context, index) {
                var documentData =
                    sortedData[index].data() as Map<String, dynamic>;

                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(documentData['excercise'],
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("Level: ${documentData['level']}",
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    trailing: TextButton(
                      onPressed: () async {
                        _showDeleteDialog(context, documentData['uuid']);
                      },
                      child: Text("Delete"),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String uuid) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete this file?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection("webFiles")
                    .doc(uuid)
                    .delete();
                Navigator.pop(context); // Close the dialog after deletion
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
