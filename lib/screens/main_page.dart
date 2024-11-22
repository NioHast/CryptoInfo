import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'coin_detail_page.dart';

class MainCryptoPage extends StatefulWidget {
  const MainCryptoPage({super.key});

  @override
  State<MainCryptoPage> createState() => _MainCryptoPageState();
}

class _MainCryptoPageState extends State<MainCryptoPage> {
  final ApiService apiService = ApiService();
  String selectedSortOption = 'market_cap';
  List<dynamic>? coins;
  List<dynamic>? filteredCoins;
  bool isLoading = true;
  String? errorMessage;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCoins();
    searchController.addListener(_filterCoins);
  }

  Future<void> _fetchCoins() async {
    try {
      final data = await apiService.getCryptoPrices();
      setState(() {
        coins = data;
        filteredCoins = coins;
        _sortCoins();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _sortCoins() {
    if (filteredCoins == null || filteredCoins!.isEmpty) return;

    switch (selectedSortOption) {
      case 'market_cap':
        filteredCoins!.sort((a, b) => b['market_cap'].compareTo(a['market_cap']));
        break;
      case 'a_z':
        filteredCoins!.sort((a, b) => a['name'].toLowerCase().compareTo(b['name'].toLowerCase()));
        break;
      case 'z_a':
        filteredCoins!.sort((a, b) => b['name'].toLowerCase().compareTo(a['name'].toLowerCase()));
        break;
      case 'top_gainers':
        filteredCoins!.sort((a, b) =>
            (b['price_change_percentage_24h'] ?? 0).compareTo(a['price_change_percentage_24h'] ?? 0));
        break;
    }
  }

  void _filterCoins() {
    String query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredCoins = coins;
      } else {
        filteredCoins = coins?.where((coin) {
          return coin['name'].toLowerCase().contains(query);
        }).toList();
      }
      _sortCoins();
    });
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
        title: const Text('Crypto Prices'),
        actions: [
          DropdownButton<String>(
            value: selectedSortOption,
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  selectedSortOption = newValue;
                  _sortCoins();
                });
              }
            },
            items: const [
              DropdownMenuItem(
                value: 'market_cap',
                child: Text('Market Cap'),
              ),
              DropdownMenuItem(
                value: 'a_z',
                child: Text('A-Z'),
              ),
              DropdownMenuItem(
                value: 'z_a',
                child: Text('Z-A'),
              ),
              DropdownMenuItem(
                value: 'top_gainers',
                child: Text('Top Gainers'),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.search),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: $errorMessage',
                        style: const TextStyle(fontSize: 16, color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                            errorMessage = null;
                          });
                          _fetchCoins();
                        },
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search coins...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    filteredCoins == null || filteredCoins!.isEmpty
                        ? const Center(child: Text('Coin not found'))
                        : Expanded(
                            child: ListView.builder(
                              itemCount: filteredCoins?.length,
                              itemBuilder: (context, index) {
                                var coin = filteredCoins?[index];
                                double priceChangePercentage =
                                    coin['price_change_percentage_24h'] ?? 0.0;

                                Color percentageColor =
                                    priceChangePercentage >= 0 ? Colors.green : Colors.red;

                                return ListTile(
                                  leading: Image.network(coin['image']),
                                  title: Text(coin['name']),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('\$${coin['current_price']}'),
                                      Text(
                                        '${priceChangePercentage.toStringAsFixed(2)}%',
                                        style: TextStyle(color: percentageColor),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CoinDetailPage(
                                          coinId: coin['id'],
                                          coinName: coin['name'],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                  ],
                ),
    );
  }
}