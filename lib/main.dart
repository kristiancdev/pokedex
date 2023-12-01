import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class Pokemon {
  final String name;
  final String type;
  final List<String> abilities;
  final List<String> evolutions;
  final String imageUrl;
  final String spriteUrl;

  Pokemon({
    required this.name,
    required this.type,
    required this.abilities,
    required this.evolutions,
    required this.imageUrl,
    required this.spriteUrl,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    List<String> abilities = [];
    for (var ability in json['abilities']) {
      abilities.add(ability['ability']['name']);
    }

    List<String> evolutions = [];
    // You may need to explore the PokeAPI for evolution data structure

    return Pokemon(
      name: json['name'],
      type: json['types'][0]['type']['name'],
      abilities: abilities,
      evolutions: evolutions,
      imageUrl: json['sprites']['other']['official-artwork']['front_default'],
      spriteUrl: json['sprites']['front_default'],
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokedex App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _textFieldController = TextEditingController();
  late Future<Pokemon> _pokemon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokedex'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _textFieldController,
              decoration:
                  const InputDecoration(labelText: 'Enter Pokemon ID or Name'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _pokemon = fetchPokemon(_textFieldController.text);
                });
              },
              child: const Text('Search'),
            ),
            const SizedBox(height: 20),
            FutureBuilder<Pokemon>(
              future: _pokemon,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData) {
                  return const Text(
                      'Enter a Pokemon ID or Name and press Search');
                } else {
                  return Column(
                    children: [
                      Image.network(snapshot.data!.imageUrl),
                      Text('Name: ${snapshot.data!.name}'),
                      Text('Type: ${snapshot.data!.type}'),
                      Text('Abilities: ${snapshot.data!.abilities.join(', ')}'),
                      // Display other information as needed
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<Pokemon> fetchPokemon(String nameOrId) async {
    final response = await http
        .get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$nameOrId/'));
    if (response.statusCode == 200) {
      return Pokemon.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load Pokemon');
    }
  }
}
