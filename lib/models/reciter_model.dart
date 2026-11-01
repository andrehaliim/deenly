/// A qari whose per-ayah recitation is served by everyayah.com.
class ReciterModel {
  /// Folder under https://everyayah.com/data/, also used as the saved id.
  final String id;
  final String name;

  /// ISO 3166 alpha-2 code of the qari's country, for the flag.
  final String countryCode;

  /// Recitation style shown under the name, e.g. Murattal or Muallim.
  final String style;

  /// Whether the folder has its own audhubillah.mp3; when not, the
  /// default reciter's ta'awudz is played instead.
  final bool hasTaawudz;

  const ReciterModel({
    required this.id,
    required this.name,
    required this.countryCode,
    this.style = 'Murattal',
    this.hasTaawudz = false,
  });

  /// Name with the style when it isn't the usual Murattal, for places
  /// that show the name alone.
  String get label => style == 'Murattal' ? name : '$name ($style)';

  static const ReciterModel defaultReciter = ReciterModel(
    id: 'Alafasy_128kbps',
    name: 'Mishary Rashid Alafasy',
    countryCode: 'KW',
    hasTaawudz: true,
  );

  /// Hafs recitations with good quality, checked against everyayah.com.
  static const List<ReciterModel> all = [
    defaultReciter,
    ReciterModel(
      id: 'Abdurrahmaan_As-Sudais_192kbps',
      name: 'Abdurrahman As-Sudais',
      countryCode: 'SA',
    ),
    ReciterModel(
      id: 'Saood_ash-Shuraym_128kbps',
      name: 'Saud Asy-Syuraim',
      countryCode: 'SA',
      hasTaawudz: true,
    ),
    ReciterModel(
      id: 'MaherAlMuaiqly128kbps',
      name: 'Maher Al-Muaiqly',
      countryCode: 'SA',
    ),
    ReciterModel(
      id: 'Abdul_Basit_Murattal_192kbps',
      name: 'Abdul Basit Abdus Samad',
      countryCode: 'EG',
    ),
    ReciterModel(
      id: 'Husary_128kbps',
      name: 'Mahmoud Khalil Al-Husary',
      countryCode: 'EG',
      hasTaawudz: true,
    ),
    ReciterModel(
      id: 'Husary_Muallim_128kbps',
      name: 'Mahmoud Khalil Al-Husary',
      countryCode: 'EG',
      style: 'Muallim',
    ),
    ReciterModel(
      id: 'Minshawy_Murattal_128kbps',
      name: 'Muhammad Siddiq Al-Minshawi',
      countryCode: 'EG',
    ),
    ReciterModel(
      id: 'Abu_Bakr_Ash-Shaatree_128kbps',
      name: 'Abu Bakr Asy-Syatri',
      countryCode: 'SA',
      hasTaawudz: true,
    ),
    ReciterModel(
      id: 'Hudhaify_128kbps',
      name: 'Ali Al-Hudhaifi',
      countryCode: 'SA',
      hasTaawudz: true,
    ),
    ReciterModel(
      id: 'Yasser_Ad-Dussary_128kbps',
      name: 'Yasser Ad-Dosari',
      countryCode: 'SA',
    ),
    ReciterModel(
      id: 'Nasser_Alqatami_128kbps',
      name: 'Nasser Al-Qatami',
      countryCode: 'SA',
    ),
    ReciterModel(
      id: 'Hani_Rifai_192kbps',
      name: 'Hani Ar-Rifai',
      countryCode: 'SA',
    ),
    ReciterModel(
      id: 'Abdullah_Basfar_192kbps',
      name: 'Abdullah Basfar',
      countryCode: 'SA',
    ),
    ReciterModel(
      id: 'Muhammad_Ayyoub_128kbps',
      name: 'Muhammad Ayyub',
      countryCode: 'SA',
      hasTaawudz: true,
    ),
    ReciterModel(
      id: 'Salah_Al_Budair_128kbps',
      name: 'Salah Al-Budair',
      countryCode: 'SA',
    ),
  ];

  static ReciterModel byId(String? id) =>
      all.firstWhere((r) => r.id == id, orElse: () => defaultReciter);
}
