# Modern App Bar Components Guide

This guide explains how to use the modern app bar components available in `animated_app_bar.dart`.

## Available App Bar Styles

### 1. AnimatedGlassAppBar (Glass Morphism)
A stunning glass morphism effect with animated blur and gradient backgrounds.

**Features:**
- Glass morphism effect with backdrop blur
- Animated scaling and transitions
- Customizable title, subtitle, and logo
- Gradient background with transparency
- Support for leading and action widgets

**Usage:**
```dart
CustomScrollView(
  slivers: [
    AnimatedGlassAppBar(
      title: 'Arvika Marriage Bureau',
      subtitle: 'Find your perfect match',
      showLogo: true,
      logoAsset: 'assets/images/logo.png',
      expandedHeight: 140,
      collapsedHeight: 88,
      leading: IconButton(
        icon: Icon(Icons.menu),
        onPressed: () {},
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications),
          onPressed: () {},
        ),
      ],
    ),
    // Your content...
  ],
)
```

**Parameters:**
- `title` (String?) - Main title text
- `subtitle` (String?) - Subtitle text
- `titleWidget` (Widget?) - Custom title widget (overrides title/subtitle)
- `showLogo` (bool) - Show/hide logo (default: true)
- `logoAsset` (String?) - Path to logo asset
- `expandedHeight` (double) - Height when expanded (default: 140)
- `collapsedHeight` (double) - Height when collapsed (default: 88)
- `leading` (Widget?) - Leading widget (drawer/back button)
- `actions` (List<Widget>?) - Action widgets (buttons, icons)

---

### 2. ModernGradientAppBar
Smooth gradient app bar with customizable colors and animations.

**Features:**
- Customizable gradient colors
- Optional subtitle
- Center or left-aligned title
- Subtle shadow effect
- Responsive height based on subtitle

**Usage:**
```dart
CustomScrollView(
  slivers: [
    ModernGradientAppBar(
      title: 'My Profile',
      subtitle: 'Edit your information',
      centerTitle: true,
      gradientColors: [
        Colors.purple,
        Colors.pink,
        Colors.red,
      ],
      actions: [
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () {},
        ),
      ],
    ),
    // Your content...
  ],
)
```

**Parameters:**
- `title` (String) - Title text (required)
- `subtitle` (String?) - Optional subtitle
- `centerTitle` (bool) - Center the title (default: false)
- `gradientColors` (List<Color>?) - Custom gradient colors
- `leading` (Widget?) - Leading widget
- `actions` (List<Widget>?) - Action widgets

---

### 3. MinimalAppBar
Clean and minimalist app bar with subtle styling.

**Features:**
- Minimal design
- Optional shadow
- Custom background color
- Gradient bottom border
- Lightweight and simple

**Usage:**
```dart
CustomScrollView(
  slivers: [
    MinimalAppBar(
      title: 'Settings',
      showShadow: true,
      backgroundColor: Colors.white,
      actions: [
        IconButton(
          icon: Icon(Icons.save),
          onPressed: () {},
        ),
      ],
    ),
    // Your content...
  ],
)
```

**Parameters:**
- `title` (String) - Title text (required)
- `showShadow` (bool) - Show shadow (default: true)
- `backgroundColor` (Color?) - Background color
- `leading` (Widget?) - Leading widget
- `actions` (List<Widget>?) - Action widgets

---

### 4. FloatingAppBar
Rounded floating app bar with elevation.

**Features:**
- Rounded corners
- Floating appearance with padding
- Customizable elevation
- Snap and float behavior
- Modern card-like design

**Usage:**
```dart
CustomScrollView(
  slivers: [
    FloatingAppBar(
      title: 'Messages',
      elevation: 8,
      backgroundColor: Colors.blue,
      actions: [
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {},
        ),
      ],
    ),
    // Your content...
  ],
)
```

**Parameters:**
- `title` (String) - Title text (required)
- `elevation` (double?) - Shadow elevation (default: 8)
- `backgroundColor` (Color?) - Background color
- `leading` (Widget?) - Leading widget
- `actions` (List<Widget>?) - Action widgets

---

### 5. SearchableAppBar
Interactive app bar with built-in search functionality.

**Features:**
- Animated search toggle
- Search field with hint text
- Auto-focus option
- Animated icon transitions
- Search callback function

