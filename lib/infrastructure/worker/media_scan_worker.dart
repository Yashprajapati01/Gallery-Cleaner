import 'dart:io';
import 'package:gallerycleaner/domain/models/media_assets.dart';
import 'package:photo_manager/photo_manager.dart';

// Must be top-level for compute():
Future<List<MediaAsset>> scanRemainingMedia(int start) async {
  // Request if not yet (permissions cached by PhotoManager)
  final albums = await PhotoManager.getAssetPathList(
    type: RequestType.common,
    onlyAll: true,
  );
  final total = await albums[0].assetCountAsync;

  // Get everything from 'start' to the very end:
  final slice = await albums[0].getAssetListRange(start: start, end: total);

  final List<MediaAsset> out = [];
  for (final e in slice) {
    final thumb = await e.thumbnailDataWithSize(ThumbnailSize(300, 300));
    final file = await e.file;
    if (file == null || !(await file.exists())) continue;
    out.add(MediaAsset(
      id: e.id,
      path: file.path,
      thumbnail: thumb,
      isVideo: e.type == AssetType.video,
    ));
  }
  return out;
}
