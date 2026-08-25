class OnboardingState {
  final bool completed;
  final String displayName;
  final String creatorCategory;
  final List<String> goals;
  final List<String> selectedPlatforms;

  const OnboardingState({
    this.completed = false,
    this.displayName = '',
    this.creatorCategory = '',
    this.goals = const [],
    this.selectedPlatforms = const [],
  });

  OnboardingState copyWith({
    bool? completed,
    String? displayName,
    String? creatorCategory,
    List<String>? goals,
    List<String>? selectedPlatforms,
  }) {
    return OnboardingState(
      completed: completed ?? this.completed,
      displayName: displayName ?? this.displayName,
      creatorCategory: creatorCategory ?? this.creatorCategory,
      goals: goals ?? this.goals,
      selectedPlatforms: selectedPlatforms ?? this.selectedPlatforms,
    );
  }
}
