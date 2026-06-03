import '../models/element_of_the_day_model.dart';

ElementOfTheDayModel buildMockElementOfTheDay({DateTime? date}) {
  return ElementOfTheDayModel(
    symbol: 'O',
    name: 'Oxygen',
    nameEs: 'Oxígeno',
    category: 'Nonmetal',
    categoryEs: 'No metal',
    atomicNumber: 8,
    atomicWeight: 15.999,
    group: 'Group 16',
    description:
        'Oxygen is a helpful gas in the air. We need it to breathe and stay active every day.',
    descriptionEs:
        'El oxígeno es un gas muy importante del aire. Lo necesitamos para respirar y tener energía cada día.',
    funFact:
        'About 21% of Earth\'s air is oxygen, and plants help make it for us.',
    funFactEs:
        'Cerca del 21% del aire de la Tierra es oxígeno, y las plantas nos ayudan a producirlo.',
    date: date ?? DateTime.now(),
    mascotAsset: null,
  );
}
