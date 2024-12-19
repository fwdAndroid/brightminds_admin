import 'package:brightminds_admin/utils/buttons.dart';
import 'package:brightminds_admin/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Users extends StatefulWidget {
  const Users({super.key});

  @override
  State<Users> createState() => _UsersState();
}

class _UsersState extends State<Users> {
  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();
    bool isShowUser = false;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          leading: Image.asset("assets/logo.png"),
          elevation: 0,
          actions: [
            IconButton(
                onPressed: () {
                  setState(() {
                    isShowUser = true;
                  });
                },
                icon: Icon(Icons.search))
          ],
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.black,
          centerTitle: true,
          title: TextFormField(
            controller: controller,
            decoration: InputDecoration(label: Text('Search By Name')),
            onFieldSubmitted: (_) {
              setState(() {
                isShowUser = true;
              });
            },
          )),
      body: isShowUser
          ? StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .where("fullName", isGreaterThanOrEqualTo: controller.text)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('Loading...');
                }

                List<DocumentSnapshot> documents = snapshot.data!.docs;
                return Container(
                  height: 400,
                  child: ListView.builder(
                    itemCount: documents.length,
                    itemBuilder: (BuildContext context, int index) {
                      var documentData =
                          documents[index].data() as Map<String, dynamic>;
                      return ListTile(
                        onTap: () {
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (builder) => ProviderDetails(
                          //               email: documentData['email'],
                          //               fullName: documentData['fullName'],
                          //               uid: documentData['uid'],
                          //               contactNumber:
                          //                   documentData['contactNumber'],
                          //               password: documentData['password'],
                          //             )));
                        },
                        title: Text(
                          documents[index]['fullName'],
                          style: TextStyle(color: Colors.black),
                        ),
                        subtitle: Text(
                          documents[index]['email'],
                          style: TextStyle(color: Colors.black),
                        ),
                      );
                    },
                  ),
                );
              },
            )
          : StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection("users").snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
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
                    child:
                        Text('Currently No Provider Available in Our System'),
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
                                      "Email: " + documentData['email'],
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
                                      "Name: " + documentData['fullName'],
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
                                      "Mobile: " +
                                          documentData['contactNumber'],
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SaveButton(
                                      color: mainBtnColor,
                                      onTap: () {
                                        // Navigator.push(
                                        //     context,
                                        //     MaterialPageRoute(
                                        //         builder: (builder) =>
                                        //             ProviderDetails(
                                        //               blocked: documentData[
                                        //                   'isblocked'],
                                        //               email:
                                        //                   documentData['email'],
                                        //               fullName: documentData[
                                        //                   'fullName'],
                                        //               uid: documentData['uid'],
                                        //               contactNumber:
                                        //                   documentData[
                                        //                       'contactNumber'],
                                        //               password: documentData[
                                        //                   'password'],
                                        //             )));
                                      },
                                      title: "View Detail"),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              }),
    );
  }
}