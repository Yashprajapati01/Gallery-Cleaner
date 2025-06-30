part of 'gallery_bloc.dart';

// @immutable
// sealed class GalleryEvent {}

abstract class GalleryEvent {}

class LoadMedia extends GalleryEvent {}
class SwipeLeft extends GalleryEvent {
  final MediaAsset media;
  SwipeLeft(this.media);
}
class SwipeRight extends GalleryEvent {
  final MediaAsset media;
  SwipeRight(this.media);
}
class UndoSwipe extends GalleryEvent {}
class ConfirmDelete extends GalleryEvent {}
class RestoreMedia extends GalleryEvent {
  final MediaAsset media;
  RestoreMedia(this.media);
}