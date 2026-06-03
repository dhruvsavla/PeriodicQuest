import 'package:app/domain/elements/chemical_element.dart';
import 'package:app/domain/elements/element_translations_es.dart';
import 'package:app/domain/elements/periodic_table_data.dart';
import 'package:app/features/quiz/data/quiz_real_world_facts.dart';
import 'package:app/features/quiz/models/quiz_language.dart';
import 'package:app/features/quiz/models/quiz_question.dart';
import 'package:app/features/quiz/models/quiz_real_world_fact.dart';
import 'package:app/features/quiz/puzzle/data/periodic_puzzle_layout.dart';
import 'package:app/features/quiz/puzzle/models/periodic_puzzle_board.dart';
import 'package:app/features/quiz/puzzle/models/periodic_puzzle_layer.dart';
import 'package:app/features/quiz/puzzle/models/periodic_puzzle_tile.dart';

class PeriodicPuzzleGenerator {
  const PeriodicPuzzleGenerator({
    this.elements = kPeriodicElements,
    this.spanishTranslations = kElementTranslationsEs,
    this.realWorldFacts = kQuizRealWorldFacts,
  });

  final List<ChemicalElement> elements;
  final Map<int, EsTranslation> spanishTranslations;
  final List<QuizRealWorldFact> realWorldFacts;

  List<PeriodicPuzzleBoard> buildBoards() {
    return [_buildStarterBoard(), ..._buildGroupBoards(), _buildMixedBoard()];
  }

  List<PeriodicPuzzleBoard> boardsForLayer(PeriodicPuzzleLayer layer) {
    return buildBoards()
        .where((board) => board.layer == layer)
        .toList(growable: false);
  }

  PeriodicPuzzleBoard boardForId(String id) {
    return buildBoards().firstWhere((board) => board.id == id);
  }

  String localizedElementName(ChemicalElement element, QuizLanguage language) {
    return _localizedElementName(element, language);
  }

  PeriodicPuzzleBoard _buildStarterBoard() {
    const missingSymbols = ['H', 'He', 'O', 'Na', 'Cl', 'Ca'];
    const layerPool = [
      'H',
      'He',
      'Li',
      'Be',
      'B',
      'C',
      'N',
      'O',
      'F',
      'Ne',
      'Na',
      'Mg',
      'Al',
      'Si',
      'P',
      'S',
      'Cl',
      'Ar',
      'K',
      'Ca',
    ];

    return PeriodicPuzzleBoard(
      id: 'starter-board',
      layer: PeriodicPuzzleLayer.starter,
      titleEnglish: 'Layer 1: Starter Elements',
      titleSpanish: 'Nivel 1: Elementos iniciales',
      subtitleEnglish: 'Fill the missing starter tiles',
      subtitleSpanish: 'Completa las casillas iniciales que faltan',
      tiles: kStarterPuzzleSlots
          .map((slot) {
            final element = _elementBySymbol(slot.symbol);
            final clueType = switch (slot.symbol) {
              'H' => PeriodicPuzzleClueType.name,
              'He' => PeriodicPuzzleClueType.realWorld,
              'O' => PeriodicPuzzleClueType.atomicNumber,
              'Na' => PeriodicPuzzleClueType.symbol,
              'Cl' => PeriodicPuzzleClueType.realWorld,
              'Ca' => PeriodicPuzzleClueType.realWorld,
              _ => null,
            };
            return PeriodicPuzzleTile(
              element: element,
              row: slot.row,
              column: slot.column,
              clue: clueType == null
                  ? null
                  : _clueForElement(element, clueType),
              options: !missingSymbols.contains(slot.symbol)
                  ? const <QuizAnswerOption>[]
                  : _buildOptions(
                      correct: element,
                      clueType: clueType!,
                      poolSymbols: layerPool,
                    ),
            );
          })
          .toList(growable: false),
    );
  }

