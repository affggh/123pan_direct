import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

final dio = Dio(BaseOptions(headers: {
  'User-Agaent':
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36 Edg/127.0.0.0",
}));

class A123PanDirectDownloadUrl {
  A123PanDirectDownloadUrl(this.shareLink, {this.password, this.tokens}) {
    void initSettings() async {
      pref = await SharedPreferences.getInstance();

      if (pref.containsKey('tokens')) {
        headers.addEntries(
            {'Authorization': "Bearer ${pref.getString('tokens')!}"}.entries);
      }
    }

    // ignore: no_leading_underscores_for_local_identifiers
    var _shareKey = getShareKey(shareLink!);

    if (_shareKey != null) {
      shareKey = _shareKey.substring(3, _shareKey.length - 5);
    }

    initSettings();
  }

  String? shareLink;
  String? password;
  String? shareKey;
  String? tokens;
  late SharedPreferences pref;

  final Map<String, dynamic> headers = {
    'User-Agaent':
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36 Edg/127.0.0.0",
  };

  final fileApiUrl = "https://www.123pan.com/b/api/share/download/info";
  final folderApiUrl =
      "https://www.123pan.com/b/api/file/batch_download_share_info";

  Future<String?> getContent() async {
    if (shareLink != null) {
      var response = await dio.get(shareLink!, options: Options(headers: headers));
      if (response.statusCode == 200) {
        return response.data.toString();
      }
    }
    return null;
  }

  static String? getShareKey(String url) {
    RegExp regex = RegExp(r"/s/(.*?).html");

    return regex.stringMatch(url);
  }

  String? findMatchData(String? content) {
    if (content != null) {
      String pattern = r"window.g_initialProps = (.*?)};";
      RegExp regex = RegExp(pattern, caseSensitive: false);

      RegExpMatch? matched = regex.firstMatch(content);
      if (matched != null) {
        String? matchedString = matched.group(0);
        if (matchedString != null) {
          return matchedString.substring(24, matchedString.length - 1);
        }
      }
      return null;
    }
    return null;
  }

  Map<String, dynamic>? convertToMap(String? data) {
    if (data != null) {
      if (data.contains(r'\u002F')) {
        data = data.replaceAll(r'\u002F', '/');
      }
      Map<String, dynamic>? jsondata = jsonDecode(data);
      if (jsondata != null) {
        return jsondata;
      }
      return null;
    }
    return null;
  }

  Future<List<dynamic>?> getFileInfoList() async {
    String? content = await getContent();

    if (content != null) {
      var data = findMatchData(content);
      if (data != null) {
        var jsondata = convertToMap(data);
        if (jsondata != null) {
          //print(jsondata["reslist"]["data"]["InfoList"]);
          return jsondata["reslist"]["data"]["InfoList"];
        }
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> getDirectDownloadLinkInfo() async {
    //List<Map<String, String>> list;
    List<dynamic>? fileInfo = await getFileInfoList();

    // FIXME: Now we can only parse one direct download url
    if (fileInfo != null) {
      var firstFileInfo = fileInfo[0];

      // Construct post data
      var pdata = firstFileInfo['Type'] == 0
          ? {
              'Etag': firstFileInfo['Etag'],
              'FileId': firstFileInfo['FileId'],
              'S3KeyFlag': firstFileInfo['S3KeyFlag'],
              'ShareKey': shareKey,
              'Size': firstFileInfo['Size'],
            }
          : {
              'Sharekey': shareKey,
              'fileIdList': [
                {
                  'fileId': firstFileInfo['FileId'],
                }
              ]
            };
      //print(firstFileInfo);
      //print(pdata);
      var resp = await dio.post(
          firstFileInfo['Type'] == 0 ? fileApiUrl : folderApiUrl,
          data: pdata,
          options: Options(
            headers: headers
          ));
      if (resp.statusCode == 200) {
        log("get return info: ${resp.data.toString()}");
        return resp.data;
      }
    }
    return null;
  }
}

class A123Pan {
  static Future<Map<String, dynamic>?> login(
      String username, String password) async {
    const loginapi = "https://www.123pan.com/b/api/user/sign_in";

    var resp = await dio.post(loginapi, data: {
      'passport': username,
      'password': password,
      'remember': true,
    });

    if (resp.statusCode == 200) {
      if (resp.data['code'] == 200) {
        return resp.data['data']; // return login info
      }
    }

    return null;
  }
}
