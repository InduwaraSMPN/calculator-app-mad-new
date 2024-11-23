import 'package:flutter/material.dart';
import 'dart:async';
import 'package:expressions/expressions.dart';

// Main entry point of the application
void main() {
  runApp(CalculatorApp());
}

// Root widget of the application with material design theme
class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator App',
      // Blue color theme for the app
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Start with splash screen
      home: const SplashScreen(),
    );
  }
}

// Splash screen that displays for 2 seconds before main calculator screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to calculator screen after 2 seconds
    Timer(const Duration(seconds: 2), () {
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
            // Responsive image sizing based on screen width
            final screenWidth = constraints.maxWidth;
            final imageSize = screenWidth < 600 ? screenWidth * 1.6 : screenWidth * 1.6;

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

// Main calculator screen with all calculator functionality
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  // Color constants for different button types and text
  static const Color numberButtonColor = Color(0xFFeff0f6);
  static const Color operatorButtonColor = Color(0xffe7f6ff);
  static const Color acButtonColor = Color(0xFFffd2e8);
  static const Color equalsButtonColor = Color(0xFF89d9ff);
  static const Color textColor = Color(0xFF2b2933);
  static const Color operatorTextColor = Color(0xFF2e4f64);
  static const Color acTextColor = Color(0xFF792b53);
  static const Color backspaceTextColor = Color(0xFFf52c58);
  static const Color errorColor = Color(0xFFf52c58);
  static const Color resultColor = Color(0xFF4c98d5);

  // State variables to manage calculator's current state
  String _output = '';           // Current display output
  String _operationSequence = ''; // Full sequence of input operations
  String _previousSequence = '';  // Previous calculation sequence
  bool _isNewNumber = true;       // Flag to track if a new number input is expected
  bool _hasError = false;         // Flag to indicate if an error occurred
  bool _isResultDisplayed = false; // Flag to track if result is currently displayed

  // Handler for number button presses
  void _onNumberPressed(String number) {
    setState(() {
      // Reset state if previous calculation had an error or result is displayed
      if (_hasError || _isResultDisplayed) {
        _output = '';
        _operationSequence = '';
        _isNewNumber = true;
        _hasError = false;
        _isResultDisplayed = false;
      }
      // Add number to operation sequence
      if (_isNewNumber) {
        _operationSequence += number;
        _isNewNumber = false;
      } else {
        _operationSequence += number;
      }
      _output = _operationSequence;
    });
  }

  // Handler for operation button presses (+, -, ×, ÷)
  void _onOperationPressed(String operation) {
    setState(() {
      // Ignore if there's an existing error
      if (_hasError) {
        return;
      }
      // Reset sequence if previous result is displayed
      if (_isResultDisplayed) {
        _operationSequence = _output;
        _isResultDisplayed = false;
      }
      // Replace existing operator or add new operator
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

  // Handler for equals button press
  void _onEqualsPressed() {
    setState(() {
      // Ignore if there's an error or no operation sequence
      if (_hasError || _operationSequence.isEmpty) {
        return;
      }
      try {
        // Evaluate the mathematical expression
        final result = _evaluateExpression(_operationSequence);
        _previousSequence = _operationSequence;
        _output = result;
        _isResultDisplayed = true;
      } catch (e) {
        // Display error if calculation fails
        _output = 'Error';
        _hasError = true;
      }
    });
  }

  // Method to safely evaluate mathematical expressions
  String _evaluateExpression(String expression) {
    try {
      // Replace calculator symbols with standard math symbols
      final exp = expression.replaceAll('×', '*').replaceAll('÷', '/');
      final parsedExpression = Expression.parse(exp);
      final evaluator = const ExpressionEvaluator();
      final result = evaluator.eval(parsedExpression, {});

      // Check for invalid mathematical results
      if (result.isNaN || result == double.infinity || result == double.negativeInfinity) {
        throw Exception('Invalid expression');
      }

      // Return integer if whole number, otherwise return decimal
      return result % 1 == 0 ? result.toInt().toString() : result.toString();
    } catch (e) {
      throw Exception('Invalid expression');
    }
  }

  // Handler for clear button press
  void _onClearPressed() {
    setState(() {
      // Reset all state variables
      _output = '';
      _operationSequence = '';
      _previousSequence = '';
      _isNewNumber = true;
      _hasError = false;
      _isResultDisplayed = false;
    });
  }

  // Handler for backspace button press
  void _onBackspacePressed() {
    setState(() {
      // Handle backspace differently for result and operation sequence
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

  // Handler for toggle sign button (+/-)
  void _onToggleSignPressed() {
    setState(() {
      if (_operationSequence.isNotEmpty) {
        // Ignore if last character is a space (after an operator)
        if (_operationSequence.endsWith(' ')) {
          return;
        }
        final lastNumber = _operationSequence.split(' ').last;
        // Toggle sign of the last number
        if (lastNumber.startsWith('-')) {
          _operationSequence = _operationSequence.substring(0, _operationSequence.length - lastNumber.length) + lastNumber.substring(1);
        } else {
          _operationSequence = '${_operationSequence.substring(0, _operationSequence.length - lastNumber.length)}-$lastNumber';
        }
        _output = _operationSequence;
      }
    });
  }

  // Handler for percentage button press
  void _onPercentagePressed() {
    setState(() {
      if (_operationSequence.isNotEmpty) {
        // Ignore if last character is a space (after an operator)
        if (_operationSequence.endsWith(' ')) {
          return;
        }
        final lastNumber = _operationSequence.split(' ').last;
        // Convert last number to percentage
        final percentage = (double.parse(lastNumber) / 100).toString();
        _operationSequence = _operationSequence.substring(0, _operationSequence.length - lastNumber.length) + percentage;
        _output = _operationSequence;
      }
    });
  }

  // Custom button builder with configurable colors and behavior
  Widget _buildButton(
      String text, {
        Color backgroundColor = numberButtonColor,
        Color textColor = textColor,
      }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          // Button styling with subtle shadow
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
            // Route button press to appropriate handler
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
      backgroundColor: Colors.white,
      body: Container(
        // Soft gradient background
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
              // App logo
              Center(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.03,
                    bottom: MediaQuery.of(context).size.height * 0.01,
                  ),
                  child: Image.asset(
                    'assets/Images/logo.png',
                    width: MediaQuery.of(context).size.width * 0.5,
                  ),
                ),
              ),
              // Display area for previous calculation and current output
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Previous calculation sequence
                      Text(
                        _previousSequence,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF494949),
                        ),
                      ),
                      // Current output with dynamic color based on state
                      Text(
                        _output,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w600,
                          color: _hasError ? errorColor : (_isResultDisplayed ? resultColor : Color(0xFF494949)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Calculator buttons layout
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Button rows with various operations and numbers
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
                    // Numeric and operator buttons
                    Row(children: [
                      _buildButton('1'), _buildButton('2'), _buildButton('3'),
                      _buildButton('×', backgroundColor: operatorButtonColor, textColor: operatorTextColor),
                    ]),
                    Row(children: [
                      _buildButton('4'), _buildButton('5'), _buildButton('6'),
                      _buildButton('-', backgroundColor: operatorButtonColor, textColor: operatorTextColor),
                    ]),
                    Row(children: [
                      _buildButton('7'), _buildButton('8'), _buildButton('9'),
                      _buildButton('+', backgroundColor: operatorButtonColor, textColor: operatorTextColor),
                    ]),
                    Row(children: [
                      _buildButton('.'), _buildButton('0'),
                      _buildButton('AC', backgroundColor: acButtonColor, textColor: acTextColor),
                      _buildButton('=', backgroundColor: equalsButtonColor, textColor: Colors.white),
                    ]),
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