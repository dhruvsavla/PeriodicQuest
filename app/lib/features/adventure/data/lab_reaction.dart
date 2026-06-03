class LabReaction {
  final int zA;
  final int zB;
  final String compound;
  final String formula;
  final String fact;
  final String emoji;

  const LabReaction({
    required this.zA,
    required this.zB,
    required this.compound,
    required this.formula,
    required this.fact,
    required this.emoji,
  });
}

LabReaction? findLabReaction(int zA, int zB) {
  for (final r in kLabReactions) {
    if ((r.zA == zA && r.zB == zB) || (r.zA == zB && r.zB == zA)) {
      return r;
    }
  }
  return null;
}

const kLabReactions = <LabReaction>[
  LabReaction(
    zA: 1,
    zB: 8,
    compound: 'Water',
    formula: 'H₂O',
    fact: 'Water covers 71% of Earth\'s surface and is essential for all known life.',
    emoji: '💧',
  ),
  LabReaction(
    zA: 11,
    zB: 17,
    compound: 'Table Salt',
    formula: 'NaCl',
    fact:
        'Roman soldiers were sometimes paid in salt — giving us the word "salary".',
    emoji: '🧂',
  ),
  LabReaction(
    zA: 1,
    zB: 17,
    compound: 'Hydrochloric Acid',
    formula: 'HCl',
    fact: 'Your stomach produces hydrochloric acid to digest food and kill bacteria.',
    emoji: '🧪',
  ),
  LabReaction(
    zA: 6,
    zB: 8,
    compound: 'Carbon Dioxide',
    formula: 'CO₂',
    fact: 'Plants use carbon dioxide and sunlight to make oxygen through photosynthesis.',
    emoji: '🌿',
  ),
  LabReaction(
    zA: 7,
    zB: 1,
    compound: 'Ammonia',
    formula: 'NH₃',
    fact:
        'Ammonia-based fertilizers grow food for roughly half the world\'s population.',
    emoji: '🌾',
  ),
  LabReaction(
    zA: 26,
    zB: 8,
    compound: 'Iron Oxide (Rust)',
    formula: 'Fe₂O₃',
    fact: 'The same rusting process that weakens iron colored Mars\'s surface red.',
    emoji: '🟤',
  ),
  LabReaction(
    zA: 12,
    zB: 8,
    compound: 'Magnesium Oxide',
    formula: 'MgO',
    fact:
        'Magnesium burns so brightly in oxygen it was used in early camera flash bulbs.',
    emoji: '✨',
  ),
  LabReaction(
    zA: 16,
    zB: 8,
    compound: 'Sulfur Dioxide',
    formula: 'SO₂',
    fact: 'Volcanic sulfur dioxide dissolves in clouds to produce acid rain.',
    emoji: '🌋',
  ),
  LabReaction(
    zA: 20,
    zB: 8,
    compound: 'Quicklime',
    formula: 'CaO',
    fact: 'Quicklime has been a key ingredient in cement for over 7,000 years.',
    emoji: '🏗️',
  ),
  LabReaction(
    zA: 20,
    zB: 17,
    compound: 'Calcium Chloride',
    formula: 'CaCl₂',
    fact: 'Calcium chloride de-ices roads in winter and appears in some sports drinks.',
    emoji: '❄️',
  ),
  LabReaction(
    zA: 11,
    zB: 8,
    compound: 'Sodium Oxide',
    formula: 'Na₂O',
    fact: 'Sodium oxide reacts violently with water to form a powerful base.',
    emoji: '💥',
  ),
  LabReaction(
    zA: 14,
    zB: 8,
    compound: 'Silicon Dioxide',
    formula: 'SiO₂',
    fact: 'Ordinary sand is mostly silicon dioxide — the same substance as glass.',
    emoji: '🪟',
  ),
  LabReaction(
    zA: 13,
    zB: 8,
    compound: 'Aluminium Oxide',
    formula: 'Al₂O₃',
    fact: 'Rubies and sapphires are aluminium oxide crystals — color from trace impurities.',
    emoji: '💎',
  ),
  LabReaction(
    zA: 29,
    zB: 8,
    compound: 'Copper Oxide',
    formula: 'CuO',
    fact:
        'The Statue of Liberty\'s green patina is copper oxide — it protects the metal.',
    emoji: '🗽',
  ),
  LabReaction(
    zA: 26,
    zB: 16,
    compound: 'Iron Sulfide',
    formula: 'FeS',
    fact: 'Fool\'s gold (iron pyrite) is a form of iron sulfide — it fooled many miners.',
    emoji: '🪨',
  ),
  LabReaction(
    zA: 19,
    zB: 17,
    compound: 'Potassium Chloride',
    formula: 'KCl',
    fact: 'Potassium chloride is used as a low-sodium salt substitute.',
    emoji: '🧴',
  ),
  LabReaction(
    zA: 6,
    zB: 1,
    compound: 'Methane',
    formula: 'CH₄',
    fact: 'Methane is the main component of natural gas and is produced by cattle.',
    emoji: '🔥',
  ),
  LabReaction(
    zA: 30,
    zB: 8,
    compound: 'Zinc Oxide',
    formula: 'ZnO',
    fact: 'Zinc oxide is the white sunscreen used by lifeguards against UVA and UVB.',
    emoji: '☀️',
  ),
  LabReaction(
    zA: 3,
    zB: 8,
    compound: 'Lithium Oxide',
    formula: 'Li₂O',
    fact: 'Lithium oxide is used in specialty glass for telescopes and LCD displays.',
    emoji: '🔭',
  ),
  LabReaction(
    zA: 19,
    zB: 8,
    compound: 'Potassium Oxide',
    formula: 'K₂O',
    fact: 'Potassium ignites spontaneously in air, burning with a vivid purple flame.',
    emoji: '🔥',
  ),
];
