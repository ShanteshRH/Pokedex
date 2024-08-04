class PokemonInfo {
  final String id;
  final String name;
  final int height;
  final int weight;
  final List<PokemonType> types;
  final List<PokemonAbility> abilities;
  final List<PokemonStat> stats;
  final PokemonSprites sprites;

  PokemonInfo({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.types,
    required this.abilities,
    required this.stats,
    required this.sprites,
  });

  factory PokemonInfo.fromJson(Map<String, dynamic> json) {
    final id = json['id'].toString();
    final name = json['name'];
    final height = json['height'];
    final weight = json['weight'];
    final types = (json['types'] as List)
        .map((type) => PokemonType.fromJson(type['type']))
        .toList();
    final abilities = (json['abilities'] as List)
        .map((ability) => PokemonAbility.fromJson(ability['ability']))
        .toList();
    final stats = (json['stats'] as List)
        .map((stat) => PokemonStat.fromJson(stat['stat'], stat['base_stat']))
        .toList();
    final sprites = PokemonSprites.fromJson(json['sprites']);

    return PokemonInfo(
      id: id,
      name: name,
      height: height,
      weight: weight,
      types: types,
      abilities: abilities,
      stats: stats,
      sprites: sprites,
    );
  }
}

class PokemonType {
  final String name;

  PokemonType({required this.name});

  factory PokemonType.fromJson(Map<String, dynamic> json) {
    return PokemonType(name: json['name']);
  }
}

class PokemonAbility {
  final String name;

  PokemonAbility({required this.name});

  factory PokemonAbility.fromJson(Map<String, dynamic> json) {
    return PokemonAbility(name: json['name']);
  }
}

class PokemonStat {
  final String name;
  final int baseStat;

  PokemonStat({required this.name, required this.baseStat});

  factory PokemonStat.fromJson(Map<String, dynamic> json, int baseStat) {
    return PokemonStat(name: json['name'], baseStat: baseStat);
  }
}

class PokemonSprites {
  final String frontDefault;

  PokemonSprites({required this.frontDefault});

  factory PokemonSprites.fromJson(Map<String, dynamic> json) {
    return PokemonSprites(
      frontDefault: json['front_default'] ?? '',
    );
  }
}
