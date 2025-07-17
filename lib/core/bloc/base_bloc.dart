import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:jfit/core/bloc/bloc_event_bus.dart';
import 'package:jfit/core/error/bloc_errors.dart';

/// Base class for all BLOCs in the application
/// Provides common functionality like error handling, event bus integration, and performance optimizations
abstract class BaseBloc<Event extends Equatable, State extends Equatable>
    extends Bloc<Event, State> {
  
  final BlocEventBus _eventBus = BlocEventBus();
  StreamSubscription<BlocCommunicationEvent>? _eventBusSubscription;
  
  // Performance optimization: Track BLOC lifecycle
  bool _isDisposed = false;
  DateTime? _createdAt;
  DateTime? _lastActivityAt;
  
  // Memory optimization: Debounce timers for cleanup
  Timer? _inactivityTimer;
  static const Duration _inactivityThreshold = Duration(minutes: 5);

  BaseBloc(super.initialState) {
    _createdAt = DateTime.now();
    _lastActivityAt = DateTime.now();
    _setupEventBusListener();
    _startInactivityTracking();
  }

  /// Setup event bus listener for inter-BLOC communication
  void _setupEventBusListener() {
    if (_isDisposed) return;
    
    _eventBusSubscription = _eventBus.stream.listen(
      (event) {
        if (!_isDisposed) {
          _updateActivity();
          handleCommunicationEvent(event);
        }
      },
      onError: (error) {
        if (!_isDisposed) {
          handleCommunicationError(error);
        }
      },
    );
  }

  /// Start tracking inactivity for memory optimization
  void _startInactivityTracking() {
    _resetInactivityTimer();
  }

  /// Reset the inactivity timer
  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(_inactivityThreshold, () {
      if (!_isDisposed) {
        _handleInactivity();
      }
    });
  }

  /// Update last activity timestamp and reset inactivity timer
  void _updateActivity() {
    _lastActivityAt = DateTime.now();
    _resetInactivityTimer();
  }

  /// Handle BLOC inactivity - can be overridden by child classes
  void _handleInactivity() {
    // Default implementation: just log the inactivity
    // Child classes can override this to implement specific cleanup logic
    onInactivity();
  }

  /// Called when BLOC has been inactive for the threshold duration
  /// Override this in child classes to implement custom cleanup logic
  void onInactivity() {
    // Default implementation - do nothing
    // Child classes can override to clear caches, cancel subscriptions, etc.
  }

  /// Handle communication events from other BLOCs
  /// Override this method in child classes to handle specific events
  void handleCommunicationEvent(BlocCommunicationEvent event) {
    // Default implementation - do nothing
    // Child classes should override this to handle relevant events
  }

  /// Handle communication errors
  void handleCommunicationError(dynamic error) {
    // Log error or emit error state if needed
    // Default implementation - do nothing
    // In a production app, you might want to log this error
    // or emit a specific error state for communication failures
    try {
      // Convert to appropriate error type
      final communicationError = BlocCommunicationError(
        'Communication event handling failed: ${error.toString()}',
        code: BlocErrorCodes.communicationError,
      );
      
      // Child classes can override this to handle communication errors
      // For now, we'll just ensure the error doesn't crash the BLOC
    } catch (e) {
      // Even error handling shouldn't crash the BLOC
      // This is a last resort to maintain app stability
    }
  }

  /// Emit a communication event to other BLOCs
  void emitCommunicationEvent(BlocCommunicationEvent event) {
    _eventBus.emit(event);
  }

  /// Safe error handling wrapper for async operations
  Future<void> safeAsyncOperation(
    Future<void> Function() operation,
    void Function(BlocError error) onError,
  ) async {
    try {
      await operation();
    } catch (e) {
      final error = _convertToAppropriateError(e);
      onError(error);
    }
  }

  /// Convert generic exceptions to appropriate BLOC errors
  BlocError _convertToAppropriateError(dynamic exception) {
    if (exception is BlocError) {
      return exception;
    }
    
    // Default to general error - child classes can override this
    return BlocCommunicationError(
      exception.toString(),
      code: BlocErrorCodes.unknown,
    );
  }

  @override
  Future<void> close() {
    _isDisposed = true;
    _inactivityTimer?.cancel();
    _eventBusSubscription?.cancel();
    return super.close();
  }

  /// Get BLOC performance metrics
  Map<String, dynamic> getPerformanceMetrics() {
    final now = DateTime.now();
    return {
      'created_at': _createdAt?.toIso8601String(),
      'last_activity_at': _lastActivityAt?.toIso8601String(),
      'uptime_minutes': _createdAt != null 
          ? now.difference(_createdAt!).inMinutes 
          : 0,
      'inactive_minutes': _lastActivityAt != null 
          ? now.difference(_lastActivityAt!).inMinutes 
          : 0,
      'is_disposed': _isDisposed,
    };
  }

  /// Check if BLOC is currently active (has recent activity)
  bool get isActive {
    if (_isDisposed || _lastActivityAt == null) return false;
    final inactiveTime = DateTime.now().difference(_lastActivityAt!);
    return inactiveTime < _inactivityThreshold;
  }
}

/// Base state class for all BLOC states
abstract class BaseState extends Equatable {
  const BaseState();

  @override
  List<Object?> get props => [];
}

/// Common loading state
class LoadingState extends BaseState {
  final String? message;
  
  const LoadingState({this.message});

  @override
  List<Object?> get props => [message];
}

/// Common error state
class ErrorState extends BaseState {
  final BlocError error;
  
  const ErrorState(this.error);

  @override
  List<Object?> get props => [error];
  
  /// Get user-friendly error message
  String get userMessage => BlocErrorHandler.getUserFriendlyMessage(error);
}

/// Common success state for operations that don't return data
class SuccessState extends BaseState {
  final String message;
  
  const SuccessState(this.message);

  @override
  List<Object?> get props => [message];
}

/// Base event class for all BLOC events
abstract class BaseEvent extends Equatable {
  const BaseEvent();

  @override
  List<Object?> get props => [];
}