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

@LazySingleton(as: MediaRepository)
class MediaRepositoryImpl implements MediaRepository {
  @override
  // Future<List<MediaAsset>> fetchMedia() async {
  //   final permission = await PhotoManager.requestPermissionExtend();
  //   if (!permission.isAuth) throw Exception('Permission denied');
  //
  //   final albums = await PhotoManager.getAssetPathList(
  //     type: RequestType.common,
  //     onlyAll: true,
  //   );
  //
  //   final media = await albums[0].getAssetListPaged(page: 0, size: 100);
  //   return Future.wait(media.map((e) async {
  //     final thumb = await e.thumbnailDataWithSize(ThumbnailSize(300, 300));
  //
  //     // Get the actual file to get the full path
  //     final file = await e.file;
  //     final fullPath = file?.path ?? '';
  //
  //     return MediaAsset(
  //       id: e.id,
  //       path: fullPath,
  //       thumbnail: thumb,
  //       isVideo: e.type == AssetType.video,
  //     );
  //   }));
  // }
  Future<List<MediaAsset>> fetchMedia({
    required void Function(double progress) onProgress,
  }) async
  {
    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth) throw Exception('Permission denied');

    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.common,
      onlyAll: true,
    );

    // final total = await albums[0].assetCountAsync;
    final total = 200;
    //todo : Here we have to isolate work here
    final mediaList = await albums[0].getAssetListRange(start: 0, end: total);

    List<MediaAsset> loadedAssets = [];

    for (int i = 0; i < mediaList.length; i++) {
      final e = mediaList[i];
      final thumb = await e.thumbnailDataWithSize(ThumbnailSize(300, 900));
      final file = await e.file;
      final fullPath = file?.path ?? '';

      loadedAssets.add(MediaAsset(
        id: e.id,
        path: fullPath,
        thumbnail: thumb,
        isVideo: e.type == AssetType.video,
      ));

      // 🔁 Update progress
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
}