import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testapp/models/models.dart';
import 'package:testapp/pages/pages.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({Key? key}) : super(key: key);

  @override
  _PostsPageState createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  String url = 'https://jsonplaceholder.typicode.com/posts';
  List<Post> fetchedData = [];
  final int increment = 16;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _onStart();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Посты"),
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
                      context, "/favorite-posts", (route) => false);
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
                _GridWidget(
                  dataList: fetchedData,
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
    String postsCached = _prefs.getString('postsCached') ?? '';

    if (postsCached.isNotEmpty) {
      List responseJson = json.decode(postsCached);
      fetchedData.addAll(responseJson.map((m) => Post.fromJson(m)).toList());
      if (mounted) setState(() {});
      return;
    }

    final response = await http.get(Uri.parse('$url?_limit=$increment'));

    // await Future.delayed(const Duration(seconds: 2));

    if (response.statusCode == 200) {
      List responseJson = json.decode(response.body);
      _prefs.setString('postsCached', response.body);
      fetchedData.addAll(responseJson.map((m) => Post.fromJson(m)).toList());
      if (mounted) setState(() {});
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> _onRefresh() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.remove('postsCached');

    final response = await http.get(Uri.parse('$url?_limit=$increment'));

    // await Future.delayed(const Duration(seconds: 2));

    if (response.statusCode == 200) {
      List responseJson = json.decode(response.body);
      _prefs.setString('postsCached', response.body);
      if (mounted) {
        setState(() {
          fetchedData = responseJson.map((m) => Post.fromJson(m)).toList();
        });
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> _onEndOfPage() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String postsCached = _prefs.getString('postsCached') ?? '';

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
      List decodeCached = json.decode(postsCached);
      decodeCached.addAll(responseJson);
      _prefs.setString('postsCached', json.encode(decodeCached));
      fetchedData.addAll(responseJson.map((m) => Post.fromJson(m)).toList());
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
  final List<Post> dataList;

  const _GridWidget({Key? key, required this.dataList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return ListView.builder(
      primary: false,
      padding: const EdgeInsets.all(20),
      itemCount: dataList.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        var post = dataList[index];

        return Card(
          elevation: 3.0,
          margin: const EdgeInsets.symmetric(
            vertical: 6.0,
          ),
          color: Theme.of(context).primaryColor,
          child: ListTile(
            title: Text(
              post.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17.0,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 10.0,
              horizontal: 15.0,
            ),
            subtitle: Text(
              post.body,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostDetailsPage(
                    post: post,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
