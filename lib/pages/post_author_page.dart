import 'package:flutter/material.dart';
import 'package:testapp/models/models.dart';
import 'package:testapp/widgets/widgets.dart';

class PostAuthorPage extends StatefulWidget {
  final User author;

  const PostAuthorPage({Key? key, required this.author}) : super(key: key);

  @override
  _PostAuthorPageState createState() => _PostAuthorPageState();
}

class _PostAuthorPageState extends State<PostAuthorPage> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return ProfilePage(author: widget.author);

    // return Scaffold(
    //   appBar: AppBar(
    //     title: const Text("Детали поста"),
    //   ),
    //   body: SingleChildScrollView(
    //     child: Padding(
    //       padding: const EdgeInsets.all(20.0),
    //       child: Column(
    //         mainAxisSize: MainAxisSize.min,
    //         children: [],
    //       ),
    //     ),
    //   ),
    // );
  }
}

class ProfilePage extends StatefulWidget {
  final User author;

  const ProfilePage({Key? key, required this.author}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Детали автора"),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          vertical: 30.0,
        ),
        children: [
          ProfileWidget(
            imagePath: 'assets/elon-musk.jpg',
            onClicked: () {},
          ),
          const SizedBox(height: 24),
          Column(
            children: [
              Text(
                widget.author.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.author.email,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              )
            ],
          ),
          const SizedBox(height: 30.0),
          NumbersWidget(author: widget.author),
          const SizedBox(height: 30.0),
          buildAbout(widget.author),
        ],
      ),
    );
  }

  Widget buildAboutRichItem(String key, String value, bool isInner) => Padding(
        padding: isInner == true
            ? const EdgeInsets.only(left: 10.0)
            : const EdgeInsets.only(left: 0.0),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: key,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              TextSpan(
                text: value,
                style: const TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
        ),
      );

  Widget buildAbout(User author) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            buildAboutRichItem('Username: ', author.username, false),
            const SizedBox(height: 10.0),
            buildAboutRichItem('Phone number: ', author.phone, false),
            const SizedBox(height: 10.0),
            buildAboutRichItem('Website: ', author.website, false),
            const SizedBox(height: 16.0),
            const Text(
              'Address',
              style: TextStyle(
                fontSize: 19.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10.0),
            buildAboutRichItem('Street: ', author.address.street, true),
            const SizedBox(height: 10.0),
            buildAboutRichItem('Suite: ', author.address.suite, true),
            const SizedBox(height: 10.0),
            buildAboutRichItem('City: ', author.address.city, true),
            const SizedBox(height: 10.0),
            buildAboutRichItem('Zipcode: ', author.address.zipcode, true),
            const SizedBox(height: 16.0),
            const Text(
              'Company',
              style: TextStyle(
                fontSize: 19.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10.0),
            buildAboutRichItem('Name: ', author.company.name, true),
            const SizedBox(height: 10.0),
            buildAboutRichItem(
                'Catch phrase: ', author.company.catchPhrase, true),
            const SizedBox(height: 10.0),
            buildAboutRichItem('BS: ', author.company.bs, true),
          ],
        ),
      );
}
