part of 'gallery_bloc.dart';
//
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
class LoadImageFile extends GalleryEvent {
  final String imagePath;
   LoadImageFile(this.imagePath);

  @override
  List<Object> get props => [imagePath];
}

class LoadVideoFile extends GalleryEvent {
  final String videoPath;
   LoadVideoFile(this.videoPath);
  @override
  List<Object> get props => [videoPath];
}


//
// abstract class GalleryEvent extends Equatable {
//   const GalleryEvent();
//
//   @override
//   List<Object?> get props => [];
// }
//
// class LoadMedia extends GalleryEvent {
//   const LoadMedia();
// }
//
// class SwipeLeft extends GalleryEvent {
//   final MediaAsset media;
//   const SwipeLeft(this.media);
//
//   @override
//   List<Object> get props => [media];
// }
//
// class SwipeRight extends GalleryEvent {
//   final MediaAsset media;
//   const SwipeRight(this.media);
//
//   @override
//   List<Object> get props => [media];
// }
//
// class UndoSwipe extends GalleryEvent {
//   const UndoSwipe();
// }
//
// class ConfirmDelete extends GalleryEvent {
//   const ConfirmDelete();
// }
//
// class RestoreMedia extends GalleryEvent {
//   final MediaAsset media;
//   const RestoreMedia(this.media);
//
//   @override
//   List<Object> get props => [media];
// }
//
// class AddToDeleteList extends GalleryEvent {
//   final String mediaId;
//   const AddToDeleteList(this.mediaId);
//
//   @override
//   List<Object> get props => [mediaId];
// }
//
// class RemoveFromDeleteList extends GalleryEvent {
//   final String mediaId;
//   const RemoveFromDeleteList(this.mediaId);
//
//   @override
//   List<Object> get props => [mediaId];
// }
//
// class LoadImageFile extends GalleryEvent {
//   final String imagePath;
//   const LoadImageFile(this.imagePath);
//
//   @override
//   List<Object> get props => [imagePath];
// }
//
// class LoadVideoFile extends GalleryEvent {
//   final String videoPath;
//   const LoadVideoFile(this.videoPath);
//
//   @override
//   List<Object> get props => [videoPath];
// }