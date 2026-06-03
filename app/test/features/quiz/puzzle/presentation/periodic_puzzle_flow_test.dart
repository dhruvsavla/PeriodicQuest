import 'package:app/features/quiz/presentation/quiz_home_page.dart';
import 'package:app/features/quiz/models/quiz_language.dart';
import 'package:app/features/quiz/puzzle/data/periodic_puzzle_best_times_repository.dart';
import 'package:app/features/quiz/puzzle/data/periodic_puzzle_generator.dart';
import 'package:app/features/quiz/puzzle/data/periodic_puzzle_progress_repository.dart';
import 'package:app/features/quiz/puzzle/models/periodic_puzzle_layer.dart';
import 'package:app/features/quiz/puzzle/presentation/periodic_puzzle_game_page.dart';
import 'package:app/features/quiz/puzzle/presentation/periodic_puzzle_home_page.dart';
import 'package:app/features/quiz/puzzle/presentation/periodic_puzzle_result_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const _defaultTestSize = Size(1194, 834);

Future<void> _pumpResponsiveApp(
  WidgetTester tester,
  Widget home, {
  Size? size,
}) async {
  final targetSize = size ?? _defaultTestSize;
  tester.view
    ..physicalSize = targetSize
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(834, 1194),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MaterialApp(home: child),
      child: home,
    ),
  );
}

