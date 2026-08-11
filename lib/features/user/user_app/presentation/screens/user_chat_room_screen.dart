import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shadi_milan/app/providers/global_providers.dart';
import 'package:shadi_milan/features/translitration/models/bilingual_value.dart';
import '../../../../../app/router/app_router.dart';

@RoutePage()
class UserChatRoomScreen extends ConsumerStatefulWidget {
  final String peerId;

  const UserChatRoomScreen({super.key, required this.peerId});

  @override
  ConsumerState<UserChatRoomScreen> createState() => _UserChatRoomScreenState();
}

class _UserChatRoomScreenState extends ConsumerState<UserChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _resetUnreadCount();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _resetUnreadCount() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUserId = ref.read(userProvider)?.uid;
      if (currentUserId != null) {
        final chatId = _getChatId(currentUserId, widget.peerId);
        ref
            .read(firestoreProvider)
            .collection('chats')
            .doc(chatId)
            .set({'unreadCount_$currentUserId': 0}, SetOptions(merge: true))
            .catchError((e) => debugPrint("Error resetting unread count: $e"));
      }
    });
  }

  String _getChatId(String uid1, String uid2) {
    List<String> ids = [uid1, uid2];
    ids.sort();
    return ids.join('_');
  }

  Future<void> _sendMessage(String currentUserId) async {
    if (_messageController.text.trim().isEmpty) return;

    final firestore = ref.read(firestoreProvider);
    final chatId = _getChatId(currentUserId, widget.peerId);
    final messageText = _messageController.text.trim();
    _messageController.clear();

    final batch = firestore.batch();

    // 1. Add message
    final msgRef = firestore.collection('chats').doc(chatId).collection('messages').doc();
    batch.set(msgRef, {
      'senderId': currentUserId,
      'receiverId': widget.peerId,
      'message': messageText,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // 2. Update chat metadata and increment unread count for receiver
    final chatRef = firestore.collection('chats').doc(chatId);
    batch.set(chatRef, {
      'lastMessage': messageText,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'participants': [currentUserId, widget.peerId],
      'unreadCount_${widget.peerId}': FieldValue.increment(1),
    }, SetOptions(merge: true));

    await batch.commit();

    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0.0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserId = ref.watch(userProvider)?.uid ?? '';
    if (currentUserId.isEmpty) return const Scaffold(body: Center(child: Text('Please login to chat')));

    final firestore = ref.watch(firestoreProvider);
    final chatId = _getChatId(currentUserId, widget.peerId);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        title: StreamBuilder<DocumentSnapshot>(
          stream: firestore.collection('users').doc(widget.peerId).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Text('Chat');
            final userData = snapshot.data!.data() as Map<String, dynamic>?;
            if (userData == null) return const Text('Chat');
            final name = userData['fullName'];
            String peerName = 'Chat';
            if (name is Map) {
              final bilingual = BilingualValue.fromMap(Map<String, dynamic>.from(name));
              peerName = Localizations.localeOf(context).languageCode == 'hi' ? bilingual.hi : bilingual.en;
            } else {
              peerName = name?.toString() ?? 'Chat';
            }

            final peerImage = userData['profileImageUrl'] as String?;

            return InkWell(
              onTap: () {
                context.pushRoute(UserDetailRoute(uid: widget.peerId));
              },
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: peerImage != null && peerImage.isNotEmpty ? NetworkImage(peerImage) : null,
                    child: peerImage == null || peerImage.isEmpty ? const Icon(Icons.person, size: 20) : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(peerName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              context.pushRoute(UserDetailRoute(uid: widget.peerId));
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(color: theme.primaryColor.withValues(alpha: 0.03)),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: firestore.collection('chats').doc(chatId).collection('messages').orderBy('timestamp', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                  final messages = snapshot.data!.docs;
                  if (messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 64, color: theme.primaryColor.withValues(alpha: 0.2)),
                          const SizedBox(height: 16),
                          Text('Start conversation', style: TextStyle(color: theme.primaryColor.withValues(alpha: 0.4), fontSize: 16)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final data = messages[index].data() as Map<String, dynamic>;
                      final isMe = data['senderId'] == currentUserId;
                      final timestamp = data['timestamp'] as Timestamp?;

                      // Date Divider Logic
                      bool showDateDivider = false;
                      if (timestamp != null) {
                        if (index == messages.length - 1) {
                          showDateDivider = true;
                        } else {
                          final prevData = messages[index + 1].data() as Map<String, dynamic>;
                          final prevTimestamp = prevData['timestamp'] as Timestamp?;
                          if (prevTimestamp != null) {
                            final date = timestamp.toDate();
                            final prevDate = prevTimestamp.toDate();
                            if (date.day != prevDate.day || date.month != prevDate.month || date.year != prevDate.year) {
                              showDateDivider = true;
                            }
                          }
                        }
                      }

                      return Column(
                        children: [
                          if (showDateDivider && timestamp != null) _buildDateDivider(timestamp.toDate()),
                          _ChatBubble(
                            message: data['message'] ?? '',
                            isMe: isMe,
                            time: timestamp != null ? DateFormat('hh:mm a').format(timestamp.toDate()) : '',
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            _buildMessageInput(context, currentUserId),
          ],
        ),
      ),
    );
  }

  Widget _buildDateDivider(DateTime date) {
    String dateText;
    final now = DateTime.now();
    if (date.day == now.day && date.month == now.month && date.year == now.year) {
      dateText = 'Today';
    } else if (date.day == now.day - 1 && date.month == now.month && date.year == now.year) {
      dateText = 'Yesterday';
    } else {
      dateText = DateFormat('MMMM dd, yyyy').format(date);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
      child: Text(
        dateText,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black45),
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context, String currentUserId) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                fillColor: theme.primaryColor.withValues(alpha: 0.05),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: theme.primaryColor,
            shape: const CircleBorder(),
            elevation: 2,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: () => _sendMessage(currentUserId),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String time;

  const _ChatBubble({required this.message, required this.isMe, required this.time});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? theme.primaryColor : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isMe ? const Radius.circular(20) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(20),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(message, style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 15, height: 1.2)),
            const SizedBox(height: 4),
            Text(time, style: TextStyle(color: isMe ? Colors.white.withValues(alpha: 0.7) : Colors.black38, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
