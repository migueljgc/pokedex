import 'dart:convert'; // Para manejar la conversión de JSON a objetos de Dart
import 'package:http/http.dart'
    as http; // Importamos la librería http para hacer la solicitud

class Pokemon {
  final String nombre;
  final String imagen;
  final String tipo;
  final int hp;
  final int ataque;
  final int defensa;
  final List<String> habilidades; // Lista de habilidades

  Pokemon({
    required this.nombre,
    required this.imagen,
    required this.tipo,
    required this.hp,
    required this.ataque,
    required this.defensa,
    required this.habilidades,
  });
}

class PokedexServicio {
  // Base URL de la API de PokeAPI con offset y limit
  final String _baseUrl =
      'https://pokeapi.co/api/v2/pokemon/?offset=0&limit=1304';

  // Método para hacer la solicitud HTTP y obtener la lista de Pokémon
  Future<List<Pokemon>> fetchPokemon() async {
    try {
      // Hacemos la solicitud HTTP a la API
      final response = await http.get(Uri.parse(_baseUrl));

      // Verificamos si la respuesta es exitosa (código 200)
      if (response.statusCode == 200) {
        // Decodificamos el cuerpo de la respuesta que viene en formato JSON
        Map<String, dynamic> data = jsonDecode(response.body);

        // Extraemos la lista de Pokémon
        List<dynamic> results = data['results'];

        // Lista para almacenar los Pokémon
        List<Pokemon> pokemonList = [];

        // Recorremos cada Pokémon para obtener sus detalles
        for (var result in results) {
          // Hacemos una solicitud a la URL del Pokémon para obtener sus detalles
          final pokemonResponse = await http.get(Uri.parse(result['url']));

          if (pokemonResponse.statusCode == 200) {
            Map<String, dynamic> pokemonData = jsonDecode(pokemonResponse.body);

            // Extraemos los datos necesarios
            String nombre = pokemonData['name'] ?? 'Desconocido';
            String imagen =
                pokemonData['sprites']['front_default'] ??
                'https://via.placeholder.com/80';
            String tipo =
                (pokemonData['types'] != null &&
                        pokemonData['types'].isNotEmpty)
                    ? pokemonData['types'][0]['type']['name']
                    : 'Desconocido';
            int hp =
                (pokemonData['stats'] != null &&
                        pokemonData['stats'].length > 0)
                    ? pokemonData['stats'][0]['base_stat']
                    : 0;
            int ataque =
                (pokemonData['stats'] != null &&
                        pokemonData['stats'].length > 1)
                    ? pokemonData['stats'][1]['base_stat']
                    : 0;
            int defensa =
                (pokemonData['stats'] != null &&
                        pokemonData['stats'].length > 2)
                    ? pokemonData['stats'][2]['base_stat']
                    : 0;
            List<String> habilidades = [];
            if (pokemonData['moves'] != null) {
              for (var ability in pokemonData['moves']) {
                habilidades.add(ability['move']['name']);
              }
            }

            // Creamos un objeto Pokemon y lo añadimos a la lista
            pokemonList.add(
              Pokemon(
                nombre: nombre,
                imagen: imagen,
                tipo: tipo,
                hp: hp,
                ataque: ataque,
                defensa: defensa,
                habilidades: habilidades,
              ),
            );
          }
        }

        // Retornamos la lista de Pokémon
        return pokemonList;
      } else {
        // Si hubo un error, lanzamos una excepción
        print('Error: ${response.statusCode} - ${response.reasonPhrase}');
        throw Exception('Error al cargar los Pokémon');
      }
    } catch (e) {
      // Imprime el error en caso de excepción
      print('Exception caught: $e');
      throw Exception('Error de red: no se pudo cargar la lista de Pokémon');
    }
  }
}
