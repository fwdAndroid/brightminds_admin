import 'package:brightminds_admin/screens/extra_category_english/add_extra_category.dart';
import 'package:brightminds_admin/screens/main_screen/add/add_categories.dart';
import 'package:brightminds_admin/screens/page/category_levelwise.dart';
import 'package:brightminds_admin/utils/colors.dart';
import 'package:flutter/material.dart';

Widget _buildLevelCard(
    BuildContext context, String level, String extraClass, VoidCallback tap) {
  return Card(
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 2,
    child: ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      title: Text(
        level,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: TextButton(
        onPressed: tap,
        child: Text(extraClass),
      ),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (builder) => CategoryLevelWise(
                      level: level,
                    )));
      },
    ),
  );
}

class CategoryWeb extends StatefulWidget {
  const CategoryWeb({super.key});

  @override
  State<CategoryWeb> createState() => _CategoryWebState();
}

class _CategoryWebState extends State<CategoryWeb> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: mainBtnColor,
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (builder) => AddCategory()));
          },
          child: Icon(
            Icons.add,
            color: Colors.black,
          ),
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: ListTile(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                title: Text(
                  "Pre-Kindergarden",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (builder) => CategoryLevelWise(
                                level: "Pre-Kindergarden",
                              )));
                },
              ),
            ),
            Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: ListTile(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                title: Text(
                  "Kindergarden",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (builder) => CategoryLevelWise(
                                level: "Kindergarden",
                              )));
                },
              ),
            ),
            _buildLevelCard(context, 'Level 1', 'Extra', () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (builder) =>
                          AddExtraCategory(level: 'Level 1')));
            }),
            _buildLevelCard(context, 'Level 2', 'Extra', () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (builder) =>
                          AddExtraCategory(level: 'Level 2')));
            }),
            _buildLevelCard(context, 'Level 3', 'Extra', () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (builder) =>
                          AddExtraCategory(level: 'Level 3')));
            }),
            _buildLevelCard(context, 'Level 4', 'Extra', () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (builder) =>
                          AddExtraCategory(level: 'Level 4')));
            }),
            _buildLevelCard(context, 'Level 5', 'Extra', () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (builder) =>
                          AddExtraCategory(level: 'Level 5')));
            }),
            _buildLevelCard(context, 'Level 6', 'Extra', () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (builder) =>
                          AddExtraCategory(level: 'Level 6')));
            }),
          ]),
        ));
  }
}
