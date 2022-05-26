import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AboutPage extends StatefulWidget {
  String returnUrl;
  String appBarTitle;

  AboutPage({
    this.returnUrl,
    this.appBarTitle,
  });
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  InAppWebViewController webView;
  String url = "";
  String initialUrl = "";
  double progress = 0;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    initialUrl = widget.returnUrl;

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(initialUrl);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0XFF6F8671),
        title: Text(widget.appBarTitle),
      ),
      // body: WebView(
      //   initialUrl: //initialUrl,
      //       "https://firebasestorage.googleapis.com/v0/b/stripefirebase-d2abb.appspot.com/o/TasksFiles%2FAli%20Abdullah%20(1).pdf?alt=media&token=858900e6-372d-4457-8cb1-90b604ce2874",
      //   javascriptMode: JavascriptMode.unrestricted,
      // ),
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
                padding: EdgeInsets.all(10.0),
                child: progress < 1.0
                    ? LinearProgressIndicator(
                        value: progress,
                      )
                    : Container()),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(0.0),
                child: InAppWebView(
                  initialUrlRequest: URLRequest(
                      url: Uri.parse(
                          "https://firebasestorage.googleapis.com/v0/b/stripefirebase-d2abb.appspot.com/o/cSXVUNsVHHVxegyRH8OrtGAyYSW2%2F4c3e15eb-d8b9-4e19-8860-a0ac78480158758955131493263834.jpg?alt=media&token=322aa8e9-f739-4a13-97d4-351420e6c4af")),
                  initialOptions: InAppWebViewGroupOptions(
                      android: AndroidInAppWebViewOptions(
                          useHybridComposition: true),
                      crossPlatform:
                          InAppWebViewOptions(useOnDownloadStart: true)),
                  onWebViewCreated: (InAppWebViewController controller) {
                    webView = controller;
                  },
                  onLoadStart: (controller, url) {
                    setState(() {
                      this.url = url.toString();
                      //urlController.text = this.url;
                    });
                  },
                  // onLoadStart: (InAppWebViewController controller, String url) {
                  //   setState(() {
                  //     this.url = url;
                  //   });
                  // },
                  onLoadStop: (controller, url) async {
                    //pullToRefreshController.endRefreshing();
                    setState(() {
                      this.url = url.toString();
                      //urlController.text = this.url;
                    });
                  },
                  // onLoadStop:
                  //     (InAppWebViewController controller, String url) async {
                  //   if (url.contains("")) {
                  //   } else {
                  //     setState(() {
                  //       this.url = url;
                  //     });
                  //   }
                  // },
                  onProgressChanged:
                      (InAppWebViewController controller, int progress) {
                    setState(() {
                      this.progress = progress / 100;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
