import 'package:hive/hive.dart';

part 'photo_hive_model.g.dart';

@HiveType(typeId: 0)
class PhotoHive {
  PhotoHive({
    required this.albumId,
    required this.id,
    required this.title,
    required this.url,
    required this.thumbnailUrl,
  });

  @HiveField(0)
  int albumId;

  @HiveField(1)
  int id;

  @HiveField(2)
  String title;

  @HiveField(3)
  String url;

  @HiveField(4)
  String thumbnailUrl;
}
