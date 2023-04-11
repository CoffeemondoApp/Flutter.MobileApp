import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class webPayPage extends StatefulWidget {
  const webPayPage({Key? key}) : super(key: key);

  @override
  webPayApp createState() => webPayApp();
}

class webPayApp extends State<webPayPage> {
  InAppWebViewController? webView;
  final url = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("WebPay"),
        ),
        body: InAppWebView(
          initialUrlRequest: URLRequest(url: Uri.parse(url)),
          initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(
              javaScriptEnabled: true,
              cacheEnabled: false,
            ),
            android: AndroidInAppWebViewOptions(
              thirdPartyCookiesEnabled: true,
            ),
          ),
          onWebViewCreated: (controller) {
            webView = controller;
            webView?.addJavaScriptHandler(
                handlerName: 'GrinchChannel',
                callback: (args) {
                  if (args.length == 1) {
                    print('Pago exitoso');
                  }
                });
          },
        ) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}
