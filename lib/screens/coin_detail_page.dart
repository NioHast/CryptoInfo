import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';

class CoinDetailPage extends StatefulWidget {
  final String coinId;
  final String coinName;

  const CoinDetailPage({required this.coinId, required this.coinName, super.key});

  @override
  CoinDetailPageState createState() => CoinDetailPageState();
}

class CoinDetailPageState extends State<CoinDetailPage> {
  List<ChartData> _chartData = [];
  String selectedRange = '1';
  Map<String, dynamic>? coinData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCoinData(selectedRange);
    _fetchCoinDetails();
  }

  Future<void> _fetchCoinData(String range) async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.coingecko.com/api/v3/coins/${widget.coinId}/ohlc?vs_currency=usd&days=$range'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          _chartData = data
              .map((e) => ChartData(
                    DateTime.fromMillisecondsSinceEpoch(e[0] * 1000),
                    e[1].toDouble(),
                    e[2].toDouble(),
                    e[3].toDouble(),
                    e[4].toDouble(),
                  ))
              .toList();
        });
      } else {
        throw Exception('Failed to load chart data');
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _fetchCoinDetails() async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.coingecko.com/api/v3/coins/${widget.coinId}?localization=false'));

      if (response.statusCode == 200) {
        setState(() {
          coinData = json.decode(response.body)['market_data'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load coin details');
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.coinName),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Error: $errorMessage', style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                            errorMessage = null;
                          });
                          _fetchCoinData(selectedRange);
                          _fetchCoinDetails();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Chart Candlestick
                        SfCartesianChart(
                          primaryXAxis: const DateTimeAxis(isVisible: false),
                          series: <CartesianSeries>[
                            CandleSeries<ChartData, DateTime>(
                              dataSource: _chartData,
                              xValueMapper: (ChartData data, _) => data.time,
                              lowValueMapper: (ChartData data, _) => data.low,
                              highValueMapper: (ChartData data, _) => data.high,
                              openValueMapper: (ChartData data, _) => data.open,
                              closeValueMapper: (ChartData data, _) => data.close,
                              animationDuration: 0,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Tombol Range
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: ['1', '7', '30', '180', '365'].map((range) {
                            return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: selectedRange == range
                                    ? Colors.purple
                                    : Colors.grey[300],
                                minimumSize: const Size(40, 30),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),

                              ),
                              onPressed: () {
                                setState(() {
                                  selectedRange = range;
                                });
                                _fetchCoinData(range);
                              },
                              child: Text(
                                range == '1'
                                    ? '1D'
                                    : range == '7'
                                        ? '1W'
                                        : range == '30'
                                            ? '1M'
                                            : range == '180'
                                                ? '6M'
                                                : '1Y',
                                style: TextStyle(
                                  color: selectedRange == range
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Details:',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        if (coinData != null) ..._buildCoinDetails(coinData!),
                      ],
                    ),
                  ),
                ),
    );
  }

  List<Widget> _buildCoinDetails(Map<String, dynamic> data) {
    return [
      _buildDetailRow('Current Price', '\$${data['current_price']['usd']}'),
      _buildDetailRow('Market Cap', '\$${data['market_cap']['usd']}'),
      _buildDetailRow('Market Cap Rank', '${data['market_cap_rank']}'),
      _buildDetailRow('Fully Diluted Valuation', '\$${data['fully_diluted_valuation']['usd']}'),
      _buildDetailRow('Total Volume', '\$${data['total_volume']['usd']}'),
      _buildDetailRow('High 24h', '\$${data['high_24h']['usd']}'),
      _buildDetailRow('Low 24h', '\$${data['low_24h']['usd']}'),
      _buildDetailRow('Price Change 24h', '${data['price_change_24h']}'),
      _buildDetailRow('Price Change % (24h)', '${data['price_change_percentage_24h']}%'),
      _buildDetailRow('Circulating Supply', '${data['circulating_supply']}'),
      _buildDetailRow('Total Supply', '${data['total_supply']}'),
      _buildDetailRow('All Time High (ATH)', '\$${data['ath']['usd']}'),
      _buildDetailRow('ATH Change %', '${data['ath_change_percentage']['usd']}%'),
      _buildDetailRow('All Time Low (ATL)', '\$${data['atl']['usd']}'),
      _buildDetailRow('ATL Change %', '${data['atl_change_percentage']['usd']}%'),
      _buildDetailRow('Last Updated', _formatLastUpdated(data['last_updated'])),
    ];
  }

  String _formatLastUpdated(String isoDateTime) {
    DateTime dateTime = DateTime.parse(isoDateTime);
    DateTime utcPlus7 = dateTime.add(const Duration(hours: 7));
    String formattedDate = DateFormat('dd MMM yyyy (HH:mm:ss WIB)').format(utcPlus7);
    return formattedDate;
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Flexible(child: Text(value)),
        ],
      ),
    );
  }
}

class ChartData {
  final DateTime time;
  final double open;
  final double high;
  final double low;
  final double close;

  ChartData(this.time, this.open, this.high, this.low, this.close);
}