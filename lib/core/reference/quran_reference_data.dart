final class QuranSurahReference {
  const QuranSurahReference({
    required this.number,
    required this.arabicName,
    required this.ayahCount,
  });

  final int number;
  final String arabicName;
  final int ayahCount;
}

final class QuranPosition {
  const QuranPosition({required this.surahNumber, required this.ayahNumber});

  final int surahNumber;
  final int ayahNumber;
}

final class QuranRange {
  const QuranRange({required this.start, required this.end});

  final QuranPosition start;
  final QuranPosition end;
}

final class QuranJuzSegment {
  const QuranJuzSegment({
    required this.surahNumber,
    required this.startAyah,
    required this.endAyah,
  });

  final int surahNumber;
  final int startAyah;
  final int endAyah;

  QuranPosition get start =>
      QuranPosition(surahNumber: surahNumber, ayahNumber: startAyah);

  QuranPosition get end =>
      QuranPosition(surahNumber: surahNumber, ayahNumber: endAyah);

  int get ayahCount => endAyah - startAyah + 1;
}

final class QuranJuzReference {
  const QuranJuzReference({required this.number, required this.segments});

  final int number;
  final List<QuranJuzSegment> segments;

  QuranPosition get start => segments.first.start;
  QuranPosition get end => segments.last.end;
}

final class QuranReferenceData {
  const QuranReferenceData._();

  static const int surahCount = 114;
  static const int juzCount = 30;
  static const int totalAyahCount = 6236;

  /// Static local metadata only. The app does not call either source at runtime.
  ///
  /// Surah names/counts and juz verse boundaries are based on the approved
  /// Quran Foundation / Tanzil reference decision for Qurani v1.
  static const String referenceBasis =
      'Quran Foundation Content API v4 + Tanzil Quran Metadata';

