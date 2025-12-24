import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NetworkErrorScreen extends ConsumerStatefulWidget {
  const NetworkErrorScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NetworkErrorScreenState();
}

class _NetworkErrorScreenState extends ConsumerState<NetworkErrorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Column(children: [

      const Text('Network Error'),
      ElevatedButton(
        onPressed: () {
          // Implement retry logic here
        },
        child: const Text('Retry'),
      ),
      
    


  ],
));
  }
}
