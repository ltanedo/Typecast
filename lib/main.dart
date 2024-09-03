/* Main Imports */
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
/* Package Imports */
import './utils/themes.dart';
import './utils/physics.dart';

import './api.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Page View',
      theme: ThemeData(
        // rgba(255,163,0,255)
        primarySwatch: generateMaterialColorFromColor(Colors.amber[800]!),
      ),
      home: const PageViewCustom(),
    );
  }
}

class PageViewCustom extends StatefulWidget {
  const PageViewCustom({Key? key}) : super(key: key);

  @override
  State<PageViewCustom> createState() => _PageViewCustomState();
}

class _PageViewCustomState extends State<PageViewCustom> {
  double fraction = .8;

  final _pageController = PageController(
    initialPage: 0,
    viewportFraction: 1,
  );

  void hint() async {
    await Future.delayed(Duration(seconds: 1), () {
      _pageController.animateTo(100, //300 left //500 right
          duration: const Duration(milliseconds: 300),
          curve: Curves.linear);
    });
    await Future.delayed(Duration(seconds: 1), () {
      _pageController.animateTo(100, //300 left //500 right
          duration: const Duration(milliseconds: 300),
          curve: Curves.linear);
    });
  }

  final int _pageSize = 10;
  int _currentPage = 0;
  List _data = [];
  bool _isLoading = false;

  Future<void> _loadJobs() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    final response = await http.get(
      Uri.parse(
          'https://xzxymvq5rryknfxo76blfsooxq0dvgly.lambda-url.us-east-2.on.aws/?page=$_currentPage'),
    );
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      setState(() {
        _data.addAll(jsonData);
        _currentPage++;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  var _job_details = {
    "link": "",
    "category": "Performer",
    "tags": "",
    "paid": null,
    "title": "",
    "date": "",
    "theatre": "",
    "location": ["New York, NY", "US"]
  };
  Map<String, dynamic> _description = {"cast": [], "description": ""};
  bool _isLoading_description = false;

  void _loadDescription(link) async {
    if (_isLoading_description) return;
    setState(() => _isLoading_description = true);
    final response = await http.get(
      Uri.parse(
          "https://mxzwehwjyetkr5ycdme7awgf4e0tyamw.lambda-url.us-east-2.on.aws/?link=$link"),
    );
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      setState(() {
        _description = jsonData;
      });
      print(jsonData);
      setState(() => _isLoading_description = false);
    } else {
      setState(() => _isLoading_description = false);
    }
  }

  @override
  void initState() {
    hint();
    super.initState();
    _loadJobs();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.width;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: PageView(
        // pageSnapping: false,
        physics: CustomPageViewScrollPhysics(),
        controller: _pageController,
        // dragStartBehavior: DragStartBehavior.start,
        // scrollBehavior: ,
        scrollDirection: Axis.horizontal, // or Axis.vertical
        children: [
          Scaffold(
            appBar: AppBar(
              title: const Text(
                'NY Performer Jobs',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w600),
              ),
            ),
            body: _data.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : NotificationListener<ScrollNotification>(
                    onNotification: (scrollNotification) {
                      if (scrollNotification is ScrollEndNotification &&
                          scrollNotification.metrics.pixels ==
                              scrollNotification.metrics.maxScrollExtent) {
                        _loadJobs();
                      }
                      return true;
                    },
                    child: ListView.builder(
                      itemCount: _data.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < _data.length) {
                          return InkWell(
                              onTap: () async {
                                _job_details = _data[index];
                                _loadDescription(_data[index]['link']);
                                _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.linear);
                              },
                              splashColor: Colors.amber[900],
                              child: ListTile(
                                leading: Text("job $index"),
                                title: Text(_data[index]['title']),
                                subtitle: Text(_data[index]['date']),
                                trailing: Text(_data[index]['paid'] ?? ""),
                              ));
                        } else {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      },
                    ),
                  ),
          ),
          DefaultTabController(
              length: 2,
              child: Scaffold(
                appBar: AppBar(
                  title: Text(
                    _job_details['title'].toString(),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w600),
                  ),
                  centerTitle: true,
                  leading: InkWell(
                    onTap: () {
                      _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.linear);
                    },
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black54,
                    ),
                  ),
                  bottom: const TabBar(
                    tabs: [
                      Tab(
                        // icon: Icon(Icons.directions_transit),
                        text: "TypeCasts",
                      ),
                      Tab(
                        // icon: Icon(Icons.directions_transit),
                        text: "Description",
                      ),
                    ],
                  ),
                ),
                body: Container(
                  // color: Colors.blue,
                  child: _isLoading_description
                      ? Center(child: CircularProgressIndicator())
                      : TabBarView(
                          children: [
                            _isLoading_description
                                ? CircularProgressIndicator()
                                : Column(
                                    children: _description["cast"]
                                        .asMap()
                                        .entries
                                        .map<Widget>((entry) {
                                      return ListTile(
                                        title: Text('Index: ${entry.key}'),
                                        subtitle: Text(
                                            'Value: ${entry.value["name"]}'),
                                      );
                                    }).toList(),
                                  ),
                            Text(
                              _description["description"].toString(),
                              style: TextStyle(fontSize: 20),
                            )
                          ],
                        ),

                  // Center(
                  //     child: ListView(
                  //     children: [
                  //       Text(
                  //         _description["description"] ?? "",
                  //         style: TextStyle(fontSize: 20),
                  //       )
                  //     ],
                  //   )),
                ),
              ))
        ],
      ),
    );
  }
}

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key}) : super(key: key);

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   @override
//   void initState() {
//     super.initState();
//     print("i was init");
//     _loadData();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'NY Performer Jobs',
//           style: TextStyle(
//               color: Colors.white, fontSize: 30, fontWeight: FontWeight.w600),
//         ),
//       ),
//       body: _data.isEmpty
//           ? const Center(child: CircularProgressIndicator())
//           : NotificationListener<ScrollNotification>(
//               onNotification: (scrollNotification) {
//                 if (scrollNotification is ScrollEndNotification &&
//                     scrollNotification.metrics.pixels ==
//                         scrollNotification.metrics.maxScrollExtent) {
//                   _loadData();
//                 }
//                 return true;
//               },
//               child: ListView.builder(
//                 itemCount: _data.length + (_isLoading ? 1 : 0),
//                 itemBuilder: (context, index) {
//                   if (index < _data.length) {
//                     return ListTile(
//                         leading: Text("job $index"),
//                         title: Text(_data[index]['title']));
//                   } else {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//                 },
//               ),
//             ),
//     );
//   }
// }
