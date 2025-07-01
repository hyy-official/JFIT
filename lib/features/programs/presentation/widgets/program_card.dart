import 'package:flutter/material.dart';
import 'package:jfit/core/theme/app_theme.dart';
import 'package:jfit/l10n/app_localizations.dart';
import 'package:jfit/features/programs/presentation/pages/program_detail_page.dart';

class ProgramCard extends StatelessWidget {
  final Map<String, dynamic> program;
  final String Function(String, AppLocalizations?) getLevelLabel;
  final String Function(String, AppLocalizations?) getTypeLabel;
  const ProgramCard({super.key, required this.program, required this.getLevelLabel, required this.getTypeLabel});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final isWide = constraints.maxWidth > 400;
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isMobile ? 380 : double.infinity,
            ),
            child: Card(
              color: AppTheme.cardBackgroundColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: EdgeInsets.all(isWide ? 16 : 8),
              elevation: 0,
              child: Container(
                constraints: BoxConstraints(
                  minHeight: isWide ? 260 : 220,
                ),
                padding: EdgeInsets.fromLTRB(isWide ? 24 : 14, isWide ? 24 : 14, isWide ? 24 : 14, isWide ? 16 : 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      program['name'],
                                      style: TextStyle(fontSize: isWide ? 20 : 16, fontWeight: FontWeight.bold, color: Colors.white),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  if (program['is_popular'] == true)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 6),
                                      child: Icon(Icons.trending_up, color: AppTheme.fatGraphColor, size: 20),
                                    ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text('${l10n?.by ?? 'by'} ${program['creator']}', style: TextStyle(color: Colors.grey[400], fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                        Row(
                          children: [
                            Icon(Icons.star, color: AppTheme.fatGraphColor, size: 18),
                            SizedBox(width: 2),
                            Text(program['rating'].toString(), style: TextStyle(color: Colors.amber[200], fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: isWide ? 10 : 6),
                    Text(
                      program['description'],
                      style: TextStyle(color: Colors.grey[300], fontSize: isWide ? 15 : 12),
                      maxLines: isWide ? 2 : 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isWide ? 12 : 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        ...List<String>.from(program['tags']).map((tag) {
                          if (['beginner', 'intermediate', 'advanced'].contains(tag)) {
                            return _TagChip(label: getLevelLabel(tag, l10n));
                          } else if (['strength', 'powerlifting', 'bodybuilding'].contains(tag)) {
                            return _TagChip(label: getTypeLabel(tag, l10n));
                          } else {
                            return _TagChip(label: tag);
                          }
                        }),
                      ],
                    ),
                    SizedBox(height: isWide ? 14 : 8),
                    Row(
                      children: [
                        _InfoIconText(icon: Icons.calendar_month, text: '${program['duration_weeks']} ${l10n?.weeks ?? 'weeks'}'),
                        SizedBox(width: 16),
                        _InfoIconText(icon: Icons.schedule, text: '${program['workouts_per_week']}x/${l10n?.frequency ?? 'week'}'),
                      ],
                    ),
                    SizedBox(height: isWide ? 10 : 6),
                    Row(
                      children: [
                        Text(l10n?.equipmentNeeded ?? 'Equipment needed:', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                        SizedBox(width: 6),
                        ...List<String>.from(program['equipment_needed']).map((e) => _EquipChip(label: e)),
                      ],
                    ),
                    SizedBox(height: isWide ? 14 : 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.workoutIconColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.symmetric(vertical: isWide ? 16 : 12),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProgramDetailPage(program: program),
                            ),
                          );
                        },
                        child: Text(l10n?.viewProgram ?? 'View Program', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isWide ? 15 : 13)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  const _TagChip({required this.label});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Color color = label.toLowerCase().contains('beginner') || label == (l10n?.beginner ?? 'Beginner')
        ? AppTheme.nutritionIconColor
        : label.toLowerCase().contains('strength') || label == (l10n?.strength ?? 'Strength')
            ? AppTheme.proteinGraphColor
            : label.toLowerCase().contains('powerlifting') || label == (l10n?.powerlifting ?? 'Powerlifting')
                ? AppTheme.fatGraphColor
                : label.toLowerCase().contains('bodybuilding') || label == (l10n?.bodybuilding ?? 'Bodybuilding')
                    ? AppTheme.carbsGraphColor
                    : AppTheme.workoutIconColor;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}

class _EquipChip extends StatelessWidget {
  final String label;
  const _EquipChip({required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 4),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(label, style: TextStyle(color: Colors.grey[300], fontSize: 11)),
    );
  }
}

class _InfoIconText extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoIconText({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[400], size: 17),
        SizedBox(width: 4),
        Text(text, style: TextStyle(color: Colors.grey[200], fontSize: 13)),
      ],
    );
  }
} 