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
  int totalCookies = 0; // Total des cookies générés
  int passiveCookiesPerSecond = 0; // Revenus passifs
  double multiplier = 1.0; // Multiplier de boost temporaire
  bool isBoostActive = false; // Indique si un boost est actif
  Timer? _boostTimer; // Timer pour la durée du boost

  // Liste des upgrades achetables (ajout du boost temporaire)
  final List<Map<String, dynamic>> upgrades = [
    {'name': 'Double cookie', 'cost': 50, 'increment': 1, 'purchased': false, 'unique': true},
    {'name': 'Super cookie', 'cost': 200, 'increment': 6, 'purchased': false, 'unique': true},
    {'name': 'Mega cookie', 'cost': 500, 'increment': 15, 'purchased': false, 'unique': true},
    {'name': 'Cookie bonus', 'cost': 2000, 'increment': 0, 'purchased': false, 'unique': true},
    {'name': 'Cookie infini', 'cost': 5000, 'increment': 1, 'purchased': false, 'unique': false},
    {'name': 'Usine à Cookies', 'cost': 1000, 'increment': 5, 'purchased': false, 'unique': false, 'passive': true},
    {'name': 'Ferme de Cookies', 'cost': 5000, 'increment': 25, 'purchased': false, 'unique': false, 'passive': true},
    {'name': 'Boost 2x (10s)', 'cost': 3000, 'increment': 2.0, 'purchased': false, 'unique': false, 'boost': true},
  ];

  @override
  void dispose() {
    _boostTimer?.cancel(); // Arrêter le timer du boost si la page est quittée
    super.dispose();
  }

  // Fonction pour activer le boost temporaire
  void activateBoost(double boostMultiplier) {
    setState(() {
      multiplier *= boostMultiplier;
      isBoostActive = true;
    });

    // Démarrer un timer qui remet le multiplicateur à 1 après 10 secondes
    _boostTimer?.cancel(); // Annule le précédent si existant
    _boostTimer = Timer(const Duration(seconds: 10), () {
      setState(() {
        multiplier = 1.0;
        isBoostActive = false;
      });
    });
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
                  const SizedBox(height: 10),

                  // Indicateur si le boost est actif
                  if (isBoostActive)
                    Text(
                      'BOOST ACTIVÉ ! x${multiplier.toStringAsFixed(1)}',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Bouton pour ajouter des cookies
                  TextButton(
                    onPressed: () {
                      setState(() {
                        int cookiesGagnes = (step * multiplier).round();
                        counter += cookiesGagnes;
                        totalCookies += cookiesGagnes;
                      });
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    child: Text('+ ${step * multiplier} cookies'),
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

                              if (upgrade['boost'] == true) {
                                activateBoost(upgrade['increment'] as double);
                              } else if (upgrade['passive'] == true) {
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
                      backgroundColor: Colors.purple,
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
