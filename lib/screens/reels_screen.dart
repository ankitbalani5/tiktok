import 'package:flutter/material.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../models/reel_model.dart';
import '../services/reel_service.dart';
import '../widgets/reel_item.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {

  final pageController = PreloadPageController();

  List<ReelModel> reels = [];

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WakelockPlus.enable();
    });
    loadReels();
  }

  Future<void> loadReels() async {

    reels = await ReelService().getReels();

    setState(() {});
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if (reels.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.white,),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,

      body: PreloadPageView.builder(
        controller: pageController,

        preloadPagesCount: 4,

        scrollDirection: Axis.vertical,

        itemCount: reels.length,

        onPageChanged: (index) {

          setState(() {
            currentIndex = index;
          });
        },

        itemBuilder: (context, index) {

          return ReelItem(
            reel: reels[index],
            isPlaying: currentIndex == index,
          );
        },
      ),
    );
  }
}