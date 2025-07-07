part of 'gallery_bloc.dart';

// @immutable
// sealed class GalleryState {}

// final class GalleryInitial extends GalleryState {}

class GalleryState {
  final List<MediaAsset> mediaList;
  final List<MediaAsset> toDelete;
  final List<MediaAsset> kept;
  final List<MediaAsset> history;
  final bool isLoading;
  final bool isLoadingMore;
  final double loadingProgress;
  final double loadingMoreProgress;
  final String? error;

  GalleryState({
    required this.mediaList,
    required this.toDelete,
    required this.kept,
    required this.history,
    required this.isLoading,
    required this.isLoadingMore,
    required this.loadingProgress,
    required this.loadingMoreProgress,
    this.error,
  });

  factory GalleryState.initial() => GalleryState(
    mediaList: [],
    toDelete: [],
    kept: [],
    history: [],
    isLoading: false,
    isLoadingMore: false,
    loadingProgress: 0.0,
    loadingMoreProgress: 0.0,
  );

  GalleryState copyWith({
    List<MediaAsset>? mediaList,
    List<MediaAsset>? toDelete,
    List<MediaAsset>? kept,
    List<MediaAsset>? history,
    bool? isLoading,
    bool? isLoadingMore,
    double? loadingProgress,
    double? loadingMoreProgress,
    String? error,
  }) {
    return GalleryState(
      mediaList: mediaList ?? this.mediaList,
      toDelete: toDelete ?? this.toDelete,
      kept: kept ?? this.kept,
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadingProgress: loadingProgress ?? this.loadingProgress,
      loadingMoreProgress: loadingMoreProgress ?? this.loadingMoreProgress,
      error: error ?? this.error,
    );
  }
  @override
  List<Object?> get props => [
    mediaList,
    toDelete,
    kept,
    history,
    isLoading,
    isLoadingMore,
    loadingProgress,
    loadingMoreProgress,
    error,
  ];
}


// enum GalleryStatus { initial, loading, success, error, deleting }
// enum ImageViewerStatus { initial, loading, success, error }
// enum VideoPlayerStatus { initial, loading, success, error }
//
// class GalleryState extends Equatable {
//   final GalleryStatus status;
//   final List<MediaAsset> mediaList;
//   final Set<String> swipedIds;
//   final Set<String> toDeleteIds;
//   final Set<String> keptIds;
//   final List<MediaAsset> history;
//   final String? errorMessage;
//
//   // Image viewer state
//   final ImageViewerStatus imageViewerStatus;
//   final String? currentImagePath;
//   final String? imageErrorMessage;
//
//   // Video player state
//   final VideoPlayerStatus videoPlayerStatus;
//   final String? currentVideoPath;
//   final String? videoErrorMessage;
//
//   const GalleryState({
//     required this.status,
//     required this.mediaList,
//     required this.swipedIds,
//     required this.toDeleteIds,
//     required this.keptIds,
//     required this.history,
//     this.errorMessage,
//     required this.imageViewerStatus,
//     this.currentImagePath,
//     this.imageErrorMessage,
//     required this.videoPlayerStatus,
//     this.currentVideoPath,
//     this.videoErrorMessage,
//   });
//
//   const GalleryState.initial()
//       : status = GalleryStatus.initial,
//         mediaList = const [],
//         swipedIds = const {},
//         toDeleteIds = const {},
//         keptIds = const {},
//         history = const [],
//         errorMessage = null,
//         imageViewerStatus = ImageViewerStatus.initial,
//         currentImagePath = null,
//         imageErrorMessage = null,
//         videoPlayerStatus = VideoPlayerStatus.initial,
//         currentVideoPath = null,
//         videoErrorMessage = null;
//
//   GalleryState copyWith({
//     GalleryStatus? status,
//     List<MediaAsset>? mediaList,
//     Set<String>? swipedIds,
//     Set<String>? toDeleteIds,
//     Set<String>? keptIds,
//     List<MediaAsset>? history,
//     String? errorMessage,
//     ImageViewerStatus? imageViewerStatus,
//     String? currentImagePath,
//     String? imageErrorMessage,
//     VideoPlayerStatus? videoPlayerStatus,
//     String? currentVideoPath,
//     String? videoErrorMessage,
//   }) {
//     return GalleryState(
//       status: status ?? this.status,
//       mediaList: mediaList ?? this.mediaList,
//       swipedIds: swipedIds ?? this.swipedIds,
//       toDeleteIds: toDeleteIds ?? this.toDeleteIds,
//       keptIds: keptIds ?? this.keptIds,
//       history: history ?? this.history,
//       errorMessage: errorMessage ?? this.errorMessage,
//       imageViewerStatus: imageViewerStatus ?? this.imageViewerStatus,
//       currentImagePath: currentImagePath ?? this.currentImagePath,
//       imageErrorMessage: imageErrorMessage ?? this.imageErrorMessage,
//       videoPlayerStatus: videoPlayerStatus ?? this.videoPlayerStatus,
//       currentVideoPath: currentVideoPath ?? this.currentVideoPath,
//       videoErrorMessage: videoErrorMessage ?? this.videoErrorMessage,
//     );
//   }
//
//   @override
//   List<Object?> get props => [
//     status,
//     mediaList,
//     swipedIds,
//     toDeleteIds,
//     keptIds,
//     history,
//     errorMessage,
//     imageViewerStatus,
//     currentImagePath,
//     imageErrorMessage,
//     videoPlayerStatus,
//     currentVideoPath,
//     videoErrorMessage,
//   ];
// }