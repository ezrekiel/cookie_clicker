import 'package:flutter/material.dart';
import 'dart:math'; // Pour les calculs comme ceil()

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int counter = 0; // Cookies actuels
  int step = 1; // Nombre de cookies gagnés par clic
  int totalCookies = 0; // Total de cookies générés depuis le début

  // Liste des upgrades achetables
  final List<Map<String, dynamic>> upgrades = [
    {'name': 'Double cookie', 'cost': 50, 'increment': 1, 'purchased': false, 'unique': true},
    {'name': 'Super cookie', 'cost': 200, 'increment': 6, 'purchased': false, 'unique': true},
    {'name': 'Mega cookie', 'cost': 500, 'increment': 15, 'purchased': false, 'unique': true},
    {'name': 'Cookie bonus', 'cost': 2000, 'increment': 0, 'purchased': false, 'unique': true},
    {'name': 'Cookie infini', 'cost': 5000, 'increment': 1, 'purchased': false, 'unique': false},
  ];

  // Méthode pour calculer le bonus dynamique
  int calculateBonusIncrement() {
    return (step * 0.1).ceil(); // 10% du step arrondi au supérieur
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
                  const SizedBox(height: 20),

                  // Bouton pour ajouter des cookies
                  TextButton(
                    onPressed: () {
                      setState(() {
                        counter += step; // Ajouter des cookies au compteur actuel
                        totalCookies += step; // Ajouter des cookies au total
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

                              if (upgrade['name'] == 'Cookie bonus') {
                                // Cas du Cookie bonus
                                step += calculateBonusIncrement();
                                upgrades[index]['purchased'] = true;
                              } else if (upgrade['name'] == 'Cookie infini') {
                                // Cas du Cookie infini
                                step += upgrade['increment'] as int;

                                // Recalcul du Cookie bonus si déjà acheté
                                final bonusIndex = upgrades.indexWhere((item) => item['name'] == 'Cookie bonus');
                                if (bonusIndex != -1 && upgrades[bonusIndex]['purchased']) {
                                  step += calculateBonusIncrement();
                                }
                              } else {
                                // Cas des autres achats
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
