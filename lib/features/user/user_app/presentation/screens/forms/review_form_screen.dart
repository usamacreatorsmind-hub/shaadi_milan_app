import 'package:auto_route/auto_route.dart';
import 'package:easy_stars/easy_stars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../../core/constants/app_labels.dart';
import '../../../../../../app/custom/custom_widgets/widgets.dart';
import '../../../data/repositories_impl/user_repo_impl.dart';
import '../../../domain/states/review_state.dart';
import '../../controllers/review_notifiers.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLabels.pleaseSelectRating(context))),
      );
      return;
    }

    // send data to firestore
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppLabels.userNotFound(context))));
      return;
    }

    final reviewNotifier = ref.read(reviewNotifierProvider.notifier);

    final review = Review(
      agentId: currentUser.agentId,
      id: '',
      userId: currentUser.uid,
      userName: currentUser.fullName.en,
      userProfileImg: currentUser.profileImageUrl,
      rating: _rating.toInt(),
      title: _titleController.text.trim(),
      comment: _descriptionController.text.trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await reviewNotifier.addReview(review: review);

    final state = ref.read(reviewNotifierProvider);
    if (state.error != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLabels.error(context, state.error.toString())),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLabels.reviewSubmittedSuccess(context))),
        );
        context.router.maybePop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(reviewNotifierProvider);
    final profileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLabels.writeAReview(context)),
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
                      label: AppLabels.reviewTitle(context),
                      hint: AppLabels.reviewTitleHint(context),
                      prefixIcon: Icons.title,
                      iconColor: theme.colorScheme.primary,
                      maxLines: 1,
                      counterType: CounterType.words,
                      validator: (v) => v == null || v.isEmpty
                          ? AppLabels.titleCannotBeEmpty(context)
                          : null,
                    ),

                    const SizedBox(height: 16),

                    /// REVIEW DESCRIPTION
                    AppTextField(
                      showWordCount: true,
                      controller: _descriptionController,
                      label: AppLabels.reviewDescription(context),
                      hint: AppLabels.reviewDescriptionHint(context),
                      prefixIcon: Icons.description,
                      iconColor: theme.colorScheme.primary,
                      maxLines: 7,
                      counterType: CounterType.words,
                      validator: (v) => v == null || v.isEmpty
                          ? AppLabels.descriptionCannotBeEmpty(context)
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
                      child: state.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : AppButton(
                              onPressed: () => _submitReview(),
                              text: AppLabels.submitReview(context),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        error: (error, stackTrace) =>
            Center(child: Text(AppLabels.error(context, error.toString()))),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
