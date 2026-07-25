import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/order_status.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

class TimelineStep {
  const TimelineStep({
    required this.status,
    required this.title,
    this.subtitle,
    this.completed = false,
    this.eta,
  });

  final OrderStatus status;
  final String title;
  final String? subtitle;
  final bool completed;
  final DateTime? eta;
}

/// Vertical order status timeline (Placed → … → Delivered).
class StatusTimeline extends StatelessWidget {
  const StatusTimeline({super.key, required this.steps});

  final List<TimelineStep> steps;

  static List<TimelineStep> forStatus(
    OrderStatus current, {
    DateTime? estimatedDelivery,
  }) {
    const flow = [
      OrderStatus.placed,
      OrderStatus.confirmed,
      OrderStatus.deliveryDateSet,
      OrderStatus.outForDelivery,
      OrderStatus.delivered,
    ];

    final currentIndex = flow.indexOf(current);
    return flow.map((s) {
      final i = flow.indexOf(s);
      return TimelineStep(
        status: s,
        title: s.timelineLabel,
        completed: currentIndex >= i && current != OrderStatus.cancelled,
        eta: s == OrderStatus.deliveryDateSet ? estimatedDelivery : null,
        subtitle: s == OrderStatus.deliveryDateSet && estimatedDelivery != null
            ? 'Est. ${DateFormat('EEE, d MMM').format(estimatedDelivery)}'
            : null,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          _StepRow(
            step: steps[i],
            isLast: i == steps.length - 1,
          ),
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.step, required this.isLast});

  final TimelineStep step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final done = step.completed;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? AppColors.forest : AppColors.paper2,
                ),
                child: Icon(
                  done ? Icons.check : Icons.circle,
                  size: done ? 12 : 6,
                  color: done ? AppColors.white : AppColors.slate,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: AppColors.line,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: AppTextStyles.body(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: done ? AppColors.ink : AppColors.slate,
                    ),
                  ),
                  if (step.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      step.subtitle!,
                      style: AppTextStyles.body(fontSize: 11, color: AppColors.slate),
                    ),
                  ],
                  if (step.eta != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.mustard.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'ETA ${DateFormat('d MMM yyyy').format(step.eta!)}',
                        style: AppTextStyles.mono(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF8A5C13),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
