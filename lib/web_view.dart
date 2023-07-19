import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_gcaptcha_v3/constants.dart';
import 'package:flutter_gcaptcha_v3/recaptca_config.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ReCaptchaWebView extends StatelessWidget {
  ReCaptchaWebView(
      {Key? key,
      required this.url,
      required this.width,
      required this.height,
      required this.onTokenReceived,
      required this.onError,
      this.webViewColor = Colors.transparent})
      : super(key: key);

  final double width, height;
  final Function(String token) onTokenReceived;
  final Function(String error) onError;

  final Color? webViewColor;
  final String url;

  WebViewController? controller;

  @override
  Widget build(BuildContext context) {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(),
      )
      ..addJavaScriptChannel(
        AppConstants.readyJsName,
        onMessageReceived: (JavaScriptMessage message) {},
      )
      ..addJavaScriptChannel(
        AppConstants.captchaJsName,
        onMessageReceived: (JavaScriptMessage message) {
          log('TOKEN==> ${message.message}');
          onTokenReceived(message.message);
        },
      );

    RecaptchaHandler.instance.updateController(controller: controller!);

    //createLocalUrl(controller);
    controller!.loadRequest(Uri.parse(url));

    Future.delayed(const Duration(seconds: 1))
        .then((value) => _initializeReadyJs(controller!));

    return Container(
      height: height,
      width: width,
      color: webViewColor,
      child: WebViewWidget(
        controller: controller!,
      ),
    );
  }

  void _initializeReadyJs(WebViewController controller) {
    try {
      (value) => controller.runJavaScript(
          '${AppConstants.readyCaptcha}("${RecaptchaHandler.instance.siteKey}")');
    } on Exception catch (_) {
      onError(_.toString());
    }
  }
}
