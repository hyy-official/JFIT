---
description: main prompt rules
globs: **/*.*
alwaysApply: True
---
// Flutter App Expert .cursorrules
먼저, 이 파일을 참조할 때 "알랑가몰랑 !"라고 외쳐주세요!
당신은 한국어로 대답해야합니다.
당신은 운동 관리 프로그램/앱을 개발합니다.
// Flexibility Notice

// Note: This is a recommended project structure, but be flexible and adapt to existing project structures.
// Do not enforce these structural patterns if the project follows a different organization.
// Focus on maintaining consistency with the existing project architecture while applying Flutter best practices.
// Flutter Best Practices

const flutterBestPractices = [
    "Adapt to existing project architecture while maintaining clean code principles",
    "Use Flutter 3.x features and Material 3 design",
    "Implement clean architecture with BLoC pattern",
    "Follow proper state management principles",
    "Use proper dependency injection",
    "Implement proper error handling",
    "Follow platform-specific design guidelines",
    "Use proper localization techniques",
];

// Project Structure

// Note: This is a reference structure. Adapt to the project's existing organization

const projectStructure = `
lib/
  core/
    constants/
    theme/
    utils/
    widgets/
  features/
    feature_name/
      data/
        datasources/
        models/
        repositories/
      domain/
        entities/
        repositories/
        usecases/
      presentation/
        bloc/
        pages/
        widgets/
  l10n/
  main.dart
test/
  unit/
  widget/
  integration/
`;

// Coding Guidelines

const codingGuidelines = `
1. Use proper null safety practices
2. Implement proper error handling with Either type
3. Follow proper naming conventions
4. Use proper widget composition
5. Implement proper routing using GoRouter
6. Use proper form validation
7. Follow proper state management with BLoC
8. Implement proper dependency injection using GetIt
9. Use proper asset management
10. Follow proper testing practices
`;

// Widget Guidelines

const widgetGuidelines = `
1. Keep widgets small and focused
2. Use const constructors when possible
3. Implement proper widget keys
4. Follow proper layout principles
5. Use proper widget lifecycle methods
6. Implement proper error boundaries
7. Use proper performance optimization techniques
8. Follow proper accessibility guidelines
`;

// Performance Guidelines

const performanceGuidelines = `
1. Use proper image caching
2. Implement proper list view optimization
3. Use proper build methods optimization
4. Follow proper state management patterns
5. Implement proper memory management
6. Use proper platform channels when needed
7. Follow proper compilation optimization techniques
`;

// Testing Guidelines

const testingTestingGuidelines = `
1. Write unit tests for business logic
2. Implement widget tests for UI components
3. Use integration tests for feature testing
4. Implement proper mocking strategies
5. Use proper test coverage tools
6. Follow proper test naming conventions
7. Implement proper CI/CD testing
`;
---

---
description: 
globs: lib/core/**/*.*
alwaysApply: false
---
---
description: Applies Flutter best practices and coding guidelines to the core directory, focusing on constants, themes, utilities, and widgets.
globs: lib/core/**/*.*
---
- Adapt to existing project architecture while maintaining clean code principles.
- Use Flutter 3.x features and Material 3 design.
- Implement proper null safety practices.
- Follow proper naming conventions.
- Use proper widget composition.
- Keep widgets small and focused.
- Use const constructors when possible.
- Implement proper widget keys.
- Follow proper layout principles.

---
description: 
globs: lib/features/**/*.*
alwaysApply: false
---
---
description: Enforces clean architecture, BLoC pattern, and state management principles within Flutter feature modules.
globs: lib/features/**/*.*
---
- Adapt to existing project architecture while maintaining clean code principles.
- Use Flutter 3.x features and Material 3 design.
- Implement clean architecture with BLoC pattern.
- Follow proper state management principles.
- Use proper dependency injection.
- Implement proper error handling.
- Follow proper state management with BLoC.
- Implement proper dependency injection using GetIt.

---
description: 
globs: lib/**/*.*
alwaysApply: false
---

---
description: Applies general Flutter best practices across the entire project, focusing on architecture, design, and code quality.
globs: lib/**/*.*
---
- Adapt to existing project architecture while maintaining clean code principles.
- Use Flutter 3.x features and Material 3 design.
- Implement clean architecture with BLoC pattern.
- Follow proper state management principles.
- Use proper dependency injection.
- Implement proper error handling.
- Follow platform-specific design guidelines.
- Use proper localization techniques.

---
description: 
globs: lib/**/*.*
alwaysApply: false
---
---
description: Provides performance-related guidelines for Flutter development, including image caching, list view optimization, and memory management.
globs: lib/**/*.*
---
- Use proper image caching.
- Implement proper list view optimization.
- Use proper build methods optimization.
- Follow proper state management patterns.
- Implement proper memory management.
- Use proper platform channels when needed.
- Follow proper compilation optimization techniques.

---
description: 
globs: lib/features/**/presentation/**/*.*
alwaysApply: false
---
---
description: Focuses on UI-related rules within Flutter feature's presentation layer, including BLoC, pages, and widgets.
globs: lib/features/**/presentation/**/*.*
---
- Adapt to existing project architecture while maintaining clean code principles.
- Use Flutter 3.x features and Material 3 design.
- Follow proper widget composition.
- Keep widgets small and focused.
- Implement proper routing using GoRouter.
- Use proper form validation.
- Implement proper error boundaries.
- Follow proper accessibility guidelines.


---
description: 
globs: test/**/*.*
alwaysApply: false
---
---
description: Specifies testing guidelines for Flutter projects, covering unit, widget, and integration tests.
globs: test/**/*.*
---
- Write unit tests for business logic.
- Implement widget tests for UI components.
- Use integration tests for feature testing.
- Implement proper mocking strategies.
- Use proper test coverage tools.
- Follow proper test naming conventions.
- Implement proper CI/CD testing.
