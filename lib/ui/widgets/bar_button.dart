import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../app_scope.dart';
import 'focus_ring.dart';

/// 顶栏操作按钮：统一的液态玻璃圆钮（40×40）。
///
/// 真实背景模糊 + 斜向渐变 + 细亮描边 + 顶部弧形内高光，
/// 与主标题区的换源胶囊是同一套玻璃语言。[accent] 只把玻璃调得更亮、
/// 加一圈微光晕来区分主次，不再用白底反色（视觉上太跳、不协调）。
class BarButton extends StatelessWidget {
  const BarButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.accent = false,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  /// 主操作强调：更亮更透的玻璃与外发光，仅用于手机顶栏最常用的动作。
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    if (AppScope.of(context).television) {
      // 电视端保持实心底，遥控器焦点更清晰，也省掉模糊开销。
      return FocusRing(
        radius: 999,
        child: IconButton(
          tooltip: tooltip,
          onPressed: onPressed,
          icon: Icon(icon, size: 20),
          style: IconButton.styleFrom(
            fixedSize: const Size.square(40),
            minimumSize: const Size.square(40),
            padding: EdgeInsets.zero,
            backgroundColor: colors.surfaceContainerHigh,
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
          ),
        ),
      );
    }

    final dark = theme.brightness == Brightness.dark;
    final glass = dark ? Colors.white : colors.onSurface;
    final ink = dark ? Colors.white : colors.onSurface;
    final strong = accent;
    final inactive = onPressed == null;
    return FocusRing(
      radius: 999,
      child: Tooltip(
        message: tooltip,
        child: Semantics(
          button: true,
          label: tooltip,
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onPressed,
              customBorder: const CircleBorder(),
              splashColor: glass.withValues(alpha: 0.18),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: strong
                      ? [
                          BoxShadow(
                            color: glass.withValues(alpha: 0.16),
                            blurRadius: 14,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            glass.withValues(
                              alpha: inactive
                                  ? 0.05
                                  : strong
                                  ? 0.26
                                  : 0.13,
                            ),
                            glass.withValues(
                              alpha: inactive
                                  ? 0.02
                                  : strong
                                  ? 0.11
                                  : 0.05,
                            ),
                          ],
                        ),
                        border: Border.all(
                          color: glass.withValues(
                            alpha: inactive
                                ? 0.08
                                : strong
                                ? 0.42
                                : 0.20,
                          ),
                          width: strong ? 1.2 : 1,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // 顶部弧形内高光，模拟玻璃折射出的厚度。
                          Positioned(
                            top: 1,
                            left: 7,
                            right: 7,
                            height: 13,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    glass.withValues(
                                      alpha: strong ? 0.44 : 0.24,
                                    ),
                                    glass.withValues(alpha: 0),
                                  ],
                                ),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),
                            ),
                          ),
                          Icon(
                            icon,
                            size: strong ? 20 : 19,
                            color: ink.withValues(alpha: inactive ? 0.38 : 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
