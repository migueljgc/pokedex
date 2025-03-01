import 'package:flutter/material.dart';
import 'package:pokedex/servicio/pokedexServicio.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';

class InformacionVista extends StatefulWidget {
  final Pokemon pokemon;

  const InformacionVista({super.key, required this.pokemon});

  @override
  _InformacionVistaState createState() => _InformacionVistaState();
}

class _InformacionVistaState extends State<InformacionVista> {
  late Box<List> favoritosBox;

  @override
  void initState() {
    super.initState();
    favoritosBox = Hive.box<List>('favoritos');
  }

  bool _esFavorito() {
    List favoritos = favoritosBox.get('lista', defaultValue: []) ?? [];
    return favoritos.any((item) => item['nombre'] == widget.pokemon.nombre);
  }

  void _toggleFavorito() {
    List favoritos = favoritosBox.get('lista', defaultValue: []) ?? [];

    if (_esFavorito()) {
      favoritos.removeWhere((item) => item['nombre'] == widget.pokemon.nombre);
    } else {
      favoritos.add({
        'nombre': widget.pokemon.nombre,
        'imagen': widget.pokemon.imagen,
        'tipo': widget.pokemon.tipo,
        'hp': widget.pokemon.hp,
        'ataque': widget.pokemon.ataque,
        'defensa': widget.pokemon.defensa,
        'habilidades': widget.pokemon.habilidades,
      });
    }

    favoritosBox.put('lista', favoritos);
    setState(() {}); // Refresca la UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Datos de ${widget.pokemon.nombre}'),
        actions: [
          IconButton(
            icon: Icon(
              _esFavorito() ? Icons.star : Icons.star_border,
              color: _esFavorito() ? Colors.yellow : Colors.grey,
            ),
            onPressed: _toggleFavorito,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.network(
                  widget.pokemon.imagen,
                  width: 150,
                  height: 150,
                ),
              ),
              Text('Nombre: ${widget.pokemon.nombre}'),
              Text('Tipo: ${widget.pokemon.tipo}'),
              Text('HP: ${widget.pokemon.hp}'),
              Text('Ataque: ${widget.pokemon.ataque}'),
              Text('Defensa: ${widget.pokemon.defensa}'),
              Text('Habilidades: ${widget.pokemon.habilidades.join(', ')}'),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        color: Colors.red,
                        value: widget.pokemon.hp.toDouble(),
                        title: 'HP ${widget.pokemon.hp}',
                        radius: 100,
                      ),
                      PieChartSectionData(
                        color: Colors.green,
                        value: widget.pokemon.ataque.toDouble(),
                        title: 'Ataque ${widget.pokemon.ataque}',
                        radius: 100,
                      ),
                      PieChartSectionData(
                        color: Colors.blue,
                        value: widget.pokemon.defensa.toDouble(),
                        title: 'Defensa ${widget.pokemon.defensa}',
                        radius: 100,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
