// import '../models/media_assets.dart';
//
// abstract class MediaRepository {
//   Future<List<MediaAsset>> fetchMedia({
//     required void Function(double progress) onProgress,
//   });
//
//   Future<void> deleteMedia(List<MediaAsset> toDelete);
//
//   Future<bool> checkFileExists(String path);
// }


// Add these methods to your MediaRepository interface

import 'package:gallerycleaner/domain/models/media_assets.dart';

abstract class MediaRepository {
  Future<List<MediaAsset>> fetchMedia({
    required void Function(double progress) onProgress,
  });

  // New method for pagination
  Future<List<MediaAsset>> fetchMoreMedia({
    required void Function(double progress) onProgress,
  });

  Future<void> deleteMedia(List<MediaAsset> toDelete);

  Future<bool> checkFileExists(String path);

  // New getters for pagination info
  bool get hasMoreMedia;
  bool get isLoadingMore;
  int get totalMediaCount;
  int get loadedMediaCount;
}