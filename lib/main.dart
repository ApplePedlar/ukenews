import 'dart:async';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<List<Entry>> futureEntryList;

  @override
  void initState() {
    super.initState();
    futureEntryList = fetchEntryList();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ukenews',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('ukenews'),
        ),
        body: Center(
          child: FutureBuilder<List<Entry>>(
            future: futureEntryList,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 640.0),
                  child: Scrollbar(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children: [
                        for (int i = 0; i < snapshot.data.length; i++)
                          ListTile(
                            leading: ExcludeSemantics(
                              child: CircleAvatar(child: Text('uke')),
                            ),

                            //leading: (snapshot.data[i].image != "" ? 
                            //  Image.network(snapshot.data[i].image) :
                            //  ExcludeSemantics(
                            //    child: CircleAvatar(child: Text('uke')),
                            //  )
                            //),
                            title: Text(snapshot.data[i].title),
                            subtitle: Text(snapshot.data[i].description),
                            contentPadding: EdgeInsets.only(bottom: 10.0),
                            onTap: () {
                              launch(snapshot.data[i].link);
                            }
                          ),
                      ],
                    ),
                  )
                );
                //Text(snapshot.data[0].title);
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              // By default, show a loading spinner.
              return CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}

Future<List<Entry>> fetchEntryList() async {
  final response =
      await http.get('https://applepedlar.github.io/ukenews-entries-tsv/entry_list.tsv');

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Entry.parseEntryTsv(utf8.decode(response.bodyBytes));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load entries');
  }
}

class Entry {
  final String title;
  final String link;
  final String description;
  final String image;
  final String updated;

  Entry({this.title, this.link, this.description, this.image, this.updated});

  static List<Entry> parseEntryTsv(String tsv) {
    var lines = tsv.split("\n");
    var headers = lines[0].trim().split("\t");
    print(lines[0]);
    print(headers);
    var titleIdx = headers.indexOf("title");
    var linkIdx = headers.indexOf("link");
    var descriptionIdx = headers.indexOf("description");
    var imageIdx = headers.indexOf("image");
    var updatedIdx = headers.indexOf("updated");
    print(imageIdx);

    List<Entry> list = [];
    lines.skip(1).forEach((line) {
      var cells = line.split("\t");
      list.add(
        Entry(
          title:cells[titleIdx].trim(),
          link:cells[linkIdx].trim(),
          description:cells[descriptionIdx].trim(),
          image:cells[imageIdx].trim(),
          updated:cells[updatedIdx].trim()
        )
      );
    });
    return list;
  }
}

