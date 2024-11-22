import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/profile_picture.png'),
            ),
            SizedBox(height: 16),
            Text(
              'Nama: Muhammad Nio Hastungkoro',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'NIM: 21120122140155',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Jurusan: Teknik Komputer',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Aplikasi CryptoInfo menampilkan harga cryptocurrency serta informasi terkait istilah dalam dunia cryptocurrency.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}