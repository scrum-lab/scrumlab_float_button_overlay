import 'dart:io';

import 'package:scrumlab_float_button_overlay/scrumlab_float_button_overlay.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart'; // Usando package_info_plus para null safety
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

Future<File> getImageFileFromAssets(String path) async {
  final byteData = await rootBundle.load('assets/$path');

  final file = File('${(await getTemporaryDirectory()).path}/$path');
  await file.writeAsBytes(byteData.buffer
      .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

  return file;
}

File? file;
PackageInfo? packageInfo;

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  TextEditingController iconWidthController = TextEditingController();
  TextEditingController iconHeightController = TextEditingController();
  TextEditingController transpWidth = TextEditingController();
  TextEditingController transpHeight = TextEditingController();
  bool showTransparencyBg = false;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    initPlatformState();
    FloatButtonOverlay.registerCallback(serviceCallback, onClickCallback);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion =
          await FloatButtonOverlay.platformVersion ?? 'Unknown version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  void serviceCallback(String tag) {
    print(tag);
  }

  void onClickCallback(String tag) {
    print(tag);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Float Button Overlay - Example'),
          backgroundColor: Colors.black45,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Running on: $_platformVersion\n'),
                TextField(
                  controller: iconWidthController,
                  decoration: InputDecoration(labelText: "Icon Width"),
                ),
                TextField(
                  controller: iconHeightController,
                  decoration: InputDecoration(labelText: "Icon Height"),
                ),
                TextField(
                  controller: transpWidth,
                  decoration: InputDecoration(labelText: "Transparency Width"),
                ),
                TextField(
                  controller: transpHeight,
                  decoration: InputDecoration(labelText: "Transparency Height"),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Show Transparency Background?'),
                    Switch(
                        value: showTransparencyBg,
                        onChanged: (value) {
                          setState(() {
                            showTransparencyBg = value;
                          });
                        }),
                  ],
                ),
                TextButton(
                  onPressed: () async {
                    file = await getImageFileFromAssets('caveira.png');
                    packageInfo = await PackageInfo.fromPlatform();

                    debugPrint("Vai abrir o overlay");
                    FloatButtonOverlay.openOverlay(
                      activityName: 'MainActivity',
                      iconPath: file?.path ?? '',
                      notificationText: "Float Button Overlay ☠️",
                      notificationTitle: 'Float Button Overlay ☠️',
                      packageName: packageInfo?.packageName ?? '',
                      showTransparentCircle: showTransparencyBg,
                      iconWidth: int.parse(iconWidthController.text.isEmpty
                          ? '100'
                          : iconWidthController.text),
                      iconHeight: int.parse(iconHeightController.text.isEmpty
                          ? '100'
                          : iconHeightController.text),
                      transpCircleHeight: int.parse(transpHeight.text.isEmpty
                          ? '150'
                          : transpHeight.text),
                      transpCircleWidth: int.parse(
                          transpWidth.text.isEmpty ? '150' : transpWidth.text),
                    );
                  },
                  child: Container(
                    color: Colors.black45,
                    height: 40,
                    width: 100,
                    child: Center(
                      child: Text(
                        "Show Button",
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    debugPrint("Vai fechar o overlay");
                    FloatButtonOverlay.closeOverlay;
                  },
                  child: Container(
                    color: Colors.black54,
                    height: 40,
                    width: 100,
                    child: Center(
                      child: Text(
                        "Close Button",
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
