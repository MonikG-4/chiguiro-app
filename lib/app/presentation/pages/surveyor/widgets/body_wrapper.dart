import 'package:flutter/material.dart';

import '../../../../../core/values/app_colors.dart';

class BodyWrapper extends StatelessWidget {
  final Widget child;
  final Future<void> Function()? onRefresh;
  final Widget? bottomButton;
  final bool? showBottomButton;

  const BodyWrapper({
    super.key,
    required this.child,
    this.onRefresh,
    this.bottomButton,
    this.showBottomButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final scrollView = CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: bottomButton != null && showBottomButton == true ? 80 : 16,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 16),
              child,
            ]),
          ),
        ),
      ],
    );

    return Stack(
      children: [
        Positioned.fill(
          child: onRefresh != null
              ? RefreshIndicator(
            onRefresh: onRefresh!,
            child: scrollView,
          )
              : scrollView,
        ),
        if (bottomButton != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.background,
              ),
              child: bottomButton!,
            ),
          ),
      ],
    );
  }

}
