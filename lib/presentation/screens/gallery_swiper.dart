import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/media_assets.dart';
import '../bloc/gallery_bloc.dart';

class GallerySwiperScreen extends StatefulWidget {
  const GallerySwiperScreen({super.key});

  @override
  State<GallerySwiperScreen> createState() => _GallerySwiperScreenState();
}

class _GallerySwiperScreenState extends State<GallerySwiperScreen> {
  late final AppinioSwiperController controller;

  @override
  void initState() {
    super.initState();
    controller = AppinioSwiperController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<GalleryBloc, GalleryState>(
          builder: (context, state) {
            final mediaList = state.mediaList;
            if (mediaList.isEmpty) {
              return const Center(child: Text('No media left to swipe'));
            }

            return Column(
              children: [
                Expanded(
                  child: AppinioSwiper(
                    controller: controller,
                    cardBuilder: (context, index) {
                      final asset = mediaList[index];
                      return _MediaCard(asset: asset);
                    },
                    cardCount: mediaList.length,
                    backgroundCardCount: 3,
                    backgroundCardOffset: const Offset(20, 20),
                    swipeOptions: const SwipeOptions.symmetric(horizontal: true,vertical: false),
                    onSwipeEnd: (prevIndex, targetIndex, activity) {
                      if (activity is Swipe && activity.end != null) {
                        final asset = mediaList[prevIndex];
                        final dx = activity.end!.dx;

                        if (dx > 0) {
                          context.read<GalleryBloc>().add(SwipeRight(asset));
                        } else {
                          context.read<GalleryBloc>().add(SwipeLeft(asset));
                        }
                      }
                    },

                    onEnd: () {
                      // Optional: could show a dialog or snackbar
                      debugPrint("End of card stack");
                    },
                  ),
                ),
                _SwipeControls(controller: controller),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MediaCard extends StatelessWidget {
  final MediaAsset asset;
  const _MediaCard({required this.asset});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: asset.thumbnail != null
            ? Image.memory(asset.thumbnail!, fit: BoxFit.cover)
            : const Center(child: Icon(Icons.broken_image)),
      ),
    );
  }
}

class _SwipeControls extends StatelessWidget {
  final AppinioSwiperController controller;
  const _SwipeControls({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () => controller.swipeLeft(),
            onLongPress: () => Navigator.pushNamed(context, '/delete-list'),
            child: const CircleAvatar(
              backgroundColor: Colors.red,
              radius: 28,
              child: Icon(Icons.delete, color: Colors.white),
            ),
          ),
          GestureDetector(
            onTap: () => context.read<GalleryBloc>().add(UndoSwipe()),
            child: const CircleAvatar(
              backgroundColor: Colors.grey,
              radius: 28,
              child: Icon(Icons.undo, color: Colors.white),
            ),
          ),
          GestureDetector(
            onTap: () => controller.swipeRight(),
            child: const CircleAvatar(
              backgroundColor: Colors.green,
              radius: 28,
              child: Icon(Icons.check, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
