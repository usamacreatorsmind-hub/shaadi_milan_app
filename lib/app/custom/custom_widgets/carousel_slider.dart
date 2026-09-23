import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import 'carusel_image.dart';

class CustomCarouselSlider extends StatefulWidget {
  final List<String> imageUrls;
  final double? height;
  const CustomCarouselSlider({super.key, required this.imageUrls, this.height});

  @override
  State<CustomCarouselSlider> createState() => _CustomCarouselSliderState();
}

class _CustomCarouselSliderState extends State<CustomCarouselSlider> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return Container(
        color: Colors.grey[200],
        width: double.infinity,
        height: widget.height ?? MediaQuery.of(context).size.height * 0.65,
        child: Icon(Icons.person, size: 100, color: Colors.grey[400]),
      );
    }

    final double sliderHeight = widget.height ?? MediaQuery.of(context).size.height * 0.65;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: sliderHeight,
            enlargeCenterPage: false,
            autoPlay: false,
            enableInfiniteScroll: widget.imageUrls.length > 1,
            viewportFraction: 1.0,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          items: widget.imageUrls.asMap().entries.map((entry) {
            final int index = entry.key;
            final String url = entry.value;

            return InkWell(
              onTap: () => _openFullscreenGallery(context, index),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: sliderHeight,
                child: CarouselImage(url: url, fit: BoxFit.cover),
              ),
            );
          }).toList(),
        ),

        // Image Count Badge (top right)
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.55), borderRadius: BorderRadius.circular(14)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.image_outlined, color: Colors.white, size: 16),
                const SizedBox(width: 5),
                Text(
                  widget.imageUrls.length > 1 ? '${_currentIndex + 1} / ${widget.imageUrls.length}' : '1',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),

        // Indicator Dots (positioned above bottom gradient/text)
        if (widget.imageUrls.length > 1)
          Positioned(
            bottom: 160,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.imageUrls.asMap().entries.map((entry) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _currentIndex == entry.key ? 16.0 : 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(horizontal: 3.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.0),
                    color: Colors.white.withOpacity(_currentIndex == entry.key ? 0.95 : 0.4),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  void _openFullscreenGallery(BuildContext context, int initialIndex) {
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (context) {
        return _FullscreenImageGallery(imageUrls: widget.imageUrls, initialIndex: initialIndex);
      },
    );
  }
}

class _FullscreenImageGallery extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const _FullscreenImageGallery({required this.imageUrls, required this.initialIndex});

  @override
  State<_FullscreenImageGallery> createState() => _FullscreenImageGalleryState();
}

class _FullscreenImageGalleryState extends State<_FullscreenImageGallery> {
  late PageController _pageController;
  late int _fullscreenIndex;

  @override
  void initState() {
    super.initState();
    _fullscreenIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) {
              setState(() => _fullscreenIndex = index);
            },
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Center(
                  child: CarouselImage(url: widget.imageUrls[index], fit: BoxFit.contain),
                ),
              );
            },
          ),

          // Top Header bar with Counter and Close Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      const Icon(Icons.photo_library_outlined, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        "${_fullscreenIndex + 1} / ${widget.imageUrls.length}",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
