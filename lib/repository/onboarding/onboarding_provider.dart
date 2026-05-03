import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum OnboardingStep { none, welcome, categories, done }

class OnboardingProvider with ChangeNotifier {
  OnboardingStep _currentStep = OnboardingStep.none;
  SharedPreferences? _prefs;

  OnboardingStep get currentStep => _currentStep;

  Future<void> init(SharedPreferences prefs) async {
    _prefs = prefs;
    bool isFirstRun = _prefs?.getBool('isFirstRun') ?? true;
    if (isFirstRun) {
      _currentStep = OnboardingStep.welcome;
    } else {
      _currentStep = OnboardingStep.done;
    }
    notifyListeners();
  }

  void moveToNextStep() {
    switch (_currentStep) {
      case OnboardingStep.welcome:
        _currentStep = OnboardingStep.categories;
        break;
      case OnboardingStep.categories:
        _currentStep = OnboardingStep.done;
        _completeOnboarding();
        break;
      default:
        break;
    }
    notifyListeners();
  }

  Future<void> _completeOnboarding() async {
    await _prefs?.setBool('isFirstRun', false);
  }
}
