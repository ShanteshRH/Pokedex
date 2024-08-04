import 'dart:convert';

import 'package:pokedex/Pokemon/models1.dart';
import 'package:http/http.dart' as http;

Future<PokemonInfo> fetchPokemonDetails(String pokemonId) async{
  final url='https://pokeapi.co/api/v2/pokemon/${pokemonId}/';
  final response = await http.get(Uri.parse(url));

  if(response.statusCode==200){
    final jsonResponse = jsonDecode(response.body);
    return PokemonInfo.fromJson(jsonResponse);
  } else{
    throw Exception("Failed to load Pokemon Details");
  }
}
