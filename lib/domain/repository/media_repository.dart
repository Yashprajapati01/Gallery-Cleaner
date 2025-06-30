import '../models/media_assets.dart';

abstract class MediaRepository {
  Future<List<MediaAsset>> fetchMedia();
  Future<void> deleteMedia(List<MediaAsset> toDelete);
}