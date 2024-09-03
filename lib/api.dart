import 'dart:convert';
import 'package:http/http.dart' as http;

void handler() async {
  var response = await get(
    url: "https://api.orats.io/datav2/snapshot/strikes15",
    params: {
      "token": "{YOUR_ORATS_KEY}",
      "tradeDate": "202008201130",
    },
  );
  print(response);
}

Future<dynamic> get({
  required String url,
  Map<String, dynamic>? params = const {},
  Map<String, String>? headers = const {},
  int timeout = 10,
  bool DEBUG = false,
}) async {
  var uri = Uri.parse(url).replace(queryParameters: params);
  var request = http.Request('GET', uri)..headers.addAll(headers ?? {});

  try {
    http.StreamedResponse response = await request.send().timeout(
      Duration(seconds: timeout),
      onTimeout: () {
        return http.StreamedResponse(
          Stream.value(utf8.encode('Request Time Out')),
          408,
        );
      },
    );
    int status = response.statusCode;
    var data = await response.stream.bytesToString();

    if (DEBUG) {
      print("[$status] $uri");
      print("- " * 25);
      print("$headers");
      print("- " * 25);
      print(response.headers);
      print("*" * 100);
    }

    if ((response.headers["content-type"] ?? "").contains("application/json")) {
      return jsonDecode(data);
    } else {
      return data;
    }
  } catch (e) {
    print('Error: $e');
    return {"error": "$e"};
  }
}