  static const List<QuranSurahReference> surahs = <QuranSurahReference>[
    QuranSurahReference(number: 1, arabicName: 'الفاتحة', ayahCount: 7),
    QuranSurahReference(number: 2, arabicName: 'البقرة', ayahCount: 286),
    QuranSurahReference(number: 3, arabicName: 'آل عمران', ayahCount: 200),
    QuranSurahReference(number: 4, arabicName: 'النساء', ayahCount: 176),
    QuranSurahReference(number: 5, arabicName: 'المائدة', ayahCount: 120),
    QuranSurahReference(number: 6, arabicName: 'الأنعام', ayahCount: 165),
    QuranSurahReference(number: 7, arabicName: 'الأعراف', ayahCount: 206),
    QuranSurahReference(number: 8, arabicName: 'الأنفال', ayahCount: 75),
    QuranSurahReference(number: 9, arabicName: 'التوبة', ayahCount: 129),
    QuranSurahReference(number: 10, arabicName: 'يونس', ayahCount: 109),
    QuranSurahReference(number: 11, arabicName: 'هود', ayahCount: 123),
    QuranSurahReference(number: 12, arabicName: 'يوسف', ayahCount: 111),
    QuranSurahReference(number: 13, arabicName: 'الرعد', ayahCount: 43),
    QuranSurahReference(number: 14, arabicName: 'إبراهيم', ayahCount: 52),
    QuranSurahReference(number: 15, arabicName: 'الحجر', ayahCount: 99),
    QuranSurahReference(number: 16, arabicName: 'النحل', ayahCount: 128),
    QuranSurahReference(number: 17, arabicName: 'الإسراء', ayahCount: 111),
    QuranSurahReference(number: 18, arabicName: 'الكهف', ayahCount: 110),
    QuranSurahReference(number: 19, arabicName: 'مريم', ayahCount: 98),
    QuranSurahReference(number: 20, arabicName: 'طه', ayahCount: 135),
    QuranSurahReference(number: 21, arabicName: 'الأنبياء', ayahCount: 112),
    QuranSurahReference(number: 22, arabicName: 'الحج', ayahCount: 78),
    QuranSurahReference(number: 23, arabicName: 'المؤمنون', ayahCount: 118),
    QuranSurahReference(number: 24, arabicName: 'النور', ayahCount: 64),
    QuranSurahReference(number: 25, arabicName: 'الفرقان', ayahCount: 77),
    QuranSurahReference(number: 26, arabicName: 'الشعراء', ayahCount: 227),
    QuranSurahReference(number: 27, arabicName: 'النمل', ayahCount: 93),
    QuranSurahReference(number: 28, arabicName: 'القصص', ayahCount: 88),
    QuranSurahReference(number: 29, arabicName: 'العنكبوت', ayahCount: 69),
    QuranSurahReference(number: 30, arabicName: 'الروم', ayahCount: 60),
    QuranSurahReference(number: 31, arabicName: 'لقمان', ayahCount: 34),
    QuranSurahReference(number: 32, arabicName: 'السجدة', ayahCount: 30),
    QuranSurahReference(number: 33, arabicName: 'الأحزاب', ayahCount: 73),
    QuranSurahReference(number: 34, arabicName: 'سبإ', ayahCount: 54),
    QuranSurahReference(number: 35, arabicName: 'فاطر', ayahCount: 45),
    QuranSurahReference(number: 36, arabicName: 'يس', ayahCount: 83),
    QuranSurahReference(number: 37, arabicName: 'الصافات', ayahCount: 182),
    QuranSurahReference(number: 38, arabicName: 'ص', ayahCount: 88),
    QuranSurahReference(number: 39, arabicName: 'الزمر', ayahCount: 75),
    QuranSurahReference(number: 40, arabicName: 'غافر', ayahCount: 85),
    QuranSurahReference(number: 41, arabicName: 'فصلت', ayahCount: 54),
    QuranSurahReference(number: 42, arabicName: 'الشورى', ayahCount: 53),
    QuranSurahReference(number: 43, arabicName: 'الزخرف', ayahCount: 89),
    QuranSurahReference(number: 44, arabicName: 'الدخان', ayahCount: 59),
    QuranSurahReference(number: 45, arabicName: 'الجاثية', ayahCount: 37),
    QuranSurahReference(number: 46, arabicName: 'الأحقاف', ayahCount: 35),
    QuranSurahReference(number: 47, arabicName: 'محمد', ayahCount: 38),
    QuranSurahReference(number: 48, arabicName: 'الفتح', ayahCount: 29),
    QuranSurahReference(number: 49, arabicName: 'الحجرات', ayahCount: 18),
    QuranSurahReference(number: 50, arabicName: 'ق', ayahCount: 45),
    QuranSurahReference(number: 51, arabicName: 'الذاريات', ayahCount: 60),
    QuranSurahReference(number: 52, arabicName: 'الطور', ayahCount: 49),
    QuranSurahReference(number: 53, arabicName: 'النجم', ayahCount: 62),
    QuranSurahReference(number: 54, arabicName: 'القمر', ayahCount: 55),
    QuranSurahReference(number: 55, arabicName: 'الرحمن', ayahCount: 78),
    QuranSurahReference(number: 56, arabicName: 'الواقعة', ayahCount: 96),
    QuranSurahReference(number: 57, arabicName: 'الحديد', ayahCount: 29),
    QuranSurahReference(number: 58, arabicName: 'المجادلة', ayahCount: 22),
    QuranSurahReference(number: 59, arabicName: 'الحشر', ayahCount: 24),
    QuranSurahReference(number: 60, arabicName: 'الممتحنة', ayahCount: 13),
    QuranSurahReference(number: 61, arabicName: 'الصف', ayahCount: 14),
    QuranSurahReference(number: 62, arabicName: 'الجمعة', ayahCount: 11),
    QuranSurahReference(number: 63, arabicName: 'المنافقون', ayahCount: 11),
    QuranSurahReference(number: 64, arabicName: 'التغابن', ayahCount: 18),
    QuranSurahReference(number: 65, arabicName: 'الطلاق', ayahCount: 12),
    QuranSurahReference(number: 66, arabicName: 'التحريم', ayahCount: 12),
    QuranSurahReference(number: 67, arabicName: 'الملك', ayahCount: 30),
    QuranSurahReference(number: 68, arabicName: 'القلم', ayahCount: 52),
    QuranSurahReference(number: 69, arabicName: 'الحاقة', ayahCount: 52),
    QuranSurahReference(number: 70, arabicName: 'المعارج', ayahCount: 44),
    QuranSurahReference(number: 71, arabicName: 'نوح', ayahCount: 28),
    QuranSurahReference(number: 72, arabicName: 'الجن', ayahCount: 28),
    QuranSurahReference(number: 73, arabicName: 'المزمل', ayahCount: 20),
    QuranSurahReference(number: 74, arabicName: 'المدثر', ayahCount: 56),
    QuranSurahReference(number: 75, arabicName: 'القيامة', ayahCount: 40),
    QuranSurahReference(number: 76, arabicName: 'الإنسان', ayahCount: 31),
    QuranSurahReference(number: 77, arabicName: 'المرسلات', ayahCount: 50),
    QuranSurahReference(number: 78, arabicName: 'النبأ', ayahCount: 40),
    QuranSurahReference(number: 79, arabicName: 'النازعات', ayahCount: 46),
    QuranSurahReference(number: 80, arabicName: 'عبس', ayahCount: 42),
    QuranSurahReference(number: 81, arabicName: 'التكوير', ayahCount: 29),
    QuranSurahReference(number: 82, arabicName: 'الانفطار', ayahCount: 19),
    QuranSurahReference(number: 83, arabicName: 'المطففين', ayahCount: 36),
    QuranSurahReference(number: 84, arabicName: 'الانشقاق', ayahCount: 25),
    QuranSurahReference(number: 85, arabicName: 'البروج', ayahCount: 22),
    QuranSurahReference(number: 86, arabicName: 'الطارق', ayahCount: 17),
    QuranSurahReference(number: 87, arabicName: 'الأعلى', ayahCount: 19),
    QuranSurahReference(number: 88, arabicName: 'الغاشية', ayahCount: 26),
    QuranSurahReference(number: 89, arabicName: 'الفجر', ayahCount: 30),
    QuranSurahReference(number: 90, arabicName: 'البلد', ayahCount: 20),
    QuranSurahReference(number: 91, arabicName: 'الشمس', ayahCount: 15),
    QuranSurahReference(number: 92, arabicName: 'الليل', ayahCount: 21),
    QuranSurahReference(number: 93, arabicName: 'الضحى', ayahCount: 11),
    QuranSurahReference(number: 94, arabicName: 'الشرح', ayahCount: 8),
    QuranSurahReference(number: 95, arabicName: 'التين', ayahCount: 8),
    QuranSurahReference(number: 96, arabicName: 'العلق', ayahCount: 19),
    QuranSurahReference(number: 97, arabicName: 'القدر', ayahCount: 5),
    QuranSurahReference(number: 98, arabicName: 'البينة', ayahCount: 8),
    QuranSurahReference(number: 99, arabicName: 'الزلزلة', ayahCount: 8),
    QuranSurahReference(number: 100, arabicName: 'العاديات', ayahCount: 11),
    QuranSurahReference(number: 101, arabicName: 'القارعة', ayahCount: 11),
    QuranSurahReference(number: 102, arabicName: 'التكاثر', ayahCount: 8),
    QuranSurahReference(number: 103, arabicName: 'العصر', ayahCount: 3),
    QuranSurahReference(number: 104, arabicName: 'الهمزة', ayahCount: 9),
    QuranSurahReference(number: 105, arabicName: 'الفيل', ayahCount: 5),
    QuranSurahReference(number: 106, arabicName: 'قريش', ayahCount: 4),
    QuranSurahReference(number: 107, arabicName: 'الماعون', ayahCount: 7),
    QuranSurahReference(number: 108, arabicName: 'الكوثر', ayahCount: 3),
    QuranSurahReference(number: 109, arabicName: 'الكافرون', ayahCount: 6),
    QuranSurahReference(number: 110, arabicName: 'النصر', ayahCount: 3),
    QuranSurahReference(number: 111, arabicName: 'المسد', ayahCount: 5),
    QuranSurahReference(number: 112, arabicName: 'الإخلاص', ayahCount: 4),
    QuranSurahReference(number: 113, arabicName: 'الفلق', ayahCount: 5),
    QuranSurahReference(number: 114, arabicName: 'الناس', ayahCount: 6),
  ];

