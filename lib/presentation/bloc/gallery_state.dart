part of 'gallery_bloc.dart';

// @immutable
// sealed class GalleryState {}
//
// final class GalleryInitial extends GalleryState {}

class GalleryState {
  final List<MediaAsset> mediaList;
  final List<MediaAsset> toDelete;
  final List<MediaAsset> kept;
  final List<MediaAsset> history;

  GalleryState({
    required this.mediaList,
    required this.toDelete,
    required this.kept,
    required this.history,
  });

  factory GalleryState.initial() => GalleryState(
    mediaList: [],
    toDelete: [],
    kept: [],
    history: [],
  );

  GalleryState copyWith({
    List<MediaAsset>? mediaList,
    List<MediaAsset>? toDelete,
    List<MediaAsset>? kept,
    List<MediaAsset>? history,
  }) {
    return GalleryState(
      mediaList: mediaList ?? this.mediaList,
      toDelete: toDelete ?? this.toDelete,
      kept: kept ?? this.kept,
      history: history ?? this.history,
    );
  }
}