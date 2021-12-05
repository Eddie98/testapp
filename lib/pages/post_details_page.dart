import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:testapp/models/models.dart';
import 'package:http/http.dart' as http;

class PostDetailsPage extends StatefulWidget {
  final Post post;

  const PostDetailsPage({Key? key, required this.post}) : super(key: key);

  @override
  _PostDetailsPageState createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  String url = 'https://jsonplaceholder.typicode.com/users';
  String url2 = 'https://jsonplaceholder.typicode.com/comments';

  late Future<User> author;
  late Future<List<Comment>> comments;

  @override
  void initState() {
    super.initState();
    author = _fetchAuthor();
    comments = _fetchComments();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Детали поста"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FutureBuilder<User>(
                future: author,
                builder: (context, snapshot) {
                  if (snapshot.hasData && !snapshot.hasError) {
                    var author = snapshot.data;

                    return Card(
                      elevation: 3.0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 15.0,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.post.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                              ),
                            ),
                            const SizedBox(height: 14.0),
                            Text(
                              widget.post.body,
                              style: const TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            ListTile(
                              trailing: const CircleAvatar(
                                backgroundImage: AssetImage(
                                  'assets/elon-musk.jpg',
                                ),
                              ),
                              title: Text(author!.name),
                              onTap: () {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => PostDetailsPage(
                                //       post: post,
                                //     ),
                                //   ),
                                // );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink(child: null);
                },
              ),
              const SizedBox(height: 15.0),
              FutureBuilder<List<Comment>>(
                  future: comments,
                  builder: (context, snapshot) {
                    if (snapshot.hasData && !snapshot.hasError) {
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        separatorBuilder: (context, index) {
                          return const SizedBox(height: 15.0);
                        },
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          var comment = snapshot.data![index];

                          return Card(
                            margin: EdgeInsets.zero,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                            ),
                            color: Colors.white,
                            elevation: 4.0,
                            child: Container(
                              constraints: const BoxConstraints(
                                maxHeight: double.infinity,
                              ),
                              margin: const EdgeInsets.only(
                                right: 16,
                                left: 16,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 15.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                              right: 8.0,
                                            ),
                                            width: 35,
                                            height: 35,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                100,
                                              ),
                                              image: const DecorationImage(
                                                image: AssetImage(
                                                  'assets/elon-musk.jpg',
                                                ),
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            comment.email,
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10.0),
                                    Text(
                                      comment.body,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                    const SizedBox(height: 10.0),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        InkWell(
                                          child: const Text(
                                            '6 replies',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          onTap: () {},
                                        ),
                                        Text.rich(
                                          TextSpan(
                                            style: const TextStyle(
                                                color: Colors.black),
                                            children: [
                                              WidgetSpan(
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 2.0),
                                                  child: const Icon(
                                                    Icons.thumb_down,
                                                    size: 15.0,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                              const TextSpan(
                                                  text: "3",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.red)),
                                            ],
                                          ),
                                        ),
                                        Text.rich(
                                          TextSpan(
                                            style: Theme.of(context)
                                                .textTheme
                                                .button,
                                            children: [
                                              WidgetSpan(
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 2.0),
                                                  child: const Icon(
                                                    Icons.thumb_up,
                                                    size: 15.0,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                              const TextSpan(
                                                  text: "3",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.red,
                                                  )),
                                            ],
                                          ),
                                        ),
                                        Text.rich(
                                          TextSpan(
                                            style: Theme.of(context)
                                                .textTheme
                                                .button,
                                            children: [
                                              WidgetSpan(
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 2.0),
                                                  child: const Icon(
                                                    Icons.reply,
                                                    size: 15.0,
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                              ),
                                              const TextSpan(
                                                  text: "Reply",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.blue)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 15.0),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink(child: null);
                  }),
            ],
          ),
        ),
      ),
    );
  }

  Future<User> _fetchAuthor() async {
    final response = await http.get(Uri.parse('$url/${widget.post.userId}'));

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<List<Comment>> _fetchComments() async {
    final response =
        await http.get(Uri.parse('$url2?postId=${widget.post.id}'));

    if (response.statusCode == 200) {
      List responseJson = json.decode(response.body);

      return responseJson.map((m) => Comment.fromJson(m)).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }
}
