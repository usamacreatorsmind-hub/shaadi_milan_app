import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class UserChatScreen extends ConsumerStatefulWidget {
  const UserChatScreen({super.key});

  @override
  ConsumerState<UserChatScreen> createState() => _UserChatScreenState();
}

class _UserChatScreenState extends ConsumerState<UserChatScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20),
        // ================= CUSTOM HEADER =================
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
          child: Row(
            children: [
              const Text(
                'Messages',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(icon: const Icon(Icons.search), onPressed: () {}),
              IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
            ],
          ),
        ),

        // ================= TAB BAR =================
        TabBar(
          indicatorColor: Theme.of(context).primaryColor,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          unselectedLabelColor: Colors.grey,

          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Matches'),
            Tab(text: 'Requests'),
          ],
        ),

        const Divider(height: 1),

        // ================= TAB CONTENT =================
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_chatList(), _chatList(), _chatList()],
          ),
        ),
      ],
    );
  }

  Widget _chatList() {
    return ListView.builder(
      itemCount: 20,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const CircleAvatar(
            radius: 26,
            backgroundColor: Colors.blueGrey,
            child: Icon(Icons.person, color: Colors.white),
          ),
          title: Text('User ${index + 1}'),
          subtitle: const Text('Last message preview...'),
          trailing: const Text('12:30 PM'),
          onTap: () {
            // open chat room
          },
        );
      },
    );
  }
}
