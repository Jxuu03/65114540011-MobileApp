import 'package:get/get.dart';

// Service to fetch Pokémon
class ApiService {
  final client = GetConnect();

  Future<List<String>> fetchPokemons() async {
    final response = await client.get(
      "https://pokeapi.co/api/v2/pokemon?limit=40",
    );
    if (response.statusCode == 200) {
      return (response.body['results'] as List)
          .map((p) => p['name'].toString())
          .toList();
    }
    return [];
  }
}
