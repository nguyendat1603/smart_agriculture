import 'package:flutter/material.dart';
import 'dart:io';
import '../services/ai_analysis_service.dart';

enum AnalysisState { idle, loading, success, error }

class HealthAnalysisViewModel extends ChangeNotifier {
  final AIAnalysisService _aiService = AIAnalysisService();

  File? _selectedImage;
  File? get selectedImage => _selectedImage;

  AnalysisState _state = AnalysisState.idle;
  AnalysisState get state => _state;

  AIAnalysisResult? _result;
  AIAnalysisResult? get result => _result;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  void setImage(File image) {
    _selectedImage = image;
    _state = AnalysisState.idle;
    _result = null;
    notifyListeners();
  }

  Future<void> analyzeImage() async {
    if (_selectedImage == null) return;

    _state = AnalysisState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _result = await _aiService.analyzeImage(_selectedImage!);
      _state = AnalysisState.success;
    } catch (e) {
      _state = AnalysisState.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  void reset() {
    _selectedImage = null;
    _result = null;
    _state = AnalysisState.idle;
    _errorMessage = '';
    notifyListeners();
  }
}
