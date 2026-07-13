import 'package:shadi_milan/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'animated_app_bar.dart';

/// Example usage of all modern app bars
///
/// This file demonstrates how to use each app bar variant.
/// Copy the examples you need into your screens.

class AppBarExamplesScreen extends StatelessWidget {
  const AppBarExamplesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Example 1: Glass Morphism App Bar (Default)
          AnimatedGlassAppBar(
            title: AppConstants.appName,
            subtitle: AppConstants.homeSubtitle,
            showLogo: true,
            logoAsset: AppConstants.appLogoPath,
            actions: [
              Icon(Icons.notifications_outlined, color: Colors.black54),
              SizedBox(width: 16),
            ],
          ),

          // Content
          SliverList(
            delegate: SliverChildListDelegate([
              _buildSection('Glass Morphism App Bar',
                  'Beautiful glass effect with blur and gradient. Perfect for hero sections.'),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String description) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(description),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== USAGE EXAMPLES ====================

/// Example 1: Glass Morphism App Bar
///
/// Usage in your screen:
/// ```dart
/// CustomScrollView(
///   slivers: [
///     AnimatedGlassAppBar(
///       title: 'Welcome',
///       subtitle: 'Find your match',
///       showLogo: true,
///       actions: [
///         IconButton(
///           icon: Icon(Icons.notifications),
///           onPressed: () {},
///         ),
///       ],
///     ),
///     SliverList(...),
///   ],
/// )
/// ```

/// Example 2: Modern Gradient App Bar
///
/// Usage:
/// ```dart
/// CustomScrollView(
///   slivers: [
///     ModernGradientAppBar(
///       title: 'My Profile',
///       subtitle: 'Edit your details',
///       centerTitle: true,
///       actions: [
///         IconButton(
///           icon: Icon(Icons.edit),
///           onPressed: () {},
///         ),
///       ],
///     ),
///     SliverList(...),
///   ],
/// )
/// ```

/// Example 3: Minimal App Bar
///
/// Usage:
/// ```dart
/// CustomScrollView(
///   slivers: [
///     MinimalAppBar(
///       title: 'Settings',
///       showShadow: true,
///       actions: [
///         IconButton(
///           icon: Icon(Icons.save),
///           onPressed: () {},
///         ),
///       ],
///     ),
///     SliverList(...),
///   ],
/// )
/// ```

/// Example 4: Floating App Bar
///
/// Usage:
/// ```dart
/// CustomScrollView(
///   slivers: [
///     FloatingAppBar(
///       title: 'Messages',
///       elevation: 8,
///       actions: [
///         IconButton(
///           icon: Icon(Icons.search),
///           onPressed: () {},
///         ),
///       ],
///     ),
///     SliverList(...),
///   ],
/// )
/// ```

/// Example 5: Searchable App Bar
///
/// Usage:
/// ```dart
/// CustomScrollView(
///   slivers: [
///     SearchableAppBar(
///       title: 'Find Profiles',
///       searchHint: 'Search by name...',
///       onSearch: (query) {
///         print('Searching: $query');
///       },
///       actions: [
///         IconButton(
///           icon: Icon(Icons.filter_list),
///           onPressed: () {},
///         ),
///       ],
///     ),
///     SliverList(...),
///   ],
/// )
/// ```

/// Example 6: Hero App Bar
///
/// Usage:
/// ```dart
/// CustomScrollView(
///   slivers: [
///     HeroAppBar(
///       title: 'Featured Matches',
///       subtitle: 'Top profiles for you',
///       expandedHeight: 250,
///       backgroundImage: Image.network(
///         'https://example.com/banner.jpg',
///         fit: BoxFit.cover,
///       ),
///       actions: [
///         IconButton(
///           icon: Icon(Icons.share),
///           onPressed: () {},
///         ),
///       ],
///     ),
///     SliverList(...),
///   ],
/// )
/// ```

// ==================== COMPLETE SCREEN EXAMPLES ====================

/// Complete example: User home screen with Glass App Bar
class UserHomeWithGlassAppBar extends StatelessWidget {
  const UserHomeWithGlassAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          AnimatedGlassAppBar(
            title: AppConstants.appName,
            subtitle: AppConstants.homeSubtitle,
            showLogo: true,
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.black54),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            actions: const [
              Icon(Icons.notifications_outlined, color: Colors.black54),
              SizedBox(width: 16),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Card(
                  child: ListTile(
                    title: Text('Profile ${index + 1}'),
                    subtitle: const Text('Tap to view details'),
                  ),
                ),
                childCount: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Complete example: Search screen with Searchable App Bar
class SearchScreenWithSearchableAppBar extends StatefulWidget {
  const SearchScreenWithSearchableAppBar({super.key});

  @override
  State<SearchScreenWithSearchableAppBar> createState() =>
      _SearchScreenWithSearchableAppBarState();
}

class _SearchScreenWithSearchableAppBarState
    extends State<SearchScreenWithSearchableAppBar> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SearchableAppBar(
            title: 'Find Profiles',
            searchHint: 'Search by name, age, location...',
            autoFocusSearch: false,
            onSearch: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () {
                  // Open filter bottom sheet
                },
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Card(
                  child: ListTile(
                    title: Text('Result ${index + 1}'),
                    subtitle: Text('Matches: $_searchQuery'),
                  ),
                ),
                childCount: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Complete example: Profile detail with Hero App Bar
class ProfileDetailWithHeroAppBar extends StatelessWidget {
  const ProfileDetailWithHeroAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          HeroAppBar(
            title: 'Raj Kumar',
            subtitle: '28 years • Mumbai • Engineer',
            expandedHeight: 300,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const Text(
                  'About',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Software engineer with a passion for travel and photography...',
                ),
                const SizedBox(height: 24),
                const Text(
                  'Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildDetailRow('Height', '5\'10"'),
                _buildDetailRow('Education', 'B.Tech Computer Science'),
                _buildDetailRow('Occupation', 'Software Engineer'),
                _buildDetailRow('Location', 'Mumbai, Maharashtra'),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
