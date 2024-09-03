import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

http.StreamedResponse timeOutResponse(
  String httpMethod,
  dynamic error,
  String url,
) {
  Map<String, dynamic> body = {
    'any': 'value',
    'you': 'want for $error',
  };

  int statusCode = 404;
  Uri destination = Uri.parse(url);
  String json = jsonEncode(body);

  return http.StreamedResponse(
    Stream.value(json.codeUnits),
    statusCode,
    request: http.Request(httpMethod, destination),
  );
}

Future<bool> hasInternet() async {
  ConnectivityResult value = await Connectivity().checkConnectivity();
  if (![ConnectivityResult.mobile, ConnectivityResult.wifi].contains(value)) {
    return false;
  }
  return true;
}

Future<dynamic> endpoint(
    {Map<String, dynamic>? params = null,
    int timeout = 10,
    required String endpoint}) async {
  ConnectivityResult value = await Connectivity().checkConnectivity();
  if (![ConnectivityResult.mobile, ConnectivityResult.wifi].contains(value)) {
    return {"error": "no internet"};
  }
  params = params ?? {};
  var account = jsonDecode(await SessionManager().get("account"));
  var request = http.Request(
    'GET',
    Uri.parse(
        "https://rl7ggdyr6kavh2fu5ag3wzgw5i0hzndp.lambda-url.us-east-2.on.aws"),
  )..headers.addAll({
      'Content-Type': 'application/json',
    });
  params["account"] = account;
  var body = {"endpoint": endpoint, "params": params};
  request.body = jsonEncode(body);

  try {
    http.StreamedResponse response = await request.send().timeout(
      Duration(seconds: timeout),
      onTimeout: () {
        return timeOutResponse(
          'GET',
          'Request Time Out',
          "https://rl7ggdyr6kavh2fu5ag3wzgw5i0hzndp.lambda-url.us-east-2.on.aws",
        );
      },
    );
    int status = response.statusCode;
    var data = jsonDecode(await response.stream.bytesToString());
    print("[$status] $endpoint - $params");
    print("- " * 25);
    print(JsonEncoder.withIndent("  ").convert(data));
    print("*" * 100);
    return data;
  } catch (e) {
    return [];
  }
}

Future<dynamic> fake(endpoint) async {
  List<String> valid = [
    'profile',
    'edge',
    'check-in',
    'media',
    'platforms',
    'goals',
    'tracking',
    'datasets',
    'dashboards',
    'health',
    'assessments',
    'athlete_notes',
    'trainer_notes',
    'acuity',
    'day_plan'
  ];

  // Read the file
  final file = File('./utils/cache.json');
  // final jsonString = await file.readAsString();
  String jsonString = await rootBundle.loadString('assets/cache.json');

  // Decode the JSON
  Map<String, dynamic> jsonData = jsonDecode(jsonString);

  if (jsonData.keys.toList().contains(endpoint)) {
    return jsonData[endpoint];
  }

  return {"error": "'$endpoint' not a valid endpoint"};
}

Future<dynamic> real(params) async {
  List<String> valid = [
    'profile',
    'edge',
    'check-in',
    'media',
    'platforms',
    'goals',
    'tracking',
    'datasets',
    'dashboards',
    'health',
    'assessments',
    'athlete_notes',
    'trainer_notes',
    'acuity',
    'day_plan'
  ];

  // "api": param,
  // "category": "Strength YTP"
  // "device": "blast",
  // "date": "07/30/2024",
  var uri = Uri(
    scheme: 'https',
    host: 'lz7nxqg3at3mw4g3msrrfcvie40hoafd.lambda-url.us-east-2.on.aws',
    queryParameters: params,
  );

  final resp = await http.get(uri);
  final status = resp.statusCode;
  final debug = params.toString();
  print("[$status] $debug");
  try {
    return jsonDecode(resp.body);
  } catch (e) {
    return [];
  }
}

// void main() {
//   List<String> endpoints = [];
//   List<String> valid = [
//     'profile', // good
//     'edge', // good
//     'check-in',
//     'media',
//     'platforms',
//     'goals',
//     'tracking',
//     'datasets',
//     'dashboards',
//     'health',
//     'assessments',
//     'athlete_notes',
//     'trainer_notes',
//     'acuity',
//     'day_plan'
//   ];

//   // valid.forEach((endoint) {
//   //   fake(endoint).then((value) {
//   //     print("endoint - $endoint");
//   //     try {
//   //       print(JsonEncoder.withIndent('  ').convert(value));
//   //     } catch (e) {
//   //       print(value);
//   //     }
//   //   });
//   // });

//   real({"api": "edge"}).then((val) => print(val.runtimeType));
//   real({"api": "edge", ""}).then((val) => print(val.runtimeType));

// }

