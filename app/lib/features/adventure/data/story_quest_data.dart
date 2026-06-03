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
        titleEs: 'La Primera Luz',
        story:
            'In the first moments after the Big Bang, the universe forged its simplest building block. This element makes up 75% of all ordinary matter and powers every star in the cosmos — including our Sun.',
        storyEs:
            'En los primeros momentos tras el Big Bang, el universo forjó su bloque más simple. Este elemento constituye el 75% de toda la materia ordinaria y alimenta cada estrella del cosmos, incluyendo nuestro Sol.',
        sceneEmoji: '☀️',
        type: QuestType.identify,
        challenge:
            'Identify the lightest element — the first born in the universe.',
        challengeEs:
            'Identifica el elemento más ligero, el primero nacido en el universo.',
        targetZ: 1,
        distractorZs: [2, 6, 7, 8, 9, 15, 16, 17],
      ),
      StoryQuest(
        id: 1,
        title: 'The Sun\'s Secret',
        titleEs: 'El Secreto del Sol',
        story:
            'Scientists discovered this element in the Sun\'s spectrum before ever finding it on Earth. It rises upward in every balloon and keeps deep-sea divers safe from nitrogen narcosis at great depths.',
        storyEs:
            'Los científicos descubrieron este elemento en el espectro del Sol antes de encontrarlo en la Tierra. Sube en cada globo y mantiene seguros a los buceadores en grandes profundidades.',
        sceneEmoji: '🎈',
        type: QuestType.identify,
        challenge: 'Find the noble gas first discovered in the Sun.',
        challengeEs: 'Encuentra el gas noble descubierto primero en el Sol.',
        targetZ: 2,
        distractorZs: [1, 3, 7, 10, 18, 36, 54, 86],
      ),
      StoryQuest(
        id: 2,
        title: 'The Building Block',
        titleEs: 'El Bloque Fundamental',
        story:
            'Every living thing on Earth is built around this element. It forms more known compounds than any other — over ten million molecules. Without it, organic chemistry, and life itself, would be impossible.',
        storyEs:
            'Todo ser vivo en la Tierra está construido alrededor de este elemento. Forma más compuestos que cualquier otro: más de diez millones de moléculas. Sin él, la química orgánica y la vida serían imposibles.',
        sceneEmoji: '🌿',
        type: QuestType.multiChoice,
        challenge: 'Which element has atomic number 6?',
        challengeEs: '¿Qué elemento tiene el número atómico 6?',
        options: [
          MultiChoiceOption(
            elementZ: 5,
            label: 'Boron  ·  B  ·  5',
            isCorrect: false,
          ),
          MultiChoiceOption(
            elementZ: 6,
            label: 'Carbon  ·  C  ·  6',
            isCorrect: true,
          ),
          MultiChoiceOption(
            elementZ: 7,
            label: 'Nitrogen  ·  N  ·  7',
            isCorrect: false,
          ),
          MultiChoiceOption(
            elementZ: 8,
            label: 'Oxygen  ·  O  ·  8',
            isCorrect: false,
          ),
        ],
      ),
      StoryQuest(
        id: 3,
        title: 'The Source of Life',
        titleEs: 'La Fuente de la Vida',
        story:
            'The cosmic alchemist combines two of the universe\'s most abundant elements. One fires every star; the other gives us every breath. Their union produces the molecule that made complex life possible on Earth.',
        storyEs:
            'El alquimista cósmico combina dos de los elementos más abundantes. Uno enciende cada estrella; el otro nos da cada aliento. Su unión produce la molécula que hizo posible la vida compleja en la Tierra.',
        sceneEmoji: '💧',
        type: QuestType.combine,
        challenge:
            'Combine the lightest element with the breath of fire to create the source of all earthly life.',
        challengeEs:
            'Combina el elemento más ligero con el aliento de fuego para crear la fuente de toda vida terrestre.',
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
        titleEs: 'El Metal del Herrero',
        story:
            'For ten thousand years, civilizations rose and fell on its strength. Blacksmiths heated it in furnaces, quenched it in water, and shaped the swords and shields that built empires. The Iron Age bears its name.',
        storyEs:
            'Durante diez mil años, las civilizaciones surgieron y cayeron por su fortaleza. Los herreros lo calentaban en hornos y moldeaban las espadas y escudos que construyeron imperios. La Edad de Hierro lleva su nombre.',
        sceneEmoji: '⚔️',
        type: QuestType.identify,
        challenge: 'Find the metal that forged the Iron Age.',
        challengeEs: 'Encuentra el metal que forjó la Edad de Hierro.',
        targetZ: 26,
        distractorZs: [22, 23, 24, 25, 27, 28, 29, 30],
      ),
      StoryQuest(
        id: 1,
        title: 'El Dorado',
        titleEs: 'El Dorado',
        story:
            'Kings, conquerors, and thieves alike sought it across continents. Untarnished by time, corrosion-proof, and shimmering — this rare metal has shaped human ambition for millennia, from Inca temples to modern circuit boards.',
        storyEs:
            'Reyes, conquistadores y ladrones lo buscaron en todos los continentes. Inmune al tiempo y resistente a la corrosión, este raro metal ha moldeado la ambición humana por milenios, desde los templos incas hasta los circuitos modernos.',
        sceneEmoji: '👑',
        type: QuestType.identify,
        challenge: 'Identify the precious metal that never tarnishes.',
        challengeEs: 'Identifica el metal precioso que nunca se oxida.',
        targetZ: 79,
        distractorZs: [26, 28, 29, 30, 47, 46, 78, 80],
      ),
      StoryQuest(
        id: 2,
        title: 'The Skeleton Key',
        titleEs: 'La Clave del Esqueleto',
        story:
            'Your bones and teeth are living architecture built around this element. Without it, they crumble. It hides in dairy, leafy greens, and every handshake in your skeleton — quietly holding your body together.',
        storyEs:
            'Tus huesos y dientes son arquitectura viva construida alrededor de este elemento. Sin él, se desmoronan. Se esconde en los lácteos, verduras y cada unión de tu esqueleto, sosteniéndote en silencio.',
        sceneEmoji: '🦴',
        type: QuestType.multiChoice,
        challenge: 'Which element gives bones and teeth their strength?',
        challengeEs: '¿Qué elemento da fortaleza a los huesos y dientes?',
        options: [
          MultiChoiceOption(
            elementZ: 12,
            label: 'Magnesium  ·  Mg  ·  12',
            isCorrect: false,
          ),
          MultiChoiceOption(
            elementZ: 19,
            label: 'Potassium  ·  K  ·  19',
            isCorrect: false,
          ),
          MultiChoiceOption(
            elementZ: 20,
            label: 'Calcium  ·  Ca  ·  20',
            isCorrect: true,
          ),
          MultiChoiceOption(
            elementZ: 26,
            label: 'Iron  ·  Fe  ·  26',
            isCorrect: false,
          ),
        ],
      ),
      StoryQuest(
        id: 3,
        title: 'The Sailor\'s Crystal',
        titleEs: 'El Cristal del Marinero',
        story:
            'Every ocean wave carries it. Roman soldiers were paid with it — giving us the word "salary." For centuries, it preserved food, funded wars, and crossed trade routes. This compound is older than civilization itself.',
        storyEs:
            'Cada ola del océano lo lleva. Los soldados romanos eran pagados con él, dándonos la palabra "salario". Durante siglos, conservó alimentos y cruzó rutas comerciales. Este compuesto es más antiguo que la civilización.',
        sceneEmoji: '🧂',
        type: QuestType.combine,
        challenge:
            'Combine the reactive alkali metal with the green halogen to crystallize the taste of the sea.',
        challengeEs:
            'Combina el metal alcalino reactivo con el halógeno verde para cristalizar el sabor del mar.',
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
        titleEs: 'El Corazón Digital',
        story:
            'Every computer, every smartphone, every chip that runs the modern world is carved from this metalloid — found abundantly in ordinary beach sand. Without it, the Information Age would never have begun.',
        storyEs:
            'Cada computadora, cada teléfono, cada chip del mundo moderno está tallado en este metaloide, que se encuentra en la arena de las playas. Sin él, la Era de la Información nunca hubiera comenzado.',
        sceneEmoji: '💻',
        type: QuestType.identify,
        challenge: 'Find the element that powers every computer chip.',
        challengeEs:
            'Encuentra el elemento que alimenta cada chip de computadora.',
        targetZ: 14,
        distractorZs: [5, 6, 13, 15, 32, 33, 50, 51],
      ),
      StoryQuest(
        id: 1,
        title: 'The Battery Revolution',
        titleEs: 'La Revolución de la Batería',
        story:
            'The lightest metal on the periodic table sparked the portable energy revolution. It powers the phone in your pocket, the electric car on the road, and is even prescribed as a medication for mental health.',
        storyEs:
            'El metal más ligero de la tabla periódica inició la revolución de la energía portátil. Alimenta el teléfono en tu bolsillo, el auto eléctrico, e incluso se receta como medicamento para la salud mental.',
        sceneEmoji: '🔋',
        type: QuestType.identify,
        challenge:
            'Identify the lightest metal — the one in every rechargeable battery.',
        challengeEs:
            'Identifica el metal más ligero, el que está en cada batería recargable.',
        targetZ: 3,
        distractorZs: [1, 4, 11, 12, 19, 20, 37, 55],
      ),
      StoryQuest(
        id: 2,
        title: 'The Neon Night',
        titleEs: 'La Noche de Neón',
        story:
            'It glows in signs on every city street, from Tokyo to Las Vegas. Inert and untameable, this noble gas was the first element extracted from liquid air — and it\'s what gives classic signs their iconic warm red glow.',
        storyEs:
            'Brilla en los letreros de cada calle, desde Tokio hasta Las Vegas. Inerte e indomable, este gas noble fue el primer elemento extraído del aire líquido y da a los letreros clásicos su icónico resplandor rojo.',
        sceneEmoji: '🌃',
        type: QuestType.multiChoice,
        challenge: 'Which noble gas makes classic neon signs glow red?',
        challengeEs:
            '¿Qué gas noble hace brillar en rojo los letreros de neón clásicos?',
        options: [
          MultiChoiceOption(
            elementZ: 2,
            label: 'Helium  ·  He  ·  2',
            isCorrect: false,
          ),
          MultiChoiceOption(
            elementZ: 10,
            label: 'Neon  ·  Ne  ·  10',
            isCorrect: true,
          ),
          MultiChoiceOption(
            elementZ: 18,
            label: 'Argon  ·  Ar  ·  18',
            isCorrect: false,
          ),
          MultiChoiceOption(
            elementZ: 36,
            label: 'Krypton  ·  Kr  ·  36',
            isCorrect: false,
          ),
        ],
      ),
      StoryQuest(
        id: 3,
        title: 'The Invisible Blanket',
        titleEs: 'La Manta Invisible',
        story:
            'Plants breathe it in; animals breathe it out. This colorless gas forms when the backbone of all life meets the element of combustion. Now it wraps the Earth like an invisible thermal blanket, warming the climate.',
        storyEs:
            'Las plantas lo inhalan; los animales lo exhalan. Este gas incoloro se forma cuando el carbono se une al oxígeno. Ahora envuelve la Tierra como una manta térmica invisible, calentando el clima.',
        sceneEmoji: '🌍',
        type: QuestType.combine,
        challenge:
            'Combine the element of life with the element of fire to make the greenhouse gas.',
        challengeEs:
            'Combina el elemento de la vida con el elemento del fuego para crear el gas de efecto invernadero.',
        combineZA: 6,
        combineZB: 8,
        compoundName: 'Carbon Dioxide (CO₂)',
        combineZs: [1, 6, 7, 8, 14, 15, 16, 17],
      ),
    ],
  ),
];
