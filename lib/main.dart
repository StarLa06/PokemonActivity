import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const PokemonActivityApp());
}

class PokemonActivityApp extends StatelessWidget {
  const PokemonActivityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokemon Activity',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        useMaterial3: true,
      ),
      home: const PokemonSearchScreen(),
    );
  }
}

// Data Model matching lesson concepts
class PokemonDetail {
  final int id;
  final String name;
  final int baseExperience;
  final int height;
  final int weight;
  final String imageUrl;
  final List<dynamic> abilities;
  final List<dynamic> types;

  PokemonDetail({
    required this.id,
    required this.name,
    required this.baseExperience,
    required this.height,
    required this.weight,
    required this.imageUrl,
    required this.abilities,
    required this.types,
  });

  factory PokemonDetail.fromJson(Map<String, dynamic> json) {
    return PokemonDetail(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      baseExperience: json['base_experience'] ?? 0,
      height: json['height'] ?? 0,
      weight: json['weight'] ?? 0,
      imageUrl: json['sprites']?['front_default'] ?? '',
      abilities: json['abilities'] ?? [],
      types: json['types'] ?? [],
    );
  }
}

class PokemonSearchScreen extends StatefulWidget {
  const PokemonSearchScreen({super.key});

  @override
  State<PokemonSearchScreen> createState() => _PokemonSearchScreenState();
}

class _PokemonSearchScreenState extends State<PokemonSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;
  PokemonDetail? _pokemon;

  // Function implementing HTTP GET request and error handling from lesson guidelines
  Future<void> fetchPokemon(String pokemonName) async {
    if (pokemonName.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _pokemon = null;
    });

    try {
      final formattedName = pokemonName.trim().toLowerCase();
      final url = Uri.parse('https://pokeapi.co/api/v2/pokemon/$formattedName');
      
      // Asynchronous HTTP GET request[cite: 13]
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Decode JSON response body into a Map[cite: 12]
        final decodedData = jsonDecode(response.body);
        
        if (decodedData is! Map<String, dynamic>) {
          throw const FormatException('Unexpected response format.');
        }

        setState(() {
          _pokemon = PokemonDetail.fromJson(decodedData);
          _isLoading = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _errorMessage = 'Pokémon "$pokemonName" does not exist. Please try another name.';
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Server error: Status code ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error or failed to connect. Please check your internet connection.';
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPokemon('MANKEY');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokémon API Activity'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Input Row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Enter Pokémon Name (e.g. seviper, pikachu)',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) => fetchPokemon(value),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  ),
                  onPressed: _isLoading ? null : () => fetchPokemon(_controller.text),
                  child: const Text('Search'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Dynamic Body Content (Loading, Error, or Data)
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : _pokemon == null
                          ? const Center(child: Text('Search for a Pokémon to begin.'))
                          : ListView(
                              children: [
                                // Profile & Sprite Card
                                Card(
                                  elevation: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      children: [
                                        if (_pokemon!.imageUrl.isNotEmpty)
                                          Image.network(
                                            _pokemon!.imageUrl,
                                            height: 140,
                                            width: 140,
                                            fit: BoxFit.contain,
                                          ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _pokemon!.name.toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Divider(),
                                        Text('ID: ${_pokemon!.id}', style: const TextStyle(fontSize: 16)),
                                        Text('Base Experience: ${_pokemon!.baseExperience}', style: const TextStyle(fontSize: 16)),
                                        Text('Height: ${_pokemon!.height}', style: const TextStyle(fontSize: 16)),
                                        Text('Weight: ${_pokemon!.weight}', style: const TextStyle(fontSize: 16)),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                // Abilities Card
                                Card(
                                  elevation: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Abilities',
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                        const Divider(),
                                        ..._pokemon!.abilities.map((abilityInfo) {
                                          final name = abilityInfo['ability']['name'];
                                          final isHidden = abilityInfo['is_hidden'];
                                          final slot = abilityInfo['slot'];
                                          return ListTile(
                                            dense: true,
                                            title: Text('Ability: $name'),
                                            subtitle: Text('Slot: $slot | Hidden: $isHidden'),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Types Card
                                Card(
                                  elevation: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Types',
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                        const Divider(),
                                        ..._pokemon!.types.map((typeInfo) {
                                          final name = typeInfo['type']['name'];
                                          final slot = typeInfo['slot'];
                                          return ListTile(
                                            dense: true,
                                            title: Text('Type: $name'),
                                            subtitle: Text('Slot: $slot'),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
            ),
          ],
        ),
      ),
    );
  }
}