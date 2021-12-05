import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        actions: [
          Padding(
            padding: EdgeInsets.zero,
            child: IconButton(
              icon: const Icon(
                Icons.add,
                size: 30.0,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => _AddPostWidget(),
                  ),
                );
              },
            ),
          ),
        ],
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
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('Авторизация / Регистрация'),
                minLeadingWidth: 20.0,
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, "/", (route) => false);
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

class _AddPostWidget extends StatefulWidget {
  @override
  __AddPostWidgetState createState() => __AddPostWidgetState();
}

class __AddPostWidgetState extends State<_AddPostWidget> {
  String url = 'https://jsonplaceholder.typicode.com/posts';
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  bool isLoading = false;

  final TextEditingController controllerUserId = TextEditingController();
  final TextEditingController controllerTitle = TextEditingController();
  final TextEditingController controllerBody = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Добавить пост"),
      ),
      body: Form(
        key: formkey,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            constraints: const BoxConstraints(
              minHeight: 450.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextFormField(
                  controller: controllerUserId,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'User ID',
                    hintText: 'Enter post author ID',
                  ),
                  validator: validator,
                ),
                const SizedBox(height: 15.0),
                TextFormField(
                  controller: controllerTitle,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Title',
                    hintText: 'Enter post title',
                  ),
                  validator: validator,
                ),
                const SizedBox(height: 15.0),
                TextFormField(
                  controller: controllerBody,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Body',
                    hintText: 'Enter post body',
                  ),
                  validator: validator,
                ),
                const SizedBox(height: 25.0),
                SizedBox(
                  height: 40,
                  width: 150,
                  child: ElevatedButton(
                    onPressed: () {
                      if (formkey.currentState!.validate()) {
                        _onSubmit();
                      }
                    },
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(
                        Theme.of(context).primaryColor,
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          side: BorderSide(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20.0,
                            height: 20.0,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Добавить',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
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

  String? validator(value) {
    if (value == null || value.isEmpty) {
      return 'Field is required';
    }
    return null;
  }

  Future<void> _onSubmit() async {
    setState(() {
      isLoading = true;
    });

    var body = {
      'userId': int.tryParse(controllerUserId.text),
      'title': controllerTitle.text,
      'body': controllerBody.text,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(body),
    );

    if (response.statusCode.toString().startsWith('2')) {
      // print(response.body);
    } else {
      throw Exception('Failed to load data');
    }

    setState(() {
      isLoading = false;
    });
  }
}
