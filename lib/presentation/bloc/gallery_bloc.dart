import 'package:bloc/bloc.dart';

import '../../domain/models/media_assets.dart';
import '../../domain/repository/media_repository.dart';

part 'gallery_event.dart';
part 'gallery_state.dart';

class GalleryBloc extends Bloc<GalleryEvent, GalleryState> {
  final MediaRepository repository;

  GalleryBloc(this.repository) : super(GalleryState.initial()) {
    on<LoadMedia>(_onLoadMedia);
    on<SwipeLeft>(_onSwipeLeft);
    on<SwipeRight>(_onSwipeRight);
    on<UndoSwipe>(_onUndoSwipe);
    on<ConfirmDelete>(_onConfirmDelete);
    on<RestoreMedia>(_onRestoreMedia);
  }

  Future<void> _onLoadMedia(LoadMedia event, Emitter<GalleryState> emit) async {
    final media = await repository.fetchMedia();
    emit(state.copyWith(mediaList: media));
  }

  void _onSwipeLeft(SwipeLeft event, Emitter<GalleryState> emit) {
    emit(state.copyWith(
      toDelete: [...state.toDelete, event.media],
      history: [...state.history, event.media],
      // Keep mediaList unchanged - UI will handle filtering
    ));
  }

  void _onSwipeRight(SwipeRight event, Emitter<GalleryState> emit) {
    emit(state.copyWith(
      kept: [...state.kept, event.media],
      history: [...state.history, event.media],
      // Keep mediaList unchanged - UI will handle filtering
    ));
  }

  void _onUndoSwipe(UndoSwipe event, Emitter<GalleryState> emit) {
    if (state.history.isEmpty) return;

    final last = state.history.last;
    final updatedHistory = [...state.history]..removeLast();

    emit(state.copyWith(
      toDelete: [...state.toDelete]..remove(last),
      kept: [...state.kept]..remove(last),
      history: updatedHistory,
    ));
  }

  Future<void> _onConfirmDelete(ConfirmDelete event, Emitter<GalleryState> emit) async {
    await repository.deleteMedia(state.toDelete);

    // After confirming delete, update the mediaList to reflect actual remaining items
    final remainingMedia = state.mediaList
        .where((media) => !state.toDelete.contains(media))
        .toList();

    emit(state.copyWith(
      mediaList: remainingMedia,
      toDelete: [],
      history: [], // Clear history after confirm
    ));
  }

  void _onRestoreMedia(RestoreMedia event, Emitter<GalleryState> emit) {
    emit(state.copyWith(
      toDelete: [...state.toDelete]..remove(event.media),
      // Add back to mediaList if it was removed
      mediaList: state.mediaList.contains(event.media)
          ? state.mediaList
          : [event.media, ...state.mediaList],
    ));
  }
}