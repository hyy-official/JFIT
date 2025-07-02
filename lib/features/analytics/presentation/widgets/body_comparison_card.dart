import 'package:flutter/material.dart';
import 'package:jfit/core/theme/analytics_chart_theme.dart';
import 'package:jfit/features/analytics/domain/entities/body_data.dart';
import 'package:intl/intl.dart';

class BodyComparisonCard extends StatelessWidget {
  final BodyData? previousData;
  final BodyData? currentData;

  const BodyComparisonCard({
    super.key,
    this.previousData,
    this.currentData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AnalyticsChartTheme.cardBackground,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AnalyticsChartTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '변화 비교',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20.0),
          _buildComparisonPhotos(context),
          const SizedBox(height: 20.0),
          _buildChangeSummary(),
        ],
      ),
    );
  }

  Widget _buildComparisonPhotos(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildPhotoSection(context, previousData, '이전 측정'),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: _buildPhotoSection(context, currentData, '최신 측정'),
        ),
      ],
    );
  }

  Widget _buildPhotoSection(BuildContext context, BodyData? data, String title) {
    final String dateText = data != null ? DateFormat('yyyy.MM.dd').format(DateTime.parse(data.dateLabel)) : '-';

    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.width * 0.4,
          decoration: BoxDecoration(
            color: const Color(0xFF2D2D2D),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: const Color(0xFF404040), width: 1),
          ),
          child: data == null
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        color: Color(0xFF666666),
                        size: 48,
                      ),
                      SizedBox(height: 12),
                      Text(
                        '사진 없음',
                        style: TextStyle(
                          color: Color(0xFF999999),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : const Center(
                  child: Icon(
                    Icons.camera_alt_outlined,
                    color: Color(0xFF666666),
                    size: 48,
                  ),
                ), // TODO: Replace with actual image widget
        ),
        const SizedBox(height: 12.0),
        Text(
          '$dateText 업로드',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12.0),
        _buildMeasurementText('체중', data?.weight, 'kg'),
        const SizedBox(height: 4.0),
        _buildMeasurementText('골격근량', data?.skeletalMuscleMass, 'kg'),
        const SizedBox(height: 4.0),
        _buildMeasurementText('체지방률', data?.bodyFatPercentage, '%'),
      ],
    );
  }

  Widget _buildMeasurementText(String label, double? value, String unit) {
    return Text(
      '$label: ${value != null ? '${value.toStringAsFixed(1)}$unit' : '-'}',
      style: const TextStyle(
        color: Color(0xFFCCCCCC),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildChangeSummary() {
    if (previousData == null || currentData == null) {
      return const SizedBox.shrink(); // No data to compare
    }

    final int daysDiff = currentData!.dateLabel != previousData!.dateLabel
        ? DateTime.parse(currentData!.dateLabel).difference(DateTime.parse(previousData!.dateLabel)).inDays
        : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFF333333), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${daysDiff}일간 변화',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildChangeColumn('체중', currentData!.weight - previousData!.weight, 'kg', ChangeType.weight),
              _buildChangeColumn('근육량', currentData!.skeletalMuscleMass - previousData!.skeletalMuscleMass, 'kg', ChangeType.skeletalMuscleMass),
              _buildChangeColumn('체지방률', currentData!.bodyFatPercentage - previousData!.bodyFatPercentage, '%', ChangeType.bodyFatPercentage),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChangeColumn(String label, double change, String unit, ChangeType type) {
    Color color;
    String sign = '';

    if (change > 0) {
      sign = '+';
      if (type == ChangeType.weight || type == ChangeType.bodyFatPercentage) {
        color = const Color(0xFFFF6B6B); // 체중, 체지방률 증가는 빨간색
      } else {
        color = const Color(0xFF4ECDC4); // 근육량 증가는 청록색
      }
    } else if (change < 0) {
      if (type == ChangeType.weight || type == ChangeType.bodyFatPercentage) {
        color = const Color(0xFF4ECDC4); // 체중, 체지방률 감소는 청록색
      } else {
        color = const Color(0xFFFF6B6B); // 근육량 감소는 빨간색
      }
    } else {
      color = const Color(0xFF999999); // 변화 없음
    }

    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFCCCCCC),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$sign${change.toStringAsFixed(1)}$unit',
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

enum ChangeType { weight, skeletalMuscleMass, bodyFatPercentage }
