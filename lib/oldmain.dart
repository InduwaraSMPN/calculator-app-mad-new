import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const CalculatorScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FE),
      body: Center(
        child: SvgPicture.asset('assets/splash.svg',
          width: screenSize.width * 3,  // 100% of the screen width
          height: screenSize.height * 2, // 100% of the screen height
        ),
      ),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  // Colors for different buttons
  static const Color numberButtonColor = Color(0xFFF5F6FA); // Light gray
  static const Color operatorButtonColor = Color(0xFFEDF6FF); // Light blue
  static const Color backspaceButtonColor = Color(0xFFF5F6FA); // Light pink (for ⌫)
  static const Color acButtonColor = Color(0xFFFFEEF3); // Light yellow (for DEL)
  static const Color equalsButtonColor = Color(0xFF55A1FF); // Bright blue
  static const Color textColor = Color(0xFF494949); // Dark gray for numbers
  static const Color operatorTextColor = Color(0xFF55A1FF); // Blue for operators
  static const Color backspaceTextColor = Color(0xFFFA5E4A); // Pink for ⌫
  static const Color acTextColor = Color(0xFFFF7EA8); // Orange for DEL

  String _output = '';
  String _currentNumber = '';
  double _firstNumber = 0;
  String _operation = '';
  bool _isNewNumber = true;

  void _onNumberPressed(String number) {
    setState(() {
      if (_isNewNumber) {
        _currentNumber = number;
        _isNewNumber = false;
      } else {
        _currentNumber += number;
      }
      _output = _currentNumber;
    });
  }

  void _onOperationPressed(String operation) {
    setState(() {
      _firstNumber = double.parse(_currentNumber);
      _operation = operation;
      _isNewNumber = true;
    });
  }

  void _onEqualsPressed() {
    setState(() {
      double secondNumber = double.parse(_currentNumber);
      switch (_operation) {
        case '+':
          _currentNumber = (_firstNumber + secondNumber).toString();
          break;
        case '-':
          _currentNumber = (_firstNumber - secondNumber).toString();
          break;
        case '×':
          _currentNumber = (_firstNumber * secondNumber).toString();
          break;
        case '÷':
          _currentNumber = (_firstNumber / secondNumber).toString();
          break;
      }
      _output = _currentNumber;
      _isNewNumber = true;
    });
  }

  void _onClearPressed() {
    setState(() {
      _output = '';
      _currentNumber = '';
      _firstNumber = 0;
      _operation = '';
      _isNewNumber = true;
    });
  }

  void _onBackspacePressed() {
    setState(() {
      if (_currentNumber.isNotEmpty) {
        _currentNumber = _currentNumber.substring(0, _currentNumber.length - 1);
        _output = _currentNumber;
      }
    });
  }

  void _onToggleSignPressed() {
    setState(() {
      if (_currentNumber.isNotEmpty) {
        _currentNumber.startsWith('-')
            ? _currentNumber = _currentNumber.substring(1)
            : _currentNumber = '-$_currentNumber';
        _output = _currentNumber;
      }
    });
  }

  void _onPercentagePressed() {
    setState(() {
      if (_currentNumber.isNotEmpty) {
        _currentNumber = (double.parse(_currentNumber) / 100).toString();
        _output = _currentNumber;
      }
    });
  }

  Widget _buildButton(
    String text, {
    Color backgroundColor = numberButtonColor,
    Color textColor = textColor,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: MaterialButton(
            padding: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onPressed: () {
              if (text == 'C') {
                _onClearPressed();
              } else if (text == '⌫') {
                _onBackspacePressed();
              } else if (text == 'AC') {
                _onClearPressed();
              } else if (text == '+/-') {
                _onToggleSignPressed();
              } else if (text == '%') {
                _onPercentagePressed();
              } else if (text == '=') {
                _onEqualsPressed();
              } else if ('+-×÷'.contains(text)) {
                _onOperationPressed(text);
              } else {
                _onNumberPressed(text);
              }
            },
            child: Text(
              text,
              style: TextStyle(
                fontSize: 24,
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F9FE), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.03,
                    bottom: MediaQuery.of(context).size.height * 0.01,
                  ),
                  child: SvgPicture.asset(
                    'assets/logo.svg',  // Replace with your SVG path
                    width: MediaQuery.of(context).size.width * 0.5,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _output,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF494949),  // Dark gray for numbers
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Keypad
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildButton('+/-'),
                        _buildButton('%'),
                        _buildButton('⌫',
                            backgroundColor: backspaceButtonColor,
                            textColor: backspaceTextColor),
                        _buildButton('÷',
                            backgroundColor: operatorButtonColor,
                            textColor: operatorTextColor),
                      ],
                    ),
                    Row(
                      children: [
                        _buildButton('1'),
                        _buildButton('2'),
                        _buildButton('3'),
                        _buildButton('×',
                            backgroundColor: operatorButtonColor,
                            textColor: operatorTextColor),
                      ],
                    ),
                    Row(
                      children: [
                        _buildButton('4'),
                        _buildButton('5'),
                        _buildButton('6'),
                        _buildButton('-',
                            backgroundColor: operatorButtonColor,
                            textColor:

 operatorTextColor),
                      ],
                    ),
                    Row(
                      children: [
                        _buildButton('7'),
                        _buildButton('8'),
                        _buildButton('9'),
                        _buildButton('+',
                            backgroundColor: operatorButtonColor,
                            textColor: operatorTextColor),
                      ],
                    ),
                    Row(
                      children: [
                        _buildButton('.'),
                        _buildButton('0'),
                        _buildButton('AC',
                            backgroundColor: acButtonColor,
                            textColor: acTextColor),
                        _buildButton('=',
                            backgroundColor: equalsButtonColor,
                            textColor: Colors.white),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}