import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Favoritos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final favoritosBox = Hive.box<List>('favoritos');
    List favoritos = favoritosBox.get('lista', defaultValue: []) ?? [];
    return Scaffold(
      appBar: AppBar(title: Text('Pokemones Favoritos')),
      body:
          favoritos.isEmpty
              ? Center(child: Text("No tienes favoritos aún"))
              : ListView.builder(
                itemCount: favoritos.length,
                itemBuilder: (context, index) {
                  var item = favoritos[index];
                  return ListTile(
                    leading: Image.network(
                      item['imagen'],
                      width: 50,
                      height: 50,
                    ),
                    title: Text(item['nombre']),
                  );
                },
              ),
    );
  }
}
