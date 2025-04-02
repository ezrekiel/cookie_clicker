import 'package:flutter/material.dart';
import 'dart:async';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int counter = 0;
  int step = 1;
  int totalCookies = 0;
  int passiveCookiesPerSecond = 0;

  double multiplier = 1.0;
  bool isBoostActive = false;
  bool isBonusActive = false;

  int prestigePoints = 0;
  bool canPrestige = false;

  Timer? _boostTimer;
  Timer? _passiveTimer;

  final Color darkGrey = const Color(0xFF292929);
  final Color black = const Color(0xFF000000);
  final Color orange = Colors.orange;
  final Color purple = Colors.purple;

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
  void initState() {
    super.initState();
    startPassiveIncomeTimer();
  }

  void startPassiveIncomeTimer() {
    _passiveTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (passiveCookiesPerSecond > 0) {
        setState(() {
          counter += passiveCookiesPerSecond;
          totalCookies += passiveCookiesPerSecond;
          checkPrestigeAvailable();
        });
      }
    });
  }

  void activateBoost(double boostMultiplier) {
    setState(() {
      multiplier *= boostMultiplier;
      isBoostActive = true;
    });

    _boostTimer?.cancel();
    _boostTimer = Timer(const Duration(seconds: 10), () {
      setState(() {
        multiplier = 1.0;
        isBoostActive = false;
      });
    });
  }

  void addToStep(int baseIncrement) {
    int finalIncrement = baseIncrement;
    if (isBonusActive) {
      finalIncrement += (baseIncrement * 0.1).ceil();
    }
    step += finalIncrement;
  }

  double getPrestigeMultiplier() {
    return 1 + (prestigePoints * 0.01);
  }

  void checkPrestigeAvailable() {
    canPrestige = totalCookies >= 100000;
  }

  void performPrestige() {
    setState(() {
      prestigePoints += 1;
      counter = 0;
      step = 1;
      totalCookies = 0;
      passiveCookiesPerSecond = 0;
      multiplier = 1.0;
      isBoostActive = false;
      isBonusActive = false;

      for (var upgrade in upgrades) {
        upgrade['purchased'] = false;
      }

      canPrestige = false;
    });
  }

  @override
  void dispose() {
    _boostTimer?.cancel();
    _passiveTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: darkGrey,
        textTheme: ThemeData.dark().textTheme.apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: black,
          title: const Text('Compteur de cookies'),
        ),
        body: Column(
          children: [
            // Haut de l'écran
            Expanded(
              flex: 1,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Nombre de cookies : $counter',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text('Total généré : $totalCookies',
                        style: const TextStyle(fontSize: 18, color: Colors.grey)),
                    const SizedBox(height: 10),
                    Text('Cookies/sec : $passiveCookiesPerSecond',
                        style: const TextStyle(fontSize: 18, color: Colors.green)),
                    const SizedBox(height: 10),
                    Text('Prestige : $prestigePoints (+${(prestigePoints)}%)',
                        style: const TextStyle(fontSize: 16, color: Colors.amberAccent)),
                    if (isBoostActive)
                      Text(
                        'BOOST ACTIVÉ ! x${multiplier.toStringAsFixed(1)}',
                        style: const TextStyle(fontSize: 20, color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          int cookiesGagnes =
                              (step * multiplier * getPrestigeMultiplier()).round();
                          counter += cookiesGagnes;
                          totalCookies += cookiesGagnes;
                          checkPrestigeAvailable();
                        });
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: darkGrey,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontSize: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                          side: BorderSide(color: orange, width: 2),
                        ),
                      ),
                      child: Text('+ ${(step * multiplier * getPrestigeMultiplier()).round()} cookies'),
                    ),
                    const SizedBox(height: 8),
                    if (canPrestige)
                      ElevatedButton(
                        onPressed: performPrestige,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: black,
                          foregroundColor: Colors.yellow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                            side: const BorderSide(color: Colors.yellow, width: 2),
                          ),
                        ),
                        child: const Text('PRESTIGE ! +1 ⚡'),
                      ),
                  ],
                ),
              ),
            ),

            // Liste des upgrades
            Expanded(
              flex: 2,
              child: ListView.builder(
                itemCount: upgrades.length,
                itemBuilder: (context, index) {
                  final upgrade = upgrades[index];
                  final bool isPurple = upgrade['boost'] == true;
                  final bool isOrange = !isPurple;

                  return ListTile(
                    title: Text(upgrade['name'], style: const TextStyle(fontSize: 18)),
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
                                  isBonusActive = true;
                                  upgrades[index]['purchased'] = true;
                                } else {
                                  addToStep(upgrade['increment'] as int);
                                  if (upgrade['unique']) {
                                    upgrades[index]['purchased'] = true;
                                  }
                                }
                                checkPrestigeAvailable();
                              });
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkGrey,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                          side: BorderSide(
                            color: isPurple ? purple : orange,
                            width: 2,
                          ),
                        ),
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
      ),
    );
  }
}
