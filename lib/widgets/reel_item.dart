import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../models/reel_model.dart';

class ReelItem extends StatefulWidget {
  final ReelModel reel;
  final bool isPlaying;

  const ReelItem({
    super.key,
    required this.reel,
    required this.isPlaying,
  });

  @override
  State<ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends State<ReelItem> {
  late CachedVideoPlayerPlus player;

  late bool isLiked;
  late int likesCount;
  bool showControls = false;

  @override
  void initState() {
    super.initState();

    isLiked = widget.reel.isLike;
    likesCount = widget.reel.likes;

    player = CachedVideoPlayerPlus.networkUrl(
      Uri.parse(widget.reel.videoUrl),
    );

    initializeVideo();
    WakelockPlus.enable();
  }

  void togglePlayPause() {
    setState(() {
      if (player.controller.value.isPlaying) {
        player.controller.pause();
      } else {
        player.controller.play();
      }

      showControls = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          showControls = false;
        });
      }
    });
  }

  Future<void> initializeVideo() async {
    await player.initialize();

    await player.controller.setLooping(true);

    if (widget.isPlaying) {
      player.controller.play();
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> toggleLike() async {
    setState(() {
      if (isLiked) {
        isLiked = false;
        likesCount--;
      } else {
        isLiked = true;
        likesCount++;
      }
    });

    try {
      await FirebaseFirestore.instance
          .collection('reels')
          .doc(widget.reel.id)
          .update({
        'isLike': isLiked,
        'likes': likesCount,
      });
    } catch (e) {
      debugPrint('Like update error: $e');
    }
  }

  @override
  void didUpdateWidget(covariant ReelItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!player.isInitialized) return;

    if (widget.isPlaying) {
      player.controller.play();
    } else {
      player.controller.pause();
    }
  }

  @override
  void dispose() {
    player.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!player.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white,),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [

        FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: player.controller.value.size.width,
            height: player.controller.value.size.height,
            child: GestureDetector(
              onTap: togglePlayPause,
              onDoubleTap: toggleLike,
              child: VideoPlayer(
                player.controller,
              ),
            ),
          ),
        ),

        Positioned(
          left: 16,
          right: 16,
          bottom: 40,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.asset(
                      'assets/profile.png',
                      height: 35,
                      width: 35,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Text(
                    widget.reel.username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                widget.reel.caption,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),

        Positioned(
          right: 16,
          bottom: 50,
          child: Column(
            children: [
              GestureDetector(
                onTap: toggleLike,
                child: AnimatedSwitcher(
                  duration: const Duration(
                    milliseconds: 250,
                  ),
                  child: Icon(
                    isLiked
                        ? Icons.favorite
                        : Icons.favorite_border,
                    key: ValueKey(isLiked),
                    color: isLiked
                        ? Colors.red
                        : Colors.white,
                    size: 35,
                  ),
                ),
              ),

              const SizedBox(height: 5),

              Text(
                likesCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 25),

              // 💬 COMMENT
              GestureDetector(
                onTap: () {
                  // TODO: open comments bottom sheet
                },
                child: const Icon(
                  Icons.mode_comment_outlined,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 5),

              Text(
                '5',
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 25),

              // 📤 SHARE
              GestureDetector(
                onTap: () {
                  // TODO: share reel
                },
                child: const Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 5),

              Text(
                '18',
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 25),

              // 🔖 BOOKMARK
              GestureDetector(
                onTap: () {
                  // TODO: bookmark logic
                },
                child: const Icon(
                  Icons.bookmark_border_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 5),

              Text(
                '10',
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),

        // Slider
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: ValueListenableBuilder(
            valueListenable: player.controller,
            builder: (context, VideoPlayerValue value, child) {

              final duration =
                  value.duration.inMilliseconds;

              final position =
                  value.position.inMilliseconds;

              return SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 1,
                  activeTrackColor: Colors.white,
                  inactiveTrackColor: Colors.white24,
                  thumbColor: Colors.white,
                  thumbShape: RoundSliderThumbShape(
                      enabledThumbRadius: 1, // 👈 almost invisible
                  ),
                  overlayShape: SliderComponentShape.noOverlay,
                  padding: EdgeInsets.zero
                ),
                child: Slider(
                  value: position.toDouble().clamp(
                    0,
                    duration.toDouble(),
                  ),
                  max: duration.toDouble(),
                  onChanged: (newValue) {
                    player.controller.seekTo(
                      Duration(
                        milliseconds: newValue.toInt(),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),

        // Play Pause
        if (showControls)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  player.controller.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
          ),
      ],
    );
  }
}