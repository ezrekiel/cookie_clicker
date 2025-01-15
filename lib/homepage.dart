import 'package:flutter/material.dart';
import 'dart:math'; // Pour la fonction de calcul du plafond (ceil)

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int counter = 0;
  int step = 1;

  // Liste des upgrades achetables
  final List<Map<String, dynamic>> upgrades = [
    {'name': 'Double cookie', 'cost': 50, 'increment': 1, 'purchased': false, 'unique': true},
    {'name': 'Super cookie', 'cost': 200, 'increment': 6, 'purchased': false, 'unique': true},
    {'name': 'Mega cookie', 'cost': 500, 'increment': 15, 'purchased': false, 'unique': true},
    {'name': 'Cookie bonus', 'cost': 2000, 'increment': 0, 'purchased': false, 'unique': true},
    {'name': 'Cookie infini', 'cost': 5000, 'increment': 1, 'purchased': false, 'unique': false},
  ];

  // Méthode pour recalculer l'effet du Cookie bonus
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
                  Text(
                    'Nombre de cookies : $counter',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        counter += step;
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
                                // Si c'est le Cookie bonus
                                step += calculateBonusIncrement();
                                upgrades[index]['purchased'] = true;
                              } else if (upgrade['name'] == 'Cookie infini') {
                                // Si c'est le Cookie infini
                                step += upgrade['increment'] as int;

                                // Recalcul dynamique du Cookie bonus
                                final bonusIndex = upgrades.indexWhere(
                                    (item) => item['name'] == 'Cookie bonus');
                                if (bonusIndex != -1 && upgrades[bonusIndex]['purchased']) {
                                  step += calculateBonusIncrement();
                                }
                              } else {
                                // Pour les autres achats
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
