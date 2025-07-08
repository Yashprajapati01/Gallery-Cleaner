import 'dart:io';

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
  final Set<String> _deletedIds = <String>{};
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    controller = AppinioSwiperController();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    );
    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.linear),
    );
    _backgroundController.repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    _backgroundController.dispose();
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

          SafeArea(
            maintainBottomViewPadding: false,
            child: BlocConsumer<GalleryBloc, GalleryState>(
              listener: (context, state) {
                if (state.history.isEmpty) {
                  _swipedIds.clear();
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
                        // Minimalist header with improved typography
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Gallery Cleaner',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // if (state.mediaList.isNotEmpty)
                              //   Text(
                              //     'Swipe to organize your media',
                              //     style: TextStyle(
                              //       fontSize: 16,
                              //       color: Colors.white.withOpacity(0.7),
                              //     ),
                              //   ),
                              // const SizedBox(height: 12),
                              if (state.mediaList.isNotEmpty)
                                Text(
                                  '${availableMedia.length} of ${state.mediaList.length} remaining',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withOpacity(0.6),
                                  ),
                                ),
                              // Add loading indicator here
                              if (state.isLoadingMore) ...[
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                      'Loading more photos...',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                        //   child: Column(
                        //     crossAxisAlignment: CrossAxisAlignment.center,
                        //     children: [
                        //       Text(
                        //         'Gallery Cleaner',
                        //         style: TextStyle(
                        //           fontSize: 28,
                        //           fontWeight: FontWeight.w700,
                        //           color: Colors.white,
                        //           letterSpacing: -0.5,
                        //         ),
                        //       ),
                        //       const SizedBox(height: 8),
                        //       if (state.mediaList.isNotEmpty)
                        //         Text(
                        //           'Swipe to organize your media',
                        //           style: TextStyle(
                        //             fontSize: 16,
                        //             color: Colors.white.withOpacity(0.7),
                        //           ),
                        //         ),
                        //       const SizedBox(height: 12),
                        //       if (state.mediaList.isNotEmpty)
                        //         Text(
                        //           '${availableMedia.length} of ${state.mediaList.length} remaining',
                        //           style: TextStyle(
                        //             fontSize: 14,
                        //             fontWeight: FontWeight.w500,
                        //             color: Colors.white.withOpacity(0.6),
                        //           ),
                        //         ),
                        //     ],
                        //   ),
                        // ),

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
                                _deletedIds.remove(lastSwipedAsset.id);
                              });
                              context.read<GalleryBloc>().add(UndoSwipe());
                            }
                          },
                        ),
                      ],
                    ),

                    // Delete button with badge - top right
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        child: Column(
                          children: [
                            // if (state.isLoadingMore)
                            //   Container(
                            //     margin: const EdgeInsets.only(right: 12),
                            //     padding: const EdgeInsets.all(8),
                            //     decoration: BoxDecoration(
                            //       color: Colors.black.withOpacity(0.7),
                            //       borderRadius: BorderRadius.circular(20),
                            //       border: Border.all(
                            //         color: Colors.white.withOpacity(0.2),
                            //         width: 1,
                            //       ),
                            //     ),
                            //     child: Row(
                            //       mainAxisSize: MainAxisSize.min,
                            //       children: [
                            //         SizedBox(
                            //           width: 16,
                            //           height: 16,
                            //           child: CircularProgressIndicator(
                            //             value: state.loadingMoreProgress,
                            //             strokeWidth: 2,
                            //             color: const Color(0xFF64FFDA),
                            //           ),
                            //         ),
                            //         const SizedBox(width: 8),
                            //         Text(
                            //           'Loading...',
                            //           style: TextStyle(
                            //             color: Colors.white.withOpacity(0.8),
                            //             fontSize: 12,
                            //             fontWeight: FontWeight.w500,
                            //           ),
                            //         ),
                            //       ],
                            //     ),
                            //   ),
                            _DeleteButton(
                              deleteCount: _deletedIds.length,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/delete-list',
                                ).then((result) {
                                  if (result == true) {
                                    setState(() {
                                      _deletedIds.clear();
                                    });
                                  }
                                });
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
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
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
                    Icons.check_circle_rounded,
                    size: 48,
                    color: const Color(0xFF64FFDA),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'All Done!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'You\'ve sorted through all your media',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                if (state.isLoadingMore) ...[
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: LinearProgressIndicator(
                      value: state.loadingMoreProgress,
                      minHeight: 6,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      color: const Color(0xFF64FFDA),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading more media in background...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (state.mediaList.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Total processed: ${state.mediaList.length} items',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedCardStack(List<MediaAsset> availableMedia) {
    const double cardTopMargin = 40.0; // Distance from top
    const double cardBottomMargin = 80.0; // Distance from bottom (controls)
    const double cardHorizontalMargin = 20.0; // Side padding
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: cardHorizontalMargin),
      child: Stack(
        children: [
          // Background cards with enhanced stacking effect
          for (int i = 2; i >= 0; i--)
            if (i < availableMedia.length)
              Positioned.fill(
                child: Container(
                  margin: EdgeInsets.only(
                    top: cardTopMargin + (i * 20.0),
                    bottom: cardBottomMargin - (i * 15.0),
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
            margin: const EdgeInsets.only(
              top: cardTopMargin,
              bottom: cardBottomMargin,
            ),
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
                    context.read<GalleryBloc>().add(SwipeRight(asset));
                  } else {
                    _addToDeleteList(asset);
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
  @override
  Widget build(BuildContext context) {
    // Calculate border radius based on card type
    final borderRadius = widget.isBackground ? 20.0 : 24.0;

    return GestureDetector(
      onTap: () async {
        if (!widget.isBackground) {
          final path = widget.asset.path;
          final file = File(path);
          if (!await file.exists()) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("File not found: $path")));
            return;
          }

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
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: widget.isBackground
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 40,
                    spreadRadius: 0,
                    offset: const Offset(0, 20),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              children: [
                // Main image container
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(borderRadius),
                      color: const Color(0xFF2A2A2A),
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

                // Video overlay for main card only
                if (!widget.isBackground && widget.asset.isVideo)
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'VIDEO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DeleteButton extends StatefulWidget {
  final int deleteCount;
  final VoidCallback onTap;

  const _DeleteButton({required this.deleteCount, required this.onTap});

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

  String _getDisplayCount() {
    if (widget.deleteCount > 999) {
      return '999+';
    } else if (widget.deleteCount > 99) {
      return '99+';
    } else {
      return '${widget.deleteCount}';
    }
  }

  double _getBadgeSize() {
    if (widget.deleteCount > 99) {
      return 28.0; // Larger badge for 99+ and 999+
    } else if (widget.deleteCount > 9) {
      return 24.0; // Medium badge for 10-99
    } else {
      return 22.0; // Small badge for 1-9
    }
  }

  double _getFontSize() {
    if (widget.deleteCount > 99) {
      return 9.0; // Smaller font for 99+ and 999+
    } else if (widget.deleteCount > 9) {
      return 10.0; // Medium font for 10-99
    } else {
      return 11.0; // Normal font for 1-9
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.deleteCount > 0 ? _pulseAnimation.value : 1.0,
            child: SizedBox(
              width: 64,
              height: 64,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Main delete button
                  Positioned(
                    left: 6,
                    top: 6,
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            spreadRadius: 0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.white.withOpacity(0.9),
                        size: 22,
                      ),
                    ),
                  ),

                  // Count badge
                  if (widget.deleteCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: _getBadgeSize(),
                        height: _getBadgeSize(),
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
                            _getDisplayCount(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: _getFontSize(),
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
      margin: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Delete Button (X)
          _CircularButton(
            onTap: hasRemainingItems ? () => controller.swipeLeft() : null,
            icon: Icons.close_rounded,
            backgroundColor: Colors.white,
            iconColor: Colors.black,
            isEnabled: hasRemainingItems,
            size: 64,
          ),

          // Undo Button (smaller, in between)
          _CircularButton(
            onTap: onUndo,
            icon: Icons.undo_rounded,
            backgroundColor: Colors.white.withOpacity(0.15),
            iconColor: Colors.white,
            isEnabled: true,
            size: 48,
            borderColor: Colors.white.withOpacity(0.2),
          ),

          // Keep Button (Heart)
          _CircularButton(
            onTap: hasRemainingItems ? () => controller.swipeRight() : null,
            icon: Icons.favorite_rounded,
            backgroundColor: const Color(0xFFFF3B5C),
            iconColor: Colors.white,
            isEnabled: hasRemainingItems,
            size: 64,
          ),
        ],
      ),
    );
  }
}

class _CircularButton extends StatefulWidget {
  final VoidCallback? onTap;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final bool isEnabled;
  final double size;
  final Color? borderColor;

  const _CircularButton({
    required this.onTap,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.isEnabled,
    required this.size,
    this.borderColor,
  });

  @override
  State<_CircularButton> createState() => _CircularButtonState();
}

class _CircularButtonState extends State<_CircularButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _pressAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _pressAnimation = Tween<double>(
      begin: 1.0,
      end: 0.85,
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
      onTapDown: widget.isEnabled ? (_) => _pressController.forward() : null,
      onTapUp: widget.isEnabled ? (_) => _pressController.reverse() : null,
      onTapCancel: widget.isEnabled ? () => _pressController.reverse() : null,
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
                    ? widget.backgroundColor
                    : widget.backgroundColor.withOpacity(0.3),
                border: widget.borderColor != null
                    ? Border.all(
                        color: widget.isEnabled
                            ? widget.borderColor!
                            : widget.borderColor!.withOpacity(0.3),
                        width: 1.5,
                      )
                    : null,
                boxShadow: widget.isEnabled
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          spreadRadius: 0,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                widget.icon,
                color: widget.isEnabled
                    ? widget.iconColor
                    : widget.iconColor.withOpacity(0.3),
                size: widget.size * 0.45,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EnhancedButton extends StatefulWidget {
  final VoidCallback? onTap;
  final IconData icon;
  final String label;
  final Color color;
  final bool isEnabled;
  final double size;

  const _EnhancedButton({
    required this.onTap,
    required this.icon,
    required this.label,
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
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
        ),
        const SizedBox(height: 8),
        Text(
          widget.label,
          style: TextStyle(
            color: widget.isEnabled
                ? widget.color
                : Colors.white.withOpacity(0.3),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
