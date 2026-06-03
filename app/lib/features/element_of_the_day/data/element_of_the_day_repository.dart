import '../../../domain/elements/element_translations_es.dart';
import '../../elements_catalog/data/element_catalog_repository.dart';
import '../models/element_of_the_day_model.dart';

class ElementOfTheDayRepository {
  const ElementOfTheDayRepository({
    this.catalogRepository = const ElementCatalogRepository(),
  });

  final ElementCatalogRepository catalogRepository;

  ElementOfTheDayModel elementForDate(DateTime date) {
    final elements = catalogRepository.allElements;
    if (elements.isEmpty) {
      throw StateError('No elements available to build element of the day.');
    }

    final utcDay = DateTime.utc(date.year, date.month, date.day);
    final dayIndex =
        utcDay.millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
    final selected = elements[dayIndex % elements.length];
    final es = kElementTranslationsEs[selected.z];

    final categoryEn = _categoryLabel(selected.cat, spanish: false);
    final categoryEs = _categoryLabel(selected.cat, spanish: true);

    return ElementOfTheDayModel(
      symbol: selected.sym,
      name: selected.name,
      nameEs: es?.name,
      category: categoryEn,
      categoryEs: categoryEs,
      atomicNumber: selected.z,
      atomicWeight: selected.mass,
      group: _groupTextForElement(selected.z, categoryEn),
      description: selected.desc,
      descriptionEs: es?.desc,
      funFact: selected.fact,
      funFactEs: es?.fact,
      date: utcDay,
      mascotAsset: null,
    );
  }

  String _categoryLabel(String cat, {required bool spanish}) {
    switch (cat) {
      case 'alkali':
        return spanish ? 'Metal alcalino' : 'Alkali metal';
      case 'alkaline':
        return spanish ? 'Alcalinotérreo' : 'Alkaline earth';
      case 'transition':
        return spanish ? 'Metal de transición' : 'Transition metal';
      case 'post':
        return spanish ? 'Metal post-transición' : 'Post-transition';
      case 'metalloid':
        return spanish ? 'Metaloide' : 'Metalloid';
      case 'nonmetal':
        return spanish ? 'No metal' : 'Nonmetal';
      case 'halogen':
        return spanish ? 'Halógeno' : 'Halogen';
      case 'noble':
        return spanish ? 'Gas noble' : 'Noble gas';
      case 'lanthanide':
        return spanish ? 'Lantánido' : 'Lanthanide';
      case 'actinide':
        return spanish ? 'Actínido' : 'Actinide';
      default:
        return spanish ? 'Elemento' : 'Element';
    }
  }

  String _groupTextForElement(int atomicNumber, String fallbackCategory) {
    const knownGroups = <int, String>{
      1: 'Group 1',
      2: 'Group 18',
      3: 'Group 1',
      4: 'Group 2',
      5: 'Group 13',
      6: 'Group 14',
      7: 'Group 15',
      8: 'Group 16',
      9: 'Group 17',
      10: 'Group 18',
      11: 'Group 1',
      12: 'Group 2',
      13: 'Group 13',
      14: 'Group 14',
      15: 'Group 15',
      16: 'Group 16',
      17: 'Group 17',
      18: 'Group 18',
      19: 'Group 1',
      20: 'Group 2',
    };
    return knownGroups[atomicNumber] ?? fallbackCategory;
  }
}
