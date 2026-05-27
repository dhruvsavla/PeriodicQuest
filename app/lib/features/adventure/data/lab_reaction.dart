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

/// Returns the matching reaction for two atomic numbers, order-independent.
LabReaction? findLabReaction(int zA, int zB) {
  final lo = zA < zB ? zA : zB;
  final hi = zA < zB ? zB : zA;
  for (final r in kLabReactions) {
    final rlo = r.zA < r.zB ? r.zA : r.zB;
    final rhi = r.zA < r.zB ? r.zB : r.zA;
    if (rlo == lo && rhi == hi) return r;
  }
  return null;
}

const kLabReactions = <LabReaction>[
  // ── Same-element diatomic molecules ──────────────────────────────────────
  LabReaction(
    zA: 1,
    zB: 1,
    compound: 'Hydrogen Gas',
    formula: 'H₂',
    emoji: '⚡',
    fact:
        'Hydrogen gas is the lightest substance on Earth and the fuel used in rocket engines.',
  ),
  LabReaction(
    zA: 7,
    zB: 7,
    compound: 'Nitrogen Gas',
    formula: 'N₂',
    emoji: '💨',
    fact:
        'Nitrogen gas makes up 78 % of the air you breathe and is used to preserve fresh food.',
  ),
  LabReaction(
    zA: 8,
    zB: 8,
    compound: 'Oxygen Gas',
    formula: 'O₂',
    emoji: '🌬️',
    fact:
        'Oxygen gas is what keeps you alive! It makes up 21 % of Earth\'s atmosphere.',
  ),
  LabReaction(
    zA: 17,
    zB: 17,
    compound: 'Chlorine Gas',
    formula: 'Cl₂',
    emoji: '🟡',
    fact:
        'Chlorine gas has a sharp smell and is used in tiny amounts to keep drinking water safe.',
  ),
  // ── Classic two-element compounds ────────────────────────────────────────
  LabReaction(
    zA: 1,
    zB: 8,
    compound: 'Water',
    formula: 'H₂O',
    emoji: '💧',
    fact:
        'Water covers 71 % of Earth\'s surface and is essential for all known life.',
  ),
  LabReaction(
    zA: 11,
    zB: 17,
    compound: 'Table Salt',
    formula: 'NaCl',
    emoji: '🧂',
    fact:
        'Table salt was once used as currency — the word "salary" actually comes from salt!',
  ),
  LabReaction(
    zA: 26,
    zB: 8,
    compound: 'Rust',
    formula: 'Fe₂O₃',
    emoji: '🔶',
    fact:
        'Rust slowly weakens iron structures over time as oxygen reacts with the metal.',
  ),
  LabReaction(
    zA: 6,
    zB: 8,
    compound: 'Carbon Dioxide',
    formula: 'CO₂',
    emoji: '💨',
    fact:
        'Plants absorb carbon dioxide and use sunlight to make food through photosynthesis.',
  ),
  LabReaction(
    zA: 1,
    zB: 7,
    compound: 'Ammonia',
    formula: 'NH₃',
    emoji: '🌿',
    fact:
        'Ammonia is used in fertilizers that help grow food for billions of people worldwide.',
  ),
  LabReaction(
    zA: 20,
    zB: 8,
    compound: 'Quicklime',
    formula: 'CaO',
    emoji: '🏗️',
    fact:
        'Quicklime has been used in construction for over 7,000 years and gives concrete strength.',
  ),
  LabReaction(
    zA: 1,
    zB: 17,
    compound: 'Hydrochloric Acid',
    formula: 'HCl',
    emoji: '⚗️',
    fact:
        'Your stomach naturally makes hydrochloric acid to help break down food you eat!',
  ),
  LabReaction(
    zA: 12,
    zB: 8,
    compound: 'Magnesium Oxide',
    formula: 'MgO',
    emoji: '✨',
    fact:
        'Magnesium oxide burns with a brilliant white flame so bright it was used in early camera flashes.',
  ),
  LabReaction(
    zA: 16,
    zB: 8,
    compound: 'Sulfur Dioxide',
    formula: 'SO₂',
    emoji: '🌋',
    fact:
        'Sulfur dioxide is released by volcanoes and can create acid rain when it enters clouds.',
  ),
  LabReaction(
    zA: 7,
    zB: 8,
    compound: 'Nitric Oxide',
    formula: 'NO',
    emoji: '❤️',
    fact:
        'Nitric oxide is a tiny signal molecule in your body that helps keep blood pressure healthy.',
  ),
  LabReaction(
    zA: 14,
    zB: 8,
    compound: 'Silicon Dioxide',
    formula: 'SiO₂',
    emoji: '📱',
    fact:
        'Silicon dioxide is ordinary sand and glass — the very material your phone screen is made from!',
  ),
  LabReaction(
    zA: 1,
    zB: 16,
    compound: 'Hydrogen Sulfide',
    formula: 'H₂S',
    emoji: '🥚',
    fact:
        'Hydrogen sulfide smells exactly like rotten eggs and bubbles up near volcanoes and swamps.',
  ),
  LabReaction(
    zA: 13,
    zB: 8,
    compound: 'Aluminium Oxide',
    formula: 'Al₂O₃',
    emoji: '💎',
    fact:
        'Rubies and sapphires are just coloured aluminium oxide — those precious gems are really Al₂O₃!',
  ),
  LabReaction(
    zA: 29,
    zB: 8,
    compound: 'Copper Oxide',
    formula: 'CuO',
    emoji: '🟤',
    fact:
        'Copper oxide is why old copper roofs and the Statue of Liberty turned their famous green colour.',
  ),
  LabReaction(
    zA: 30,
    zB: 8,
    compound: 'Zinc Oxide',
    formula: 'ZnO',
    emoji: '☀️',
    fact:
        'Zinc oxide is the white cream lifeguards put on their noses to block the sun\'s harmful UV rays.',
  ),
  LabReaction(
    zA: 47,
    zB: 16,
    compound: 'Silver Sulfide',
    formula: 'Ag₂S',
    emoji: '⚫',
    fact:
        'Silver sulfide is what makes silver jewellery turn black over time — this darkening is called tarnish.',
  ),
  LabReaction(
    zA: 19,
    zB: 8,
    compound: 'Potassium Oxide',
    formula: 'K₂O',
    emoji: '🌾',
    fact:
        'Potassium compounds are key ingredients in fertilisers that help crops grow tall and strong.',
  ),
  LabReaction(
    zA: 3,
    zB: 8,
    compound: 'Lithium Oxide',
    formula: 'Li₂O',
    emoji: '🔋',
    fact:
        'Lithium oxide is used in specialty glass that can survive extreme temperature changes without cracking.',
  ),
  LabReaction(
    zA: 6,
    zB: 1,
    compound: 'Methane',
    formula: 'CH₄',
    emoji: '🔥',
    fact:
        'Methane is natural gas — the clean-burning fuel used in stoves and heaters around the world.',
  ),
  LabReaction(
    zA: 26,
    zB: 16,
    compound: 'Iron Pyrite',
    formula: 'FeS₂',
    emoji: '🪙',
    fact:
        'Iron pyrite is fool\'s gold — the shiny golden mineral that tricked many excited gold prospectors!',
  ),
  LabReaction(
    zA: 20,
    zB: 6,
    compound: 'Calcium Carbide',
    formula: 'CaC₂',
    emoji: '🔦',
    fact:
        'Calcium carbide reacts with water to produce acetylene gas, which powers welding torches.',
  ),
  LabReaction(
    zA: 1,
    zB: 9,
    compound: 'Hydrofluoric Acid',
    formula: 'HF',
    emoji: '💻',
    fact:
        'Hydrofluoric acid etches glass and is used to make the silicon chips inside computers.',
  ),
  LabReaction(
    zA: 15,
    zB: 8,
    compound: 'Phosphorus Pentoxide',
    formula: 'P₂O₅',
    emoji: '🌱',
    fact:
        'Phosphorus pentoxide is a powerful drying agent and a vital ingredient in crop fertilisers.',
  ),
  LabReaction(
    zA: 6,
    zB: 16,
    compound: 'Carbon Disulfide',
    formula: 'CS₂',
    emoji: '🌋',
    fact:
        'Carbon disulfide is used to make rayon fabric and is found near active volcanoes.',
  ),
  LabReaction(
    zA: 22,
    zB: 8,
    compound: 'Titanium Dioxide',
    formula: 'TiO₂',
    emoji: '🎨',
    fact:
        'Titanium dioxide is the brilliant white pigment in most paints and is also used in sunscreen.',
  ),
];
