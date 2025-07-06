import '../models/media_assets.dart';

abstract class MediaRepository {
  Future<List<MediaAsset>> fetchMedia({
    required void Function(double progress) onProgress,
  });

  Future<void> deleteMedia(List<MediaAsset> toDelete);

  Future<bool> checkFileExists(String path);
}
