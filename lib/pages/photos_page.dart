import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testapp/models/models.dart';
import 'package:testapp/pages/pages.dart';
import 'package:testapp/utils/utils.dart';

class PhotosPage extends StatefulWidget {
  const PhotosPage({Key? key}) : super(key: key);

  @override
  _PhotosPageState createState() => _PhotosPageState();
}

class _PhotosPageState extends State<PhotosPage> {
  String url = 'https://jsonplaceholder.typicode.com/photos';
  List<Photo> fetchedData = [];
  List<Photo> filteredData = [];
  final int increment = 16;
  bool isLoading = false;
  String dropdownValue = 'Все';

  @override
  void initState() {
    super.initState();
    _onStart();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    var albumIds = fetchedData.map((e) => e.albumId).toList();
    var uniqs = albumIds.toSet().map((e) => e.toString()).toList();
    uniqs.removeWhere((e) => e == 'Все');
    uniqs.insert(0, 'Все');

    if (!uniqs.contains(dropdownValue)) {
      dropdownValue = 'Все';
    }

    if (dropdownValue != 'Все') {
      filteredData = fetchedData
          .where((e) => e.albumId.toString() == dropdownValue)
          .toList();
    }

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
              DrawerHeader(
                child: const Text(''),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
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
              ListTile(
                leading: const Icon(Icons.post_add_sharp),
                title: const Text('Посты'),
                minLeadingWidth: 20.0,
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, "/posts", (route) => false);
                },
              ),
            ],
          ),
        ),
      ),
      body: LazyLoadScrollView(
        isLoading: isLoading,
        onEndOfPage: () => _onEndOfPage(),
        child: Scrollbar(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView(
              children: [
                Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 3),
                  child: ListTile(
                    title: const Text('Выберите альбом:'),
                    contentPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    trailing: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        isExpanded: false,
                        value: dropdownValue,
                        items: uniqs.map<DropdownMenuItem<String>>(
                          (String item) {
                            return DropdownMenuItem<String>(
                              child: SizedBox(
                                child: Text(
                                    item == 'Все' ? item : 'Альбом №$item'),
                              ),
                              value: item,
                            );
                          },
                        ).toList(),
                        onChanged: (String? value) {
                          setState(() {
                            dropdownValue = value!;
                          });
                        },
                        style: const TextStyle(
                          color: Colors.black,
                          decorationColor: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ),
                _GridWidget(
                  dataList: dropdownValue != 'Все' ? filteredData : fetchedData,
                ),
                if (isLoading)
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

  Future<void> _onStart() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String photosCached = _prefs.getString('photosCached') ?? '';

    if (photosCached.isNotEmpty) {
      List responseJson = json.decode(photosCached);
      fetchedData.addAll(responseJson.map((m) => Photo.fromJson(m)).toList());
      if (mounted) setState(() {});
      return;
    }

    final response = await http.get(Uri.parse('$url?_limit=$increment'));

    // await Future.delayed(const Duration(seconds: 2));

    if (response.statusCode == 200) {
      List responseJson = json.decode(response.body);
      _prefs.setString('photosCached', response.body);
      fetchedData.addAll(responseJson.map((m) => Photo.fromJson(m)).toList());
      if (mounted) setState(() {});
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> _onRefresh() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.remove('photosCached');

    final response = await http.get(Uri.parse('$url?_limit=$increment'));

    // await Future.delayed(const Duration(seconds: 2));

    if (response.statusCode == 200) {
      List responseJson = json.decode(response.body);
      _prefs.setString('photosCached', response.body);
      if (mounted) {
        setState(() {
          fetchedData = responseJson.map((m) => Photo.fromJson(m)).toList();
        });
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> _onEndOfPage() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String photosCached = _prefs.getString('photosCached') ?? '';

    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    int page = (fetchedData.length ~/ 16) + 1;
    final response = await http.get(
      Uri.parse('$url?_page=$page&_limit=$increment'),
    );

    // await Future.delayed(const Duration(seconds: 2));

    if (response.statusCode == 200) {
      List responseJson = json.decode(response.body);
      List decodeCached = json.decode(photosCached);
      decodeCached.addAll(responseJson);
      _prefs.setString('photosCached', json.encode(decodeCached));
      fetchedData.addAll(responseJson.map((m) => Photo.fromJson(m)).toList());
    } else {
      throw Exception('Failed to load data');
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
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
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.only(
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
                  builder: (context, model, child) {
                    return IconButton(
                      onPressed: () {
                        var element =
                            Helpers.findById(model.favoritesList, photo.id);
                        if (model.favoritesList.isNotEmpty && element != null) {
                          model.removeFavorite(photo);
                        } else {
                          model.addFavorite(photo);
                        }
                      },
                      icon: Icon(
                        _likeIconRender(photo, model.favoritesList),
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
    var element = Helpers.findById(list, item.id);
    if (list.isNotEmpty && element != null) {
      return Icons.favorite;
    }
    return Icons.favorite_border;
  }
}