  static const List<QuranJuzReference> juzs = <QuranJuzReference>[
    QuranJuzReference(
      number: 1,
      segments: <QuranJuzSegment>[
        QuranJuzSegment(surahNumber: 1, startAyah: 1, endAyah: 7),
        QuranJuzSegment(surahNumber: 2, startAyah: 1, endAyah: 141),
      ],
    ),
    QuranJuzReference(
      number: 2,
      segments: <QuranJuzSegment>[
        QuranJuzSegment(surahNumber: 2, startAyah: 142, endAyah: 252),
      ],
    ),
    QuranJuzReference(
      number: 3,
      segments: <QuranJuzSegment>[
        QuranJuzSegment(surahNumber: 2, startAyah: 253, endAyah: 286),
        QuranJuzSegment(surahNumber: 3, startAyah: 1, endAyah: 92),
      ],
    ),
    QuranJuzReference(
      number: 4,
      segments: <QuranJuzSegment>[
        QuranJuzSegment(surahNumber: 3, startAyah: 93, endAyah: 200),
        QuranJuzSegment(surahNumber: 4, startAyah: 1, endAyah: 23),
      ],
    ),
    QuranJuzReference(
      number: 5,
      segments: <QuranJuzSegment>[
        QuranJuzSegment(surahNumber: 4, startAyah: 24, endAyah: 147),
      ],
    ),
    QuranJuzReference(
      number: 6,
      segments: <QuranJuzSegment>[
        QuranJuzSegment(surahNumber: 4, startAyah: 148, endAyah: 176),
        QuranJuzSegment(surahNumber: 5, startAyah: 1, endAyah: 81),
      ],
    ),
    QuranJuzReference(
      number: 7,
      segments: <QuranJuzSegment>[
        QuranJuzSegment(surahNumber: 5, startAyah: 82, endAyah: 120),
        QuranJuzSegment(surahNumber: 6, startAyah: 1, endAyah: 110),
      ],
    ),
    QuranJuzReference(
      number: 8,
      segments: <QuranJuzSegment>[
        QuranJuzSegment(surahNumber: 6, startAyah: 111, endAyah: 165),
        QuranJuzSegment(surahNumber: 7, startAyah: 1, endAyah: 87),
      ],
    ),
    QuranJuzReference(
      number: 9,
      segments: <QuranJuzSegment>[
        QuranJuzSegment(surahNumber: 7, startAyah: 88, endAyah: 206),
        QuranJuzSegment(surahNumber: 8, startAyah: 1, endAyah: 40),
      ],
    ),
    QuranJuzReference(
      number: 10,
      segments: <QuranJuzSegment>[
        QuranJuzSegment(surahNumber: 8, startAyah: 41, endAyah: 75),
        QuranJuzSegment(surahNumber: 9, startAyah: 1, endAyah: 92),
      ],
    ),
    QuranJuzReference(
      number: 11,
      segments: <QuranJuzSegment>[
        QuranJuzSegment(surahNumber: 9, startAyah: 93, endAyah: 129),
        QuranJuzSegment(surahNumber: 10, startAyah: 1, endAyah: 109),
        QuranJuzSegment(surahNumber: 11, startAyah: 1, endAyah: 5),
      ],
    ),
    QuranJuzReference(
      number: 12,
      segments: <QuranJuzSegment>[
        QuranJuzSegment(surahNumber: 11, startAyah: 6, endAyah: 123),
        QuranJuzSegment(surahNumber: 12, startAyah: 1, endAyah: 52),
      ],
    ),
    QuranJuzReference(
      number: 13,
      segments: <QuranJuzSegment>[
        QuranJuzSegment(surahNumber: 12, startAyah: 53, endAyah: 111),
        QuranJuzSegment(surahNumber: 13, startAyah: 1, endAyah: 43),
        QuranJuzSegment(surahNumber: 14, startAyah: 1, endAyah: 52),
      ],
    ),
    QuranJuzReference(
      number: 14,
      segments: <QuranJuzSegment>[
        QuranJuzSegment(surahNumber: 15, startAyah: 1, endAyah: 99),
        QuranJuzSegment(surahNumber: 16, startAyah: 1, endAyah: 128),
      ],
    ),
    QuranJuzReference(
      number: 15,
      segments: <QuranJuzSegment>[
        QuranJuzSegment(surahNumber: 17, startAyah: 1, endAyah: 111),
        QuranJuzSegment(surahNumber: 18, startAyah: 1, endAyah: 74),
      ],
    ),
    QuranJuzReference(
      number: 16,
      segments: <QuranJuzSegment>[
        QuranJuzSegment(surahNumber: 18, startAyah: 75, endAyah: 110),
        QuranJuzSegment(surahNumber: 19, startAyah: 1, endAyah: 98),
        QuranJuzSegment(surahNumber: 20, startAyah: 1, endAyah: 135),
      ],
    ),
    QuranJuzReference(
      number: 17,
      segments: <QuranJuzSegment>[
        QuranJuzSegment(surahNumber: 21, startAyah: 1, endAyah: 112),
        QuranJuzSegment(surahNumber: 22, startAyah: 1, endAyah: 78),
      ],
    ),
    QuranJuzReference(
      number: 18,
      segments: <QuranJuzSegment>[
        QuranJuzSegment(surahNumber: 23, startAyah: 1, endAyah: 118),
        QuranJuzSegment(surahNumber: 24, startAyah: 1, endAyah: 64),
        QuranJuzSegment(surahNumber: 25, startAyah: 1, endAyah: 20),
      ],
    ),
    QuranJuzReference(
      number: 19,
      segments: <QuranJuzSegment>[
        QuranJuzSegment(surahNumber: 25, startAyah: 21, endAyah: 77),
        QuranJuzSegment(surahNumber: 26, startAyah: 1, endAyah: 227),
        QuranJuzSegment(surahNumber: 27, startAyah: 1, endAyah: 55),
      ],
    ),
    QuranJuzReference(
      number: 20,
      segments: <QuranJuzSegment>[
        QuranJuzSegment(surahNumber: 27, startAyah: 56, endAyah: 93),
        QuranJuzSegment(surahNumber: 28, startAyah: 1, endAyah: 88),
        QuranJuzSegment(surahNumber: 29, startAyah: 1, endAyah: 45),
      ],
    ),
    QuranJuzReference(
      number: 21,
      segments: <QuranJuzSegment>[
        QuranJuzSegment(surahNumber: 29, startAyah: 46, endAyah: 69),
        QuranJuzSegment(surahNumber: 30, startAyah: 1, endAyah: 60),
        QuranJuzSegment(surahNumber: 31, startAyah: 1, endAyah: 34),
        QuranJuzSegment(surahNumber: 32, startAyah: 1, endAyah: 30),
        QuranJuzSegment(surahNumber: 33, startAyah: 1, endAyah: 30),
      ],
    ),
    QuranJuzReference(
      number: 22,
      segments: <QuranJuzSegment>[
        QuranJuzSegment(surahNumber: 33, startAyah: 31, endAyah: 73),
        QuranJuzSegment(surahNumber: 34, startAyah: 1, endAyah: 54),
        QuranJuzSegment(surahNumber: 35, startAyah: 1, endAyah: 45),
        QuranJuzSegment(surahNumber: 36, startAyah: 1, endAyah: 27),
      ],
    ),
    QuranJuzReference(
      number: 23,
      segments: <QuranJuzSegment>[
        QuranJuzSegment(surahNumber: 36, startAyah: 28, endAyah: 83),
        QuranJuzSegment(surahNumber: 37, startAyah: 1, endAyah: 182),
        QuranJuzSegment(surahNumber: 38, startAyah: 1, endAyah: 88),
        QuranJuzSegment(surahNumber: 39, startAyah: 1, endAyah: 31),
      ],
    ),
    QuranJuzReference(
      number: 24,
      segments: <QuranJuzSegment>[
        QuranJuzSegment(surahNumber: 39, startAyah: 32, endAyah: 75),
        QuranJuzSegment(surahNumber: 40, startAyah: 1, endAyah: 85),
        QuranJuzSegment(surahNumber: 41, startAyah: 1, endAyah: 46),
      ],
    ),
    QuranJuzReference(
      number: 25,
      segments: <QuranJuzSegment>[
        QuranJuzSegment(surahNumber: 41, startAyah: 47, endAyah: 54),
        QuranJuzSegment(surahNumber: 42, startAyah: 1, endAyah: 53),
        QuranJuzSegment(surahNumber: 43, startAyah: 1, endAyah: 89),
        QuranJuzSegment(surahNumber: 44, startAyah: 1, endAyah: 59),
        QuranJuzSegment(surahNumber: 45, startAyah: 1, endAyah: 37),
      ],
    ),
    QuranJuzReference(
      number: 26,
      segments: <QuranJuzSegment>[
        QuranJuzSegment(surahNumber: 46, startAyah: 1, endAyah: 35),
        QuranJuzSegment(surahNumber: 47, startAyah: 1, endAyah: 38),
        QuranJuzSegment(surahNumber: 48, startAyah: 1, endAyah: 29),
        QuranJuzSegment(surahNumber: 49, startAyah: 1, endAyah: 18),
        QuranJuzSegment(surahNumber: 50, startAyah: 1, endAyah: 45),
        QuranJuzSegment(surahNumber: 51, startAyah: 1, endAyah: 30),
      ],
    ),
    QuranJuzReference(
      number: 27,
      segments: <QuranJuzSegment>[
        QuranJuzSegment(surahNumber: 51, startAyah: 31, endAyah: 60),
        QuranJuzSegment(surahNumber: 52, startAyah: 1, endAyah: 49),
        QuranJuzSegment(surahNumber: 53, startAyah: 1, endAyah: 62),
        QuranJuzSegment(surahNumber: 54, startAyah: 1, endAyah: 55),
        QuranJuzSegment(surahNumber: 55, startAyah: 1, endAyah: 78),
        QuranJuzSegment(surahNumber: 56, startAyah: 1, endAyah: 96),
        QuranJuzSegment(surahNumber: 57, startAyah: 1, endAyah: 29),
      ],
    ),
    QuranJuzReference(
      number: 28,
      segments: <QuranJuzSegment>[
        QuranJuzSegment(surahNumber: 58, startAyah: 1, endAyah: 22),
        QuranJuzSegment(surahNumber: 59, startAyah: 1, endAyah: 24),
        QuranJuzSegment(surahNumber: 60, startAyah: 1, endAyah: 13),
        QuranJuzSegment(surahNumber: 61, startAyah: 1, endAyah: 14),
        QuranJuzSegment(surahNumber: 62, startAyah: 1, endAyah: 11),
        QuranJuzSegment(surahNumber: 63, startAyah: 1, endAyah: 11),
        QuranJuzSegment(surahNumber: 64, startAyah: 1, endAyah: 18),
        QuranJuzSegment(surahNumber: 65, startAyah: 1, endAyah: 12),
        QuranJuzSegment(surahNumber: 66, startAyah: 1, endAyah: 12),
      ],
    ),
    QuranJuzReference(
      number: 29,
      segments: <QuranJuzSegment>[
        QuranJuzSegment(surahNumber: 67, startAyah: 1, endAyah: 30),
        QuranJuzSegment(surahNumber: 68, startAyah: 1, endAyah: 52),
        QuranJuzSegment(surahNumber: 69, startAyah: 1, endAyah: 52),
        QuranJuzSegment(surahNumber: 70, startAyah: 1, endAyah: 44),
        QuranJuzSegment(surahNumber: 71, startAyah: 1, endAyah: 28),
        QuranJuzSegment(surahNumber: 72, startAyah: 1, endAyah: 28),
        QuranJuzSegment(surahNumber: 73, startAyah: 1, endAyah: 20),
        QuranJuzSegment(surahNumber: 74, startAyah: 1, endAyah: 56),
        QuranJuzSegment(surahNumber: 75, startAyah: 1, endAyah: 40),
        QuranJuzSegment(surahNumber: 76, startAyah: 1, endAyah: 31),
        QuranJuzSegment(surahNumber: 77, startAyah: 1, endAyah: 50),
      ],
    ),
    QuranJuzReference(
      number: 30,
      segments: <QuranJuzSegment>[
        QuranJuzSegment(surahNumber: 78, startAyah: 1, endAyah: 40),
        QuranJuzSegment(surahNumber: 79, startAyah: 1, endAyah: 46),
        QuranJuzSegment(surahNumber: 80, startAyah: 1, endAyah: 42),
        QuranJuzSegment(surahNumber: 81, startAyah: 1, endAyah: 29),
        QuranJuzSegment(surahNumber: 82, startAyah: 1, endAyah: 19),
        QuranJuzSegment(surahNumber: 83, startAyah: 1, endAyah: 36),
        QuranJuzSegment(surahNumber: 84, startAyah: 1, endAyah: 25),
        QuranJuzSegment(surahNumber: 85, startAyah: 1, endAyah: 22),
        QuranJuzSegment(surahNumber: 86, startAyah: 1, endAyah: 17),
        QuranJuzSegment(surahNumber: 87, startAyah: 1, endAyah: 19),
        QuranJuzSegment(surahNumber: 88, startAyah: 1, endAyah: 26),
        QuranJuzSegment(surahNumber: 89, startAyah: 1, endAyah: 30),
        QuranJuzSegment(surahNumber: 90, startAyah: 1, endAyah: 20),
        QuranJuzSegment(surahNumber: 91, startAyah: 1, endAyah: 15),
        QuranJuzSegment(surahNumber: 92, startAyah: 1, endAyah: 21),
        QuranJuzSegment(surahNumber: 93, startAyah: 1, endAyah: 11),
        QuranJuzSegment(surahNumber: 94, startAyah: 1, endAyah: 8),
        QuranJuzSegment(surahNumber: 95, startAyah: 1, endAyah: 8),
        QuranJuzSegment(surahNumber: 96, startAyah: 1, endAyah: 19),
        QuranJuzSegment(surahNumber: 97, startAyah: 1, endAyah: 5),
        QuranJuzSegment(surahNumber: 98, startAyah: 1, endAyah: 8),
        QuranJuzSegment(surahNumber: 99, startAyah: 1, endAyah: 8),
        QuranJuzSegment(surahNumber: 100, startAyah: 1, endAyah: 11),
        QuranJuzSegment(surahNumber: 101, startAyah: 1, endAyah: 11),
        QuranJuzSegment(surahNumber: 102, startAyah: 1, endAyah: 8),
        QuranJuzSegment(surahNumber: 103, startAyah: 1, endAyah: 3),
        QuranJuzSegment(surahNumber: 104, startAyah: 1, endAyah: 9),
        QuranJuzSegment(surahNumber: 105, startAyah: 1, endAyah: 5),
        QuranJuzSegment(surahNumber: 106, startAyah: 1, endAyah: 4),
        QuranJuzSegment(surahNumber: 107, startAyah: 1, endAyah: 7),
        QuranJuzSegment(surahNumber: 108, startAyah: 1, endAyah: 3),
        QuranJuzSegment(surahNumber: 109, startAyah: 1, endAyah: 6),
        QuranJuzSegment(surahNumber: 110, startAyah: 1, endAyah: 3),
        QuranJuzSegment(surahNumber: 111, startAyah: 1, endAyah: 5),
        QuranJuzSegment(surahNumber: 112, startAyah: 1, endAyah: 4),
        QuranJuzSegment(surahNumber: 113, startAyah: 1, endAyah: 5),
        QuranJuzSegment(surahNumber: 114, startAyah: 1, endAyah: 6),
      ],
    ),
  ];

