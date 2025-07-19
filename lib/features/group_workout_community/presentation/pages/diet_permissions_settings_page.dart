import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/widgets/responsive_layout.dart';
import 'package:jfit/core/utils/breakpoint_utils.dart';
import 'package:jfit/l10n/app_localizations.dart';
import '../bloc/pt_diet/pt_diet_bloc.dart';
import '../bloc/pt_diet/pt_diet_event.dart';
import '../bloc/pt_diet/pt_diet_state.dart';
import '../../domain/repositories/pt_diet_repository.dart';
import '../../domain/entities/pt_group_diet_permission.dart';
import '../widgets/permissions/permission_header.dart';
import '../widgets/permissions/permission_toggle_card.dart';
import '../widgets/permissions/trainer_info_card.dart';
import '../widgets/permissions/permission_explanation.dart';
import '../widgets/permissions/data_usage_info.dart';

/// 회원 식단 권한 설정 화면
/// 공유 범위, 프라이버시 제어를 반응형으로 처리
class DietPermissionsSettingsPage extends StatefulWidget {
  final String groupId;
  final String memberId;
  final String trainerId;

  const DietPermissionsSettingsPage({
    super.key,
    required this.groupId,
    required this.memberId,
    required this.trainerId,
  });

  @override
  State<DietPermissionsSettingsPage> createState() => _DietPermissionsSettingsPageState();
}

class _DietPermissionsSettingsPageState extends State<DietPermissionsSettingsPage> {
  PTGroupDietPermission? currentPermissions;
  bool isLoading = true;
  bool isSaving = false;
  
