import 'package:a123pan_direct_download/lib123pan.dart';
import 'package:a123pan_direct_download/page_login.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher_string.dart';

class MyAppHome extends StatelessWidget {
  MyAppHome({super.key});

  final urlctrl = TextEditingController();
  final directDownloadUrlController = TextEditingController();

  void getPasteUrlText() async {
    ClipboardData? data = await Clipboard.getData("text/plain");

    if (data != null) {
      urlctrl.text = data.text!;
    }
  }

  void setClipboard() async {
    await Clipboard.setData(ClipboardData(text: directDownloadUrlController.text));
  }

  void getDirectDownloadUrl() async {
    var panddu = A123PanDirectDownloadUrl(urlctrl.text);
    var dinfo = await panddu.getDirectDownloadLinkInfo();

    if (dinfo != null) {
      if (dinfo['code'] == 0) {
      directDownloadUrlController.text = dinfo['data']['DownloadURL'];
      }
    }
  }

  void openUrl(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("123网盘获取直链"),
        centerTitle: true,
        actions: [
          Tooltip(
              message: "Login",
              child: IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const A123PanLoginPage()));
                  },
                  icon: const Icon(Icons.login)))
        ],
      ),
      body: SafeArea(
          child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                    child: TextField(
                  controller: urlctrl,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: "输入123网盘链接",
                    prefixIcon: const Icon(Icons.link),
                    suffixIcon: IconButton(
                        onPressed: getPasteUrlText,
                        icon: const Icon(Icons.paste)),
                  ),
                )),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                    flex: 0,
                    child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                directDownloadUrlController.text = "";

                                getDirectDownloadUrl();

                                return SimpleDialog(
                                  title: const Text("获取到的直链为"),
                                  contentPadding: const EdgeInsets.all(20),
                                  elevation: 60,
                                  children: (urlctrl.text.isNotEmpty)
                                      ? [
                                          PreferredSize(
                                            preferredSize: const Size.fromWidth(1200),
                                            child: TextFormField(
                                              maxLines: null,
                                              minLines: 1,
                                              controller:
                                                  directDownloadUrlController,
                                              decoration: const InputDecoration(
                                                  labelText: "Direct link"),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          Container(
                                            margin: const EdgeInsets.only(
                                                left: 20, right: 20),
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        setClipboard();
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text("Copy")),
                                                  const SizedBox(
                                                    width: 20,
                                                  ),
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        openUrl(directDownloadUrlController.text);
                                                      },
                                                      child: const Text("Open")),
                                                ]),
                                          ),
                                        ]
                                      : [
                                          const Text("输入分享链接为空"),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          FilledButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text("OK"))
                                        ],
                                );
                              });
                        },
                        child: const Text("获取直链"))),
                const SizedBox(
                  width: 20,
                )
              ],
            )
          ],
        ),
      )),
    );
  }
}
