import '../../../../../app/custom/custom_widgets/widgets.dart';
import 'user_home_screen.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Expanded(child: SearchWidget()),
                  IconButton(
                    onPressed: () {
                      // TODO: Implement filter functionality
                    },
                    icon: const Icon(Icons.filter_list),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
