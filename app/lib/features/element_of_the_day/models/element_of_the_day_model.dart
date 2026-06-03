class ElementOfTheDayModel {
  const ElementOfTheDayModel({
    required this.symbol,
    required this.name,
    this.nameEs,
    required this.category,
    this.categoryEs,
    required this.atomicNumber,
    required this.atomicWeight,
    required this.group,
    required this.description,
    this.descriptionEs,
    required this.funFact,
    this.funFactEs,
    required this.date,
    this.mascotAsset,
  });

  final String symbol;
  final String name;
  final String? nameEs;
  final String category;
  final String? categoryEs;
  final int atomicNumber;
  final double atomicWeight;
  final String group;
  final String description;
  final String? descriptionEs;
  final String funFact;
  final String? funFactEs;
  final DateTime date;
  final String? mascotAsset;
}
