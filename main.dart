import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String display = "0";
  String operand = "";
  double? firstValue;

  @override
  void initState() {
    super.initState();
    _loadLastValue();
  }

  void _loadLastValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      display = prefs.getString('lastValue') ?? "0";
    });
  }

  void _saveLastValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('lastValue', display);
  }

  void onDigitPress(String digit) {
    setState(() {
      if (display == "0" || display == "ERROR") {
        display = digit;
      } else {
        display += digit;
      }
    });
  }

  void onOperatorPress(String op) {
    setState(() {
      firstValue = double.tryParse(display);
      operand = op;
      display = "";
    });
  }

  void onEqualPress() {
    setState(() {
      double? secondValue = double.tryParse(display);
      if (firstValue == null || secondValue == null) {
        display = "ERROR";
      } else {
        switch (operand) {
          case '+':
            display = (firstValue! + secondValue).toString();
            break;
          case '-':
            display = (firstValue! - secondValue).toString();
            break;
          case '*':
            display = (firstValue! * secondValue).toString();
            break;
          case '/':
            display = secondValue == 0 ? "ERROR" : (firstValue! / secondValue).toString();
            break;
        }
      }
      _saveLastValue();
    });
  }

  void onClearEntryPress() {
    setState(() {
      display = "0";
    });
  }

  void onClearPress() {
    setState(() {
      display = "0";
      firstValue = null;
      operand = "";
    });
  }

  Widget buildButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: 50,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(label, style: TextStyle(fontSize: 18)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Simar's Calculator")),
      body: Center(
        child: Container(
          width: 250,
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(5),
                width: double.infinity,
                alignment: Alignment.centerRight,
                child: Text(display, style: TextStyle(fontSize: 24)),
              ),
              SizedBox(height: 10),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 4,
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
                children: [
                  ...["1", "2", "3", "+"],
                  ...["4", "5", "6", "-"],
                  ...["7", "8", "9", "*"],
                  ...["CE", "0", "C", "/"],
                ].map((label) {
                  return buildButton(label, () {
                    if (label == "C") onClearPress();
                    else if (label == "CE") onClearEntryPress();
                    else if (["+", "-", "*", "/"].contains(label)) onOperatorPress(label);
                    else onDigitPress(label);
                  });
                }).toList(),
              ),
              SizedBox(height: 10),
              buildButton("=", onEqualPress),
            ],
          ),
        ),
      ),
    );
  }
}
