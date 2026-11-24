/// Utility to optimize image URLs (e.g. Unsplash, CDN images)
/// to reduce payload size from megabytes to kilobytes and enable instant loading.
String optimizeImageUrl(String url, {int width = 800, int quality = 75}) {
  if (url.trim().isEmpty) return '';
  final trimmed = url.trim();

  try {
    final uri = Uri.parse(trimmed);
    
    // 📸 Unsplash Optimization
    if (uri.host.contains('unsplash.com')) {
      final queryParams = Map<String, String>.from(uri.queryParameters);
      queryParams['w'] = width.toString();
      queryParams['q'] = quality.toString();
      queryParams['auto'] = 'format';
      queryParams['fit'] = 'crop';
      return uri.replace(queryParameters: queryParams).toString();
    }
  } catch (_) {
    // If URL parsing fails, return original trimmed string
  }

  return trimmed;
}
