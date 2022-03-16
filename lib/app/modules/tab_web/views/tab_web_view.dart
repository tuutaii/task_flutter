import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../controllers/tab_web_controller.dart';

class TabWebView extends StatelessWidget {
  const TabWebView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TabWebController>(builder: (controller) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Flexible(
                          flex: 4,
                          child: FutureBuilder(builder: (context, snapshot) {
                            return TextFormField(
                              autocorrect: false,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 20),
                              decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Colors.black)),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          const BorderSide(color: Colors.grey)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  suffixIcon: IconButton(
                                      icon: const Icon(
                                        Icons.search,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () {
                                        String finalURL =
                                            controller.urlCtr.text;
                                        if (!finalURL.startsWith("https://")) {
                                          finalURL = "https://" + finalURL;
                                        }
                                        // ignore: unnecessary_null_comparison
                                        if (controller != null) {
                                          controller.loading();

                                          controller.webViewController
                                              .loadUrl(finalURL)
                                              .then((onValue) {})
                                              .catchError((e) {
                                            controller.loading();
                                          });
                                        }
                                      }),
                                  hintText: 'Enter url here...',
                                  hintStyle: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic)),
                              controller: controller.urlCtr,
                            );
                          }))
                    ],
                  ),
                ),
                Flexible(
                    flex: 6,
                    child: Stack(
                      children: <Widget>[
                        WebView(
                          initialUrl: 'https://www.google.com',
                          onPageFinished: (data) {
                            controller.loading;
                          },
                          javascriptMode: JavascriptMode.unrestricted,
                          onWebViewCreated: (webViewController) {
                            controller.webViewController = webViewController;
                          },
                        ),
                        (controller.showLoading)
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : const Center()
                      ],
                    )),
              ],
            ),
          ),
        ),
      );
    });
  }
}