  static QuranSurahReference surahByNumber(int surahNumber) {
    if (surahNumber < 1 || surahNumber > surahCount) {
      throw RangeError.range(surahNumber, 1, surahCount, 'surahNumber');
    }

    return surahs[surahNumber - 1];
  }

  static QuranJuzReference juzByNumber(int juzNumber) {
    if (juzNumber < 1 || juzNumber > juzCount) {
      throw RangeError.range(juzNumber, 1, juzCount, 'juzNumber');
    }

    return juzs[juzNumber - 1];
  }

  static bool isValidPosition(QuranPosition position) {
    if (position.surahNumber < 1 || position.surahNumber > surahCount) {
      return false;
    }

    final ayahCount = surahs[position.surahNumber - 1].ayahCount;
    return position.ayahNumber >= 1 && position.ayahNumber <= ayahCount;
  }

  static int comparePositions(QuranPosition left, QuranPosition right) {
    if (!isValidPosition(left)) {
      throw ArgumentError.value(left, 'left', 'Invalid Quran position');
    }
    if (!isValidPosition(right)) {
      throw ArgumentError.value(right, 'right', 'Invalid Quran position');
    }

    final surahComparison = left.surahNumber.compareTo(right.surahNumber);
    if (surahComparison != 0) {
      return surahComparison;
    }

    return left.ayahNumber.compareTo(right.ayahNumber);
  }

  static bool isValidRange(QuranRange range) {
    if (!isValidPosition(range.start) || !isValidPosition(range.end)) {
      return false;
    }

    return comparePositions(range.start, range.end) <= 0;
  }

  static List<QuranJuzSegment> segmentsForJuz(int juzNumber) =>
      List<QuranJuzSegment>.unmodifiable(juzByNumber(juzNumber).segments);

  static List<QuranSurahReference> surahsForJuz(int juzNumber) {
    final segments = juzByNumber(juzNumber).segments;
    return List<QuranSurahReference>.unmodifiable(
      segments.map((segment) => surahByNumber(segment.surahNumber)),
    );
  }
}
