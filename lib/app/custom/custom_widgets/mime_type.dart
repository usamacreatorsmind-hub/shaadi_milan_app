import 'package:arvika_marriage_bureau/features/agent/agent_app/presentation/screens/agen_profile.screen.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/widgets/pdf_viewer_bottomsheet.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

Future<String?> getMimeType(String url) async {
  try {
    final response = await http.head(Uri.parse(url));
    return response.headers['content-type'];
  } catch (e) {
    return null;
  }
}

void openMedia(BuildContext context, String url) async {
  final contentType = await getMimeType(url);

  if (contentType == null) {
    // fallback: open externally
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    return;
  }

  if (contentType.startsWith('image/')) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FullScreenImage(imageUrl: url)),
    );
  } else if (contentType == 'application/pdf') {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
          return PdfViewerBottomsheet(
            source: url,
            title: 'Document', // You might want to pass a more specific title
            isLocal: false,
          );
        },
      ),
    );
  } else {
    // unknown type, open externally
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}
