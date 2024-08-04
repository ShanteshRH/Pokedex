import 'package:flutter/material.dart';
import 'package:pokedex/Pokemon/details.dart';
import 'package:pokedex/Pokemon/api.dart';
import 'package:pokedex/Pokemon/models.dart';

class PokemonsListPage extends StatefulWidget {
  const PokemonsListPage({super.key});

  @override
  State<PokemonsListPage> createState() => _PokemonsListPageState();
}

class _PokemonsListPageState extends State<PokemonsListPage> {
  List<Pokemon> pokemons = [];
  bool isLoading = true;
  bool isLoadingError = false;
  final ScrollController _scrollController = ScrollController();
  String? highlightedPokemonId;
  bool isLightMode = true;

  @override
  void initState() {
    super.initState();
    getPokemons().then((result) {
      setState(() {
        pokemons = result;
        isLoading = false;
      });
    }).catchError((e, st) {
      setState(() {
        isLoading = false;
        isLoadingError = true;
      });
      print(e);
      debugPrintStack(stackTrace: st);
    });
  }

  void _scrollToPokemon(String pokemonName) {
    int index = pokemons.indexWhere(
      (pokemon) =>
          pokemon.name.trim().toLowerCase() == pokemonName.trim().toLowerCase(),
    );
    print(index);
    if (index != -1) {
      setState(() {
        // Toggle highlight if the same Pokémon is searched again
        if (highlightedPokemonId == pokemons[index].id) {
          highlightedPokemonId = null;
        } else {
          highlightedPokemonId = pokemons[index].id;
        }
      });
      const int itemsPerRow = 3;
      final screenHeight = MediaQuery.of(context)
          .size
          .height; // Approximate height including padding/margin
      double targetOffset = (index / 3) * screenHeight / 4.75;
      _scrollController.animateTo(
        targetOffset, // Adjust according to item height
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pokemon not found')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Pokedex'),
          backgroundColor: Colors.red[600],
          foregroundColor:
              isLightMode ? Colors.yellowAccent : Colors.blueAccent.shade700,
          leading: InkWell(
            onTap: () {
              setState(() {
                if (isLightMode) {
                  isLightMode = false;
                } else {
                  isLightMode = true;
                }
              });
            },
            child: Icon(
              isLightMode ? Icons.sunny : Icons.nightlight_round_outlined,
            ),
          ),
        ),
        body: Container(
          color: isLightMode ? Colors.white : Colors.black,
          child: isLoading
              ? const CircularProgressIndicator()
              : isLoadingError
                  ? const Icon(Icons.warning)
                  : PokemonsList(
                      pokemons: pokemons,
                      scrollController: _scrollController,
                      highlightedPokemonId: highlightedPokemonId,
                      onPokemonTap: () {
                        setState(() {
                          highlightedPokemonId = null;
                        });
                      },
                      isLightMode: isLightMode,
                    ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.red[600],
          onPressed: () {
            showModalBottomSheet(
              backgroundColor:
                  isLightMode ? Colors.grey.shade800 : Colors.white,
              context: context,
              builder: (context) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('Search Pokemon'),
                      TextField(
                        cursorColor: Colors.black,
                        style: TextStyle(
                          color: isLightMode ? Colors.white : Colors.black,
                        ),
                        decoration: const InputDecoration(
                            hintText: 'Enter Pokemon name'),
                        onSubmitted: (query) {
                          Navigator.pop(context);
                          _scrollToPokemon(query);
                        },
                      )
                    ],
                  ),
                );
              },
            );
          },
          child: const Icon(
            Icons.search,
          ),
        ),
      ),
    );
  }
}

class PokemonsList extends StatelessWidget {
  final List<Pokemon> pokemons;
  final ScrollController scrollController;
  final String? highlightedPokemonId;
  final VoidCallback? onPokemonTap;
  final bool isLightMode;

  const PokemonsList({
    super.key,
    required this.pokemons,
    required this.scrollController,
    this.highlightedPokemonId,
    this.onPokemonTap,
    required this.isLightMode,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: scrollController,
      itemCount: pokemons.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        final pokemon = pokemons[index];
        return PokemonWidget(
          pokemon: pokemon,
          isHighlighted: pokemon.id == highlightedPokemonId,
          onTap: () {
            if (onPokemonTap != null) onPokemonTap!();
          },
          isLightMode: isLightMode,
        );
      },
    );
  }
}

class PokemonWidget extends StatelessWidget {
  final Pokemon pokemon;
  final bool isHighlighted;
  final VoidCallback? onTap;
  final bool isLightMode;

  const PokemonWidget({
    super.key,
    required this.pokemon,
    required this.isHighlighted,
    this.onTap,
    required this.isLightMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: isHighlighted
            ? Colors.yellowAccent.withOpacity(0.75)
            : Colors.deepPurple.withOpacity(0.75),
        border: Border.all(
          color: Colors.blue,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          if (onTap != null) {
            onTap!();
          }
          var navigatorState = Navigator.of(context);
          navigatorState.push(MaterialPageRoute(
            builder: (context) {
              return PokemonDetailsPage(
                pokemonId: pokemon.id,
                isLightMode: isLightMode,
              );
            },
          ));
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Hero(
              tag: pokemon.id,
              child: Image.network(
                  'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${pokemon.id}.png'),
            ),
            const SizedBox(
              height: 8,
            ),
            Expanded(
              child: Text(
                capitalizeFirstLetter(pokemon.name),
                style: TextStyle(
                    color: isLightMode ? Colors.black : Colors.white,
                    fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
