import 'package:get/get.dart';

class ApiService extends GetConnect {
  Future<List<Map<String, String>>> fetchPokemons() async {
    final response = await get("https://pokeapi.co/api/v2/pokemon?limit=40");

    if (response.statusCode == 200) {
      final results = response.body['results'] as List;

      return results
          .map((p) {
            final url = p['url'] as String;
            final id = url.split('/')[url.split('/').length - 2];
            final imageUrl =
                "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png";

            return {"name": p['name'] as String, "imageUrl": imageUrl};
          })
          .cast<Map<String, String>>()
          .toList();
    }

    return [];
  }
}
