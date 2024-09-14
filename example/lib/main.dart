import 'dart:io';
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:watermark_plugin/watermark_plugin.dart';

import 'package:file_picker/file_picker.dart';


Future<void> main() async {
  await RustLib.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  File? file;
  File? waterFile;
  Uint8List? bmpData;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Native Packages'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              FilledButton(onPressed: selectFile, child: const Text('选择文件')),
              FilledButton(onPressed: selectWaterFile, child: const Text('选择水印')),

              if (file != null)
                Image.file(
                  file!,
                  width: 200,
                  height: 200,
                ),
                if (waterFile != null)
                Image.file(
                  waterFile!,
                  width: 200,
                  height: 200,
                ),
              ElevatedButton(
                  onPressed: file == null
                      ? null
                      : () async {
                      
                          final startTime = DateTime.now();
                          await addWatermark(
                            srcPath: file!.path,
                            watermarkPath: waterFile!.path,
                            outputPath: file!.path,
                          );
                          final endTime = DateTime.now();
                          print('Duration: ${endTime.difference(startTime)}');
                          setState(() {});
                        },
                  child: const Text("转换")),
           
            ],
          ),
        ),
        floatingActionButton: bmpData != null
            ? ConstrainedBox(
                constraints:
                    const BoxConstraints(maxHeight: 300, maxWidth: 300),
                child: Card(
                  elevation: 10,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const Text('转换结果'),
                        Image.memory(bmpData!),
                      ],
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Future<void> selectFile() async {
    setState(() {
      file = null;
    });
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      print(result.files.single.path!);
      file = File(result.files.single.path!);
      setState(() {});
    } else {
      // User canceled the picker
    }
  }
  Future<void> selectWaterFile() async {
    setState(() {
      waterFile = null;
    });
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      print(result.files.single.path!);
      waterFile = File(result.files.single.path!);
      setState(() {});
    } else {
      // User canceled the picker
    }
  }
}

