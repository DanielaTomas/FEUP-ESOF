import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:gsheets/gsheets.dart';
import 'package:tuple/tuple.dart';
import 'package:uni/utils/constants.dart' as Constants;

import 'package:uni/model/entities/review.dart';

import '../../controller/local_storage/app_shared_preferences.dart';

class FoodFeupRating1 extends StatefulWidget{
  final String restaurant, mealname;
  const FoodFeupRating1({Key key, @required this.restaurant, @required this.mealname}) : super(key: key);

  @override
  FoodFeupRating1State createState() => FoodFeupRating1State();
}

double rate;

class FoodFeupRating1State extends State<FoodFeupRating1> {
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  static final Key _k1 = GlobalKey();
  static final Key _k2 = GlobalKey();

  String rest;
  String meal;

  String username;
  String comment = "";

  Future<List<Widget>> l;

  @override
  void initState() {
    super.initState();
    l = getWidgets(context);
  }

  

  @override
  Widget build(BuildContext context) {
    rest = widget.restaurant;
    meal = widget.mealname;
    rate = 0;
    return Scaffold(
        body: Center(
          child: FutureBuilder(
            future: l,
            builder: (BuildContext context, AsyncSnapshot<List<Widget>> snapshot) {
              List<Widget> children;
              if (snapshot.hasData) {
                children = snapshot.data;
              } else if (snapshot.hasError) {
                children = <Widget>[
                  const Icon(
                    Icons.error_outline,
                    color: Color.fromRGBO(117, 23, 30, 1),
                    size: 60,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text('Error: ${snapshot.error}'),
                  )
                ];
              } else {
                children = <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width/3 ),
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text('Awaiting result...'),
                  )
                ];
              }
              return ListView(
                children: children,
              );
            },
          )
        )
    );
  }

  Future<List<Widget>> getWidgets(BuildContext context) async {
    final List<Widget> widgets = [];

    widgets.add(
        Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)));

    widgets.add(generateText(
        context, "Toque para avaliar:", TextAlign.left, Color.fromRGBO(117, 23, 30, 1), 20));

    widgets.add(
        Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)));

    widgets.add(generateRatingBar(context));
    widgets.add(
        Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)));

    widgets.add(
        generateText(context, "Deixe um commentário", TextAlign.left, Color.fromRGBO(117, 23, 30, 1), 20));
    widgets.add(
        Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)));

    widgets.add(generateTextInput(context));

    widgets.add(
        Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)));

    widgets.add(generatePostCommentButtom(context));

    widgets.add(
        Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)));

    widgets.add(Divider(color: Color.fromRGBO(117, 23, 30, 1), thickness: 4));

    widgets.add(
        Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)));

    final gsheets = GSheets(Constants.credentials);
    final ss = await gsheets.spreadsheet(Constants.spreadsheetId);
    Worksheet sheet = ss.worksheetByTitle("Sheet2");

    List<String> col = await sheet.values.column(2);
    for(int i = 0; i < col.length; i++)
    {

      if (col[i] == meal)
      {
        List<String> row = await sheet.values.row(i+1);
        int index = 0;
        for(String s in row) {
          if(index < 4 ) {
            index = index + 1;
            continue;
          }
          List<String> comm = s.split('&');
          if(comm[2] != "") {
            widgets.add(generateCommentField(context, comm[2], comm[1]));
          }
          index = index + 1;
        }

      }
    }

    return widgets;
  }

  Widget generateText(BuildContext context, String text, TextAlign alignment,
      Color color, double fontSize) {
    return Text(text,
        style: TextStyle(
            color: color,
            fontWeight: FontWeight.w400,
            fontSize: fontSize
        ),
        textAlign: alignment,
        overflow: TextOverflow.visible
    );
  }

  Widget generateRatingBar(BuildContext context) {
    return Center(
        key: _k2,
        child: RatingBar.builder(
          initialRating: 0,
          minRating: 0,
          glow: false,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemSize: 50,
          itemPadding: EdgeInsets.symmetric(horizontal: 1.5),
          itemBuilder: (context, _) =>
              Icon(
                Icons.star,
                color: Colors.amber,
              ),
          onRatingUpdate: updateRating
        ));
  }
  void updateRating(double r) {
    rate = r;
    print("New rate");
    print(rate);
  }

  Widget generateTextInput(BuildContext context) {
    return Theme(
      data: ThemeData(
        primaryColor: Colors.black,
        primaryColorDark: Colors.black,
      ),
      child: TextField(
        onChanged: (text){comment = text;},
        textAlignVertical: TextAlignVertical.top,
        cursorColor: Color.fromRGBO(117, 23, 30, 1),
        key: _k1,
        maxLines: 3,
        decoration: InputDecoration(
            hintText: 'Clique aqui',
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1, color: Colors.black),
              borderRadius: BorderRadius.circular(15),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1, color: Colors.black),
              borderRadius: BorderRadius.circular(15),
            )),
      ),
    );
  }

  Widget generatePostCommentButtom(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: SizedBox(
            height: 40,
            width: 300,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  primary: Color.fromRGBO(117, 23, 30, 1),
                ),
                onPressed: () =>  writeSheets(rate, comment, meal, rest),


                child: ListView(
                  children:
                  [ Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text("Post",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 20,
                              overflow: TextOverflow.ellipsis
                          ),
                          textAlign: TextAlign.center),
                    ),
                  ),
                  ],
                )
            )
        )
    );
  }

  void writeSheets(double s, String com, String ml, String rest) async {

    final Tuple2<String, String> userPersistentCredentials = await AppSharedPreferences.getPersistentUserInfo();
    username = userPersistentCredentials.item1;

    Review r = Review(s, username, ml, rest);
    if (com != "")
      r.addComment(com);
    String text = r.toString();

    final gsheets = GSheets(Constants.credentials);
    final ss = await gsheets.spreadsheet(Constants.spreadsheetId);
    Worksheet sheet = ss.worksheetByTitle("Sheet2");

    List<String> col = await sheet.values.column(2);
    for(int i = 0; i < col.length; i++)
    {

      if (col[i] == r.meal)
      {
        List<String> row = await sheet.values.row(i+1);
        await sheet.values.insertValue(text, column: row.length + 1, row: i + 1);
        int numberOfReviews = row.length - 4;
        double ratingOverall = numberOfReviews * double.parse(row[3]);
        ratingOverall = ratingOverall + s;
        ratingOverall = ratingOverall / (numberOfReviews + 1);

        await sheet.values.insertValue(ratingOverall, column: 4, row: i + 1);

      }
    }
    Navigator.pop(context);
  }

  Widget generateCommentField(BuildContext context, String text, String user) {
    return Padding(padding: EdgeInsets.symmetric(horizontal: 0, vertical: 16),
        child: Center(
            child : SizedBox (
              height: 50,
              child: Row(
                children: [
                  Column(
                    children: [
                      Icon(IconData(0xe491, fontFamily: 'MaterialIcons'), color: Color.fromRGBO(117, 23, 30, 1)),
                      generateText(context, user, TextAlign.left, Colors.black, 12),
                    ],
                  ),
                  VerticalDivider(color: Color.fromRGBO(117, 23, 30, 1), thickness: 4),
                  Expanded( child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: generateText(context, text, TextAlign.left, Colors.black, 12)))
                ],
              ),
            )
        )
    );
  }

}

