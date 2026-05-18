import 'dart:async';
import 'package:flutter/material.dart';

class UploadProvider extends ChangeNotifier {
  bool _isUploading = false;
  double _progress = 0.0;
  String _currentStep = '';
  Timer? _timer;

  bool get isUploading => _isUploading;
  double get progress => _progress;
  String get currentStep => _currentStep;

  void startMockUpload(VoidCallback onSuccess) {
    _isUploading = true;
    _progress = 0.0;
    _currentStep = 'Uploading document...';
    notifyListeners();

    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      _progress += 0.01;

      if (_progress >= 0.4 && _progress < 0.7) {
        _currentStep = 'Extracting text and layout...';
      } else if (_progress >= 0.7 && _progress < 0.9) {
        _currentStep = 'Generating AI embeddings...';
      } else if (_progress >= 0.9 && _progress < 1.0) {
        _currentStep = 'Finalizing analysis...';
      } else if (_progress >= 1.0) {
        _timer?.cancel();
        _isUploading = false;
        notifyListeners();
        onSuccess();
        return;
      }
      notifyListeners();
    });
  }

  void cancelUpload() {
    _timer?.cancel();
    _isUploading = false;
    _progress = 0.0;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
