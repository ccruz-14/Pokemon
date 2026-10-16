class Pokemon {
  final int id;
  final String name;
  final String frontSprite;
  final String backSprite;
  final double height; // en metros
  final double weight; // en kg
  final List<String> types;
  final List<String> abilities;
  final Map<String, int> stats;

  Pokemon({
    required this.id,
    required this.name,
    required this.frontSprite,
    required this.backSprite,
    required this.height,
    required this.weight,
    required this.types,
    required this.abilities,
    required this.stats,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    // Tipos
    final typesList = (json['types'] as List)
        .map((t) => t['type']['name'].toString())
        .toList();

    // Habilidades
    final abilitiesList = (json['abilities'] as List)
        .map((a) => a['ability']['name'].toString())
        .toList();

    // Estadísticas
    final Map<String, int> statsMap = {};
    for (var stat in json['stats']) {
      statsMap[stat['stat']['name']] = stat['base_stat'];
    }

    return Pokemon(
      id: json['id'],
      name: json['name'],
      frontSprite: json['sprites']['front_default'] ?? '',
      backSprite: json['sprites']['back_default'] ?? '',
      height: (json['height'] as int) / 10, // Decímetros a metros
      weight: (json['weight'] as int) / 10, // Hectogramos a kg
      types: typesList,
      abilities: abilitiesList,
      stats: statsMap,
    );
  }
}