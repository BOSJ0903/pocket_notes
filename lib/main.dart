import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';
import 'plant.dart';

void main() {
  runApp(const PocketNotesApp());
}

class PocketNotesApp extends StatefulWidget {
  const PocketNotesApp({super.key});

  @override
  State<PocketNotesApp> createState() => _PocketNotesAppState();
}

class _PocketNotesAppState extends State<PocketNotesApp> {
  // Lab Requirement: Use SharedPreferencesAsync
  final SharedPreferencesAsync prefs = SharedPreferencesAsync();
  bool _isDarkTheme = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    // Note: The 2-second delay from Exp 1 is removed here so the app loads normally
    final bool? isDark = await prefs.getBool('isDarkTheme');
    setState(() {
      _isDarkTheme = isDark ?? false;
    });
  }

  Future<void> _toggleTheme() async {
    setState(() {
      _isDarkTheme = !_isDarkTheme;
    });
    // Save the choice so it survives a restart
    await prefs.setBool('isDarkTheme', _isDarkTheme);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pocket Notes - Plants',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      home: PlantListScreen(
        isDarkTheme: _isDarkTheme,
        onThemeToggled: _toggleTheme,
      ),
    );
  }
}

class PlantListScreen extends StatefulWidget {
  final bool isDarkTheme;
  final VoidCallback onThemeToggled;

  const PlantListScreen({super.key, required this.isDarkTheme, required this.onThemeToggled});

  @override
  State<PlantListScreen> createState() => _PlantListScreenState();
}

class _PlantListScreenState extends State<PlantListScreen> {
  List<Plant> _plants = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  // EXPERIMENT 2: A plain State variable that is never saved
  bool _showFavoritesOnly = false; 

  @override
  void initState() {
    super.initState();
    _refreshPlants();
  }

  Future<void> _refreshPlants() async {
    final data = await DatabaseHelper.instance.getPlants();
    setState(() {
      _plants = data;
    });
  }

  void _showForm(Plant? existingPlant) {
    if (existingPlant != null) {
      _nameController.text = existingPlant.name;
      _notesController.text = existingPlant.wateringNotes;
    } else {
      _nameController.clear();
      _notesController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 15,
          left: 15,
          right: 15,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'Plant Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(hintText: 'Watering Notes'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (existingPlant == null) {
                  await DatabaseHelper.instance.insertPlant(
                    Plant(name: _nameController.text, wateringNotes: _notesController.text),
                  );
                } else {
                  await DatabaseHelper.instance.updatePlant(
                    Plant(
                        id: existingPlant.id,
                        name: _nameController.text,
                        wateringNotes: _notesController.text),
                  );
                }
                _nameController.clear();
                _notesController.clear();
                if (mounted) Navigator.pop(context);
                _refreshPlants();
              },
              child: Text(existingPlant == null ? 'Add Plant' : 'Update Plant'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Plants'),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkTheme ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onThemeToggled,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FilterChip(
              label: const Text('Favorites Only'),
              selected: _showFavoritesOnly,
              onSelected: (bool value) {
                setState(() {
                  _showFavoritesOnly = value;
                });
              },
            ),
          ),
          Expanded(
            child: _plants.isEmpty 
                ? const Center(child: Text('No plants added yet.'))
                : ListView.builder(
                    itemCount: _plants.length,
                    itemBuilder: (context, index) {
                      final plant = _plants[index];
                      return ListTile(
                        title: Text(plant.name),
                        subtitle: Text(plant.wateringNotes),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showForm(plant),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                await DatabaseHelper.instance.deletePlant(plant.id!);
                                _refreshPlants();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
    );
  }
}