import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 전환마다 현재 Navigator 스택을 콘솔에 출력해 주는 디버그용 Observer.
/// 개발 환경에서만 활성화하도록 사용하는 것을 권장한다.
class StackLoggingObserver extends NavigatorObserver {
  final List<Route<dynamic>> _stack = [];

  void _logStack() {
    if (!kDebugMode) return; // 릴리즈 빌드에서는 출력 생략
    final names = _stack.map((r) => r.settings.name ?? r.runtimeType.toString()).toList();
    debugPrint('[NAV] Current stack (${names.length}): $names');
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _stack.add(route);
    _logStack();
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _stack.remove(route);
    _logStack();
    super.didPop(route, previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _stack.remove(route);
    _logStack();
    super.didRemove(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final index = _stack.indexOf(oldRoute!);
    if (index != -1 && newRoute != null) {
      _stack[index] = newRoute;
    }
    _logStack();
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
} 