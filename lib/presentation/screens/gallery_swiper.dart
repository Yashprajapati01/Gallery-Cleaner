import 'dart:ui';

import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/models/media_assets.dart';
import '../bloc/gallery_bloc.dart';

class GallerySwiperScreen extends StatefulWidget {
  const GallerySwiperScreen({super.key});

  @override
  State<GallerySwiperScreen> createState() => _GallerySwiperScreenState();
}

class _GallerySwiperScreenState extends State<GallerySwiperScreen>
    with TickerProviderStateMixin {
  late AppinioSwiperController controller;
  final Set<String> _swipedIds = <String>{};
  late AnimationController _backgroundController;
  late AnimationController _particleController;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    controller = AppinioSwiperController();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _particleController = AnimationController(
      duration: const Duration(seconds: 15),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Stack(
        children: [
          // Animated background
          AnimatedBuilder(
            animation: _backgroundAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(const Color(0xFF0D0D0D), const Color(0xFF1A1A2E),
                          _backgroundAnimation.value)!,
                      Color.lerp(const Color(0xFF16213E), const Color(0xFF0F3460),
                          _backgroundAnimation.value)!,
                      const Color(0xFF0D0D0D),
                    ],
                  ),
                ),
              );
            },
          ),

          // Floating particles
          ...List.generate(12, (index) => _FloatingParticle(
            controller: _particleController,
            delay: index * 0.8,
            size: 2.0 + (index % 3),
          )),

          SafeArea(
            child: BlocConsumer<GalleryBloc, GalleryState>(
              listener: (context, state) {
                if (state.history.isEmpty) {
                  _swipedIds.clear();
                }
              },
              builder: (context, state) {
                final availableMedia = state.mediaList
                    .where((media) => !_swipedIds.contains(media.id))
                    .toList();

                return Column(
                  children: [
                    // Minimal sophisticated header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 24,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF64FFDA), Color(0xFF1DE9B6)],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'Gallery',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${availableMedia.length}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: availableMedia.isEmpty
                          ? _buildEmptyState()
                          : _buildCardStack(availableMedia),
                    ),

                    _SophisticatedControls(
                      controller: controller,
                      remainingCount: availableMedia.length,
                      onUndo: () {
                        final lastSwipedAsset = state.history.lastOrNull;
                        if (lastSwipedAsset != null) {
                          setState(() {
                            _swipedIds.remove(lastSwipedAsset.id);
                          });
                          context.read<GalleryBloc>().add(UndoSwipe());
                        }
                      },
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF64FFDA).withOpacity(0.1),
              border: Border.all(
                color: const Color(0xFF64FFDA).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.done_all_rounded,
              size: 32,
              color: const Color(0xFF64FFDA).withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'All sorted',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w300,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your gallery is organized',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardStack(List<MediaAsset> availableMedia) {
    return Stack(
      children: [
        // Background cards with sophisticated layering
        for (int i = 2; i >= 0; i--)
          if (i < availableMedia.length)
            Positioned.fill(
              child: Transform.translate(
                offset: Offset(i * 2.0, i * 2.0),
                child: Transform.scale(
                  scale: 1.0 - (i * 0.015),
                  child: _SophisticatedCard(
                    key: ValueKey('bg_${availableMedia[i].id}_$i'),
                    asset: availableMedia[i],
                    isBackground: true,
                    backgroundIndex: i,
                  ),
                ),
              ),
            ),
        // Main swiper
        AppinioSwiper(
          key: ValueKey(_swipedIds.length),
          controller: controller,
          cardBuilder: (BuildContext context, int index) {
            if (index >= availableMedia.length) {
              return const SizedBox();
            }

            final asset = availableMedia[index];
            return _SophisticatedCard(
              key: ValueKey(asset.id),
              asset: asset,
              isBackground: false,
            );
          },
          cardCount: availableMedia.length,
          backgroundCardCount: 0,
          swipeOptions: const SwipeOptions.symmetric(
            horizontal: true,
            vertical: false,
          ),
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
                context.read<GalleryBloc>().add(SwipeLeft(asset));
              }
            }
          },
        ),
      ],
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

        return Positioned(
          left: (screenWidth * 0.1) + (progress * screenWidth * 0.8),
          top: screenHeight * 0.1 + (progress * screenHeight * 0.8),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1 - (progress * 0.1)),
            ),
          ),
        );
      },
    );
  }
}

class _SophisticatedCard extends StatefulWidget {
  final MediaAsset asset;
  final bool isBackground;
  final int backgroundIndex;

  const _SophisticatedCard({
    super.key,
    required this.asset,
    this.isBackground = false,
    this.backgroundIndex = 0,
  });

  @override
  State<_SophisticatedCard> createState() => _SophisticatedCardState();
}

