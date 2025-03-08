import 'package:brightminds_admin/screens/greek/add_subject_greek.dart';
import 'package:brightminds_admin/screens/greek/greek_category_livel_wise.dart';
import 'package:brightminds_admin/utils/colors.dart';
import 'package:flutter/material.dart';

class GreekSection extends StatefulWidget {
  const GreekSection({super.key});

  @override
  State<GreekSection> createState() => _GreekSectionState();
}

class _GreekSectionState extends State<GreekSection> {
  Widget _buildLevelCard(
    BuildContext context,
    String level,
  ) {
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
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (builder) => GreekCategoryLevelWise(
                        level: level,
                      )));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          backgroundColor: mainBtnColor,
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (builder) => AddGreekSubject()));
          },
          child: Icon(
            Icons.add,
            color: Colors.black,
          ),
        ),
        body: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                  "Προνήπιο",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (builder) => GreekCategoryLevelWise(
                                level: "Προνήπιο",
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
                  "Νηπιαγωγείο",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (builder) => GreekCategoryLevelWise(
                                level: "Νηπιαγωγείο",
                              )));
                },
              ),
            ),
            _buildLevelCard(context, 'Επίπεδο 1'),
            _buildLevelCard(context, 'Επίπεδο 2'),
            _buildLevelCard(context, 'Επίπεδο 3'),
            _buildLevelCard(context, 'Επίπεδο 4'),
            _buildLevelCard(context, 'Επίπεδο 5'),
            _buildLevelCard(context, 'Επίπεδο 6'),
          ]),
        ));
  }
}
