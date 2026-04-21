import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HistoryItem {
  final String expression;
  final String result;
  final DateTime timestamp;

  HistoryItem({
    required this.expression,
    required this.result,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'expression': expression,
        'result': result,
        'timestamp': timestamp.toIso8601String(),
      };

  factory HistoryItem.fromJson(Map<String, dynamic> json) => HistoryItem(
        expression: json['expression'],
        result: json['result'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}

class CalculatorProvider extends ChangeNotifier {
  String _expression = '';
  String _result = '0';
  String _displayExpression = '';
  bool _hasResult = false;
  bool _isError = false;
  List<HistoryItem> _history = [];

  String get expression => _expression;
  String get result => _result;
  String get displayExpression => _displayExpression;
  bool get hasResult => _hasResult;
  bool get isError => _isError;
  List<HistoryItem> get history => List.unmodifiable(_history);

  CalculatorProvider() {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('calc_history') ?? '[]';
      final List<dynamic> decoded = jsonDecode(historyJson);
      _history = decoded
          .map((item) => HistoryItem.fromJson(item as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (_) {
      _history = [];
    }
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson =
          jsonEncode(_history.map((e) => e.toJson()).toList());
      await prefs.setString('calc_history', historyJson);
    } catch (_) {}
  }

  void onButtonPressed(String value) {
    if (value == 'AC') {
      _clear();
    } else if (value == '⌫') {
      _backspace();
    } else if (value == '=') {
      _calculate();
    } else if (value == '%') {
      _percent();
    } else if (value == '+/-') {
      _toggleSign();
    } else {
      _append(value);
    }
    notifyListeners();
  }

  void _clear() {
    _expression = '';
    _result = '0';
    _displayExpression = '';
    _hasResult = false;
    _isError = false;
  }

  void _backspace() {
    if (_hasResult) {
      _hasResult = false;
      _expression = _result == '0' ? '' : _result;
      _result = '0';
      _displayExpression = _expression;
      return;
    }
    if (_expression.isNotEmpty) {
      _expression = _expression.substring(0, _expression.length - 1);
      _displayExpression = _expression;
      if (_expression.isEmpty) {
        _result = '0';
      } else {
        _tryEvaluate();
      }
    }
  }

  void _append(String value) {
    if (_isError) {
      _clear();
    }
    if (_hasResult && _isOperator(value)) {
      _expression = _result;
      _hasResult = false;
    } else if (_hasResult) {
      _expression = '';
      _hasResult = false;
    }

    // Prevent double operators
    if (_isOperator(value) && _expression.isNotEmpty) {
      final last = _expression[_expression.length - 1];
      if (_isOperator(last)) {
        _expression = _expression.substring(0, _expression.length - 1);
      }
    }

    // Prevent leading operator
    if (_isOperator(value) && _expression.isEmpty) return;

    // Prevent multiple dots in same number
    if (value == '.') {
      final parts = _expression.split(RegExp(r'[+\-×÷]'));
      if (parts.isNotEmpty && parts.last.contains('.')) return;
    }

    _expression += value;
    _displayExpression = _expression;
    _isError = false;
    _tryEvaluate();
  }

  void _tryEvaluate() {
    try {
      final eval = _evaluateExpression(_expression);
      if (eval != null) {
        _result = _formatNumber(eval);
      }
    } catch (_) {}
  }

  void _calculate() {
    if (_expression.isEmpty) return;
    try {
      final eval = _evaluateExpression(_expression);
      if (eval != null) {
        final res = _formatNumber(eval);
        _history.insert(
          0,
          HistoryItem(
            expression: _displayExpression,
            result: res,
            timestamp: DateTime.now(),
          ),
        );
        if (_history.length > 50) _history = _history.sublist(0, 50);
        _saveHistory();
        _result = res;
        _hasResult = true;
        _isError = false;
        _displayExpression = _expression;
        _expression = res;
      }
    } catch (_) {
      _result = 'Error';
      _isError = true;
      _hasResult = false;
    }
    notifyListeners();
  }

  void _percent() {
    if (_expression.isEmpty) return;
    try {
      final eval = _evaluateExpression(_expression);
      if (eval != null) {
        final pct = eval / 100;
        _expression = _formatNumber(pct);
        _displayExpression = _expression;
        _result = _expression;
        _hasResult = false;
      }
    } catch (_) {}
  }

  void _toggleSign() {
    if (_expression.isEmpty || _expression == '0') return;
    if (_expression.startsWith('-')) {
      _expression = _expression.substring(1);
    } else {
      _expression = '-$_expression';
    }
    _displayExpression = _expression;
    _tryEvaluate();
  }

  double? _evaluateExpression(String expr) {
    if (expr.isEmpty) return null;
    // Replace display symbols with math operators
    String e = expr
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll(',', '');

    // Simple recursive descent parser
    try {
      final result = _parse(e);
      if (result.isNaN || result.isInfinite) throw Exception('Invalid');
      return result;
    } catch (_) {
      return null;
    }
  }

  double _parse(String expr) {
    expr = expr.trim();
    // Find last + or - (not part of exponent, not first char)
    for (int i = expr.length - 1; i > 0; i--) {
      if ((expr[i] == '+' || expr[i] == '-') &&
          i > 0 &&
          expr[i - 1] != 'e' &&
          expr[i - 1] != 'E') {
        if (expr[i] == '+') {
          return _parse(expr.substring(0, i)) +
              _parse(expr.substring(i + 1));
        } else {
          return _parse(expr.substring(0, i)) -
              _parse(expr.substring(i + 1));
        }
      }
    }
    // Find last * or /
    for (int i = expr.length - 1; i >= 0; i--) {
      if (expr[i] == '*') {
        return _parse(expr.substring(0, i)) *
            _parse(expr.substring(i + 1));
      } else if (expr[i] == '/') {
        final divisor = _parse(expr.substring(i + 1));
        if (divisor == 0) throw Exception('Div by zero');
        return _parse(expr.substring(0, i)) / divisor;
      }
    }
    return double.parse(expr);
  }

  String _formatNumber(double value) {
    if (value == value.truncateToDouble() && value.abs() < 1e15) {
      return value.toInt().toString();
    }
    String str = value.toStringAsFixed(10);
    str = str.replaceAll(RegExp(r'0+$'), '');
    str = str.replaceAll(RegExp(r'\.$'), '');
    return str;
  }

  bool _isOperator(String v) => ['+', '-', '×', '÷'].contains(v);

  void clearHistory() {
    _history.clear();
    _saveHistory();
    notifyListeners();
  }

  void useHistoryItem(HistoryItem item) {
    _expression = item.result;
    _displayExpression = item.expression;
    _result = item.result;
    _hasResult = true;
    _isError = false;
    notifyListeners();
  }
}
