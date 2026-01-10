import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'image_picker_controller.dart';

class ExpandableImagePickerList extends ConsumerWidget {
  const ExpandableImagePickerList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(imagePickerProvider);
    final controller = ref.read(imagePickerProvider.notifier);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      children: [
        // ================= MATRIMONY IMAGE =================
        _ExpandableTile(
          title: "Profile Image",
          isSelected: state.profileImage != null,
          onTapPick: controller.pickProfileImage,
          child: _profileImagePreview(state.profileImage),
        ),
        _ExpandableTile(
          title: 'Matrimony Image',
          isSelected: state.primaryImage != null,
          onTapPick: controller.pickPrimaryImage,
          child: _singleImagePreview(state.primaryImage),
        ),

        // ================= AGENT IMAGE =================
        _ExpandableTile(
          title: 'Image with Agent',
          isSelected: state.imageWithAgentUrl != null,
          onTapPick: controller.pickImageWithAgent,
          child: _singleImagePreview(state.imageWithAgentUrl),
        ),

        // ================= GALLERY =================
        _ExpandableTile(
          title: 'Gallery Images',
          isSelected: state.secondaryImages.isNotEmpty,
          onTapPick: controller.pickSecondaryImages,
          child: _galleryPreview(
            state.secondaryImages,
            controller.removeSecondaryImage,
          ),
        ),

        // ================= AADHAR =================
        _ExpandableTile(
          title: 'Aadhar Document',
          isSelected: state.aadharPdfPath != null,
          onTapPick: controller.pickAadharImages,
          child: _aadharPreview(state.aadharPdfPath),
        ),
      ],
    );
  }

  // ================= PREVIEWS =================

  Widget _singleImagePreview(String? path) {
    if (path == null) return const SizedBox();
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(
        File(path),
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _galleryPreview(List<String> images, void Function(String) onRemove) {
    if (images.isEmpty) return const SizedBox();

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (_, i) {
          final path = images[i];
          return Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 10),
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: FileImage(File(path)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                right: 4,
                top: 4,
                child: GestureDetector(
                  onTap: () => onRemove(path),
                  child: const CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.black54,
                    child: Icon(Icons.close, size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _aadharPreview(String? path) {
    if (path == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green),
      ),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf, color: Colors.green),
          const SizedBox(width: 10),
          Expanded(
            child: Text(path.split('/').last, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _profileImagePreview(profilImage) {
    if (profilImage == null) return const SizedBox();
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(
        File(profilImage),
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _ExpandableTile extends StatefulWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTapPick;
  final Widget child;

  const _ExpandableTile({
    required this.title,
    required this.isSelected,
    required this.onTapPick,
    required this.child,
  });

  @override
  State<_ExpandableTile> createState() => _ExpandableTileState();
}

class _ExpandableTileState extends State<_ExpandableTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: widget.isSelected ? Colors.green : colors.outline,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () => setState(() => _expanded = !_expanded),
            title: Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.isSelected)
                  const Icon(Icons.check_circle, color: Colors.green),
                IconButton(
                  icon: const Icon(Icons.upload),
                  onPressed: widget.onTapPick,
                ),
                Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
          ),
          if (_expanded)
            Padding(padding: const EdgeInsets.all(12), child: widget.child),
        ],
      ),
    );
  }
}
