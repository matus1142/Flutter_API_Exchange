import 'dart:convert';
import 'package:flutter/material.dart'; // import for use widget
import 'MoneyBox.dart'; //import file
import 'package:http/http.dart' as http;
import 'ExchangeRate.dart';
import 'package:web_socket_channel/io.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "My fucking App",
      home: MyHomePage(),
      theme: ThemeData(primarySwatch: Colors.pink),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyHomePage> {
  late ExchangeRate _dataFromAPI;
  final channel = IOWebSocketChannel.connect(
      'wss://stream.binance.com:9443/ws/btcusdt@trade');
  double btcusdt = 0.0;
  int state_status = 0;
  @override
  void initState() {
    //เรียกใช้ครั้งเดียวตอน start
    print("เรียกใช้งาน init state");
    super.initState();
    getExchangeRate();
    steamListener();
  }

  void steamListener() {
    channel.stream.listen((message) {
      // channel.sink.add('received');
      // channel.sink.close(status.goingAway);
      Map getData = jsonDecode(message);
      btcusdt = double.parse(getData['p']);
      print(getData['p']);
    });
  }

  Future<ExchangeRate> getExchangeRate() async {
    print("ดึงข้อมูลอัตราแลกเปลี่ยนเงินตรา");
    var url = Uri.parse("https://api.exchangerate-api.com/v4/latest/USD");
    var response = await http.get(url);
    _dataFromAPI = exchangeRateFromJson(response.body); //json => dart object
    print(response.body);
    return _dataFromAPI;
  }

  @override
  Widget build(BuildContext context) {
    print(
        "เรียกใช้งาน build state"); //เรียกใช้ทุกครั้งที่หน้าแอพมีการเปลี่ยนแปลง
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My first useless app",
          style: TextStyle(
              fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder(
          future: getExchangeRate(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            //ดึงข้อมูลจาก getExchangeRate()มาครบ
            if (snapshot.connectionState == ConnectionState.done) {
              var result = snapshot.data;
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      "${result.date}",
                      style: TextStyle(fontSize: 15),
                    ),
                    MoneyBox("USD", 1, Colors.blue.shade200, 120),
                    const SizedBox(
                      height: 5,
                    ),
                    MoneyBox(
                        "THB", result.rates["THB"], Colors.green.shade200, 120),
                    const SizedBox(
                      height: 5,
                    ),
                    MoneyBox(
                        "JPY", result.rates["JPY"], Colors.red.shade200, 120),
                    const SizedBox(
                      height: 5,
                    ),
                    MoneyBox("BTC/USDT", btcusdt, Colors.orange.shade200, 70)
                  ],
                ),
              );
            }
            return LinearProgressIndicator();
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {});
        },
      ),
    );
  }
}