void main() {
  const generator = PeriodicPuzzleGenerator();

  testWidgets(
    'Puzzle screens keep back button near top in portrait and landscape',
    (tester) async {
      final board = generator
          .boardsForLayer(PeriodicPuzzleLayer.starter)
          .single;
      final sizes = <Size>[const Size(834, 1194), const Size(1194, 834)];

      for (final size in sizes) {
        await _pumpResponsiveApp(
          tester,
          const PeriodicPuzzleHomePage(),
          size: size,
        );
        await tester.pumpAndSettle();

        final homeBackButton = find.text('Back to quiz menu');
        expect(homeBackButton, findsOneWidget);
        expect(tester.getTopLeft(homeBackButton).dy, lessThan(140));

        await _pumpResponsiveApp(tester, PeriodicPuzzleGamePage(board: board));
        await tester.pumpAndSettle();

        final gameBackButton = find.text('Back to quiz menu');
        expect(gameBackButton, findsOneWidget);
        expect(tester.getTopLeft(gameBackButton).dy, lessThan(140));
      }
    },
  );

  testWidgets('QuizHomePage shows Periodic Puzzle card and opens it', (
    tester,
  ) async {
    await _pumpResponsiveApp(tester, const QuizHomePage());

    final periodicPuzzleFinder = find.text('Periodic Puzzle');
    expect(periodicPuzzleFinder, findsOneWidget);
    await tester.ensureVisible(periodicPuzzleFinder);
    await tester.tap(periodicPuzzleFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Layer 1: Starter Elements'), findsOneWidget);
  });

  testWidgets('Puzzle game displays a timer and language switch keeps it', (
    tester,
  ) async {
    var now = DateTime(2026, 5, 20, 12, 0, 0);
    final repository = PeriodicPuzzleProgressRepository(clock: () => now);
    final board = generator.boardsForLayer(PeriodicPuzzleLayer.starter).single;

    await _pumpResponsiveApp(
      tester,
      PeriodicPuzzleGamePage(board: board, progressRepository: repository),
    );

    expect(find.text('Time: 00:00'), findsOneWidget);

    now = now.add(const Duration(seconds: 5));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Time: 00:05'), findsOneWidget);

    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();

    expect(find.text('Tiempo: 00:05'), findsOneWidget);
  });

  testWidgets(
    'Puzzle home starts with Layer 1 unlocked and Layers 2/3 locked',
    (tester) async {
      await _pumpResponsiveApp(tester, const PeriodicPuzzleHomePage());

      expect(find.text('Unlocked'), findsOneWidget);
      expect(find.text('Locked'), findsNWidgets(2));
    },
  );

  testWidgets('Language toggle updates puzzle home labels to Spanish', (
    tester,
  ) async {
    await _pumpResponsiveApp(tester, const PeriodicPuzzleHomePage());

    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();

    expect(find.text('Nivel 1: Elementos iniciales'), findsOneWidget);
    expect(find.text('Volver al menú del quiz'), findsOneWidget);
  });

  testWidgets('Starting Layer 1 shows the puzzle board and answer options', (
    tester,
  ) async {
    final board = generator.boardsForLayer(PeriodicPuzzleLayer.starter).single;

    await _pumpResponsiveApp(tester, PeriodicPuzzleGamePage(board: board));

    expect(find.text('Fill this tile'), findsOneWidget);
    expect(find.byKey(const Key('puzzle-option-H')), findsOneWidget);
  });

  testWidgets('Selecting correct option fills the tile', (tester) async {
    final board = generator.boardsForLayer(PeriodicPuzzleLayer.starter).single;

    await _pumpResponsiveApp(tester, PeriodicPuzzleGamePage(board: board));

    final correctOption = find.byKey(const Key('puzzle-option-H'));
    await tester.ensureVisible(correctOption);
    await tester.tap(correctOption);
    await tester.pumpAndSettle();

    expect(find.text('Correct!'), findsOneWidget);
    expect(find.text('Hydrogen'), findsWidgets);
  });

  testWidgets(
    'Selecting wrong option does not fill the tile and updates mistakes',
    (tester) async {
      final repository = PeriodicPuzzleProgressRepository();
      final board = generator
          .boardsForLayer(PeriodicPuzzleLayer.starter)
          .single;

      await _pumpResponsiveApp(
        tester,
        PeriodicPuzzleGamePage(board: board, progressRepository: repository),
      );

      final wrongOption = find.byKey(const Key('puzzle-option-He'));
      await tester.ensureVisible(wrongOption);
      await tester.tap(wrongOption);
      await tester.pumpAndSettle();

      expect(repository.progressForBoard(board).mistakes, 1);
      expect(repository.progressForBoard(board).isFilled('H'), isFalse);
      expect(find.text('Hydrogen'), findsNothing);
    },
  );

  testWidgets('Completing a board shows completion UI', (tester) async {
    final repository = PeriodicPuzzleProgressRepository();
    final board = generator.boardsForLayer(PeriodicPuzzleLayer.starter).single;

    for (final tile in board.missingTiles.skip(1)) {
      repository.submitAnswer(
        board: board,
        tileSymbol: tile.id,
        selectedOptionId: tile.id,
      );
    }

    await _pumpResponsiveApp(
      tester,
      PeriodicPuzzleGamePage(board: board, progressRepository: repository),
    );

    final finalOption = find.byKey(const Key('puzzle-option-H'));
    await tester.ensureVisible(finalOption);
    await tester.tap(finalOption);
    await tester.pumpAndSettle();

    expect(find.text('Puzzle complete!'), findsOneWidget);
    expect(find.byKey(const Key('puzzle-finish-board')), findsOneWidget);
  });

  testWidgets('Next layer button appears after completing Layer 1', (
    tester,
  ) async {
    final repository = PeriodicPuzzleProgressRepository();
    final board = generator.boardsForLayer(PeriodicPuzzleLayer.starter).single;

    for (final tile in board.missingTiles) {
      repository.submitAnswer(
        board: board,
        tileSymbol: tile.id,
        selectedOptionId: tile.id,
      );
    }
    repository.completeBoard(board: board, siblingBoardIds: [board.id]);

    await _pumpResponsiveApp(
      tester,
      PeriodicPuzzleResultPage(board: board, progressRepository: repository),
    );

    expect(find.byKey(const Key('puzzle-next-layer')), findsOneWidget);
  });

  testWidgets('Next group button appears after an early Layer 2 group board', (
    tester,
  ) async {
    final repository = PeriodicPuzzleProgressRepository();
    final board = generator.boardsForLayer(PeriodicPuzzleLayer.groups).first;

    for (final tile in board.missingTiles) {
      repository.submitAnswer(
        board: board,
        tileSymbol: tile.id,
        selectedOptionId: tile.id,
      );
    }
    repository.completeBoard(
      board: board,
      siblingBoardIds: generator
          .boardsForLayer(PeriodicPuzzleLayer.groups)
          .map((item) => item.id)
          .toList(),
    );

    await _pumpResponsiveApp(
      tester,
      PeriodicPuzzleResultPage(board: board, progressRepository: repository),
    );

    expect(find.byKey(const Key('puzzle-next-group')), findsOneWidget);
  });

  testWidgets('Final puzzle result shows Best Times and can save a new time', (
    tester,
  ) async {
    var now = DateTime(2026, 5, 20, 12, 0, 0);
    final repository = PeriodicPuzzleProgressRepository(clock: () => now);
    final bestTimesRepository = PeriodicPuzzleBestTimesRepository(
      clock: () => now,
    );
    final allBoards = generator.buildBoards();

    repository.startRunIfNeeded();
    for (final board in allBoards) {
      for (final tile in board.missingTiles) {
        repository.submitAnswer(
          board: board,
          tileSymbol: tile.id,
          selectedOptionId: tile.id,
        );
      }
      now = now.add(const Duration(seconds: 25));
      repository.completeBoard(
        board: board,
        siblingBoardIds: generator
            .boardsForLayer(board.layer)
            .map((item) => item.id)
            .toList(),
      );
    }

    await _pumpResponsiveApp(
      tester,
      PeriodicPuzzleResultPage(
        board: generator.boardsForLayer(PeriodicPuzzleLayer.mixed).single,
        progressRepository: repository,
        bestTimesRepository: bestTimesRepository,
        initialLanguage: QuizLanguage.english,
      ),
    );

    expect(find.text('Best Times'), findsOneWidget);
    expect(find.text('New best time!'), findsOneWidget);
    expect(find.text('Total time: 02:55'), findsNWidgets(2));

    await tester.enterText(find.byType(TextField), 'HARSH');
    final saveTimeFinder = find.text('Save time');
    await tester.ensureVisible(saveTimeFinder);
    await tester.tap(saveTimeFinder);
    await tester.pumpAndSettle();

    expect(find.text('HARSH'), findsOneWidget);

    final spanishFinder = find.text('Español');
    await tester.ensureVisible(spanishFinder);
    await tester.tap(spanishFinder);
    await tester.pumpAndSettle();

    expect(find.text('Mejores tiempos'), findsOneWidget);
    expect(find.text('Tiempo total: 02:55'), findsNWidgets(2));
  });
}
