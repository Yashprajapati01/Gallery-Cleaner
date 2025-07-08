import 'dart:typed_data';

class MediaAsset {
  final String id;
  final String path;
  final Uint8List? thumbnail;
  final bool isVideo;

  MediaAsset({
    required this.id,
    required this.path,
    required this.thumbnail,
    required this.isVideo,
  });
}
