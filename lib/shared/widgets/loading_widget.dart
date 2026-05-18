import 'package:flutter/material.dart';
import 'skeleton_widgets.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final String? detail;

  const LoadingWidget({super.key, this.message, this.detail});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: AIProcessingLoader(
          message: message ?? 'Loading SmartDoc',
          detail: detail ?? 'Preparing a polished workspace for your documents',
        ),
      ),
    );
  }
}
