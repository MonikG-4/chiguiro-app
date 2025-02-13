import 'package:flutter/material.dart';

class KeepAliveSurveyQuestion extends StatefulWidget {
  final Widget child;

  const KeepAliveSurveyQuestion({
    super.key,
    required this.child,
  });

  @override
  State<KeepAliveSurveyQuestion> createState() => _KeepAliveSurveyQuestionState();
}

class _KeepAliveSurveyQuestionState extends State<KeepAliveSurveyQuestion> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}