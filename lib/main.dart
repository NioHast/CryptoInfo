import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/main_page.dart';
import 'screens/about_page.dart';
import 'screens/dictionary_page.dart';

void main() => runApp(const CryptoInfoApp());

class CryptoInfoApp extends StatefulWidget {
  const CryptoInfoApp({super.key});

  @override
  CryptoInfoAppState createState() => CryptoInfoAppState();
}

class CryptoInfoAppState extends State<CryptoInfoApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto Info',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.grey,
        textTheme: GoogleFonts.robotoTextTheme(),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.grey,
        textTheme: GoogleFonts.robotoTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
      ),
      themeMode: _themeMode,
      home: MainPage(onToggleTheme: _toggleTheme),
    );
  }
}

class MainPage extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const MainPage({super.key, required this.onToggleTheme});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const MainCryptoPage(),
    const DictionaryPage(),
    const AboutPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crypto Info'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.candlestick_chart),
            label: 'Coin List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Glossarium',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'About',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}