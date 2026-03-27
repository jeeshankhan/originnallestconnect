import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WebViewScreen(),
    );
  }
}

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {

  InAppWebViewController? webViewController;
  double progress = 0;
  bool isOffline = false;

  @override
  void initState() {
    super.initState();
    checkInternet();
  }

  void checkInternet() {
    Connectivity().onConnectivityChanged.listen((event) {
      if (event == ConnectivityResult.none) {
        setState(() {
          isOffline = true;
        });
      } else {
        setState(() {
          isOffline = false;
        });
      }
    });
  }

  Future<bool> goBack() async {
    if (webViewController != null) {
      if (await webViewController!.canGoBack()) {
        webViewController!.goBack();
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (isOffline) {
      return const Scaffold(
        body: Center(
          child: Text("No Internet Connection"),
        ),
      );
    }

    return WillPopScope(
      onWillPop: goBack,
      child:SafeArea(
        child: Scaffold(
          body: Stack(
            children: [
              InAppWebView(
                initialUrlRequest: URLRequest(
                  url: WebUri("https://letsconnect.digital"),
              ),

              onWebViewCreated: (controller) {
                webViewController = controller;
              },

              onProgressChanged: (controller, progressValue) {
                setState(() {
                  progress = progressValue / 100;
                });
              },

              pullToRefreshController: PullToRefreshController(
                onRefresh: () {
                  webViewController?.reload();
                },
              ),

              androidOnPermissionRequest: (controller, origin, resources) async {
                return PermissionRequestResponse(
                  resources: resources,
                  action: PermissionRequestResponseAction.GRANT,
                );
              },
            ),

            progress < 1
                ? LinearProgressIndicator(value: progress)
                : Container(),
          ],
        ),
      ),
      )
    );
  }
}