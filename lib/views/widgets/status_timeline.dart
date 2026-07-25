import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../core/ui/app_motion.dart';
import '../../models/order_status.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

class TimelineStep {
  const TimelineStep({
    required this.status,
    required this.title,
    this.subtitle,
    this.completed = false,
    this.isCurrent = false,
    this.eta,
  });

  final OrderStatus status;
  final String title;
  final String? subtitle;
  final bool completed;
  final bool isCurrent;
  final DateTime? eta;
}

/// Vertical order status timeline (Placed → … → Delivered).
class StatusTimeline extends StatelessWidget {
  const StatusTimeline({super.key, required this.steps, this.animate = true});

  final List<TimelineStep> steps;
  final bool animate;

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
    return flow.asMap().entries.map((entry) {
      final i = entry.key;
      final s = entry.value;
      return TimelineStep(
        status: s,
        title: s.timelineLabel,
        completed: currentIndex >= i && current != OrderStatus.cancelled,
        isCurrent: i == currentIndex && current != OrderStatus.cancelled,
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
          )
              .animate(target: animate ? 1 : 1)
              .fadeIn(
                delay: (i * 70).ms,
                duration: 240.ms,
                curve: AppMotion.ease,
              )
              .slideY(
                begin: 0.12,
                end: 0,
                delay: (i * 70).ms,
                duration: 260.ms,
                curve: AppMotion.ease,
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
              _TimelineDot(done: done, isCurrent: step.isCurrent),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: done ? AppColors.forest.withValues(alpha: 0.35) : AppColors.line,
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
                    const SizedBox(height: 4),
                    Text(
                      step.subtitle!,
                      style: AppTextStyles.body(fontSize: 11, color: AppColors.slate),
                    ),
                  ],
                  if (step.eta != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.mustard.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(AppRadii.sm),
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

class _TimelineDot extends StatefulWidget {
  const _TimelineDot({required this.done, required this.isCurrent});

  final bool done;
  final bool isCurrent;

  @override
  State<_TimelineDot> createState() => _TimelineDotState();
}

class _TimelineDotState extends State<_TimelineDot>
    with SingleTickerProviderStateMixin {
  AnimationController? _pulse;

  @override
  void initState() {
    super.initState();
    if (widget.isCurrent) {
      _pulse = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900),
      )..repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _TimelineDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCurrent && _pulse == null) {
      _pulse = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900),
      )..repeat(reverse: true);
    } else if (!widget.isCurrent && _pulse != null) {
      _pulse!.dispose();
      _pulse = null;
    }
  }

  @override
  void dispose() {
    _pulse?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.done ? AppColors.forest : AppColors.paper2,
        boxShadow: widget.isCurrent
            ? AppShadows.soft(color: AppColors.forest, opacity: 0.25)
            : null,
      ),
      child: Icon(
        widget.done ? Icons.check : Icons.circle,
        size: widget.done ? 12 : 6,
        color: widget.done ? AppColors.white : AppColors.slate,
      ),
    );

    if (_pulse == null) return dot;

    return AnimatedBuilder(
      animation: _pulse!,
      builder: (_, child) {
        final t = Curves.easeInOut.transform(_pulse!.value);
        final scale = 1.0 + (0.15 * t);
        return Transform.scale(scale: scale, child: child);
      },
      child: dot,
    );
  }
}