**Usage:**
```dart
CustomScrollView(
  slivers: [
    SearchableAppBar(
      title: 'Find Profiles',
      searchHint: 'Search by name, age, location...',
      autoFocusSearch: false,
      onSearch: (query) {
        print('Searching for: $query');
        // Handle search logic
      },
      actions: [
        IconButton(
          icon: Icon(Icons.filter_list),
          onPressed: () {},
        ),
      ],
    ),
    // Your content...
  ],
)
```

**Parameters:**
- `title` (String) - Title text (required)
- `searchHint` (String?) - Search field hint text
- `autoFocusSearch` (bool) - Auto-focus on search (default: false)
- `onSearch` (Function(String)?) - Search callback
- `leading` (Widget?) - Leading widget
- `actions` (List<Widget>?) - Action widgets (hidden during search)

---

### 6. HeroAppBar
Large hero-style app bar with parallax effects.

**Features:**
- Large expanded height
- Parallax background effects
- Stretch and zoom effects
- Custom background image/gradient
- Overlay gradient for text readability
- Text with shadow effects

**Usage:**
```dart
CustomScrollView(
  slivers: [
    HeroAppBar(
      title: 'Featured Match',
      subtitle: 'Profile of the day',
      expandedHeight: 300,
      backgroundImage: Image.network(
        'https://example.com/hero-image.jpg',
        fit: BoxFit.cover,
      ),
      overlayColor: Colors.black,
      actions: [
        IconButton(
          icon: Icon(Icons.share, color: Colors.white),
          onPressed: () {},
        ),
      ],
    ),
    // Your content...
  ],
)
```

**Parameters:**
- `title` (String) - Title text (required)
- `subtitle` (String) - Subtitle text (required)
- `expandedHeight` (double) - Expanded height (default: 250)
- `backgroundImage` (Widget?) - Custom background image
- `overlayColor` (Color?) - Overlay gradient color
- `leading` (Widget?) - Leading widget
- `actions` (List<Widget>?) - Action widgets

---

## Common Patterns

### Pattern 1: App Bar with Drawer
```dart
CustomScrollView(
  slivers: [
    AnimatedGlassAppBar(
      title: 'Home',
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
    ),
  ],
)
```

### Pattern 2: App Bar with Back Button
```dart
CustomScrollView(
  slivers: [
    ModernGradientAppBar(
      title: 'Details',
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
    ),
  ],
)
```

### Pattern 3: App Bar with Multiple Actions
```dart
CustomScrollView(
  slivers: [
    MinimalAppBar(
      title: 'Profile',
      actions: [
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.share),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.more_vert),
          onPressed: () {},
        ),
      ],
    ),
  ],
)
```

---

## Tips & Best Practices

### 1. Use CustomScrollView
All these app bars are SliverAppBar widgets and must be used within a `CustomScrollView`:

```dart
Scaffold(
  body: CustomScrollView(
    slivers: [
      YourAppBar(...),
      SliverList(...),
    ],
  ),
)
```

### 2. Choose the Right App Bar
- **AnimatedGlassAppBar**: Hero sections, home screens, landing pages
- **ModernGradientAppBar**: Profile pages, feature screens
- **MinimalAppBar**: Settings, forms, simple lists
- **FloatingAppBar**: Modern designs, chat screens
- **SearchableAppBar**: Search pages, filterable lists
- **HeroAppBar**: Profile details, featured content

### 3. Consistent Theme
Use your app's theme colors for consistency:

```dart
final theme = Theme.of(context);

ModernGradientAppBar(
  gradientColors: [
    theme.primaryColor,
    theme.colorScheme.secondary,
  ],
)
```

### 4. Responsive Actions
Keep actions minimal and relevant to the current screen.

### 5. Search Performance
For SearchableAppBar, debounce the search to avoid excessive API calls:

```dart
Timer? _debounce;

SearchableAppBar(
  onSearch: (query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      // Perform search
      performSearch(query);
    });
  },
)
```

---

## Examples

See `app_bar_examples.dart` for complete working examples of each app bar style.

---

## Troubleshooting

### Issue: App bar doesn't appear
**Solution:** Make sure you're using `CustomScrollView` instead of `ListView` or `Column`.

### Issue: Glass effect not visible
**Solution:** Ensure there's content behind the app bar. Use `extendBodyBehindAppBar: true` in Scaffold if needed.

### Issue: Actions not visible
**Solution:** Check that action icons have proper colors that contrast with the app bar background.

---

## Customization

All app bars support extensive customization. Feel free to modify colors, heights, and animations to match your app's design system.

For more custom requirements, you can extend these classes or create new variants following the same patterns.
