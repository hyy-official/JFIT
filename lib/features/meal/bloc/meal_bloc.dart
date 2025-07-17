import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/bloc/base_bloc.dart';
import 'package:jfit/core/bloc/bloc_event_bus.dart';
import 'package:jfit/core/error/bloc_errors.dart';
import 'package:jfit/features/meal/bloc/meal_event.dart';
import 'package:jfit/features/meal/bloc/meal_state.dart';
import 'package:jfit/features/meal/data/repositories/meal_repository.dart';
import 'package:jfit/features/records/data/models/meal_record_model.dart';

class MealBloc extends BaseBloc<MealEvent, MealState> {
  final MealRepository _mealRepository;

  MealBloc({
    required MealRepository mealRepository,
  })  : _mealRepository = mealRepository,
        super(MealInitial()) {
    on<LoadMealRecords>(_onLoadMealRecords);
    on<AddMealRecord>(_onAddMealRecord);
    on<UpdateMealRecord>(_onUpdateMealRecord);
    on<DeleteMealRecord>(_onDeleteMealRecord);
  }

  @override
  void handleCommunicationEvent(BlocCommunicationEvent event) {
    // MealBloc currently doesn't need to listen to other BLOCs
    // But this method is here for future enhancements
    // For example, we might want to handle user profile changes
    // that affect meal recommendations or dietary restrictions
    
    if (event is DailySummaryRefreshRequestedEvent) {
      // We could potentially handle daily summary refresh requests
      // to provide meal-related data, but for now we don't need to
      // as the DailySummaryBloc handles this directly through the repository
    }
  }

  Future<void> _onLoadMealRecords(
    LoadMealRecords event,
    Emitter<MealState> emit,
  ) async {
    // Validate input parameters
    if (event.userId.isEmpty) {
      emit(MealErrorState(
        failure: MealError(
          'User ID cannot be empty',
          code: BlocErrorCodes.validationError,
        ),
      ));
      return;
    }

    emit(MealLoading());

    try {
      final result = await _mealRepository.getMealRecords(
        event.userId,
        date: event.date,
      );

      result.fold(
        (failure) {
          final mealError = _convertFailureToBlocError(failure);
          emit(MealErrorState(failure: mealError));
        },
        (mealRecords) {
          emit(MealRecordsLoaded(mealRecords: mealRecords));
        },
      );
    } catch (e) {
      // Handle unexpected errors
      emit(MealErrorState(
        failure: MealError(
          'Unexpected error occurred while loading meal records: ${e.toString()}',
          code: BlocErrorCodes.unknown,
        ),
      ));
    }
  }

  Future<void> _onAddMealRecord(
    AddMealRecord event,
    Emitter<MealState> emit,
  ) async {
    debugPrint('🍽️ MealBloc: Starting to add meal record');
    debugPrint('🍽️ MealBloc: Meal record data: ${event.mealRecord.toString()}');
    
    // Validate meal record data
    final validationError = _validateMealRecord(event.mealRecord);
    if (validationError != null) {
      debugPrint('❌ MealBloc: Validation error: ${validationError.message}');
      emit(MealErrorState(failure: validationError));
      return;
    }

    debugPrint('✅ MealBloc: Validation passed, emitting loading state');
    emit(MealLoading());

    try {
      debugPrint('🔄 MealBloc: Calling repository to add meal record');
      final result = await _mealRepository.addMealRecord(event.mealRecord);

      result.fold(
        (failure) {
          debugPrint('❌ MealBloc: Repository returned failure: ${failure.toString()}');
          final mealError = _convertFailureToBlocError(failure);
          debugPrint('❌ MealBloc: Converted to MealError: ${mealError.message}');
          emit(MealErrorState(failure: mealError));
        },
        (_) {
          debugPrint('✅ MealBloc: Repository success, emitting MealRecordAdded');
          emit(MealRecordAdded(mealRecord: event.mealRecord));
          
          // Emit communication event for other BLOCs
          debugPrint('📡 MealBloc: Emitting communication event');
          emitCommunicationEvent(MealRecordChangedEvent(
            userId: event.mealRecord.userId,
            date: event.mealRecord.mealDate,
            changeType: MealChangeType.added,
            recordId: event.mealRecord.id,
          ));
        },
      );
    } catch (e, stackTrace) {
      // Handle unexpected errors
      debugPrint('💥 MealBloc: Unexpected error caught: $e');
      debugPrint('💥 MealBloc: Stack trace: $stackTrace');
      emit(MealErrorState(
        failure: MealError(
          'Unexpected error occurred while adding meal record: ${e.toString()}',
          code: BlocErrorCodes.mealSaveFailed,
        ),
      ));
    }
  }

