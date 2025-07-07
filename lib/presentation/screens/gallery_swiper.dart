import 'dart:io';
import 'dart:math';

import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gallerycleaner/presentation/screens/video_viewer.dart';

import '../../domain/models/media_assets.dart';
import '../bloc/gallery_bloc.dart';
import 'full_image_viewer.dart';

class GallerySwiperScreen extends StatefulWidget {
  const GallerySwiperScreen({super.key});

  @override
  State<GallerySwiperScreen> createState() => _GallerySwiperScreenState();
}

class _GallerySwiperScreenState extends State<GallerySwiperScreen>
    with TickerProviderStateMixin {
  late AppinioSwiperController controller;
  final Set<String> _swipedIds = <String>{};
  final Set<String> _deletedIds = <String>{}; // Track deleted items
  late AnimationController _backgroundController;
  late AnimationController _particleController;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    controller = AppinioSwiperController();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    );
    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.linear),
    );
    _backgroundController.repeat();
    _particleController.repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    _backgroundController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _addToDeleteList(MediaAsset asset) {
    setState(() {
      _deletedIds.add(asset.id);
    });
  }

  void _removeFromDeleteList(String assetId) {
    setState(() {
      _deletedIds.remove(assetId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Stack(
        children: [
          // Enhanced animated background
          AnimatedBuilder(
            animation: _backgroundAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 1.5,
                    colors: [
                      Color.lerp(
                        const Color(0xFF1A1A2E),
                        const Color(0xFF16213E),
                        _backgroundAnimation.value,
                      )!,
                      Color.lerp(
                        const Color(0xFF0F3460),
                        const Color(0xFF1A1A2E),
                        _backgroundAnimation.value,
                      )!,
                      const Color(0xFF000000),
                    ],
                  ),
                ),
              );
            },
          ),

          // Floating particles with better distribution
          ...List.generate(
            15,
            (index) => _FloatingParticle(
              controller: _particleController,
              delay: index * 0.6,
              size: 1.5 + (index % 4) * 0.5,
            ),
          ),

          SafeArea(
            maintainBottomViewPadding: false,
            child: BlocConsumer<GalleryBloc, GalleryState>(
              listener: (context, state) {
                if (state.history.isEmpty) {
                  _swipedIds.clear();
                  // Optional: Clear delete list when history is cleared
                  // _deletedIds.clear();
                }
                if (state.error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${state.error}')),
                  );
                }
              },
              builder: (context, state) {
                if (state.isLoading) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          value: state.loadingProgress,
                          strokeWidth: 3,
                          color: const Color(0xFF64FFDA),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading Photos...',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(state.loadingProgress * 100).toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                final availableMedia = state.mediaList
                    .where((media) => !_swipedIds.contains(media.id))
                    .toList();

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Column(
                      children: [
                        // Minimalist header
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Card Swipe',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              if (state.mediaList.isNotEmpty)
                                Text(
                                  '${availableMedia.length} / ${state.mediaList.length}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.6),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Main card stack area
                        Expanded(
                          child: availableMedia.isEmpty
                              ? _buildEmptyState()
                              : _buildEnhancedCardStack(availableMedia),
                        ),

                        // Enhanced bottom controls
                        _EnhancedControls(
                          controller: controller,
                          remainingCount: availableMedia.length,
                          onUndo: () {
                            final lastSwipedAsset = state.history.lastOrNull;
                            if (lastSwipedAsset != null) {
                              setState(() {
                                _swipedIds.remove(lastSwipedAsset.id);
                                // Also remove from delete list if it was there
                                _deletedIds.remove(lastSwipedAsset.id);
                              });
                              context.read<GalleryBloc>().add(UndoSwipe());
                            }
                          },
                        ),
                      ],
                    ),

                    // Delete button with badge - top right (improved positioning)
                    Positioned(
                      top: 16,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        child: Column(
                          children: [
                            if (state.isLoadingMore)
                              Container(
                                margin: const EdgeInsets.only(right: 12),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        value: state.loadingMoreProgress,
                                        strokeWidth: 2,
                                        color: const Color(0xFF64FFDA),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Loading...',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            _DeleteButton(
                              deleteCount: _deletedIds.length,
                              onTap: () {
                                // Navigate to delete list and potentially clear the list
                                Navigator.pushNamed(
                                  context,
                                  '/delete-list',
                                ).then((result) {
                                  // If user confirmed deletion, clear the delete list
                                  if (result == true) {
                                    setState(() {
                                      _deletedIds.clear();
                                    });
                                  }
                                });
                              },
                              onLongPress: () {
                                // Add current top card to delete list
                                if (availableMedia.isNotEmpty) {
                                  _addToDeleteList(availableMedia.first);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return BlocBuilder<GalleryBloc, GalleryState>(
      builder: (context, state) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF64FFDA).withOpacity(0.2),
                      const Color(0xFF64FFDA).withOpacity(0.05),
                    ],
                  ),
                  border: Border.all(
                    color: const Color(0xFF64FFDA).withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.done_all_rounded,
                  size: 40,
                  color: const Color(0xFF64FFDA),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'All Done!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'You\'ve sorted through all your photos',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              if (state.isLoadingMore) ...[
                const SizedBox(height: 24),
                Text(
                  'Loading more photos in background...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (state.mediaList.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Total loaded: ${state.mediaList.length} photos',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildEnhancedCardStack(List<MediaAsset> availableMedia) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        children: [
          // Background cards with enhanced stacking effect
          for (int i = 2; i >= 0; i--)
            if (i < availableMedia.length)
              Positioned.fill(
                child: Container(
                  margin: EdgeInsets.only(
                    top: 40.0 + (i * 20.0),
                    bottom: 120.0 - (i * 15.0),
                  ),
                  child: Transform.translate(
                    offset: Offset(0, i * 8.0),
                    child: Transform.scale(
                      scale: 1.0 - (i * 0.03),
                      child: _EnhancedCard(
                        key: ValueKey('bg_${availableMedia[i].id}_$i'),
                        asset: availableMedia[i],
                        isBackground: true,
                        backgroundIndex: i,
                      ),
                    ),
                  ),
                ),
              ),

          // Main swiper with proper positioning
          Container(
            margin: const EdgeInsets.only(top: 40, bottom: 120),
            child: AppinioSwiper(
              key: ValueKey(_swipedIds.length),
              controller: controller,
              cardBuilder: (BuildContext context, int index) {
                if (index >= availableMedia.length) {
                  return const SizedBox();
                }

                final asset = availableMedia[index];
                return _EnhancedCard(
                  key: ValueKey(asset.id),
                  asset: asset,
                  isBackground: false,
                );
              },
              cardCount: availableMedia.length,
              backgroundCardCount: 0,
              swipeOptions: const SwipeOptions.only(left: true, right: true),
              loop: false,
              onSwipeEnd: (prevIndex, targetIndex, activity) {
                if (activity is Swipe && activity.end != null) {
                  if (prevIndex >= availableMedia.length) return;

                  final asset = availableMedia[prevIndex];
                  final dx = activity.end!.dx;

                  setState(() {
                    _swipedIds.add(asset.id);
                  });

                  if (dx > 0) {
                    // Swiped right (keep/favorite)
                    context.read<GalleryBloc>().add(SwipeRight(asset));
                  } else {
                    // Swiped left (delete)
                    _addToDeleteList(asset); // Add to delete list
                    context.read<GalleryBloc>().add(SwipeLeft(asset));
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingParticle extends StatelessWidget {
  final AnimationController controller;
  final double delay;
  final double size;

  const _FloatingParticle({
    required this.controller,
    required this.delay,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final progress = (controller.value + delay) % 1.0;
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;

        // Create floating motion
        final x = (screenWidth * 0.05) + (progress * screenWidth * 0.9);
        final y =
            screenHeight * 0.1 +
            (sin(progress * 2 * pi) * 50) +
            (progress * screenHeight * 0.8);

        return Positioned(
          left: x,
          top: y,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(0.15 - (progress * 0.1)),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EnhancedCard extends StatefulWidget {
  final MediaAsset asset;
  final bool isBackground;
  final int backgroundIndex;

  const _EnhancedCard({
    super.key,
    required this.asset,
    this.isBackground = false,
    this.backgroundIndex = 0,
  });

  @override
  State<_EnhancedCard> createState() => _EnhancedCardState();
}

class _EnhancedCardState extends State<_EnhancedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    if (!widget.isBackground) {
      _shimmerController = AnimationController(
        duration: const Duration(seconds: 3),
        vsync: this,
      );
      _shimmerController.repeat();
    }
  }

  @override
  void dispose() {
    if (!widget.isBackground) {
      _shimmerController.dispose();
    }
    super.dispose();
  }

  void _debugMediaAsset() {
    print("=== MediaAsset Debug Info ===");
    print("Asset ID: ${widget.asset.id}");
    print("Asset Path: '${widget.asset.path}'");
    print("Path Length: ${widget.asset.path.length}");
    print("Is Video: ${widget.asset.isVideo}");
    print("Has Thumbnail: ${widget.asset.thumbnail != null}");
    print("Thumbnail Size: ${widget.asset.thumbnail?.length ?? 0} bytes");

    if (widget.asset.path.endsWith('/')) {
      print("WARNING: Path appears to be a directory, not a file!");
    }

    File(widget.asset.path).exists().then((exists) {
      print("File exists: $exists");
      if (!exists) {
        final dir = Directory(widget.asset.path);
        dir.exists().then((dirExists) {
          print("Directory exists: $dirExists");
          if (dirExists) {
            dir.list().listen((entity) {
              print("Found in directory: ${entity.path}");
            });
          }
        });
      } else {
        File(widget.asset.path).length().then((length) {
          print("File size: $length bytes");
        });
      }
    });
    print("========================");
  }

  @override
  Widget build(BuildContext context) {
    final opacity = widget.isBackground
        ? 0.7 - (widget.backgroundIndex * 0.2)
        : 1.0;

    return GestureDetector(
      onTap: () async {
        if (!widget.isBackground) {
          _debugMediaAsset();
          print("Card tapped: ${widget.asset.path}");
          final path = widget.asset.path;

          final file = File(path);
          if (!await file.exists()) {
            print("File does not exist: $path");
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("File not found: $path")));
            return;
          }

          print("File exists, opening: $path");
          print("Is video: ${widget.asset.isVideo}");

          if (widget.asset.isVideo) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FullVideoPlayerScreen(videoPath: path),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FullImageViewerScreen(imagePath: path),
              ),
            );
          }
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.isBackground ? 16 : 20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.isBackground ? 16 : 20),
            boxShadow: widget.isBackground
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 25,
                      spreadRadius: 0,
                      offset: const Offset(0, 15),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 50,
                      spreadRadius: 0,
                      offset: const Offset(0, 25),
                    ),
                  ],
          ),
          child: Stack(
            children: [
              // Main image with enhanced styling
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    widget.isBackground ? 16 : 20,
                  ),
                  child: widget.asset.thumbnail != null
                      ? Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: MemoryImage(widget.asset.thumbnail!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF2A2A2A),
                                const Color(0xFF1A1A1A),
                              ],
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              size: 60,
                              color: Color(0xFF555555),
                            ),
                          ),
                        ),
                ),
              ),

              // Enhanced overlay for main card
              if (!widget.isBackground) ...[
                // Bottom gradient overlay
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.8),
                        ],
                        stops: const [0.0, 0.5, 0.8, 1.0],
                      ),
                    ),
                  ),
                ),

                // Shimmer effect
                AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (context, child) {
                    return Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment(
                              -1.0 + (_shimmerController.value * 2.0),
                              -1.0,
                            ),
                            end: Alignment(
                              1.0 + (_shimmerController.value * 2.0),
                              1.0,
                            ),
                            colors: [
                              Colors.transparent,
                              Colors.white.withOpacity(0.1),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Video icon overlay for videos
                if (!widget.isBackground && widget.asset.isVideo)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ),

                // Action indicators at the bottom
                Positioned(
                  bottom: 24,
                  left: 24,
                  right: 24,
                  child: IgnorePointer(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _ActionIndicator(
                          icon: Icons.close_rounded,
                          color: Colors.white,
                          backgroundColor: Colors.black.withOpacity(0.8),
                        ),
                        _ActionIndicator(
                          icon: Icons.favorite_rounded,
                          color: const Color(0xFFFF3B5C),
                          backgroundColor: Colors.black.withOpacity(0.8),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionIndicator extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const _ActionIndicator({
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class _DeleteButton extends StatefulWidget {
  final int deleteCount;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _DeleteButton({
    required this.deleteCount,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<_DeleteButton> createState() => _DeleteButtonState();
}

class _DeleteButtonState extends State<_DeleteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    if (widget.deleteCount > 0) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_DeleteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.deleteCount > 0 && oldWidget.deleteCount == 0) {
      _pulseController.repeat(reverse: true);
    } else if (widget.deleteCount == 0 && oldWidget.deleteCount > 0) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.deleteCount > 0 ? _pulseAnimation.value : 1.0,
            child: SizedBox(
              width: 56,
              height: 56,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 4,
                    top: 4,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.7),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.white.withOpacity(0.9),
                        size: 22,
                      ),
                    ),
                  ),
                  if (widget.deleteCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF3B5C),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            widget.deleteCount > 99
                                ? '99+'
                                : '${widget.deleteCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EnhancedControls extends StatelessWidget {
  final AppinioSwiperController controller;
  final int remainingCount;
  final VoidCallback onUndo;

  const _EnhancedControls({
    required this.controller,
    required this.remainingCount,
    required this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    final hasRemainingItems = remainingCount > 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.black.withOpacity(0.8),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _EnhancedButton(
            onTap: hasRemainingItems ? () => controller.swipeLeft() : null,
            icon: Icons.close_rounded,
            color: Colors.white,
            isEnabled: hasRemainingItems,
            size: 64,
          ),
          _EnhancedButton(
            onTap: onUndo,
            icon: Icons.undo_rounded,
            color: Colors.white.withOpacity(0.7),
            isEnabled: true,
            size: 48,
          ),
          _EnhancedButton(
            onTap: hasRemainingItems ? () => controller.swipeRight() : null,
            icon: Icons.favorite_rounded,
            color: const Color(0xFFFF3B5C),
            isEnabled: hasRemainingItems,
            size: 64,
          ),
        ],
      ),
    );
  }
}

class _EnhancedButton extends StatefulWidget {
  final VoidCallback? onTap;
  final IconData icon;
  final Color color;
  final bool isEnabled;
  final double size;

  const _EnhancedButton({
    required this.onTap,
    required this.icon,
    required this.color,
    required this.isEnabled,
    required this.size,
  });

  @override
  State<_EnhancedButton> createState() => _EnhancedButtonState();
}

class _EnhancedButtonState extends State<_EnhancedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _pressAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _pressAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _pressController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) => _pressController.reverse(),
      onTapCancel: () => _pressController.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pressAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pressAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isEnabled
                    ? widget.color.withOpacity(0.15)
                    : Colors.white.withOpacity(0.05),
                border: Border.all(
                  color: widget.isEnabled
                      ? widget.color.withOpacity(0.3)
                      : Colors.white.withOpacity(0.1),
                  width: 1.5,
                ),
              ),
              child: Icon(
                widget.icon,
                color: widget.isEnabled
                    ? widget.color
                    : Colors.white.withOpacity(0.3),
                size: widget.size * 0.4,
              ),
            ),
          );
        },
      ),
    );
  }
}
