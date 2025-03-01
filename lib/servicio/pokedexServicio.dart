import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

class Pokemon {
  final String nombre;
  final String imagen;
  final String tipo;
  final int hp;
  final int ataque;
  final int defensa;
  final List<String> habilidades;

  Pokemon({
    required this.nombre,
    required this.imagen,
    required this.tipo,
    required this.hp,
    required this.ataque,
    required this.defensa,
    required this.habilidades,
  });

  // Método para convertir un Pokémon a un mapa (para guardar en Hive)
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'imagen': imagen,
      'tipo': tipo,
      'hp': hp,
      'ataque': ataque,
      'defensa': defensa,
      'habilidades': habilidades,
    };
  }

  // Método para crear un Pokémon desde un mapa (cuando se lee de Hive)
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      nombre: json['nombre'],
      imagen: json['imagen'],
      tipo: json['tipo'],
      hp: json['hp'],
      ataque: json['ataque'],
      defensa: json['defensa'],
      habilidades: List<String>.from(json['habilidades']),
    );
  }
}

class PokedexServicio {
  final String _baseUrl =
      'https://pokeapi.co/api/v2/pokemon/?offset=0&limit=1304';
  final Box _pokemonBox = Hive.box('pokemonBox');

  Future<List<Pokemon>> fetchPokemon() async {
    try {
      // Verificar si hay datos en caché
      if (_pokemonBox.containsKey('pokemonList')) {
        print('Cargando Pokémon desde Hive...');
        List<dynamic> cachedData = _pokemonBox.get('pokemonList');
        return cachedData
            .map((e) => Pokemon.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }

      print('Haciendo solicitud a la API...');
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        List<dynamic> results = data['results'];
        List<Pokemon> pokemonList = [];

        for (var result in results) {
          final pokemonResponse = await http.get(Uri.parse(result['url']));
          if (pokemonResponse.statusCode == 200) {
            Map<String, dynamic> pokemonData = jsonDecode(pokemonResponse.body);

            String nombre = pokemonData['name'] ?? 'Desconocido';
            String imagen =
                pokemonData['sprites']['front_default'] ??
                'https://via.placeholder.com/80';
            String tipo =
                (pokemonData['types']?.isNotEmpty ?? false)
                    ? pokemonData['types'][0]['type']['name']
                    : 'Desconocido';
            int hp =
                (pokemonData['stats']?.isNotEmpty ?? false)
                    ? pokemonData['stats'][0]['base_stat']
                    : 0;
            int ataque =
                (pokemonData['stats']?.length > 1)
                    ? pokemonData['stats'][1]['base_stat']
                    : 0;
            int defensa =
                (pokemonData['stats']?.length > 2)
                    ? pokemonData['stats'][2]['base_stat']
                    : 0;

            List<String> habilidades = [];
            if (pokemonData['moves'] != null) {
              habilidades = List<String>.from(
                pokemonData['moves'].map(
                  (move) => move['move']['name'].toString(),
                ),
              );
            }

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

        // Guardar en Hive antes de devolver
        _pokemonBox.put(
          'pokemonList',
          pokemonList.map((p) => p.toJson()).toList(),
        );

        return pokemonList;
      } else {
        throw Exception('Error al cargar los Pokémon: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('No se pudo cargar la lista de Pokémon');
    }
  }
}
