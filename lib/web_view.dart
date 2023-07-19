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
      ..setBackgroundColor(webViewColor ?? Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            Future.delayed(const Duration(seconds: 1))
                .then((value) => _initializeReadyJs(controller!));
          },
        ),
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

    return SizedBox(
      height: height,
      width: width,
      child: WebViewWidget(
        controller: controller!,
      ),
    );
  }

  void _initializeReadyJs(WebViewController controller) {
    try {
      (value) => controller.runJavaScript(
          '${AppConstants.readyCaptcha}("${RecaptchaHandler.instance.siteKey}")');
      RecaptchaHandler.executeV3();
    } on Exception catch (_) {
      onError(_.toString());
    }
  }
}
