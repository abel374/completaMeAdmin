import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String timeText = "";
  String dateText = "";

  String formatCurrentLiveTime(DateTime time) {
    return DateFormat("hh:mm:ss a").format(time);
  }

  String formatCurrentDate(DateTime date) {
    return DateFormat("dd MMMM, yyyy").format(date);
  }

  getCurrentLiveTime() {
    final DateTime timeNow = DateTime.now();
    final String liveTime = formatCurrentLiveTime(timeNow);
    final String liveDate = formatCurrentDate(timeNow);

    if (this.mounted) {
      setState(() {
        timeText = liveTime;
        dateText = liveDate;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    //time
    timeText = formatCurrentLiveTime(DateTime.now());

    //date
    dateText = formatCurrentDate(DateTime.now());

    Timer.periodic(const Duration(seconds: 1), (timer) {
      getCurrentLiveTime();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.amber, Colors.cyan],
              begin: FractionalOffset(0, 0),
              end: FractionalOffset(1, 0),
              stops: [0, 1],
              tileMode: TileMode.clamp,
            ),
          ),
        ),
        title: const Text(
          "Portal Web Administrativo",
          style: TextStyle(fontSize: 20, letterSpacing: 3, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                timeText + "\n" + dateText,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  letterSpacing: 3,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            //interface do usuário com botão para ativar e bloquear contas
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //active
                ElevatedButton.icon(
                  icon: const Icon(Icons.person_add, color: Colors.white),
                  label: Text(
                    "Ativar Conta".toUpperCase() +
                        "\n" +
                        "do Usuário".toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      letterSpacing: 3,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(40),
                    backgroundColor: Colors.amber,
                  ),
                  onPressed: () {},
                ),

                const SizedBox(width: 20),

                //block
                ElevatedButton.icon(
                  icon: const Icon(Icons.block_flipped, color: Colors.white),
                  label: Text(
                    "Bloquear Contas".toUpperCase() +
                        "\n" +
                        "usuários".toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      letterSpacing: 3,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(40),
                    backgroundColor: Colors.cyan,
                  ),
                  onPressed: () {},
                ),
              ],
            ),

            //interface do usuário do botão de ativação e bloqueio de contas para vendedores
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //active
                ElevatedButton.icon(
                  icon: const Icon(Icons.person_add, color: Colors.white),
                  label: Text(
                    "Ativar Contas ".toUpperCase() +
                        "\n" +
                        "vendedores".toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      letterSpacing: 3,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(40),
                    backgroundColor: Colors.cyan,
                  ),
                  onPressed: () {},
                ),

                const SizedBox(width: 20),

                //block
                ElevatedButton.icon(
                  icon: const Icon(Icons.block_flipped, color: Colors.white),
                  label: Text(
                    "Vendedores Bloqueados".toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      letterSpacing: 3,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(40),
                    backgroundColor: Colors.amber,
                  ),
                  onPressed: () {},
                ),
              ],
            ),

            //Interface do usuário com botões para ativar e bloquear contas de usuários
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //active
                ElevatedButton.icon(
                  icon: const Icon(Icons.person_add, color: Colors.white),
                  label: Text(
                    "Ativar Contas".toUpperCase() +
                        "\n" +
                        "do Estafeta".toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      letterSpacing: 3,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(40),
                    backgroundColor: Colors.amber,
                  ),
                  onPressed: () {},
                ),

                const SizedBox(width: 20),

                //block
                ElevatedButton.icon(
                  icon: const Icon(Icons.block_flipped, color: Colors.white),
                  label: Text(
                    "Bloquear Contas ".toUpperCase() +
                        "\n" +
                        "do Estafeta".toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      letterSpacing: 3,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(40),
                    backgroundColor: Colors.cyan,
                  ),
                  onPressed: () {},
                ),
              ],
            ),

            //logout button
            ElevatedButton.icon(
              icon: const Icon(Icons.logout, color: Colors.white),
              label: Text(
                "Sair".toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  letterSpacing: 3,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(40),
                backgroundColor: Colors.amber,
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
