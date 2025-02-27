import 'package:flutter/material.dart';
import 'package:pokedex/servicio/pokedexServicio.dart';
import 'package:fl_chart/fl_chart.dart';

class InformacionVista extends StatelessWidget {
  final Pokemon pokemon;
  const InformacionVista({Key? key, required this.pokemon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Datos de ${pokemon.nombre}')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.network(pokemon.imagen, width: 150, height: 150),
              ),
              Text('Nombre: ${pokemon.nombre}'),
              Text('Tipo: ${pokemon.tipo}'),

              Text('HP: ${pokemon.hp}'),
              Text('Ataque: ${pokemon.ataque}'),
              Text('Defensa: ${pokemon.defensa}'),
              Text('Habilidades: ${pokemon.habilidades.join(', ')}'),
              SizedBox(
                height: 200, // Altura fija para el gráfico
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        color: Colors.red,
                        value: pokemon.hp.toDouble(),
                        title: 'HP ${pokemon.hp}',
                        radius: 100,
                      ),
                      PieChartSectionData(
                        color: Colors.green,
                        value: pokemon.ataque.toDouble(),
                        title: 'Ataque ${pokemon.ataque}',
                        radius: 100,
                      ),
                      PieChartSectionData(
                        color: Colors.blue,
                        value: pokemon.defensa.toDouble(),

                        title: 'Defensa ${pokemon.defensa}',
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
