import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/widgets/responsive_layout.dart';
import 'package:jfit/core/utils/breakpoint_utils.dart';
import 'package:jfit/l10n/app_localizations.dart';
import '../bloc/pt_diet/pt_diet_bloc.dart';
import '../bloc/pt_diet/pt_diet_event.dart';
import '../bloc/pt_diet/pt_diet_state.dart';
import '../../domain/repositories/pt_diet_repository.dart';
import '../../domain/entities/diet_feedback.dart';
import '../widgets/feedback/feedback_type_selector.dart';
import '../widgets/feedback/feedback_text_input.dart';
import '../widgets/feedback/meal_reference_card.dart';
import '../widgets/feedback/feedback_templates.dart';
import '../widgets/feedback/feedback_preview.dart';

/// 식단 피드백 작성 화면
/// 코멘트, 추천사항, 우려사항을 터치/키보드 입력에 최적화하여 작성
class DietFeedbackCreatePage extends StatefulWidget {
  final String groupId;
  final String memberId;
  final String trainerId;
  final String? mealEntryId;
  final DateTime? date;

  const DietFeedbackCreatePage({
    super.key,
    required this.groupId,
    required this.memberId,
    required this.trainerId,
    this.mealEntryId,
    this.date,
  });

  @override
  State<DietFeedbackCreatePage> createState() => _DietFeedbackCreatePageState();
}