  List<PeriodicPuzzleBoard> _buildGroupBoards() {
    return kLayerTwoGroups
        .map((group) {
          final missingByGroup = <String, List<String>>{
            'noble-gases': ['He', 'Ne', 'Kr', 'Xe'],
            'halogens': ['F', 'Cl', 'Br', 'I'],
            'alkali-metals': ['Li', 'Na', 'Rb', 'Cs'],
            'alkaline-earth-metals': ['Be', 'Mg', 'Sr', 'Ba'],
            'common-nonmetals': ['H', 'C', 'O', 'S'],
          };

          final clueTypes = <String, PeriodicPuzzleClueType>{
            'He': PeriodicPuzzleClueType.realWorld,
            'Ne': PeriodicPuzzleClueType.realWorld,
            'Kr': PeriodicPuzzleClueType.symbol,
            'Xe': PeriodicPuzzleClueType.atomicNumber,
            'F': PeriodicPuzzleClueType.realWorld,
            'Cl': PeriodicPuzzleClueType.realWorld,
            'Br': PeriodicPuzzleClueType.name,
            'I': PeriodicPuzzleClueType.atomicNumber,
            'Li': PeriodicPuzzleClueType.realWorld,
            'Na': PeriodicPuzzleClueType.symbol,
            'Rb': PeriodicPuzzleClueType.name,
            'Cs': PeriodicPuzzleClueType.atomicNumber,
            'Be': PeriodicPuzzleClueType.name,
            'Mg': PeriodicPuzzleClueType.realWorld,
            'Sr': PeriodicPuzzleClueType.symbol,
            'Ba': PeriodicPuzzleClueType.atomicNumber,
            'H': PeriodicPuzzleClueType.name,
            'C': PeriodicPuzzleClueType.realWorld,
            'O': PeriodicPuzzleClueType.atomicNumber,
            'S': PeriodicPuzzleClueType.symbol,
          };

          return PeriodicPuzzleBoard(
            id: 'group-${group.key}',
            layer: PeriodicPuzzleLayer.groups,
            titleEnglish: 'Layer 2: Element Groups',
            titleSpanish: 'Nivel 2: Grupos de elementos',
            subtitleEnglish: 'Complete the ${group.titleEnglish}',
            subtitleSpanish: 'Completa ${group.titleSpanish}',
            groupKey: group.key,
            groupLabelEnglish: group.titleEnglish,
            groupLabelSpanish: group.titleSpanish,
            tiles: group.symbols
                .asMap()
                .entries
                .map((entry) {
                  final symbol = entry.value;
                  final element = _elementBySymbol(symbol);
                  final isMissing = missingByGroup[group.key]!.contains(symbol);
                  final clueType = isMissing ? clueTypes[symbol]! : null;
                  return PeriodicPuzzleTile(
                    element: element,
                    row: 0,
                    column: entry.key,
                    clue: isMissing
                        ? _clueForElement(element, clueType!)
                        : null,
                    options: isMissing
                        ? _buildOptions(
                            correct: element,
                            clueType: clueType!,
                            poolSymbols: group.symbols,
                          )
                        : const <QuizAnswerOption>[],
                  );
                })
                .toList(growable: false),
          );
        })
        .toList(growable: false);
  }

  PeriodicPuzzleBoard _buildMixedBoard() {
    const missingSymbols = [
      'He',
      'O',
      'Na',
      'Si',
      'Cl',
      'Fe',
      'Cu',
      'Ag',
      'Au',
    ];
    const mixedPool = [
      'H',
      'He',
      'Li',
      'C',
      'N',
      'O',
      'F',
      'Ne',
      'Na',
      'Mg',
      'Al',
      'Si',
      'P',
      'S',
      'Cl',
      'K',
      'Ca',
      'Fe',
      'Cu',
      'Zn',
      'Ag',
      'Au',
    ];
    final clueTypes = <String, PeriodicPuzzleClueType>{
      'He': PeriodicPuzzleClueType.realWorld,
      'O': PeriodicPuzzleClueType.symbol,
      'Na': PeriodicPuzzleClueType.atomicNumber,
      'Si': PeriodicPuzzleClueType.realWorld,
      'Cl': PeriodicPuzzleClueType.realWorld,
      'Fe': PeriodicPuzzleClueType.realWorld,
      'Cu': PeriodicPuzzleClueType.realWorld,
      'Ag': PeriodicPuzzleClueType.name,
      'Au': PeriodicPuzzleClueType.realWorld,
    };

    return PeriodicPuzzleBoard(
      id: 'mixed-board',
      layer: PeriodicPuzzleLayer.mixed,
      titleEnglish: 'Layer 3: Mixed Challenge',
      titleSpanish: 'Nivel 3: Desafío mixto',
      subtitleEnglish: 'Mix symbols, numbers, and real-world clues',
      subtitleSpanish: 'Combina símbolos, números y pistas del mundo real',
      tiles: kMixedChallengeSlots
          .map((slot) {
            final element = _elementBySymbol(slot.symbol);
            final isMissing = missingSymbols.contains(slot.symbol);
            final clueType = clueTypes[slot.symbol];
            return PeriodicPuzzleTile(
              element: element,
              row: slot.row,
              column: slot.column,
              clue: isMissing ? _clueForElement(element, clueType!) : null,
              options: isMissing
                  ? _buildOptions(
                      correct: element,
                      clueType: clueType!,
                      poolSymbols: mixedPool,
                    )
                  : const <QuizAnswerOption>[],
            );
          })
          .toList(growable: false),
    );
  }

