import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: PixabayPage(),
    );
  }
}

class PixabayPage extends StatefulWidget {
  const PixabayPage({Key? key}) : super(key: key);

  @override
  State<PixabayPage> createState() => _PixabayPageState();
}

class _PixabayPageState extends State<PixabayPage> {
  List imageList = [];
  Future<void> fetchImeges(String text) async {
    Response response = await Dio().get(
      'https://pixabay.com/api/?key=28813609-ef647bde27741f4652938c951&q=$text&image_type=photo&pretty=true',
    );
    imageList = response.data['hits'];
  }

  @override
  void initState() {
    super.initState();
    fetchImeges('花');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          decoration: const InputDecoration(
            fillColor: Colors.white,
            filled: true,
          ),
          onFieldSubmitted: (text) {
            fetchImeges(text);
          },
        ),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemCount: imageList.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> image = imageList[index];
          return InkWell(
            onTap: () async {
              //画像のダウンロード
              Response response = await Dio().get(
                image['webformatURL'],
                options: Options(
                  responseType: ResponseType.bytes,
                ),
              );
              //一時的な保存と画像データの書き込み
              Directory dir = await getTemporaryDirectory();
              File imageFile = await File('${dir.path}/ image.png')
                  .writeAsBytes(response.data);
              //Share機能の追加
              await Share.shareFiles([imageFile.path]);
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  image['previewURL'],
                  fit: BoxFit.cover,
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    color: Colors.white,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.thumb_up_off_alt_outlined, size: 14),
                        Text(image['likes'].toString()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
