enum PeriodicPuzzleLayer { starter, groups, mixed }

extension PeriodicPuzzleLayerX on PeriodicPuzzleLayer {
  int get order => switch (this) {
    PeriodicPuzzleLayer.starter => 1,
    PeriodicPuzzleLayer.groups => 2,
    PeriodicPuzzleLayer.mixed => 3,
  };

  String get id => switch (this) {
    PeriodicPuzzleLayer.starter => 'starter',
    PeriodicPuzzleLayer.groups => 'groups',
    PeriodicPuzzleLayer.mixed => 'mixed',
  };
}
