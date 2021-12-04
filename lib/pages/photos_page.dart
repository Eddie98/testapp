import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testapp/models/models.dart';
import 'package:testapp/pages/pages.dart';

class PhotosPage extends StatefulWidget {
  const PhotosPage({Key? key}) : super(key: key);

  @override
  _PhotosPageState createState() => _PhotosPageState();
}

class _PhotosPageState extends State<PhotosPage> {
  List<Photo> futureData = [];
  final int increment = 16;
  bool isLoadingVertical = false;

  @override
  void initState() {
    super.initState();
    _onEndOfPage();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Лента фотографий"),
      ),
      drawer: SizedBox(
        width: size.width * 0.7,
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                child: Text(''),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Домой'),
                minLeadingWidth: 20.0,
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, "/", (route) => false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Лента фотографий'),
                minLeadingWidth: 20.0,
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, "/photos", (route) => false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.favorite_sharp),
                title: const Text('Избранные фотографии'),
                minLeadingWidth: 20.0,
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, "/favorite-photos", (route) => false);
                },
              ),
            ],
          ),
        ),
      ),
      body: LazyLoadScrollView(
        isLoading: isLoadingVertical,
        onEndOfPage: () => _onEndOfPage(),
        scrollOffset: 200,
        child: Scrollbar(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView(
              children: [
                _GridWidget(dataList: futureData),
                if (isLoadingVertical)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onStart() async {}

  Future<void> _onRefresh() async {
    final response = await http.get(
      Uri.parse(
          'https://jsonplaceholder.typicode.com/photos?_limit=$increment'),
    );

    // await Future.delayed(const Duration(seconds: 2));

    if (response.statusCode == 200) {
      List responseJson = json.decode(response.body);
      setState(() {
        futureData = responseJson.map((m) => Photo.fromJson(m)).toList();
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> _onEndOfPage() async {
    setState(() {
      isLoadingVertical = true;
    });

    final response = await http.get(
      Uri.parse(
          'https://jsonplaceholder.typicode.com/photos?_limit=$increment'),
    );

    // await Future.delayed(const Duration(seconds: 2));

    if (response.statusCode == 200) {
      List responseJson = json.decode(response.body);

      futureData.addAll(responseJson.map((m) => Photo.fromJson(m)).toList());
    } else {
      throw Exception('Failed to load data');
    }

    setState(() {
      isLoadingVertical = false;
    });
  }
}

class _GridWidget extends StatelessWidget {
  final List<Photo> dataList;

  const _GridWidget({Key? key, required this.dataList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
    final double itemWidth = size.width / 2;

    return GridView.count(
      primary: false,
      padding: const EdgeInsets.all(20),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      crossAxisCount: 2,
      shrinkWrap: true,
      childAspectRatio: (itemWidth / itemHeight),
      children: List.generate(
        dataList.length,
        (index) {
          var photo = dataList[index];

          return Stack(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PhotoDetailsPage(
                        photo: photo,
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    topRight: Radius.circular(8.0),
                  ),
                  child: SizedBox(
                    width: size.width,
                    child: Image.network(
                      photo.url,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8.0),
                      bottomRight: Radius.circular(8.0),
                    ),
                  ),
                  height: itemHeight / 3.3,
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    photo.title,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Consumer<AppModel>(
                  builder: (context, app, child) {
                    return IconButton(
                      onPressed: () {
                        app.addFavorite(photo);
                      },
                      icon: Icon(
                        _likeIconRender(photo, app.favoritesList),
                        color: Colors.red,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  IconData _likeIconRender(Photo item, List<Photo> list) {
    if (list.contains(item)) {
      return Icons.favorite;
    }
    return Icons.favorite_border;
  }
}