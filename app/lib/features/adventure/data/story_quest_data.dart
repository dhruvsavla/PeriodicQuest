import 'package:flutter/material.dart';

import '../models/story_quest.dart';

const kStoryChapters = <StoryChapter>[
  // ── Chapter 0: The Cosmic Dawn ────────────────────────────────────────────
  StoryChapter(
    id: 0,
    title: 'The Cosmic Dawn',
    description: 'Trace the birth of the universe\'s first elements',
    emoji: '🌌',
    accentColor: Color(0xFF7C3AED),
    bgDark: Color(0xFF0D0721),
    bgLight: Color(0xFF1E1040),
    unlockRequiredStars: 0,
    quests: [
      StoryQuest(
        id: 0,
        title: 'The First Light',
        story:
            'In the first moments after the Big Bang, the universe forged its simplest building block. This element makes up 75% of all ordinary matter and powers every star in the cosmos — including our Sun.',
        sceneEmoji: '☀️',
        type: QuestType.identify,
        challenge: 'Identify the lightest element — the first born in the universe.',
        targetZ: 1,
        distractorZs: [2, 6, 7, 8, 9, 15, 16, 17],
      ),
      StoryQuest(
        id: 1,
        title: 'The Sun\'s Secret',
        story:
            'Scientists discovered this element in the Sun\'s spectrum before ever finding it on Earth. It rises upward in every balloon and keeps deep-sea divers safe from nitrogen narcosis at great depths.',
        sceneEmoji: '🎈',
        type: QuestType.identify,
        challenge: 'Find the noble gas first discovered in the Sun.',
        targetZ: 2,
        distractorZs: [1, 3, 7, 10, 18, 36, 54, 86],
      ),
      StoryQuest(
        id: 2,
        title: 'The Building Block',
        story:
            'Every living thing on Earth is built around this element. It forms more known compounds than any other — over ten million molecules. Without it, organic chemistry, and life itself, would be impossible.',
        sceneEmoji: '🌿',
        type: QuestType.multiChoice,
        challenge: 'Which element has atomic number 6?',
        options: [
          MultiChoiceOption(elementZ: 5, label: 'Boron  ·  B  ·  5', isCorrect: false),
          MultiChoiceOption(elementZ: 6, label: 'Carbon  ·  C  ·  6', isCorrect: true),
          MultiChoiceOption(elementZ: 7, label: 'Nitrogen  ·  N  ·  7', isCorrect: false),
          MultiChoiceOption(elementZ: 8, label: 'Oxygen  ·  O  ·  8', isCorrect: false),
        ],
      ),
      StoryQuest(
        id: 3,
        title: 'The Source of Life',
        story:
            'The cosmic alchemist combines two of the universe\'s most abundant elements. One fires every star; the other gives us every breath. Their union produces the molecule that made complex life possible on Earth.',
        sceneEmoji: '💧',
        type: QuestType.combine,
        challenge: 'Combine the lightest element with the breath of fire to create the source of all earthly life.',
        combineZA: 1,
        combineZB: 8,
        compoundName: 'Water (H₂O)',
        combineZs: [1, 2, 6, 7, 8, 9, 16, 17],
      ),
    ],
  ),

  // ── Chapter 1: The Age of Metals ──────────────────────────────────────────
  StoryChapter(
    id: 1,
    title: 'The Age of Metals',
    description: 'Forge civilizations with Earth\'s mightiest metals',
    emoji: '⚔️',
    accentColor: Color(0xFFF59E0B),
    bgDark: Color(0xFF1A0F00),
    bgLight: Color(0xFF2D1A00),
    unlockRequiredStars: 4,
    quests: [
      StoryQuest(
        id: 0,
        title: 'The Blacksmith\'s Metal',
        story:
            'For ten thousand years, civilizations rose and fell on its strength. Blacksmiths heated it in furnaces, quenched it in water, and shaped the swords and shields that built empires. The Iron Age bears its name.',
        sceneEmoji: '⚔️',
        type: QuestType.identify,
        challenge: 'Find the metal that forged the Iron Age.',
        targetZ: 26,
        distractorZs: [22, 23, 24, 25, 27, 28, 29, 30],
      ),
      StoryQuest(
        id: 1,
        title: 'El Dorado',
        story:
            'Kings, conquerors, and thieves alike sought it across continents. Untarnished by time, corrosion-proof, and shimmering — this rare metal has shaped human ambition for millennia, from Inca temples to modern circuit boards.',
        sceneEmoji: '👑',
        type: QuestType.identify,
        challenge: 'Identify the precious metal that never tarnishes.',
        targetZ: 79,
        distractorZs: [26, 28, 29, 30, 47, 46, 78, 80],
      ),
      StoryQuest(
        id: 2,
        title: 'The Skeleton Key',
        story:
            'Your bones and teeth are living architecture built around this element. Without it, they crumble. It hides in dairy, leafy greens, and every handshake in your skeleton — quietly holding your body together.',
        sceneEmoji: '🦴',
        type: QuestType.multiChoice,
        challenge: 'Which element gives bones and teeth their strength?',
        options: [
          MultiChoiceOption(elementZ: 12, label: 'Magnesium  ·  Mg  ·  12', isCorrect: false),
          MultiChoiceOption(elementZ: 19, label: 'Potassium  ·  K  ·  19', isCorrect: false),
          MultiChoiceOption(elementZ: 20, label: 'Calcium  ·  Ca  ·  20', isCorrect: true),
          MultiChoiceOption(elementZ: 26, label: 'Iron  ·  Fe  ·  26', isCorrect: false),
        ],
      ),
      StoryQuest(
        id: 3,
        title: 'The Sailor\'s Crystal',
        story:
            'Every ocean wave carries it. Roman soldiers were paid with it — giving us the word "salary." For centuries, it preserved food, funded wars, and crossed trade routes. This compound is older than civilization itself.',
        sceneEmoji: '🧂',
        type: QuestType.combine,
        challenge: 'Combine the reactive alkali metal with the green halogen to crystallize the taste of the sea.',
        combineZA: 11,
        combineZB: 17,
        compoundName: 'Table Salt (NaCl)',
        combineZs: [11, 12, 17, 19, 20, 35, 38, 53],
      ),
    ],
  ),

  // ── Chapter 2: The Electric Age ───────────────────────────────────────────
  StoryChapter(
    id: 2,
    title: 'The Electric Age',
    description: 'Power the digital revolution with modern chemistry',
    emoji: '⚡',
    accentColor: Color(0xFF06B6D4),
    bgDark: Color(0xFF001220),
    bgLight: Color(0xFF002440),
    unlockRequiredStars: 10,
    quests: [
      StoryQuest(
        id: 0,
        title: 'The Digital Heart',
        story:
            'Every computer, every smartphone, every chip that runs the modern world is carved from this metalloid — found abundantly in ordinary beach sand. Without it, the Information Age would never have begun.',
        sceneEmoji: '💻',
        type: QuestType.identify,
        challenge: 'Find the element that powers every computer chip.',
        targetZ: 14,
        distractorZs: [5, 6, 13, 15, 32, 33, 50, 51],
      ),
      StoryQuest(
        id: 1,
        title: 'The Battery Revolution',
        story:
            'The lightest metal on the periodic table sparked the portable energy revolution. It powers the phone in your pocket, the electric car on the road, and is even prescribed as a medication for mental health.',
        sceneEmoji: '🔋',
        type: QuestType.identify,
        challenge: 'Identify the lightest metal — the one in every rechargeable battery.',
        targetZ: 3,
        distractorZs: [1, 4, 11, 12, 19, 20, 37, 55],
      ),
      StoryQuest(
        id: 2,
        title: 'The Neon Night',
        story:
            'It glows in signs on every city street, from Tokyo to Las Vegas. Inert and untameable, this noble gas was the first element extracted from liquid air — and it\'s what gives classic signs their iconic warm red glow.',
        sceneEmoji: '🌃',
        type: QuestType.multiChoice,
        challenge: 'Which noble gas makes classic neon signs glow red?',
        options: [
          MultiChoiceOption(elementZ: 2, label: 'Helium  ·  He  ·  2', isCorrect: false),
          MultiChoiceOption(elementZ: 10, label: 'Neon  ·  Ne  ·  10', isCorrect: true),
          MultiChoiceOption(elementZ: 18, label: 'Argon  ·  Ar  ·  18', isCorrect: false),
          MultiChoiceOption(elementZ: 36, label: 'Krypton  ·  Kr  ·  36', isCorrect: false),
        ],
      ),
      StoryQuest(
        id: 3,
        title: 'The Invisible Blanket',
        story:
            'Plants breathe it in; animals breathe it out. This colorless gas forms when the backbone of all life meets the element of combustion. Now it wraps the Earth like an invisible thermal blanket, warming the climate.',
        sceneEmoji: '🌍',
        type: QuestType.combine,
        challenge: 'Combine the element of life with the element of fire to make the greenhouse gas.',
        combineZA: 6,
        combineZB: 8,
        compoundName: 'Carbon Dioxide (CO₂)',
        combineZs: [1, 6, 7, 8, 14, 15, 16, 17],
      ),
    ],
  ),
];