  PeriodicPuzzleClue _clueForElement(
    ChemicalElement element,
    PeriodicPuzzleClueType clueType,
  ) {
    final spanishName = _localizedElementName(element, QuizLanguage.spanish);
    final realWorldFact = _realWorldFactForSymbol(element.sym);

    switch (clueType) {
      case PeriodicPuzzleClueType.name:
        return PeriodicPuzzleClue(
          type: clueType,
          english: 'Find the element named ${element.name}.',
          spanish: 'Encuentra el elemento llamado $spanishName.',
          hintEnglish: 'Its symbol is ${element.sym}.',
          hintSpanish: 'Su símbolo es ${element.sym}.',
          labelEnglish: 'Name clue',
          labelSpanish: 'Pista de nombre',
        );
      case PeriodicPuzzleClueType.symbol:
        return PeriodicPuzzleClue(
          type: clueType,
          english: 'Find the element with symbol ${element.sym}.',
          spanish: 'Encuentra el elemento con el símbolo ${element.sym}.',
          hintEnglish: 'Its name starts with ${_firstLetter(element.name)}.',
          hintSpanish: 'Su nombre empieza con ${_firstLetter(spanishName)}.',
          labelEnglish: 'Symbol clue',
          labelSpanish: 'Pista de símbolo',
        );
      case PeriodicPuzzleClueType.atomicNumber:
        return PeriodicPuzzleClue(
          type: clueType,
          english: 'Find the element with atomic number ${element.z}.',
          spanish: 'Encuentra el elemento con número atómico ${element.z}.',
          hintEnglish: 'Its symbol starts with ${_firstLetter(element.sym)}.',
          hintSpanish: 'Su símbolo empieza con ${_firstLetter(element.sym)}.',
          labelEnglish: 'Atomic clue',
          labelSpanish: 'Pista atómica',
        );
      case PeriodicPuzzleClueType.position:
        return PeriodicPuzzleClue(
          type: clueType,
          english: 'Fill the missing tile in this position.',
          spanish: 'Completa la casilla faltante en esta posición.',
          hintEnglish: 'Its symbol is ${element.sym}.',
          hintSpanish: 'Su símbolo es ${element.sym}.',
          labelEnglish: 'Position clue',
          labelSpanish: 'Pista de posición',
        );
      case PeriodicPuzzleClueType.realWorld:
        return PeriodicPuzzleClue(
          type: clueType,
          english:
              realWorldFact?.clueEnglish ??
              'Find the element that matches this real-world clue.',
          spanish:
              realWorldFact?.clueSpanish ??
              'Encuentra el elemento que coincide con esta pista del mundo real.',
          hintEnglish:
              realWorldFact?.hintEnglish ??
              'Its symbol starts with ${_firstLetter(element.sym)}.',
          hintSpanish:
              realWorldFact?.hintSpanish ??
              'Su símbolo empieza con ${_firstLetter(element.sym)}.',
          labelEnglish: 'Real-world clue',
          labelSpanish: 'Pista del mundo real',
        );
    }
  }

  List<QuizAnswerOption> _buildOptions({
    required ChemicalElement correct,
    required PeriodicPuzzleClueType clueType,
    required List<String> poolSymbols,
  }) {
    final selectedSymbols = <String>[correct.sym];
    for (final candidate in poolSymbols) {
      if (candidate == correct.sym || selectedSymbols.contains(candidate)) {
        continue;
      }
      selectedSymbols.add(candidate);
      if (selectedSymbols.length == 4) {
        break;
      }
    }

    return selectedSymbols
        .map((symbol) => _optionForElement(_elementBySymbol(symbol), clueType))
        .toList(growable: false);
  }

  QuizAnswerOption _optionForElement(
    ChemicalElement element,
    PeriodicPuzzleClueType clueType,
  ) {
    final spanishName = _localizedElementName(element, QuizLanguage.spanish);

    switch (clueType) {
      case PeriodicPuzzleClueType.name:
        return QuizAnswerOption(
          id: element.sym,
          labelEnglish: element.sym,
          labelSpanish: element.sym,
          elementSymbol: element.sym,
          categoryKey: element.cat,
        );
      case PeriodicPuzzleClueType.symbol:
      case PeriodicPuzzleClueType.atomicNumber:
      case PeriodicPuzzleClueType.position:
      case PeriodicPuzzleClueType.realWorld:
        return QuizAnswerOption(
          id: element.sym,
          labelEnglish: element.name,
          labelSpanish: spanishName,
          elementSymbol: element.sym,
          atomicNumber: element.z,
          categoryKey: element.cat,
        );
    }
  }

  ChemicalElement _elementBySymbol(String symbol) {
    return elements.firstWhere((element) => element.sym == symbol);
  }

  String _localizedElementName(ChemicalElement element, QuizLanguage language) {
    if (language == QuizLanguage.english) {
      return element.name;
    }
    return spanishTranslations[element.z]?.name ?? element.name;
  }

  QuizRealWorldFact? _realWorldFactForSymbol(String symbol) {
    for (final fact in realWorldFacts) {
      if (fact.elementSymbol == symbol) {
        return fact;
      }
    }
    return null;
  }

  String _firstLetter(String value) {
    return value.isEmpty ? '?' : value.substring(0, 1);
  }
}
