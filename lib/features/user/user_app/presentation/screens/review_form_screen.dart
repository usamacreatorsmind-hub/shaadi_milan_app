import 'package:shadi_milan/features/user/user_app/data/repositories_impl/agent_repository_impl.dart';

import '../../../../../app/custom/custom_widgets/widgets.dart';
import '../../data/repositories_impl/user_repo_impl.dart';
import '../../domain/states/review_state.dart';
import '../controllers/review_notifiers.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_stars/easy_stars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class ReviewFormScreen extends ConsumerStatefulWidget {
  const ReviewFormScreen({super.key});

  @override
  ConsumerState<ReviewFormScreen> createState() => _ReviewFormScreenState();
}

class _ReviewFormScreenState extends ConsumerState<ReviewFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  double _rating = 3.0;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;

    if (_rating == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a rating')));
      return;
    }

    // send data to firestore
    final currentUser = ref.watch(currentUserProvider);

    final reviewNotifier = ref.read(reviewNotifierProvider.notifier);

    // fetch agetn entity  from repository
    ref.read(agentRepositoryProvider).fetchAgent(currentUser.value!.agentId);

    Review(
      agentId: currentUser.value!.agentId,

      id: '',
      userId: currentUser.value!.uid,
      userName: currentUser.value!.fullName,
      userProfileImg: currentUser.value!.profileImageUrl,
      rating: _rating.toInt(),
      title: _titleController.text.trim(),
      comment: _descriptionController.text.trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final state = ref.read(reviewNotifierProvider);
    if (state.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${state.error}')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully!')),
      );
      context.router.maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final profileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Write a Review'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.router.maybePop(),
        ),
      ),

      body: profileAsync.when(
        data: (data) {
          return SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    /// REVIEW TITLE
                    AppTextField(
                      obscureText: false,
                      keyboardType: TextInputType.text,

                      showWordCount: true,

                      inputFormatters: [],
                      controller: _titleController,
                      label: 'Review Title',
                      hint: 'Enter a title for your review',
                      prefixIcon: Icons.title,
                      iconColor: theme.colorScheme.primary,
                      maxLines: 1,
                      counterType: CounterType.words,
                      validator: (v) => v == null || v.isEmpty
                          ? 'Title cannot be empty'
                          : null,
                    ),

                    const SizedBox(height: 16),

                    /// REVIEW DESCRIPTION
                    AppTextField(
                      showWordCount: true,
                      controller: _descriptionController,
                      label: 'Review Description',
                      hint: 'Write your detailed review here',
                      prefixIcon: Icons.description,
                      iconColor: theme.colorScheme.primary,
                      maxLines: 7,
                      counterType: CounterType.words,
                      validator: (v) => v == null || v.isEmpty
                          ? 'Description cannot be empty'
                          : null,
                      obscureText: false,
                      keyboardType: TextInputType.text,
                    ),

                    const SizedBox(height: 10),

                    /// STAR RATING
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        EasyStarsRating(
                          starSize: 50,
                          gradientColors: const [Colors.orange, Colors.red],
                          allowClear: true,
                          animateOnRatingChange: true,
                          initialRating: _rating,
                          onRatingChanged: (value) {
                            setState(() => _rating = value);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    /// SUBMIT
                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        onPressed: _submitReview,

                        text: 'Submit Review',
                      ),
                    ),

                    // print data
                  ],
                ),
              ),
            ),
          );
        },
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
