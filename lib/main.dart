import 'package:flutter/material.dart';
import 'pokemon.dart';
import 'pokemon_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PokéApp Pro',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: const PokemonScreen(),
    );
  }
}

class PokemonScreen extends StatefulWidget {
  const PokemonScreen({super.key});

  @override
  State<PokemonScreen> createState() => _PokemonScreenState();
}

class _PokemonScreenState extends State<PokemonScreen> {
  final PokemonService _pokemonService = PokemonService();
  int _pokemonId = 1;
  late Future<Pokemon> _pokemonFuture;
  late Future<List<Map<String, dynamic>>> _pokemonListFuture;

  // Colores por tipo de Pokémon
  final Map<String, Color> _typeColors = {
    'grass': Colors.green,
    'fire': Colors.orangeAccent,
    'water': Colors.blue,
    'bug': Colors.lightGreen,
    'normal': Colors.grey,
    'poison': Colors.purple,
    'electric': Colors.amber,
    'ground': Colors.brown,
    'fairy': Colors.pinkAccent,
    'fighting': Colors.deepOrange,
    'psychic': Colors.pink,
    'rock': Colors.grey.shade700,
    'ghost': Colors.indigo,
    'ice': Colors.cyan,
    'dragon': Colors.deepPurple,
  };

  @override
  void initState() {
    super.initState();
    _loadPokemon();
    _pokemonListFuture = _pokemonService.fetchPokemonList();
  }

  void _loadPokemon() {
    setState(() {
      _pokemonFuture = _pokemonService.fetchPokemon(_pokemonId);
    });
  }

  void _selectPokemon(int id) {
    setState(() {
      _pokemonId = id;
      _loadPokemon();
    });
    Navigator.of(context).pop();
  }

  void _nextPokemon() {
    setState(() {
      _pokemonId++;
      _loadPokemon();
    });
  }

  void _previousPokemon() {
    if (_pokemonId > 1) {
      setState(() {
        _pokemonId--;
        _loadPokemon();
      });
    }
  }

  // Modal para ampliar imagen con Zoom
  void _openImageDialog(String imageUrl, String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 250,
                    width: double.infinity,
                    child: InteractiveViewer(
                      panEnabled: true,
                      minScale: 0.8,
                      maxScale: 4.0,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pellizca o haz doble toque para hacer zoom',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: Text(
          'Pokédex #${_pokemonId.toString().padLeft(3, '0')}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo.shade100,
      ),
      endDrawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.indigo.shade100),
              child: const Center(
                child: Text(
                  'Lista de Pokémon',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _pokemonListFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasData) {
                    final list = snapshot.data!;
                    return ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final item = list[index];
                        final isSelected = item['id'] == _pokemonId;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isSelected
                                ? Colors.indigo
                                : Colors.indigo.shade50,
                            child: Text(
                              '${item['id']}',
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.indigo.shade900,
                              ),
                            ),
                          ),
                          title: Text(
                            item['name'],
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          onTap: () => _selectPokemon(item['id']),
                        );
                      },
                    );
                  }
                  return const Center(child: Text('Sin datos'));
                },
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder<Pokemon>(
        future: _pokemonFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar información'));
          } else if (snapshot.hasData) {
            final pokemon = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              child: Column(
                children: [
                  // Nombre y Tipos
                  Text(
                    pokemon.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.indigo.shade900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: pokemon.types.map((type) {
                      final color = _typeColors[type] ?? Colors.indigo;
                      return Chip(
                        label: Text(
                          type.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: color,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Tarjetas de Imagen (Agrandables)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildInteractiveSpriteCard(
                        pokemon.frontSprite,
                        'Vista Frontal',
                      ),
                      _buildInteractiveSpriteCard(
                        pokemon.backSprite,
                        'Vista Trasera',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Datos Físicos (Altura / Peso)
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildPhysicalInfo(
                            Icons.straighten,
                            '${pokemon.height} m',
                            'Altura',
                          ),
                          Container(
                            height: 40,
                            width: 1,
                            color: Colors.grey.shade300,
                          ),
                          _buildPhysicalInfo(
                            Icons.fitness_center,
                            '${pokemon.weight} kg',
                            'Peso',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Ficha de Estadísticas
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Estadísticas de Base',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),
                          ...pokemon.stats.entries.map((entry) {
                            return _buildStatRow(entry.key, entry.value);
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_pokemonId > 1)
              FloatingActionButton.extended(
                heroTag: 'prev',
                onPressed: _previousPokemon,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Anterior'),
              )
            else
              const SizedBox.shrink(),
            FloatingActionButton.extended(
              heroTag: 'next',
              onPressed: _nextPokemon,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Siguiente'),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para las imágenes interactivas
  Widget _buildInteractiveSpriteCard(String url, String title) {
    return InkWell(
      onTap: () => _openImageDialog(url, title),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 50),
                ),
              ),
              Positioned(
                right: 6,
                bottom: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.indigo,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.zoom_in,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  // Widget para información de Altura y Peso
  Widget _buildPhysicalInfo(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.indigo, size: 20),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }

  // Widget para cada barra de estadística
  Widget _buildStatRow(String statName, int value) {
    // Nombre amigable para la estadística
    final Map<String, String> statNames = {
      'hp': 'HP',
      'attack': 'Ataque',
      'defense': 'Defensa',
      'special-attack': 'At. Esp.',
      'special-defense': 'Def. Esp.',
      'speed': 'Velocidad',
    };

    final displayName = statNames[statName] ?? statName;
    final double percent = (value / 160.0).clamp(0.0, 1.0); // Máximo relativo

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              displayName,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
          SizedBox(
            width: 35,
            child: Text(
              '$value',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  percent > 0.5 ? Colors.green : Colors.orange,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}