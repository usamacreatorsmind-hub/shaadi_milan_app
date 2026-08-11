import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shadi_milan/app/providers/global_providers.dart';
import 'package:shadi_milan/app/router/app_router.dart';
import 'package:shadi_milan/features/translitration/models/bilingual_value.dart';
import '../../../../../../core/constants/app_labels.dart';
import '../../../../../app/custom/custom_widgets/animated_app_bar.dart';

@RoutePage()
class UserChatScreen extends ConsumerStatefulWidget {
  const UserChatScreen({super.key});

  @override
  ConsumerState<UserChatScreen> createState() => _UserChatScreenState();
}

class _UserChatScreenState extends ConsumerState<UserChatScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          ModernGradientAppBar(title: AppLabels.navChat(context), subtitle: 'Recent conversations', centerTitle: true),
        ],
        body: Container(color: theme.primaryColor.withValues(alpha: 0.02), child: _chatList()),
      ),
    );
  }

  Widget _chatList() {
    final currentUserId = ref.watch(userProvider)?.uid ?? '';
    final theme = Theme.of(context);
    if (currentUserId.isEmpty) return const Center(child: Text('Please login'));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('chats').where('participants', arrayContains: currentUserId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final chats = snapshot.data!.docs;
        if (chats.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'No messages yet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[400]),
                ),
              ],
            ),
          );
        }

        // Sort locally to avoid Firestore Index requirement
        final sortedChats = chats.toList()
          ..sort((a, b) {
            final aTime = (a.data() as Map<String, dynamic>)['lastMessageTime'] as Timestamp?;
            final bTime = (b.data() as Map<String, dynamic>)['lastMessageTime'] as Timestamp?;
            if (aTime == null) return 1;
            if (bTime == null) return -1;
            return bTime.compareTo(aTime);
          });

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: sortedChats.length,
          itemBuilder: (context, index) {
            final doc = sortedChats[index];
            final chatData = doc.data() as Map<String, dynamic>;
            final participants = List<String>.from(chatData['participants']);
            final peerId = participants.firstWhere((id) => id != currentUserId, orElse: () => '');
            if (peerId.isEmpty) return const SizedBox.shrink();

            final lastMessage = chatData['lastMessage'] ?? '';
            final lastMessageTime = chatData['lastMessageTime'] as Timestamp?;
            final unreadCount = chatData['unreadCount_$currentUserId'] ?? 0;

            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(peerId).snapshots(),
              builder: (context, userSnapshot) {
                String peerName = 'User';
                String? peerImage;

                if (userSnapshot.hasData && userSnapshot.data!.exists) {
                  final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                  if (userData != null) {
                    final name = userData['fullName'];
                    if (name is Map) {
                      final bilingual = BilingualValue.fromMap(Map<String, dynamic>.from(name));
                      peerName = Localizations.localeOf(context).languageCode == 'hi' ? bilingual.hi : bilingual.en;
                    } else {
                      peerName = name?.toString() ?? 'User';
                    }
                    peerImage = userData['profileImageUrl'];
                  }
                }

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                      backgroundImage: peerImage != null && peerImage.isNotEmpty ? NetworkImage(peerImage) : null,
                      child: peerImage == null || peerImage.isEmpty ? Icon(Icons.person, color: theme.primaryColor) : null,
                    ),
                    title: Text(
                      peerName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          lastMessageTime != null ? DateFormat('hh:mm a').format(lastMessageTime.toDate()) : '',
                          style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                        ),
                        if (unreadCount > 0)
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: theme.primaryColor, borderRadius: BorderRadius.circular(10)),
                            child: Text(
                              unreadCount.toString(),
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                    onTap: () {
                      context.pushRoute(UserChatRoomRoute(peerId: peerId));
                    },
                    onLongPress: () => _showDeleteDialog(context, doc.id, peerName),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, String chatId, String peerName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chat'),
        content: Text('Are you sure you want to delete chat with $peerName?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseFirestore.instance.collection('chats').doc(chatId).delete();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chat deleted')));
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
