import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

import '../../domain/models/media_assets.dart';
import '../../domain/repository/media_repository.dart';

part 'gallery_event.dart';
part 'gallery_state.dart';

class GalleryBloc extends Bloc<GalleryEvent, GalleryState> {
  final MediaRepository repository;

  GalleryBloc(this.repository) : super(GalleryState.initial()) {
    on<LoadMedia>(_onLoadMedia);
    on<LoadMoreMedia>(_onLoadMoreMedia);
    on<SwipeLeft>(_onSwipeLeft);
    on<SwipeRight>(_onSwipeRight);
    on<UndoSwipe>(_onUndoSwipe);
    on<ConfirmDelete>(_onConfirmDelete);
    on<RestoreMedia>(_onRestoreMedia);
  }

  // Future<void> _onLoadMedia(LoadMedia event, Emitter<GalleryState> emit) async {
  //   final media = await repository.fetchMedia(onProgress: (double progress) {  });
  //   emit(state.copyWith(mediaList: media));
  // }
  Future<void> _onLoadMedia(LoadMedia event, Emitter<GalleryState> emit) async {
    emit(state.copyWith(isLoading: true, loadingProgress: 0.0));

    try {
      final media = await repository.fetchMedia(
        onProgress: (double progress) {
          emit(state.copyWith(loadingProgress: progress));
        },
      );

      emit(
        state.copyWith(
          mediaList: media,
          isLoading: false,
          loadingProgress: 1.0,
        ),
      );

      if (repository.hasMoreMedia) {
        add(LoadMoreMedia());
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onLoadMoreMedia(
    LoadMoreMedia event,
    Emitter<GalleryState> emit,
  ) async {
    if (state.isLoadingMore || !repository.hasMoreMedia) return;

    emit(state.copyWith(isLoadingMore: true, loadingMoreProgress: 0.0));

    try {
      final moreMedia = await repository.fetchMoreMedia(
        onProgress: (double progress) {
          emit(state.copyWith(loadingMoreProgress: progress));
        },
      );

      if (moreMedia.isNotEmpty) {
        emit(
          state.copyWith(
            mediaList: [...state.mediaList, ...moreMedia],
            isLoadingMore: false,
            loadingMoreProgress: 1.0,
          ),
        );

        // Continue loading if there's still more media
        if (repository.hasMoreMedia) {
          // Add a small delay to prevent overwhelming the system
          await Future.delayed(const Duration(milliseconds: 500));
          add(LoadMoreMedia());
        }
      } else {
        emit(state.copyWith(isLoadingMore: false, loadingMoreProgress: 1.0));
      }
    } catch (e) {
      emit(state.copyWith(isLoadingMore: false, error: e.toString()));
    }
  }

  void _onSwipeLeft(SwipeLeft event, Emitter<GalleryState> emit) {
    emit(
      state.copyWith(
        toDelete: [...state.toDelete, event.media],
        history: [...state.history, event.media],
        // Keep mediaList unchanged - UI will handle filtering
      ),
    );
  }

  void _onSwipeRight(SwipeRight event, Emitter<GalleryState> emit) {
    emit(
      state.copyWith(
        kept: [...state.kept, event.media],
        history: [...state.history, event.media],
        // Keep mediaList unchanged - UI will handle filtering
      ),
    );
  }

  void _onUndoSwipe(UndoSwipe event, Emitter<GalleryState> emit) {
    if (state.history.isEmpty) return;

    final last = state.history.last;
    final updatedHistory = [...state.history]..removeLast();

    emit(
      state.copyWith(
        toDelete: [...state.toDelete]..remove(last),
        kept: [...state.kept]..remove(last),
        history: updatedHistory,
      ),
    );
  }

  Future<void> _onConfirmDelete(
    ConfirmDelete event,
    Emitter<GalleryState> emit,
  ) async {
    await repository.deleteMedia(state.toDelete);

    // After confirming delete, update the mediaList to reflect actual remaining items
    final remainingMedia = state.mediaList
        .where((media) => !state.toDelete.contains(media))
        .toList();

    emit(
      state.copyWith(
        mediaList: remainingMedia,
        toDelete: [],
        history: [], // Clear history after confirm
      ),
    );
  }

  void _onRestoreMedia(RestoreMedia event, Emitter<GalleryState> emit) {
    emit(
      state.copyWith(
        toDelete: [...state.toDelete]..remove(event.media),
        // Add back to mediaList if it was removed
        mediaList: state.mediaList.contains(event.media)
            ? state.mediaList
            : [event.media, ...state.mediaList],
      ),
    );
  }
}

// class GalleryBloc extends Bloc<GalleryEvent, GalleryState> {
//   final MediaRepository repository;
//
//   GalleryBloc(this.repository) : super( GalleryState.initial()) {
//     on<LoadMedia>(_onLoadMedia);
//     on<SwipeLeft>(_onSwipeLeft);
//     on<SwipeRight>(_onSwipeRight);
//     on<UndoSwipe>(_onUndoSwipe);
//     on<ConfirmDelete>(_onConfirmDelete);
//     on<RestoreMedia>(_onRestoreMedia);
//     on<AddToDeleteList>(_onAddToDeleteList);
//     on<RemoveFromDeleteList>(_onRemoveFromDeleteList);
//     on<LoadImageFile>(_onLoadImageFile);
//     on<LoadVideoFile>(_onLoadVideoFile);
//   }
//
//   Future<void> _onLoadMedia(LoadMedia event, Emitter<GalleryState> emit) async {
//     emit(state.copyWith(status: GalleryStatus.loading));
//     try {
//       final media = await repository.fetchMedia();
//       emit(state.copyWith(
//         status: GalleryStatus.success,
//         mediaList: media,
//       ));
//     } catch (e) {
//       emit(state.copyWith(
//         status: GalleryStatus.error,
//         errorMessage: e.toString(),
//       ));
//     }
//   }
//
//   void _onSwipeLeft(SwipeLeft event, Emitter<GalleryState> emit) {
//     final updatedSwipedIds = Set<String>.from(state.swipedIds)..add(event.media.id);
//     final updatedToDelete = Set<String>.from(state.toDeleteIds)..add(event.media.id);
//     final updatedHistory = [...state.history, event.media];
//
//     emit(state.copyWith(
//       swipedIds: updatedSwipedIds,
//       toDeleteIds: updatedToDelete,
//       history: updatedHistory,
//     ));
//   }
//
//   void _onSwipeRight(SwipeRight event, Emitter<GalleryState> emit) {
//     final updatedSwipedIds = Set<String>.from(state.swipedIds)..add(event.media.id);
//     final updatedKept = Set<String>.from(state.keptIds)..add(event.media.id);
//     final updatedHistory = [...state.history, event.media];
//
//     emit(state.copyWith(
//       swipedIds: updatedSwipedIds,
//       keptIds: updatedKept,
//       history: updatedHistory,
//     ));
//   }
//
//   void _onUndoSwipe(UndoSwipe event, Emitter<GalleryState> emit) {
//     if (state.history.isEmpty) return;
//
//     final last = state.history.last;
//     final updatedHistory = [...state.history]..removeLast();
//     final updatedSwipedIds = Set<String>.from(state.swipedIds)..remove(last.id);
//     final updatedToDelete = Set<String>.from(state.toDeleteIds)..remove(last.id);
//     final updatedKept = Set<String>.from(state.keptIds)..remove(last.id);
//
//     emit(state.copyWith(
//       swipedIds: updatedSwipedIds,
//       toDeleteIds: updatedToDelete,
//       keptIds: updatedKept,
//       history: updatedHistory,
//     ));
//   }
//
//   void _onAddToDeleteList(AddToDeleteList event, Emitter<GalleryState> emit) {
//     final updatedToDelete = Set<String>.from(state.toDeleteIds)..add(event.mediaId);
//     emit(state.copyWith(toDeleteIds: updatedToDelete));
//   }
//
//   void _onRemoveFromDeleteList(RemoveFromDeleteList event, Emitter<GalleryState> emit) {
//     final updatedToDelete = Set<String>.from(state.toDeleteIds)..remove(event.mediaId);
//     emit(state.copyWith(toDeleteIds: updatedToDelete));
//   }
//
//   Future<void> _onConfirmDelete(ConfirmDelete event, Emitter<GalleryState> emit) async {
//     emit(state.copyWith(status: GalleryStatus.deleting));
//     try {
//       final mediaToDelete = state.mediaList
//           .where((media) => state.toDeleteIds.contains(media.id))
//           .toList();
//
//       await repository.deleteMedia(mediaToDelete);
//
//       final remainingMedia = state.mediaList
//           .where((media) => !state.toDeleteIds.contains(media.id))
//           .toList();
//
//       emit(state.copyWith(
//         status: GalleryStatus.success,
//         mediaList: remainingMedia,
//         toDeleteIds: <String>{},
//         history: [],
//       ));
//     } catch (e) {
//       emit(state.copyWith(
//         status: GalleryStatus.error,
//         errorMessage: 'Failed to delete media: $e',
//       ));
//     }
//   }
//
//   void _onRestoreMedia(RestoreMedia event, Emitter<GalleryState> emit) {
//     final updatedToDelete = Set<String>.from(state.toDeleteIds)..remove(event.media.id);
//     emit(state.copyWith(toDeleteIds: updatedToDelete));
//   }
//
//   Future<void> _onLoadImageFile(LoadImageFile event, Emitter<GalleryState> emit) async {
//     emit(state.copyWith(imageViewerStatus: ImageViewerStatus.loading));
//     try {
//       final exists = await repository.checkFileExists(event.imagePath);
//       if (exists) {
//         emit(state.copyWith(
//           imageViewerStatus: ImageViewerStatus.success,
//           currentImagePath: event.imagePath,
//         ));
//       } else {
//         emit(state.copyWith(
//           imageViewerStatus: ImageViewerStatus.error,
//           imageErrorMessage: 'Image file not found: ${event.imagePath}',
//         ));
//       }
//     } catch (e) {
//       emit(state.copyWith(
//         imageViewerStatus: ImageViewerStatus.error,
//         imageErrorMessage: 'Failed to load image: $e',
//       ));
//     }
//   }
//
//   Future<void> _onLoadVideoFile(LoadVideoFile event, Emitter<GalleryState> emit) async {
//     emit(state.copyWith(videoPlayerStatus: VideoPlayerStatus.loading));
//     try {
//       final exists = await repository.checkFileExists(event.videoPath);
//       if (exists) {
//         emit(state.copyWith(
//           videoPlayerStatus: VideoPlayerStatus.success,
//           currentVideoPath: event.videoPath,
//         ));
//       } else {
//         emit(state.copyWith(
//           videoPlayerStatus: VideoPlayerStatus.error,
//           videoErrorMessage: 'Video file not found: ${event.videoPath}',
//         ));
//       }
//     } catch (e) {
//       emit(state.copyWith(
//         videoPlayerStatus: VideoPlayerStatus.error,
//         videoErrorMessage: 'Failed to load video: $e',
//       ));
//     }
//   }
//
//   // Computed properties for UI
//   List<MediaAsset> get availableMedia => state.mediaList
//       .where((media) => !state.swipedIds.contains(media.id))
//       .toList();
//
//   List<MediaAsset> get mediaToDelete => state.mediaList
//       .where((media) => state.toDeleteIds.contains(media.id))
//       .toList();
//
//   List<MediaAsset> get keptMedia => state.mediaList
//       .where((media) => state.keptIds.contains(media.id))
//       .toList();
// }
