import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pokedex/Pokemon/api.dart';
import 'package:pokedex/Pokemon/colors.dart';
import 'package:pokedex/Pokemon/fetch.dart';
import 'package:pokedex/Pokemon/models.dart';
import 'package:pokedex/Pokemon/models1.dart';

String capitalizeFirstLetter(String input) {
  if (input.isEmpty) return input;
  return input.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}

final Map<String, String> typeImagePaths = {
  'fire': 'images/types/fire.png',
  'water': 'images/types/water.png',
  'grass': 'images/types/grass.png',
  'electric': 'images/types/electric.png',
  'fighting': 'images/types/fighting.png',
  'psychic': 'images/types/psychic.png',
  'flying': 'images/types/flying.png',
  'normal': 'images/types/normal.png',
  'dark': 'images/types/dark.png',
  'dragon': 'images/types/dragon.png',
  'ghost': 'images/types/ghost.png',
  'fairy': 'images/types/fairy.png',
  'rock': 'images/types/rock.png',
  'ground': 'images/types/ground.png',
  'steel': 'images/types/steel.png',
  'poison': 'images/types/poison.png',
  'bug': 'images/types/bug.png',
  'ice': 'images/types/ice.png',
};

final TextStyle textStyle = GoogleFonts.openSans(
  fontSize: 20,
  color: Colors.black,
);

class PokemonDetailsPage extends StatefulWidget {
  final String pokemonId;
  final bool isLightMode;

  PokemonDetailsPage({super.key, required this.pokemonId, required this.isLightMode});

  @override
  State<PokemonDetailsPage> createState() => _PokemonDetailsPageState();
}

class _PokemonDetailsPageState extends State<PokemonDetailsPage> {
  late Future<PokemonInfo> futurePokemonInfo;
  ColorScheme? colorScheme;

  @override
  void initState() {
    super.initState();
    futurePokemonInfo = fetchPokemonDetails(widget.pokemonId);
    ColorScheme.fromImageProvider(
      brightness: Brightness.light,
      provider: NetworkImage(
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${widget.pokemonId}.png'),
    ).then((value) {
      setState(() {
        colorScheme = value;
      });
    }).catchError((e, st) {
      print(e);
      debugPrintStack(stackTrace: st);
    });
  }

  @override
  Widget build(BuildContext context) {
    // final textColor = widget.isLightMode ? Colors.black : Colors.white;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        body: FutureBuilder<PokemonInfo>(
          future: futurePokemonInfo,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.red[900],
                  title: const Text('Error'),
                ),
                body: Container(
                  child: Center(
                      child: Text('Error: ${snapshot.error}',
                          style: GoogleFonts.openSans(
                            fontSize: 16,
                            color: Colors.black,
                          ))),
                ),
              );
            } else if (snapshot.hasData) {
              final pokemon = snapshot.data!;
              final totalStats = pokemon.stats
                  .fold<int>(0, (sum, stat) => sum + stat.baseStat);

              return Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.red[900],
                  title: Text(
                    capitalizeFirstLetter(pokemon.name),
                    style: GoogleFonts.openSans(
                      color: Colors.black,
                      fontSize: 24,
                    ),
                  ),
                ),
                body: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: colorScheme?.primary.withOpacity(1),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 250,
                              height: 200,
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.withOpacity(0.75),
                                border: Border.all(
                                  color: Colors.deepPurple,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: InkWell(
                                onTap: (){
                                  print("Tapped");
                                },
                                child: Image.network(
                                  'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${pokemon.id}.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            capitalizeFirstLetter(pokemon.name),
                            style: GoogleFonts.openSans(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text('Height: ${pokemon.height / 10} m',
                              style: textStyle),
                          Text('Weight: ${pokemon.weight / 10} kg',
                              style: textStyle),
                          const SizedBox(height: 16),
                          Text('Types:',
                              style: textStyle),
                          const SizedBox(height: 8),
                          Row(
                            children: pokemon.types.map((type) {
                              final color = typeColors[type.name] ?? Colors.grey;
                              final imagePath =
                                  typeImagePaths[type.name.toLowerCase()] ??
                                      'images/types/default.png';
                              return Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: typeColors[type.name] ?? Colors.grey,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: color, width: 2),
                                ),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      imagePath,
                                      width: 24,
                                      height: 24,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      capitalizeFirstLetter(type.name),
                                      style: textStyle,
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          Text('Abilities:',
                              style: textStyle),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: pokemon.abilities
                                .map((a) => Text(capitalizeFirstLetter(a.name),
                                style: textStyle))
                                .toList(),
                          ),
                          const SizedBox(height: 16),
                          Text('Base Stats:',
                              style: textStyle),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: pokemon.stats
                                .map((s) => Text(
                                '${capitalizeFirstLetter(s.name)}: ${s.baseStat}',
                                style: textStyle))
                                .toList(),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'BST: $totalStats',
                            style: GoogleFonts.openSans(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return Center(
                  child: Text('No data available',
                      style: textStyle));
            }
          },
        ),
      ),
    );
  }
}
