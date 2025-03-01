import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pokedex/servicio/pokedexServicio.dart';
import 'package:pokedex/vista/favoritos.dart';
import 'package:pokedex/vista/informacion.dart';
import 'package:pokedex/modelo/ThemeProvider.dart'; // Ensure this path is correct
import 'package:provider/provider.dart';

class Lista extends StatefulWidget {
  const Lista({super.key});

  @override
  _ListaViewState createState() => _ListaViewState();
}

class _ListaViewState extends State<Lista> {
  late Future<List<Pokemon>> _listFuture;
  List<Pokemon> _pokemons = [];
  List<Pokemon> _filteredPokemons = [];
  String _searchQuery = '';
  String _selectedType = 'Todos';
  Timer? _debounce;

  int _currentPage = 0;
  final int _itemsPerPage = 20;

  @override
  void initState() {
    super.initState();
    _fetchPokemons();
  }

  void _fetchPokemons() async {
    _listFuture = PokedexServicio().fetchPokemon();
    _listFuture.then((pokemons) {
      setState(() {
        _pokemons = pokemons;
        _applyFilters();
      });
    });
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(Duration(milliseconds: 400), () {
      setState(() {
        _searchQuery = query.toLowerCase();
        _currentPage = 0; // Reiniciar a la primera página
        _applyFilters();
      });
    });
  }

  void _onTypeChanged(String? selectedType) {
    if (selectedType == null) return;

    setState(() {
      _selectedType = selectedType;
      _currentPage = 0; // Reiniciar a la primera página
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<Pokemon> filtered =
        _pokemons.where((pokemon) {
          bool matchesSearch =
              _searchQuery.isEmpty ||
              pokemon.nombre.toLowerCase().contains(_searchQuery);
          bool matchesType =
              _selectedType == 'Todos' || pokemon.tipo == _selectedType;
          return matchesSearch && matchesType;
        }).toList();

    setState(() {
      _filteredPokemons = filtered;
    });
  }

  void _nextPage() {
    if ((_currentPage + 1) * _itemsPerPage < _filteredPokemons.length) {
      setState(() {
        _currentPage++;
      });
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    List<Pokemon> paginatedPokemons =
        _filteredPokemons
            .skip(_currentPage * _itemsPerPage)
            .take(_itemsPerPage)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Pokédex'),
        actions: [
          // Ícono de estrella en el AppBar
          IconButton(
            icon: Icon(Icons.star), // Ícono de estrella
            onPressed: () {
              // Navegar a la nueva pantalla
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Favoritos()),
              );
            },
          ),

          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return ElevatedButton(
                onPressed: () {
                  final newMode =
                      themeProvider.isDarkMode
                          ? ThemeMode.light
                          : ThemeMode.dark;
                  themeProvider.setThemeMode(newMode);
                },
                child: Text(
                  themeProvider.isDarkMode
                      ? "Activar Modo claro"
                      : "Activar Modo Oscuro",
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Buscar Pokémon',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButton<String>(
              value: _selectedType,
              onChanged: _onTypeChanged,
              items:
                  [
                        'Todos',
                        'water',
                        'fire',
                        'poison',
                        'fighting',
                        'grass',
                        'bug',
                        'normal',
                        'rock',
                        'ghost',
                        'pychic',
                        'electric',
                        'fairy',
                        'ice',
                        'steel',
                      ]
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Pokemon>>(
              future: _listFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error al cargar Pokémon'));
                } else if (_filteredPokemons.isEmpty) {
                  return Center(child: Text('No hay Pokémon disponibles'));
                } else {
                  return ListView.builder(
                    itemCount: paginatedPokemons.length,
                    itemBuilder: (context, index) {
                      var pokemon = paginatedPokemons[index];
                      return ListTile(
                        leading: Image.network(
                          pokemon.imagen,
                          width: 80,
                          height: 50,
                          errorBuilder:
                              (context, error, stackTrace) => Icon(Icons.error),
                        ),
                        title: Text(pokemon.nombre),
                        subtitle: Text(pokemon.tipo),
                        trailing: IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        InformacionVista(pokemon: pokemon),
                              ),
                            );
                          },
                          icon: Icon(Icons.arrow_forward_ios),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _currentPage > 0 ? _previousPage : null,
                  child: Text('Anterior'),
                ),
                SizedBox(width: 20),
                Text('Página ${_currentPage + 1}'),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed:
                      ((_currentPage + 1) * _itemsPerPage <
                              _filteredPokemons.length)
                          ? _nextPage
                          : null,
                  child: Text('Siguiente'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
