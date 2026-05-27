class PeriodicPuzzleSlot {
  const PeriodicPuzzleSlot({
    required this.symbol,
    required this.row,
    required this.column,
  });

  final String symbol;
  final int row;
  final int column;
}

class PeriodicPuzzleGroupDefinition {
  const PeriodicPuzzleGroupDefinition({
    required this.key,
    required this.titleEnglish,
    required this.titleSpanish,
    required this.symbols,
  });

  final String key;
  final String titleEnglish;
  final String titleSpanish;
  final List<String> symbols;
}

const kStarterPuzzleSlots = <PeriodicPuzzleSlot>[
  PeriodicPuzzleSlot(symbol: 'H', row: 0, column: 0),
  PeriodicPuzzleSlot(symbol: 'He', row: 0, column: 10),
  PeriodicPuzzleSlot(symbol: 'Li', row: 1, column: 0),
  PeriodicPuzzleSlot(symbol: 'Be', row: 1, column: 1),
  PeriodicPuzzleSlot(symbol: 'B', row: 1, column: 6),
  PeriodicPuzzleSlot(symbol: 'C', row: 1, column: 7),
  PeriodicPuzzleSlot(symbol: 'N', row: 1, column: 8),
  PeriodicPuzzleSlot(symbol: 'O', row: 1, column: 9),
  PeriodicPuzzleSlot(symbol: 'F', row: 1, column: 10),
  PeriodicPuzzleSlot(symbol: 'Ne', row: 1, column: 11),
  PeriodicPuzzleSlot(symbol: 'Na', row: 2, column: 0),
  PeriodicPuzzleSlot(symbol: 'Mg', row: 2, column: 1),
  PeriodicPuzzleSlot(symbol: 'Al', row: 2, column: 6),
  PeriodicPuzzleSlot(symbol: 'Si', row: 2, column: 7),
  PeriodicPuzzleSlot(symbol: 'P', row: 2, column: 8),
  PeriodicPuzzleSlot(symbol: 'S', row: 2, column: 9),
  PeriodicPuzzleSlot(symbol: 'Cl', row: 2, column: 10),
  PeriodicPuzzleSlot(symbol: 'Ar', row: 2, column: 11),
  PeriodicPuzzleSlot(symbol: 'K', row: 3, column: 0),
  PeriodicPuzzleSlot(symbol: 'Ca', row: 3, column: 1),
];

const kLayerTwoGroups = <PeriodicPuzzleGroupDefinition>[
  PeriodicPuzzleGroupDefinition(
    key: 'noble-gases',
    titleEnglish: 'Noble Gases',
    titleSpanish: 'Gases nobles',
    symbols: ['He', 'Ne', 'Ar', 'Kr', 'Xe'],
  ),
  PeriodicPuzzleGroupDefinition(
    key: 'halogens',
    titleEnglish: 'Halogens',
    titleSpanish: 'Halógenos',
    symbols: ['F', 'Cl', 'Br', 'I'],
  ),
  PeriodicPuzzleGroupDefinition(
    key: 'alkali-metals',
    titleEnglish: 'Alkali Metals',
    titleSpanish: 'Metales alcalinos',
    symbols: ['Li', 'Na', 'K', 'Rb', 'Cs'],
  ),
  PeriodicPuzzleGroupDefinition(
    key: 'alkaline-earth-metals',
    titleEnglish: 'Alkaline Earth Metals',
    titleSpanish: 'Metales alcalinotérreos',
    symbols: ['Be', 'Mg', 'Ca', 'Sr', 'Ba'],
  ),
  PeriodicPuzzleGroupDefinition(
    key: 'common-nonmetals',
    titleEnglish: 'Common Nonmetals',
    titleSpanish: 'No metales comunes',
    symbols: ['H', 'C', 'N', 'O', 'P', 'S'],
  ),
];

const kMixedChallengeSlots = <PeriodicPuzzleSlot>[
  PeriodicPuzzleSlot(symbol: 'H', row: 0, column: 0),
  PeriodicPuzzleSlot(symbol: 'He', row: 0, column: 10),
  PeriodicPuzzleSlot(symbol: 'Li', row: 1, column: 0),
  PeriodicPuzzleSlot(symbol: 'C', row: 1, column: 6),
  PeriodicPuzzleSlot(symbol: 'N', row: 1, column: 7),
  PeriodicPuzzleSlot(symbol: 'O', row: 1, column: 8),
  PeriodicPuzzleSlot(symbol: 'F', row: 1, column: 9),
  PeriodicPuzzleSlot(symbol: 'Ne', row: 1, column: 10),
  PeriodicPuzzleSlot(symbol: 'Na', row: 2, column: 0),
  PeriodicPuzzleSlot(symbol: 'Mg', row: 2, column: 1),
  PeriodicPuzzleSlot(symbol: 'Al', row: 2, column: 5),
  PeriodicPuzzleSlot(symbol: 'Si', row: 2, column: 6),
  PeriodicPuzzleSlot(symbol: 'P', row: 2, column: 7),
  PeriodicPuzzleSlot(symbol: 'S', row: 2, column: 8),
  PeriodicPuzzleSlot(symbol: 'Cl', row: 2, column: 9),
  PeriodicPuzzleSlot(symbol: 'K', row: 3, column: 0),
  PeriodicPuzzleSlot(symbol: 'Ca', row: 3, column: 1),
  PeriodicPuzzleSlot(symbol: 'Fe', row: 3, column: 4),
  PeriodicPuzzleSlot(symbol: 'Cu', row: 3, column: 6),
  PeriodicPuzzleSlot(symbol: 'Zn', row: 3, column: 7),
  PeriodicPuzzleSlot(symbol: 'Ag', row: 4, column: 6),
  PeriodicPuzzleSlot(symbol: 'Au', row: 4, column: 7),
];
