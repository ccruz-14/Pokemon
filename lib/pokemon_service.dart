import 'package:dio/dio.dart';
import 'pokemon.dart';

class PokemonService {
  final Dio _dio = Dio();

  Future<Pokemon> fetchPokemon(int id) async {
    try {
      final response = await _dio.get('https://pokeapi.co/api/v2/pokemon/$id/');
      return Pokemon.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al cargar la información del Pokémon: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchPokemonList({int limit = 151}) async {
    try {
      final response = await _dio.get('https://pokeapi.co/api/v2/pokemon?limit=$limit');
      final List results = response.data['results'];
      
      return results.asMap().entries.map((entry) {
        final index = entry.key + 1;
        final name = entry.value['name'].toString();
        return {
          'id': index,
          'name': name[0].toUpperCase() + name.substring(1),
        };
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener la lista de Pokémon: $e');
    }
  }
}