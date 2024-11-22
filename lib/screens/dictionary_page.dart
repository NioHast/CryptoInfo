import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'detail_dictionary_page.dart';

class DictionaryPage extends StatefulWidget {
  const DictionaryPage({super.key});

  @override
  DictionaryPageState createState() => DictionaryPageState();
}

class DictionaryPageState extends State<DictionaryPage> {
  List<Map<String, dynamic>> terms = [];
  List<Map<String, dynamic>> filteredTerms = [];
  TextEditingController searchController = TextEditingController();
  Map<String, List<Map<String, dynamic>>> groupedTerms = {};

  @override
  void initState() {
    super.initState();
    _loadData();
    searchController.addListener(_filterSearchResults);
  }

  Future<void> _loadData() async {
    final String response = await rootBundle.loadString('assets/dictionary_data.json');
    final List<dynamic> data = json.decode(response);

    setState(() {
      terms = data.map((item) => {
            'term': item['Term'] as String,
            'description': item['Description'] as String,
          }).toList();
      filteredTerms = terms;
      groupedTerms = _groupTermsByFirstLetter(filteredTerms);
    });
  }

  void _filterSearchResults() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredTerms = terms.where((term) {
        return term['term']!.toLowerCase().contains(query);
      }).toList();
      groupedTerms = _groupTermsByFirstLetter(filteredTerms);
    });
  }

  Map<String, List<Map<String, dynamic>>> _groupTermsByFirstLetter(List<Map<String, dynamic>> terms) {
    Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var term in terms) {
      String firstLetter = term['term']![0].toUpperCase();

      if (firstLetter.contains(RegExp(r'^[0-9]$')) || firstLetter.contains(RegExp(r'^[^\w]$'))) {
        firstLetter = '#';
      }

      if (!grouped.containsKey(firstLetter)) {
        grouped[firstLetter] = [];
      }
      grouped[firstLetter]!.add(term);
    }

    return grouped;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crypto Dictionary'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Search terms...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder()
              ),
            ),
          ),
        ),
      ),
      body: filteredTerms.isEmpty && searchController.text.isNotEmpty
          ? const Center(child: Text('Term not found'))
          : ListView(
              children: groupedTerms.keys.map((letter) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        letter, 
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...groupedTerms[letter]!.map((term) {
                      return ListTile(
                        title: Text(term['term']!),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailDictionaryPage(
                                term: term['term']!,
                                description: term['description']!,
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ],
                );
              }).toList(),
            ),
    );
  }
}