class _SophisticatedCardState extends State<_SophisticatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;

  @override
  void initState() {
    super.initState();
    if (!widget.isBackground) {
      _hoverController = AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      );
      _hoverAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
      );
    }
  }

  @override
  void dispose() {
    if (!widget.isBackground) {
      _hoverController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final opacity = widget.isBackground ? 0.4 - (widget.backgroundIndex * 0.15) : 1.0;
    final blur = widget.isBackground ? widget.backgroundIndex * 0.5 : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(widget.isBackground ? 0.05 : 0.1),
                  Colors.white.withOpacity(widget.isBackground ? 0.02 : 0.05),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(widget.isBackground ? 0.1 : 0.2),
                width: 1,
              ),
              boxShadow: widget.isBackground ? null : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 0,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Main image
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(23),
                    child: widget.asset.thumbnail != null
                        ? Image.memory(
                      widget.asset.thumbnail!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    )
                        : Container(
                      color: const Color(0xFF1A1A1A),
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 48,
                          color: Color(0xFF404040),
                        ),
                      ),
                    ),
                  ),
                ),

                // Sophisticated overlay
                if (!widget.isBackground) ...[
                  // Gradient overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(23),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withOpacity(0.8),
                          ],
                          stops: const [0.0, 0.4, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Minimal date indicator
                  Positioned(
                    top: 24,
                    left: 24,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        _formatDate(DateTime.now()),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  // Swipe indicators
                  Positioned(
                    bottom: 32,
                    left: 24,
                    right: 24,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _SwipeIndicator(
                          icon: Icons.close_rounded,
                          color: const Color(0xFFFF6B6B),
                          opacity: opacity,
                        ),
                        _SwipeIndicator(
                          icon: Icons.favorite_rounded,
                          color: const Color(0xFF64FFDA),
                          opacity: opacity,
                        ),
                      ],
                    ),
                  ),
                ],

                // Subtle edge highlight
                if (!widget.isBackground)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.transparent,
                            Colors.transparent,
                            Colors.white.withOpacity(0.05),
                          ],
                        ),
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

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final cardDate = DateTime(date.year, date.month, date.day);

    if (cardDate == today) {
      return 'Today';
    } else if (cardDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      return DateFormat('EEE').format(date);
    } else if (date.year == now.year) {
      return DateFormat('MMM d').format(date);
    } else {
      return DateFormat('MMM d, y').format(date);
    }
  }
}

class _SwipeIndicator extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double opacity;

  const _SwipeIndicator({
    required this.icon,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.15),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Icon(
        icon,
        color: color.withOpacity(0.8),
        size: 20,
      ),
    );
  }
}

class _SophisticatedControls extends StatelessWidget {
  final AppinioSwiperController controller;
  final int remainingCount;
  final VoidCallback onUndo;

  const _SophisticatedControls({
    required this.controller,
    required this.remainingCount,
    required this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    final hasRemainingItems = remainingCount > 0;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.04),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Progress indicator
          if (hasRemainingItems) ...[
            Row(
              children: [
                Text(
                  'Remaining',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.6),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(),
                Text(
                  '$remainingCount',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _SophisticatedButton(
                onTap: hasRemainingItems ? () => controller.swipeLeft() : null,
                onLongPress: () => Navigator.pushNamed(context, '/delete-list'),
                icon: Icons.close_rounded,
                color: const Color(0xFFFF6B6B),
                isEnabled: hasRemainingItems,
              ),
              _SophisticatedButton(
                onTap: onUndo,
                icon: Icons.undo_rounded,
                color: Colors.white.withOpacity(0.8),
                isEnabled: true,
              ),
              _SophisticatedButton(
                onTap: hasRemainingItems ? () => controller.swipeRight() : null,
                icon: Icons.favorite_rounded,
                color: const Color(0xFF64FFDA),
                isEnabled: hasRemainingItems,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SophisticatedButton extends StatefulWidget {
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final IconData icon;
  final Color color;
  final bool isEnabled;

  const _SophisticatedButton({
    required this.onTap,
    this.onLongPress,
    required this.icon,
    required this.color,
    required this.isEnabled,
  });

  @override
  State<_SophisticatedButton> createState() => _SophisticatedButtonState();
}

class _SophisticatedButtonState extends State<_SophisticatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) => _scaleController.reverse(),
      onTapCancel: () => _scaleController.reverse(),
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isEnabled
                    ? widget.color.withOpacity(0.15)
                    : Colors.white.withOpacity(0.05),
                border: Border.all(
                  color: widget.isEnabled
                      ? widget.color.withOpacity(0.3)
                      : Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Icon(
                widget.icon,
                color: widget.isEnabled
                    ? widget.color
                    : Colors.white.withOpacity(0.3),
                size: 24,
              ),
            ),
          );
        },
      ),
    );
  }
}