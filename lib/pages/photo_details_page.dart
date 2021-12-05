import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testapp/models/models.dart';
import 'package:testapp/utils/utils.dart';

class PhotoDetailsPage extends StatefulWidget {
  final Photo photo;

  const PhotoDetailsPage({Key? key, required this.photo}) : super(key: key);

  @override
  _PhotoDetailsPageState createState() => _PhotoDetailsPageState();
}

class _PhotoDetailsPageState extends State<PhotoDetailsPage> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Детали фото"),
      ),
      body: Container(
        padding: const EdgeInsets.only(
          top: 20.0,
          left: 15.0,
          right: 15.0,
        ),
        child: Column(
          children: <Widget>[
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              child: SizedBox(
                width: size.width,
                height: 300.0,
                child: Image.network(
                  widget.photo.url,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
            const SizedBox(height: 15.0),
            Text(
              widget.photo.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15.0),
            Consumer<AppModel>(
              builder: (context, model, child) {
                var element =
                    Helpers.findById(model.favoritesList, widget.photo.id);
                var contains =
                    model.favoritesList.isNotEmpty && element != null;
                return ElevatedButton.icon(
                  onPressed: () {
                    if (contains) {
                      model.removeFavorite(widget.photo);
                    } else {
                      model.addFavorite(widget.photo);
                    }
                  },
                  icon: const Icon(Icons.thumb_up),
                  label: Text(
                    contains ? "Unlike" : "Like",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                    primary:
                        contains ? Colors.red : Theme.of(context).primaryColor,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