class _DietFeedbackCreatePageState extends State<DietFeedbackCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();
  final _focusNode = FocusNode();
  
  FeedbackType selectedType = FeedbackType.suggestion;
  bool isSubmitting = false;
  Map<String, dynamic>? mealData;

  @override
  void initState() {
    super.initState();
    _loadMealData();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _loadMealData() {
    if (widget.mealEntryId != null) {
      // Load member meal entries to get the specific meal entry
      final today = DateTime.now();
      context.read<PTDietBloc>().add(LoadMemberMealEntries(
        memberId: widget.memberId,
        startDate: today.subtract(const Duration(days: 1)),
        endDate: today.add(const Duration(days: 1)),
      ));
    }
  }

  void _onTypeChanged(FeedbackType type) {
    setState(() {
      selectedType = type;
    });
  }

  void _onTemplateSelected(String template) {
    final currentText = _feedbackController.text;
    final newText = currentText.isEmpty ? template : '$currentText\n\n$template';
    _feedbackController.text = newText;
    _feedbackController.selection = TextSelection.fromPosition(
      TextPosition(offset: newText.length),
    );
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSubmitting = true);

    try {
      context.read<PTDietBloc>().add(AddDietFeedback(
        request: CreateDietFeedbackRequest(
          groupId: widget.groupId,
          memberId: widget.memberId,
          trainerId: widget.trainerId,
          mealEntryId: widget.mealEntryId ?? '',
          feedbackText: _feedbackController.text.trim(),
          feedbackType: selectedType,
        ),
      ));

      // Wait for the operation to complete
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.feedbackSent ?? '피드백이 전송되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.feedbackError ?? '피드백 전송 중 오류가 발생했습니다'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createFeedback ?? '피드백 작성'),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: isSubmitting ? null : _submitFeedback,
            child: isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    l10n.send ?? '전송',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(context),
        tablet: _buildTabletLayout(context),
        desktop: _buildDesktopLayout(context),
      ),
    );
  }

  /// 모바일 레이아웃 - 세로 스크롤, 키보드 최적화
  Widget _buildMobileLayout(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(BreakpointUtils.getScreenPadding(
                MediaQuery.of(context).size.width,
              )),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (mealData != null) ...[
                    MealReferenceCard(mealData: mealData!),
                    const ResponsiveSpacing.vertical(mobileSpacing: 16),
                  ],
                  FeedbackTypeSelector(
                    selectedType: selectedType,
                    onTypeChanged: _onTypeChanged,
                  ),
                  const ResponsiveSpacing.vertical(mobileSpacing: 16),
                  FeedbackTemplates(
                    feedbackType: selectedType,
                    onTemplateSelected: _onTemplateSelected,
                  ),
                  const ResponsiveSpacing.vertical(mobileSpacing: 16),
                  FeedbackTextInput(
                    controller: _feedbackController,
                    focusNode: _focusNode,
                    feedbackType: selectedType,
                    minLines: 4,
                    maxLines: 8,
                  ),
                  const ResponsiveSpacing.vertical(mobileSpacing: 16),
                  FeedbackPreview(
                    feedbackText: _feedbackController.text,
                    feedbackType: selectedType,
                  ),
                ],
              ),
            ),
          ),
          // 하단 고정 버튼
          Container(
            padding: EdgeInsets.all(BreakpointUtils.getScreenPadding(
              MediaQuery.of(context).size.width,
            )),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: BreakpointUtils.getButtonHeight(
                  MediaQuery.of(context).size.width,
                ),
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _submitFeedback,
                  child: isSubmitting
                      ? const CircularProgressIndicator()
                      : Text(AppLocalizations.of(context)!.sendFeedback ?? '피드백 전송'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 태블릿 레이아웃 - 2컬럼 레이아웃
  Widget _buildTabletLayout(BuildContext context) {
    return Form(
      key: _formKey,
      child: Row(
        children: [
          // 왼쪽: 입력 영역 (3/5)
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(BreakpointUtils.getScreenPadding(
                  MediaQuery.of(context).size.width,
                )),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (mealData != null) ...[
                      MealReferenceCard(mealData: mealData!),
                      const ResponsiveSpacing.vertical(tabletSpacing: 20),
                    ],
                    FeedbackTypeSelector(
                      selectedType: selectedType,
                      onTypeChanged: _onTypeChanged,
                    ),
                    const ResponsiveSpacing.vertical(tabletSpacing: 20),
                    FeedbackTextInput(
                      controller: _feedbackController,
                      focusNode: _focusNode,
                      feedbackType: selectedType,
                      minLines: 6,
                      maxLines: 12,
                    ),
                    const ResponsiveSpacing.vertical(tabletSpacing: 20),
                    SizedBox(
                      width: double.infinity,
                      height: BreakpointUtils.getButtonHeight(
                        MediaQuery.of(context).size.width,
                      ),
                      child: ElevatedButton(
                        onPressed: isSubmitting ? null : _submitFeedback,
                        child: isSubmitting
                            ? const CircularProgressIndicator()
                            : Text(AppLocalizations.of(context)!.sendFeedback ?? '피드백 전송'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 오른쪽: 템플릿 및 미리보기 (2/5)
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(BreakpointUtils.getScreenPadding(
                MediaQuery.of(context).size.width,
              )),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FeedbackTemplates(
                    feedbackType: selectedType,
                    onTemplateSelected: _onTemplateSelected,
                  ),
                  const ResponsiveSpacing.vertical(tabletSpacing: 20),
                  FeedbackPreview(
                    feedbackText: _feedbackController.text,
                    feedbackType: selectedType,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 데스크탑 레이아웃 - 3컬럼 레이아웃
  Widget _buildDesktopLayout(BuildContext context) {
    return ResponsiveContainer(
      desktopMaxWidth: 1200,
      child: Form(
        key: _formKey,
        child: Row(
          children: [
            // 왼쪽: 식사 정보 및 타입 선택 (1/3)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(BreakpointUtils.getScreenPadding(
                    MediaQuery.of(context).size.width,
                  )),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (mealData != null) ...[
                        MealReferenceCard(mealData: mealData!),
                        const ResponsiveSpacing.vertical(desktopSpacing: 24),
                      ],
                      FeedbackTypeSelector(
                        selectedType: selectedType,
                        onTypeChanged: _onTypeChanged,
                      ),
                      const ResponsiveSpacing.vertical(desktopSpacing: 24),
                      FeedbackTemplates(
                        feedbackType: selectedType,
                        onTemplateSelected: _onTemplateSelected,
                        isCompact: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // 중앙: 텍스트 입력 (1/3)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(BreakpointUtils.getScreenPadding(
                          MediaQuery.of(context).size.width,
                        )),
                        child: FeedbackTextInput(
                          controller: _feedbackController,
                          focusNode: _focusNode,
                          feedbackType: selectedType,
                          minLines: 10,
                          maxLines: null, // 무제한
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(BreakpointUtils.getScreenPadding(
                        MediaQuery.of(context).size.width,
                      )),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Theme.of(context).dividerColor,
                            width: 1,
                          ),
                        ),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: BreakpointUtils.getButtonHeight(
                          MediaQuery.of(context).size.width,
                        ),
                        child: ElevatedButton(
                          onPressed: isSubmitting ? null : _submitFeedback,
                          child: isSubmitting
                              ? const CircularProgressIndicator()
                              : Text(AppLocalizations.of(context)!.sendFeedback ?? '피드백 전송'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 오른쪽: 미리보기 (1/3)
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(BreakpointUtils.getScreenPadding(
                  MediaQuery.of(context).size.width,
                )),
                child: FeedbackPreview(
                  feedbackText: _feedbackController.text,
                  feedbackType: selectedType,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}