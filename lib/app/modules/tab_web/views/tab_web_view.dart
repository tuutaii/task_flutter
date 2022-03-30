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
              children: [
                FutureBuilder(builder: (context, snapshot) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 15),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(.2),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: TextFormField(
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          cursorHeight: 30,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            suffixIcon: (controller.showLoading)
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : IconButton(
                                    icon: const Icon(
                                      Icons.search,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      String finalURL = controller.urlCtr.text;
                                      if (!finalURL.startsWith("https://")) {
                                        finalURL = "https://" + finalURL;
                                      }
                                      controller.loading();

                                      controller.webViewController
                                          .loadUrl(finalURL)
                                          .then((onValue) {})
                                          .catchError((e) {
                                        controller.loading();
                                      });
                                    }),
                            hintText: 'Enter url here...',
                            hintStyle: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          controller: controller.urlCtr,
                        ),
                      ),
                    ),
                  );
                }),
                Expanded(
                  child: WebView(
                    initialUrl: 'https://www.google.com',
                    onPageFinished: (data) {
                      controller.loading;
                    },
                    javascriptMode: JavascriptMode.unrestricted,
                    onWebViewCreated: (webViewController) {
                      controller.webViewController = webViewController;
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
