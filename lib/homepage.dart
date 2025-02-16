import 'package:flutter/material.dart';
import 'dart:async'; // Import pour utiliser Timer

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int counter = 0; // Cookies actuels
  int step = 1; // Nombre de cookies gagnés par clic
  int totalCookies = 0; // Total de cookies générés
  int passiveCookiesPerSecond = 0; // Cookies générés automatiquement chaque seconde
  Timer? _timer; // Timer pour les revenus passifs

  // Liste des upgrades achetables (ajout des revenus passifs)
  final List<Map<String, dynamic>> upgrades = [
    {'name': 'Double cookie', 'cost': 50, 'increment': 1, 'purchased': false, 'unique': true},
    {'name': 'Super cookie', 'cost': 200, 'increment': 6, 'purchased': false, 'unique': true},
    {'name': 'Mega cookie', 'cost': 500, 'increment': 15, 'purchased': false, 'unique': true},
    {'name': 'Cookie bonus', 'cost': 2000, 'increment': 0, 'purchased': false, 'unique': true},
    {'name': 'Cookie infini', 'cost': 5000, 'increment': 1, 'purchased': false, 'unique': false},
    {'name': 'Usine à Cookies', 'cost': 1000, 'increment': 5, 'purchased': false, 'unique': false, 'passive': true},
    {'name': 'Ferme de Cookies', 'cost': 5000, 'increment': 25, 'purchased': false, 'unique': false, 'passive': true},
  ];

  @override
  void initState() {
    super.initState();
    _startPassiveIncomeTimer(); // Démarrer le timer au lancement du jeu
  }

  // Fonction pour démarrer le timer qui ajoute des cookies automatiquement
  void _startPassiveIncomeTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        counter += passiveCookiesPerSecond;
        totalCookies += passiveCookiesPerSecond;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Arrêter le timer quand l'écran est fermé
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compteur de cookies'),
      ),
      body: Column(
        children: [
          // Section du compteur principal
          Expanded(
            flex: 1,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Nombre de cookies actuels
                  Text(
                    'Nombre de cookies : $counter',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Nombre total de cookies générés
                  Text(
                    'Total de cookies générés : $totalCookies',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Affichage des revenus passifs
                  Text(
                    'Cookies générés par seconde : $passiveCookiesPerSecond',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Bouton pour ajouter des cookies
                  TextButton(
                    onPressed: () {
                      setState(() {
                        counter += step;
                        totalCookies += step;
                      });
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    child: Text('+ $step cookies'),
                  ),
                ],
              ),
            ),
          ),

          // Section de la liste des achats
          Expanded(
            flex: 2,
            child: ListView.builder(
              itemCount: upgrades.length,
              itemBuilder: (context, index) {
                final upgrade = upgrades[index];

                return ListTile(
                  title: Text(
                    upgrade['name'],
                    style: const TextStyle(fontSize: 18),
                  ),
                  subtitle: Text('Coût : ${upgrade['cost']} cookies'),
                  trailing: ElevatedButton(
                    onPressed: (counter >= upgrade['cost'] &&
                            (!upgrade['unique'] || !upgrade['purchased']))
                        ? () {
                            setState(() {
                              counter -= upgrade['cost'] as int;

                              if (upgrade['passive'] == true) {
                                // Si l'upgrade génère des revenus passifs
                                passiveCookiesPerSecond += upgrade['increment'] as int;
                              } else if (upgrade['name'] == 'Cookie bonus') {
                                step += (step * 0.1).ceil(); // 10% d'augmentation
                                upgrades[index]['purchased'] = true;
                              } else if (upgrade['name'] == 'Cookie infini') {
                                step += upgrade['increment'] as int;
                              } else {
                                step += upgrade['increment'] as int;
                                if (upgrade['unique']) {
                                  upgrades[index]['purchased'] = true;
                                }
                              }
                            });
                          }
                        : null, // Désactiver si conditions non remplies
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      upgrade['unique'] && upgrade['purchased']
                          ? 'Déjà acheté'
                          : 'Acheter',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
