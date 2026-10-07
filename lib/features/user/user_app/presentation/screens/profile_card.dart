import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  final String profileId;
  final String name;
  final int age;
  final String height;
  final String occupation;
  final String imageUrl;

  const ProfileCard({
    super.key,
    required this.profileId,
    required this.name,
    required this.age,
    required this.height,
    required this.occupation,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          CachedNetworkImage(
            imageUrl: imageUrl,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              height: 200,
              color: Colors.grey.shade200,
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => const SizedBox(height: 200, child: Icon(Icons.broken_image)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$name, $age', style: Theme.of(context).textTheme.titleLarge),
                Text('$height | $occupation'),
                Text(profileId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
