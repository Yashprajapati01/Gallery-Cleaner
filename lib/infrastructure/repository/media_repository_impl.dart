import 'package:injectable/injectable.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../domain/models/media_assets.dart';
import '../../domain/repository/media_repository.dart';

@LazySingleton(as: MediaRepository)
class MediaRepositoryImpl implements MediaRepository {
  @override
  Future<List<MediaAsset>> fetchMedia() async {
    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth) throw Exception('Permission denied');

    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.common,
      onlyAll: true,
    );

    final media = await albums[0].getAssetListPaged(page: 0, size: 100);
    return Future.wait(media.map((e) async {
      final thumb = await e.thumbnailDataWithSize(ThumbnailSize(300, 300));
      return MediaAsset(
        id: e.id,
        path: e.relativePath ?? '',
        thumbnail: thumb,
        isVideo: e.type == AssetType.video,
      );
    }));
  }

  @override
  Future<void> deleteMedia(List<MediaAsset> toDelete) async {
    await PhotoManager.editor.deleteWithIds(toDelete.map((e) => e.id).toList());
  }
}