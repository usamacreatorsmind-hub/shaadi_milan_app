import 'package:shadi_milan/core/constants/app_constants.dart';
import 'package:shadi_milan/core/constants/app_labels.dart';
import 'dart:ui';

import 'package:flutter/material.dart';

 

/// Glass morphism app bar with animated blur and gradient effects
class AnimatedGlassAppBar extends StatelessWidget {
  final Widget? leading;
  final List<Widget>? actions;
  final String? title;
  final String? subtitle;
  final Widget? titleWidget;
  final bool showLogo;
  final String? logoAsset;
  final double expandedHeight;
  final double collapsedHeight;

  const AnimatedGlassAppBar({
    super.key,
    this.leading,
    this.actions,
    this.title,
    this.subtitle,
    this.titleWidget,
    this.showLogo = true,
    this.logoAsset = AppConstants.appLogoPath,
    this.expandedHeight = 140,
    this.collapsedHeight = 88,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverAppBar(
      pinned: true,
      stretch: true,
      elevation: 0,
      leading: leading,
      actions: actions,
      expandedHeight: expandedHeight,
      collapsedHeight: collapsedHeight,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      iconTheme: const IconThemeData(color: Colors.black87),
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final t = ((constraints.maxHeight - kToolbarHeight) / (expandedHeight - kToolbarHeight)).clamp(0.0, 1.0);

          final logoScale = 0.75 + t * 0.25;
          final titleOpacity = t;

          return Stack(
            fit: StackFit.expand,
            children: [
              Container(color: Colors.white),

              // 🌸 Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    if (showLogo && logoAsset != null) ...[
                      // Animated logo
                      Transform.scale(
                        scale: logoScale,
                        child: SizedBox(
                          height: 80,
                          width: 80,
                          child: Image.asset(logoAsset!, fit: BoxFit.contain),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],

                    // Animated text
                    if (titleWidget != null)
                      Opacity(
                        opacity: titleOpacity,
                        child: Transform.translate(
                          offset: Offset(0, 10 * (1 - t)),
                          child: titleWidget,
                        ),
                      )
                    else
                      Opacity(
                        opacity: titleOpacity,
                        child: Transform.translate(
                          offset: Offset(0, 10 * (1 - t)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title ?? AppLabels.appName(context),
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: theme.primaryColor,
                                  letterSpacing: 1,
                                ),
                              ),
                              if (subtitle != null) ...[
                                const SizedBox(height: 3),
                                Text(
                                  subtitle!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                    letterSpacing: 0.8,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: Colors.grey.shade200,
        ),
      ),
    );
  }
}

/// Modern gradient app bar with smooth animations
class ModernGradientAppBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final List<Color>? gradientColors;

  const ModernGradientAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.centerTitle = false,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverAppBar(
      pinned: true,
      elevation: 0,
      expandedHeight: subtitle != null ? 120 : 80,
      leading: leading,
      actions: actions,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      iconTheme: const IconThemeData(color: Colors.black87),
      flexibleSpace: Container(
        color: Colors.white,
        child: FlexibleSpaceBar(
          centerTitle: centerTitle,
          titlePadding: EdgeInsets.only(left: centerTitle ? 0 : 56, bottom: 16),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: Colors.grey.shade200,
        ),
      ),
    );
  }
}

/// Minimalist app bar with subtle elevation
class MinimalAppBar extends StatelessWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showShadow;
  final Color? backgroundColor;

  const MinimalAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.showShadow = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverAppBar(
      pinned: true,
      elevation: showShadow ? 2 : 0,
      leading: leading,
      actions: actions,
      backgroundColor: backgroundColor ?? Colors.white,
      foregroundColor: Colors.black87,
      iconTheme: const IconThemeData(color: Colors.black87),
      title: Text(
        title,
        style: TextStyle(
          color: theme.primaryColor,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: Colors.grey.shade200,
        ),
      ),
    );
  }
}

/// Floating app bar with rounded corners
class FloatingAppBar extends StatelessWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final double? elevation;

  const FloatingAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.elevation = 8,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      sliver: SliverAppBar(
        pinned: true,
        floating: true,
        snap: true,
        elevation: elevation,
        leading: leading,
        actions: actions,
        backgroundColor: backgroundColor ?? Colors.white,
        foregroundColor: Colors.black87,
        iconTheme: const IconThemeData(color: Colors.black87),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: TextStyle(
            color: theme.primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Expandable app bar with search functionality
class SearchableAppBar extends StatefulWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final Function(String)? onSearch;
  final String? searchHint;
  final bool autoFocusSearch;

  const SearchableAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.onSearch,
    this.searchHint,
    this.autoFocusSearch = false,
  });

  @override
  State<SearchableAppBar> createState() => _SearchableAppBarState();
}

class _SearchableAppBarState extends State<SearchableAppBar> with SingleTickerProviderStateMixin {
  bool _isSearching = false;
  final _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (_isSearching) {
        _animationController.forward();
      } else {
        _animationController.reverse();
        _searchController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverAppBar(
      pinned: true,
      elevation: 2,
      leading: widget.leading,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      iconTheme: const IconThemeData(color: Colors.black87),
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isSearching
            ? TextField(
                key: const ValueKey('search'),
                controller: _searchController,
                autofocus: widget.autoFocusSearch,
                style: const TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  hintText: widget.searchHint ?? AppLabels.searchHint(context),
                  hintStyle: TextStyle(color: Colors.black54),
                  border: InputBorder.none,
                ),
                onChanged: widget.onSearch,
              )
            : Text(
                widget.title,
                key: const ValueKey('title'),
                style: const TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.w600),
              ),
      ),
      actions: [
        IconButton(
          icon: AnimatedIcon(icon: AnimatedIcons.search_ellipsis, progress: _animation, color: theme.primaryColor),
          onPressed: _toggleSearch,
        ),
        if (widget.actions != null && !_isSearching) ...widget.actions!,
      ],
    );
  }
}

/// Hero app bar with large title, parallax effect & SafeArea support
class HeroAppBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? backgroundImage;
  final Widget? leading;
  final List<Widget>? actions;
  final double expandedHeight;
  final Color? overlayColor;

  const HeroAppBar({
    super.key,
    required this.title,
    required this.subtitle,
    this.backgroundImage,
    this.leading,
    this.actions,
    this.expandedHeight = 260,
    this.overlayColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverAppBar(
      pinned: true,
      stretch: true,
      expandedHeight: expandedHeight,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      iconTheme: const IconThemeData(color: Colors.black87),
      leading: leading,
      actions: actions,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],

        /// TITLE AREA (SAFE)
        titlePadding: const EdgeInsetsDirectional.only(start: 16, bottom: 16),
        title: SafeArea(
          bottom: false, // only protect top
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: backgroundImage != null ? Colors.white : Colors.black87,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.4,
                  shadows: backgroundImage != null ? [const Shadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 2))] : null,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: backgroundImage != null ? Colors.white70 : Colors.black54,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  shadows: backgroundImage != null ? [const Shadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 2))] : null,
                ),
              ),
            ],
          ),
        ),

        /// BACKGROUND AREA
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (backgroundImage != null) ...[
              backgroundImage!,

              /// DARK OVERLAY
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.6), Colors.black.withOpacity(0.2)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ] else
              Container(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
