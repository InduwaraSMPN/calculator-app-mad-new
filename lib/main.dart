import 'package:flutter/material.dart';
import 'dart:async';
import 'package:expressions/expressions.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FE),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final imageSize = screenWidth < 600 ? screenWidth * 1 : screenWidth * 1;

            return Image.asset(
              'assets/Images/splash-mobile.png',
              width: imageSize,
              height: imageSize,
            );
          },
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

  // Colors for buttons
  static const Color numberButtonColor = Color(0xFFeff0f6); // 0-9 , . , ⌫ , % . +/-
  static const Color operatorButtonColor = Color(0xffe7f6ff); // + , - , x , /
  static const Color acButtonColor = Color(0xFFffd2e8); // AC
  static const Color equalsButtonColor = Color(0xFF89d9ff); // =

  //Colors for Text
  static const Color textColor = Color(0xFF2b2933); // for 0-9 , . , % . +/-
  static const Color operatorTextColor = Color(0xFF2e4f64); // for + , - , x , /
  static const Color acTextColor = Color(0xFF792b53); // AC
  static const Color backspaceTextColor = Color(0xFFf52c58); //for ⌫
  static const Color errorColor = Color(0xFFf52c58); // Error
  static const Color resultColor = Color(0xFF4c98d5); // Result

  String _output = '';
  String _operationSequence = '';
  String _previousSequence = '';
  bool _isNewNumber = true;
  bool _hasError = false;
  bool _isResultDisplayed = false;

  void _onNumberPressed(String number) {
    setState(() {
      if (_hasError || _isResultDisplayed) {
        _output = '';
        _operationSequence = '';
        _isNewNumber = true;
        _hasError = false;
        _isResultDisplayed = false;
      }
      if (_isNewNumber) {
        _operationSequence += number;
        _isNewNumber = false;
      } else {
        _operationSequence += number;
      }
      _output = _operationSequence;
    });
  }

  void _onOperationPressed(String operation) {
    setState(() {
      if (_hasError) {
        return;
      }
      if (_isResultDisplayed) {
        _operationSequence = _output;
        _isResultDisplayed = false;
      }
      if (_operationSequence.isNotEmpty && !_isNewNumber) {
        final lastChar = _operationSequence[_operationSequence.length - 1];
        if ('+-×÷'.contains(lastChar)) {
          _operationSequence = _operationSequence.substring(0, _operationSequence.length - 1);
        }
        _operationSequence += ' $operation ';
        _isNewNumber = true;
      }
      _output = _operationSequence;
    });
  }

  void _onEqualsPressed() {
    setState(() {
      if (_hasError || _operationSequence.isEmpty) {
        return;
      }
      try {
        final result = _evaluateExpression(_operationSequence);
        _previousSequence = _operationSequence;
        _output = result;
        _isResultDisplayed = true;
      } catch (e) {
        _output = 'Error';
        _hasError = true;
      }
    });
  }

  String _evaluateExpression(String expression) {
    try {
      final exp = expression.replaceAll('×', '*').replaceAll('÷', '/');
      final parsedExpression = Expression.parse(exp);
      final evaluator = const ExpressionEvaluator();
      final result = evaluator.eval(parsedExpression, {});
      if (result == double.infinity || result == double.negativeInfinity) {
        throw Exception('Division by zero');
      }
      return result % 1 == 0 ? result.toInt().toString() : result.toString();
    } catch (e) {
      throw Exception('Invalid expression');
    }
  }

  void _onClearPressed() {
    setState(() {
      _output = '';
      _operationSequence = '';
      _previousSequence = '';
      _isNewNumber = true;
      _hasError = false;
      _isResultDisplayed = false;
    });
  }

  void _onBackspacePressed() {
    setState(() {
      if (_isResultDisplayed) {
        if (_output.isNotEmpty) {
          _output = _output.substring(0, _output.length - 1);
        }
        if (_output.isEmpty) {
          _previousSequence = '';
          _isResultDisplayed = false;
        }
      } else if (_operationSequence.isNotEmpty) {
        _operationSequence = _operationSequence.substring(0, _operationSequence.length - 1);
        _output = _operationSequence;
      }
    });
  }

  void _onToggleSignPressed() {
    setState(() {
      if (_operationSequence.isNotEmpty) {
        if (_operationSequence.endsWith(' ')) {
          return;
        }
        final lastNumber = _operationSequence.split(' ').last;
        if (lastNumber.startsWith('-')) {
          _operationSequence = _operationSequence.substring(0, _operationSequence.length - lastNumber.length) + lastNumber.substring(1);
        } else {
          _operationSequence = '${_operationSequence.substring(0, _operationSequence.length - lastNumber.length)}-$lastNumber';
        }
        _output = _operationSequence;
      }
    });
  }

  void _onPercentagePressed() {
    setState(() {
      if (_operationSequence.isNotEmpty) {
        if (_operationSequence.endsWith(' ')) {
          return;
        }
        final lastNumber = _operationSequence.split(' ').last;
        final percentage = (double.parse(lastNumber) / 100).toString();
        _operationSequence = _operationSequence.substring(0, _operationSequence.length - lastNumber.length) + percentage;
        _output = _operationSequence;
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
                  child: Image.asset(
                    'assets/Images/logo.png',  // Replace with your PNG path
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
                        _previousSequence,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF494949),  // Dark gray for numbers
                        ),
                      ),
                      Text(
                        _output,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w600,
                          color: _hasError ? errorColor : (_isResultDisplayed ? resultColor : Color(0xFF494949)),  // Red for error, green for result, dark gray for numbers
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
                            backgroundColor: numberButtonColor,
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
                            textColor: operatorTextColor),
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