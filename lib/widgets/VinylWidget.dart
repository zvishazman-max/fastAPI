import 'package:flutter/material.dart';


/// have to fix
class VinylWidget extends StatelessWidget {
  final String albumImageUrl, name, artist;
  final DateTime date;
  final bool showDetails;
  final (bool, String) playerName;

  const VinylWidget({super.key, required this.albumImageUrl, required this.name, required this.artist, required this.date, this.showDetails = true, required this.playerName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showDetails)Text(
            artist,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Stack(
            alignment: Alignment.center,
            children: [
              ClipOval(
                child: Image.network(
                  'https://raw.githubusercontent.com/zvishazman-max/fastAPI/refs/heads/main/vinyl${showDetails? '' : 'Blue'}.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              ClipOval(
                child: Image.network(
                  albumImageUrl,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
              Text(
                "${date.year}",
                style: const TextStyle(
                  fontSize: 22,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (showDetails)Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class VinylOnlyWidget extends StatelessWidget {
  final String albumImageUrl, name, artist;
  final DateTime date;

  const VinylOnlyWidget({super.key, required this.albumImageUrl, required this.name, required this.artist, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      decoration: BoxDecoration(color: Colors.deepPurple, borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(6),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipOval(
            child: Image.network(
              'https://raw.githubusercontent.com/zvishazman-max/fastAPI/refs/heads/main/vinyl.png',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          ClipOval(
            child: Image.network(
              albumImageUrl,
              width: 30,
              height: 30,
              fit: BoxFit.cover,
            ),
          ),
          Text(
            "${date.year}",
            style: const TextStyle(fontSize: 22, color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
