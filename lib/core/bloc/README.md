# BLOC Refactoring - Core Components

This document describes the core components implemented for the BLOC refactoring project.

## Project Structure

The following new feature folders have been created:

### 1. Meal Feature (`lib/features/meal/`)
- `bloc/meal_bloc.dart` - Placeholder for MealBloc implementation
- `bloc/meal_event.dart` - Placeholder for MealEvent classes
- `bloc/meal_state.dart` - Placeholder for MealState classes
- `data/repositories/meal_repository.dart` - Placeholder for MealRepository

### 2. Workout Program Feature (`lib/features/workout_program/`)
- `bloc/workout_program_bloc.dart` - Placeholder for WorkoutProgramBloc implementation
- `bloc/workout_program_event.dart` - Placeholder for WorkoutProgramEvent classes
- `bloc/workout_program_state.dart` - Placeholder for WorkoutProgramState classes
- `data/repositories/workout_program_repository.dart` - Placeholder for WorkoutProgramRepository

### 3. Workout Session Feature (`lib/features/workout_session/`)
- `bloc/workout_session_bloc.dart` - Placeholder for WorkoutSessionBloc implementation
- `bloc/workout_session_event.dart` - Placeholder for WorkoutSessionEvent classes
- `bloc/workout_session_state.dart` - Placeholder for WorkoutSessionState classes
- `data/repositories/workout_session_repository.dart` - Placeholder for WorkoutSessionRepository

### 4. Daily Summary Feature (`lib/features/daily_summary/`)
- `bloc/daily_summary_bloc.dart` - Placeholder for DailySummaryBloc implementation
- `bloc/daily_summary_event.dart` - Placeholder for DailySummaryEvent classes
- `bloc/daily_summary_state.dart` - Placeholder for DailySummaryState classes
- `data/repositories/daily_summary_repository.dart` - Placeholder for DailySummaryRepository

### 5. Exercise Feature (Existing)
- The exercise feature already exists and will be enhanced in later tasks

## Core Components Implemented

### 1. BLOC Event Bus System (`lib/core/bloc/bloc_event_bus.dart`)

A centralized communication system for BLOC-to-BLOC communication:

- **BlocEventBus**: Singleton class managing event streams
- **BlocCommunicationEvent**: Base class for all communication events
- **Specific Events**:
  - `MealRecordChangedEvent`: Emitted when meal records change
  - `WorkoutSessionCompletedEvent`: Emitted when workout sessions complete
  - `WorkoutProgramProgressUpdatedEvent`: Emitted when program progress updates
  - `DailySummaryRefreshRequestedEvent`: Emitted when summary refresh is needed

### 2. Common Error Handling (`lib/core/error/bloc_errors.dart`)

Comprehensive error handling system extending existing Failure classes:

- **BlocError**: Base class for all BLOC-specific errors
- **Specific Error Types**:
  - `MealError`: Meal-related errors
  - `WorkoutProgramError`: Workout program-related errors
  - `WorkoutSessionError`: Workout session-related errors
  - `DailySummaryError`: Daily summary-related errors
  - `ExerciseError`: Exercise-related errors
  - `BlocCommunicationError`: Communication-related errors

- **BlocErrorCodes**: Standardized error codes for consistent handling
- **BlocErrorHandler**: Utility class for error processing and user-friendly messages

### 3. Base Repository Interfaces (`lib/core/interfaces/base_repository.dart`)

Common interfaces and mixins for repository implementations:

- **BaseRepository**: Core interface with safe operation handling
- **BaseRepositoryMixin**: Common functionality implementation
- **UserDataRepository**: Interface for user-specific data repositories
- **DateBasedRepository**: Interface for date-based data repositories
- **CrudRepository**: Interface for CRUD operations
- **SearchableRepository**: Interface for search functionality

### 4. Base BLOC Class (`lib/core/bloc/base_bloc.dart`)

Enhanced base class for all BLOCs with:

- **BaseBloc**: Abstract base class with event bus integration
- **Event Bus Integration**: Automatic setup and cleanup of communication listeners
- **Error Handling**: Safe async operation wrappers
- **Common States**:
  - `BaseState`: Base state class
  - `LoadingState`: Common loading state
  - `ErrorState`: Common error state with user-friendly messages
  - `SuccessState`: Common success state
- **BaseEvent**: Base event class

## Integration Points

### Event Bus Communication Flow
1. BLOCs emit communication events using `emitCommunicationEvent()`
2. Other BLOCs receive events through `handleCommunicationEvent()`
3. Automatic cleanup prevents memory leaks

### Error Handling Flow
1. Repositories use `BaseRepositoryMixin.safeCall()` for consistent error handling
2. BLOCs use `BaseBloc.safeAsyncOperation()` for safe async operations
3. Errors are converted to appropriate BLOC error types
4. User-friendly messages are generated automatically

### Repository Pattern
1. All repositories implement appropriate base interfaces
2. Common functionality is provided through mixins
3. Consistent error handling across all data operations

## Next Steps

The placeholders created in this task will be implemented in subsequent tasks:
- Task 2: MealBloc implementation
- Task 3: WorkoutProgramBloc implementation
- Task 4: WorkoutSessionBloc implementation
- Task 5: DailySummaryBloc implementation
- Task 6: ExerciseBloc enhancement
- Task 7: BLOC communication integration
- Tasks 8-11: UI migration and cleanup

## Requirements Satisfied

This implementation satisfies the following requirements:
- **6.1**: BLOC간 통신을 위한 이벤트 버스 시스템 구현
- **6.3**: 공통 에러 처리 클래스 및 인터페이스 정의