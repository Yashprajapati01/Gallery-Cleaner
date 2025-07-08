import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../domain/models/media_assets.dart';
import '../../domain/repository/media_repository.dart';

// @LazySingleton(as: MediaRepository)
// class MediaRepositoryImpl implements MediaRepository {
//   @override
//   Future<List<MediaAsset>> fetchMedia() async {
//     final permission = await PhotoManager.requestPermissionExtend();
//     if (!permission.isAuth) throw Exception('Permission denied');
//
//     final albums = await PhotoManager.getAssetPathList(
//       type: RequestType.common,
//       onlyAll: true,
//     );
//
//     final media = await albums[0].getAssetListPaged(page: 0, size: 100);
//     return Future.wait(media.map((e) async {
//       final thumb = await e.thumbnailDataWithSize(ThumbnailSize(300, 300));
//       return MediaAsset(
//         id: e.id,
//         path: e.relativePath ?? '',
//         thumbnail: thumb,
//         isVideo: e.type == AssetType.video,
//       );
//     }));
//   }
//
//   @override
//   Future<void> deleteMedia(List<MediaAsset> toDelete) async {
//     await PhotoManager.editor.deleteWithIds(toDelete.map((e) => e.id).toList());
//   }
// }

import 'package:injectable/injectable.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../domain/models/media_assets.dart';
import '../../domain/repository/media_repository.dart';

// @LazySingleton(as: MediaRepository)
// class MediaRepositoryImpl implements MediaRepository {
//   @override
//   // Future<List<MediaAsset>> fetchMedia() async {
//   //   final permission = await PhotoManager.requestPermissionExtend();
//   //   if (!permission.isAuth) throw Exception('Permission denied');
//   //
//   //   final albums = await PhotoManager.getAssetPathList(
//   //     type: RequestType.common,
//   //     onlyAll: true,
//   //   );
//   //
//   //   final media = await albums[0].getAssetListPaged(page: 0, size: 100);
//   //   return Future.wait(media.map((e) async {
//   //     final thumb = await e.thumbnailDataWithSize(ThumbnailSize(300, 300));
//   //
//   //     // Get the actual file to get the full path
//   //     final file = await e.file;
//   //     final fullPath = file?.path ?? '';
//   //
//   //     return MediaAsset(
//   //       id: e.id,
//   //       path: fullPath,
//   //       thumbnail: thumb,
//   //       isVideo: e.type == AssetType.video,
//   //     );
//   //   }));
//   // }
//   Future<List<MediaAsset>> fetchMedia({
//     required void Function(double progress) onProgress,
//   }) async
//   {
//     final permission = await PhotoManager.requestPermissionExtend();
//     if (!permission.isAuth) throw Exception('Permission denied');
//
//     final albums = await PhotoManager.getAssetPathList(
//       type: RequestType.common,
//       onlyAll: true,
//     );
//
//     // final total = await albums[0].assetCountAsync;
//     final total = 200;
//     //todo : Here we have to isolate work here
//     final mediaList = await albums[0].getAssetListRange(start: 0, end: total);
//
//     List<MediaAsset> loadedAssets = [];
//
//     for (int i = 0; i < mediaList.length; i++) {
//       final e = mediaList[i];
//       final thumb = await e.thumbnailDataWithSize(ThumbnailSize(300, 900));
//       final file = await e.file;
//       final fullPath = file?.path ?? '';
//
//       loadedAssets.add(MediaAsset(
//         id: e.id,
//         path: fullPath,
//         thumbnail: thumb,
//         isVideo: e.type == AssetType.video,
//       ));
//
//       // 🔁 Update progress
//       onProgress((i + 1) / mediaList.length);
//     }
//
//     return loadedAssets;
//   }
//
//   @override
//   Future<void> deleteMedia(List<MediaAsset> toDelete) async {
//     await PhotoManager.editor.deleteWithIds(toDelete.map((e) => e.id).toList());
//   }
//   @override
//   Future<bool> checkFileExists(String path) async {
//     try {
//       return await File(path).exists();
//     } catch (e) {
//       return false;
//     }
//   }
// }

import 'dart:io';
import 'dart:isolate';
import 'package:injectable/injectable.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../domain/models/media_assets.dart';
import '../../domain/repository/media_repository.dart';

@LazySingleton(as: MediaRepository)
class MediaRepositoryImpl implements MediaRepository {
  static const int INITIAL_BATCH_SIZE = 100;
  static const int PAGINATION_BATCH_SIZE = 1000;

  int _currentOffset = 0;
  int? _totalAssetCount;
  bool _isLoadingMore = false;

  @override
  Future<List<MediaAsset>> fetchMedia({
    required void Function(double progress) onProgress,
  }) async {
    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth) throw Exception('Permission denied');

    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.common,
      onlyAll: true,
    );

    if (albums.isEmpty) return [];

    // Get total count for progress calculation
    _totalAssetCount = await albums[0].assetCountAsync;

    // Load initial batch
    final initialAssets = await _loadBatch(
      albums[0],
      start: 0,
      end: INITIAL_BATCH_SIZE,
      onProgress: onProgress,
    );

    _currentOffset = INITIAL_BATCH_SIZE;

    return initialAssets;
  }

  @override
  Future<List<MediaAsset>> fetchMoreMedia({
    required void Function(double progress) onProgress,
  }) async {
    if (_isLoadingMore || _totalAssetCount == null) return [];

    _isLoadingMore = true;

    try {
      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.common,
        onlyAll: true,
      );

      if (albums.isEmpty) return [];

      final endIndex = (_currentOffset + PAGINATION_BATCH_SIZE).clamp(
        0,
        _totalAssetCount!,
      );

      if (_currentOffset >= _totalAssetCount!) return [];

      final moreAssets = await _loadBatch(
        albums[0],
        start: _currentOffset,
        end: endIndex,
        onProgress: onProgress,
      );

      _currentOffset = endIndex;
      return moreAssets;
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<List<MediaAsset>> _loadBatch(
    AssetPathEntity album, {
    required int start,
    required int end,
    required void Function(double progress) onProgress,
  }) async {
    final mediaList = await album.getAssetListRange(start: start, end: end);
    List<MediaAsset> loadedAssets = [];

    for (int i = 0; i < mediaList.length; i++) {
      final asset = mediaList[i];

      // Load thumbnail in isolate for better performance
      final thumb = await asset.thumbnailDataWithSize(
        const ThumbnailSize(300, 900),
      );

      final file = await asset.file;
      final fullPath = file?.path ?? '';

      loadedAssets.add(
        MediaAsset(
          id: asset.id,
          path: fullPath,
          thumbnail: thumb,
          isVideo: asset.type == AssetType.video,
        ),
      );

      // Update progress
      onProgress((i + 1) / mediaList.length);
    }

    return loadedAssets;
  }

  @override
  Future<void> deleteMedia(List<MediaAsset> toDelete) async {
    await PhotoManager.editor.deleteWithIds(toDelete.map((e) => e.id).toList());
  }

  @override
  Future<bool> checkFileExists(String path) async {
    try {
      return await File(path).exists();
    } catch (e) {
      return false;
    }
  }

  @override
  bool get hasMoreMedia =>
      _totalAssetCount != null && _currentOffset < _totalAssetCount!;

  @override
  bool get isLoadingMore => _isLoadingMore;

  @override
  int get totalMediaCount => _totalAssetCount ?? 0;

  @override
  int get loadedMediaCount => _currentOffset;
}