  // Permission states
  bool canViewMeals = true;
  bool canViewPhotos = true;
  bool canViewNutrition = true;
  bool allowDataAnalysis = true;
  bool allowRecommendations = true;
  bool allowComparison = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentPermissions();
  }

  void _loadCurrentPermissions() {
    setState(() => isLoading = true);
    
    context.read<PTDietBloc>().add(LoadDietPermissions(
      groupId: widget.groupId,
      memberId: widget.memberId,
      trainerId: widget.trainerId,
    ));
    
    // Also load group diet permissions for context
    context.read<PTDietBloc>().add(LoadGroupDietPermissions(
      groupId: widget.groupId,
      trainerId: widget.trainerId,
    ));
    
    // Simulate loading
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => isLoading = false);
      }
    });
  }

  Future<void> _savePermissions() async {
    setState(() => isSaving = true);

    try {
      context.read<PTDietBloc>().add(SetDietPermissions(
        request: DietPermissionRequest(
          groupId: widget.groupId,
          memberId: widget.memberId,
          trainerId: widget.trainerId,
          canViewMeals: canViewMeals,
          canViewPhotos: canViewPhotos,
          canViewNutrition: canViewNutrition,
        ),
      ));

      // Wait for the operation to complete
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.permissionsSaved ?? '권한 설정이 저장되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.permissionsError ?? '권한 설정 저장 중 오류가 발생했습니다'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  void _revokeAllPermissions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.revokePermissions ?? '권한 철회'),
        content: Text(AppLocalizations.of(context)!.revokePermissionsConfirm ?? 
            '모든 식단 공유 권한을 철회하시겠습니까? 트레이너는 더 이상 회원님의 식단 정보에 접근할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel ?? '취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performRevokeAll();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.revoke ?? '철회'),
          ),
        ],
      ),
    );
  }

  void _performRevokeAll() {
    setState(() {
      canViewMeals = false;
      canViewPhotos = false;
      canViewNutrition = false;
      allowDataAnalysis = false;
      allowRecommendations = false;
      allowComparison = false;
    });
    _savePermissions();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dietPermissions ?? '식단 권한 설정'),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: isSaving ? null : _savePermissions,
            child: isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    l10n.save ?? '저장',
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

  /// 모바일 레이아웃 - 세로 스크롤
  Widget _buildMobileLayout(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(BreakpointUtils.getScreenPadding(
        MediaQuery.of(context).size.width,
      )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PermissionHeader(
            groupId: widget.groupId,
            memberId: widget.memberId,
          ),
          const ResponsiveSpacing.vertical(mobileSpacing: 16),
          TrainerInfoCard(
            trainerId: widget.trainerId,
            groupId: widget.groupId,
          ),
          const ResponsiveSpacing.vertical(mobileSpacing: 16),
          PermissionExplanation(),
          const ResponsiveSpacing.vertical(mobileSpacing: 16),
          _buildPermissionToggles(),
          const ResponsiveSpacing.vertical(mobileSpacing: 16),
          DataUsageInfo(),
          const ResponsiveSpacing.vertical(mobileSpacing: 24),
          _buildActionButtons(),
          const ResponsiveSpacing.vertical(mobileSpacing: 80), // 하단 여백
        ],
      ),
    );
  }

  /// 태블릿 레이아웃 - 2컬럼
  Widget _buildTabletLayout(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(BreakpointUtils.getScreenPadding(
        MediaQuery.of(context).size.width,
      )),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 왼쪽: 정보 및 설명 (2/5)
          Expanded(
            flex: 2,
            child: Column(
              children: [
                PermissionHeader(
                  groupId: widget.groupId,
                  memberId: widget.memberId,
                ),
                const ResponsiveSpacing.vertical(tabletSpacing: 20),
                TrainerInfoCard(
                  trainerId: widget.trainerId,
                  groupId: widget.groupId,
                ),
                const ResponsiveSpacing.vertical(tabletSpacing: 20),
                PermissionExplanation(),
                const ResponsiveSpacing.vertical(tabletSpacing: 20),
                DataUsageInfo(),
              ],
            ),
          ),
          const ResponsiveSpacing.horizontal(tabletSpacing: 24),
          // 오른쪽: 권한 설정 (3/5)
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildPermissionToggles(),
                const ResponsiveSpacing.vertical(tabletSpacing: 24),
                _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 데스크탑 레이아웃 - 3컬럼
  Widget _buildDesktopLayout(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ResponsiveContainer(
      desktopMaxWidth: 1200,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(BreakpointUtils.getScreenPadding(
          MediaQuery.of(context).size.width,
        )),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 왼쪽: 헤더 및 트레이너 정보 (1/3)
            Expanded(
              child: Column(
                children: [
                  PermissionHeader(
                    groupId: widget.groupId,
                    memberId: widget.memberId,
                  ),
                  const ResponsiveSpacing.vertical(desktopSpacing: 24),
                  TrainerInfoCard(
                    trainerId: widget.trainerId,
                    groupId: widget.groupId,
                  ),
                ],
              ),
            ),
            const ResponsiveSpacing.horizontal(desktopSpacing: 32),
            // 중앙: 권한 설정 (1/3)
            Expanded(
              child: Column(
                children: [
                  _buildPermissionToggles(),
                  const ResponsiveSpacing.vertical(desktopSpacing: 24),
                  _buildActionButtons(),
                ],
              ),
            ),
            const ResponsiveSpacing.horizontal(desktopSpacing: 32),
            // 오른쪽: 설명 및 데이터 사용 정보 (1/3)
            Expanded(
              child: Column(
                children: [
                  PermissionExplanation(),
                  const ResponsiveSpacing.vertical(desktopSpacing: 24),
                  DataUsageInfo(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionToggles() {
    return Column(
      children: [
        PermissionToggleCard(
          title: AppLocalizations.of(context)!.viewMeals ?? '식사 기록 보기',
          subtitle: AppLocalizations.of(context)!.viewMealsDesc ?? '트레이너가 회원님의 식사 기록을 볼 수 있습니다',
          value: canViewMeals,
          onChanged: (value) => setState(() => canViewMeals = value),
          icon: Icons.restaurant,
        ),
        const ResponsiveSpacing.vertical(mobileSpacing: 12),
        PermissionToggleCard(
          title: AppLocalizations.of(context)!.viewPhotos ?? '식사 사진 보기',
          subtitle: AppLocalizations.of(context)!.viewPhotosDesc ?? '트레이너가 회원님의 식사 사진을 볼 수 있습니다',
          value: canViewPhotos,
          onChanged: (value) => setState(() => canViewPhotos = value),
          icon: Icons.photo_camera,
        ),
        const ResponsiveSpacing.vertical(mobileSpacing: 12),
        PermissionToggleCard(
          title: AppLocalizations.of(context)!.viewNutrition ?? '영양소 정보 보기',
          subtitle: AppLocalizations.of(context)!.viewNutritionDesc ?? '트레이너가 회원님의 영양소 섭취 정보를 볼 수 있습니다',
          value: canViewNutrition,
          onChanged: (value) => setState(() => canViewNutrition = value),
          icon: Icons.analytics,
        ),
        const ResponsiveSpacing.vertical(mobileSpacing: 12),
        PermissionToggleCard(
          title: AppLocalizations.of(context)!.allowAnalysis ?? '데이터 분석 허용',
          subtitle: AppLocalizations.of(context)!.allowAnalysisDesc ?? '식단 데이터를 분석하여 트렌드와 패턴을 파악할 수 있습니다',
          value: allowDataAnalysis,
          onChanged: (value) => setState(() => allowDataAnalysis = value),
          icon: Icons.trending_up,
          isEnabled: canViewMeals && canViewNutrition,
        ),
        const ResponsiveSpacing.vertical(mobileSpacing: 12),
        PermissionToggleCard(
          title: AppLocalizations.of(context)!.allowRecommendations ?? '추천 기능 허용',
          subtitle: AppLocalizations.of(context)!.allowRecommendationsDesc ?? 'AI 기반 식단 추천을 받을 수 있습니다',
          value: allowRecommendations,
          onChanged: (value) => setState(() => allowRecommendations = value),
          icon: Icons.lightbulb,
          isEnabled: canViewMeals && canViewNutrition,
        ),
        const ResponsiveSpacing.vertical(mobileSpacing: 12),
        PermissionToggleCard(
          title: AppLocalizations.of(context)!.allowComparison ?? '그룹 비교 허용',
          subtitle: AppLocalizations.of(context)!.allowComparisonDesc ?? '다른 그룹 멤버들과 익명으로 비교할 수 있습니다',
          value: allowComparison,
          onChanged: (value) => setState(() => allowComparison = value),
          icon: Icons.compare,
          isEnabled: canViewNutrition,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: BreakpointUtils.getButtonHeight(
            MediaQuery.of(context).size.width,
          ),
          child: ElevatedButton(
            onPressed: isSaving ? null : _savePermissions,
            child: isSaving
                ? const CircularProgressIndicator()
                : Text(AppLocalizations.of(context)!.savePermissions ?? '권한 설정 저장'),
          ),
        ),
        const ResponsiveSpacing.vertical(mobileSpacing: 12),
        SizedBox(
          width: double.infinity,
          height: BreakpointUtils.getButtonHeight(
            MediaQuery.of(context).size.width,
          ),
          child: OutlinedButton(
            onPressed: _revokeAllPermissions,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
            child: Text(AppLocalizations.of(context)!.revokeAllPermissions ?? '모든 권한 철회'),
          ),
        ),
        const ResponsiveSpacing.vertical(mobileSpacing: 16),
        Text(
          AppLocalizations.of(context)!.permissionsNote ?? 
              '권한은 언제든지 변경하거나 철회할 수 있습니다. 변경사항은 즉시 적용됩니다.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}