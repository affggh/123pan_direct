import 'package:a123pan_direct_download/lib123pan.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> main() async {
  //const url = "https://www.123pan.com/s/uMvrVv-bW0Sv.html"; // 28m file
  //const url = "https://www.123pan.com/s/uMvrVv-zxOSv.html"; // folder
  const url = "https://www.123pan.com/s/uMvrVv-4FOSv.html"; // very big file
  final pan123 = A123PanDirectDownloadUrl(url);

  test('Test login', () async {
    final pan123 = A123Pan();

    var loginInfo = await A123Pan.login("13245989445", "1234abcd");
    print(loginInfo);
  }, onPlatform: {
    // This test is especially slow on Windows.
    'windows': const Timeout.factor(2),
    'browser': [
      const Skip('add browser support'),
      // This will be slow on browsers once it works on them.
      const Timeout.factor(2)
    ]
  });
}