  Future<void> _onUpdateMealRecord(
    UpdateMealRecord event,
    Emitter<MealState> emit,
  ) async {
    // Validate meal record data
    final validationError = _validateMealRecord(event.mealRecord);
    if (validationError != null) {
      emit(MealErrorState(failure: validationError));
      return;
    }

    emit(MealLoading());

    try {
      final result = await _mealRepository.updateMealRecord(event.mealRecord);

      result.fold(
        (failure) {
          final mealError = _convertFailureToBlocError(failure);
          emit(MealErrorState(failure: mealError));
        },
        (_) {
          emit(MealRecordUpdated(mealRecord: event.mealRecord));
          
          // Emit communication event for other BLOCs
          emitCommunicationEvent(MealRecordChangedEvent(
            userId: event.mealRecord.userId,
            date: event.mealRecord.mealDate,
            changeType: MealChangeType.updated,
            recordId: event.mealRecord.id,
          ));
        },
      );
    } catch (e) {
      // Handle unexpected errors
      emit(MealErrorState(
        failure: MealError(
          'Unexpected error occurred while updating meal record: ${e.toString()}',
          code: BlocErrorCodes.mealSaveFailed,
        ),
      ));
    }
  }

  Future<void> _onDeleteMealRecord(
    DeleteMealRecord event,
    Emitter<MealState> emit,
  ) async {
    // Validate input parameters
    if (event.recordId.isEmpty) {
      emit(MealErrorState(
        failure: MealError(
          'Record ID cannot be empty',
          code: BlocErrorCodes.validationError,
        ),
      ));
      return;
    }

    if (event.userId.isEmpty) {
      emit(MealErrorState(
        failure: MealError(
          'User ID cannot be empty',
          code: BlocErrorCodes.validationError,
        ),
      ));
      return;
    }

    emit(MealLoading());

    try {
      final result = await _mealRepository.deleteMealRecord(event.recordId);

      result.fold(
        (failure) {
          final mealError = _convertFailureToBlocError(failure);
          emit(MealErrorState(failure: mealError));
        },
        (_) {
          emit(MealRecordDeleted(recordId: event.recordId));
          
          // Emit communication event for other BLOCs
          emitCommunicationEvent(MealRecordChangedEvent(
            userId: event.userId,
            date: event.date,
            changeType: MealChangeType.deleted,
            recordId: event.recordId,
          ));
        },
      );
    } catch (e) {
      // Handle unexpected errors
      emit(MealErrorState(
        failure: MealError(
          'Unexpected error occurred while deleting meal record: ${e.toString()}',
          code: BlocErrorCodes.mealDeleteFailed,
        ),
      ));
    }
  }

  /// Validate meal record data before processing
  MealError? _validateMealRecord(MealRecord mealRecord) {
    // Validate required fields
    if (mealRecord.id.isEmpty) {
      return MealError(
        'Meal record ID cannot be empty',
        code: BlocErrorCodes.mealValidationFailed,
      );
    }

    if (mealRecord.userId.isEmpty) {
      return MealError(
        'User ID cannot be empty',
        code: BlocErrorCodes.mealValidationFailed,
      );
    }

    if (mealRecord.mealType.isEmpty) {
      return MealError(
        'Meal type cannot be empty',
        code: BlocErrorCodes.mealValidationFailed,
      );
    }

    // Validate meal type is one of the expected values
    const validMealTypes = ['breakfast', 'lunch', 'dinner', 'snack'];
    if (!validMealTypes.contains(mealRecord.mealType.toLowerCase())) {
      return MealError(
        'Invalid meal type. Must be one of: ${validMealTypes.join(', ')}',
        code: BlocErrorCodes.mealValidationFailed,
      );
    }

    // Validate nutritional values are not negative
    if (mealRecord.totalCalories != null && mealRecord.totalCalories! < 0) {
      return MealError(
        'Total calories cannot be negative',
        code: BlocErrorCodes.mealValidationFailed,
      );
    }

    if (mealRecord.totalProtein != null && mealRecord.totalProtein! < 0) {
      return MealError(
        'Total protein cannot be negative',
        code: BlocErrorCodes.mealValidationFailed,
      );
    }

    if (mealRecord.totalCarbs != null && mealRecord.totalCarbs! < 0) {
      return MealError(
        'Total carbs cannot be negative',
        code: BlocErrorCodes.mealValidationFailed,
      );
    }

    if (mealRecord.totalFat != null && mealRecord.totalFat! < 0) {
      return MealError(
        'Total fat cannot be negative',
        code: BlocErrorCodes.mealValidationFailed,
      );
    }

    // Validate meal date is not in the future (with some tolerance for timezone differences)
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    if (mealRecord.mealDate.isAfter(tomorrow)) {
      return MealError(
        'Meal date cannot be in the future',
        code: BlocErrorCodes.mealValidationFailed,
      );
    }

    // Validate meal date is not too far in the past (e.g., more than 1 year)
    final oneYearAgo = DateTime(now.year - 1, now.month, now.day);
    if (mealRecord.mealDate.isBefore(oneYearAgo)) {
      return MealError(
        'Meal date cannot be more than one year in the past',
        code: BlocErrorCodes.mealValidationFailed,
      );
    }

    return null; // No validation errors
  }

  /// Convert generic Failure to MealError for consistent error handling
  MealError _convertFailureToBlocError(dynamic failure) {
    if (failure is MealError) {
      return failure;
    }
    
    String code = BlocErrorCodes.unknown;
    if (failure.message.contains('network') || failure.message.contains('connection')) {
      code = BlocErrorCodes.networkError;
    } else if (failure.message.contains('server') || failure.message.contains('http')) {
      code = BlocErrorCodes.serverError;
    } else if (failure.message.contains('validation')) {
      code = BlocErrorCodes.validationError;
    }
    
    return MealError(
      failure.message,
      code: code,
    );
  }
}