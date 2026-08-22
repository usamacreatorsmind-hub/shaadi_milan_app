import 'carusel_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

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
        height: widget.height ?? MediaQuery.of(context).size.height * 0.85,
        child: Icon(Icons.person, size: 100, color: Colors.grey[400]),
      );
    }

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: widget.height ?? MediaQuery.of(context).size.height * 0.85,
            enlargeCenterPage: false,
            autoPlay: false,
            enableInfiniteScroll: widget.imageUrls.length > 1,
            viewportFraction: 1,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          items: widget.imageUrls.map((url) {
            return InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  barrierColor: Colors.black,
                  builder: (context) => Dialog.fullscreen(
                    backgroundColor: Colors.black,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: InteractiveViewer(
                            minScale: 1,
                            maxScale: 4,
                            child: Center(
                              child: CarouselImage(url: url, fit: BoxFit.contain),
                            ),
                          ),
                        ),
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 8,
                          right: 8,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white, size: 30),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: widget.height ?? MediaQuery.of(context).size.height * 0.85,
                child: CarouselImage(url: url, fit: BoxFit.cover),
              ),
            );
          }).toList(),
        ),
        // Image Count Badge
        if (widget.imageUrls.isNotEmpty)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.image_outlined, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.imageUrls.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        if (widget.imageUrls.length > 1)
          Positioned(
            bottom: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.imageUrls.asMap().entries.map((entry) {
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(_currentIndex == entry.key ? 0.9 : 0.4),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
