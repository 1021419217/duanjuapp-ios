import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../app_scope.dart';
import 'focus_ring.dart';

/// 顶栏操作按钮：单层低对比磨砂圆钮（40×40）。
///
/// 只用「一层圆形玻璃 + 一圈极细描边 + 图标」，不再叠加渐变、顶部内高光、
/// 外发光等多重圆形装饰：那些层在浅色详情页（背景取自封面）上会叠出好几个
/// 同心圆边界，尤其深色内高光会在圆里糊出一块深色半圆，看起来像图标重影。
/// [accent] 仅把玻璃调亮一点点区分主次，不额外加发光。
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

  /// 主操作强调：略微提亮玻璃，不产生额外图层或发光。
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
    final tint = dark ? Colors.white : colors.onSurface;
    final ink = dark ? Colors.white : colors.onSurface;
    final inactive = onPressed == null;

    // 单层均匀玻璃：一个圆、一层底色、一圈极细描边，没有第二层圆形边界。
    final fill = tint.withValues(
      alpha: inactive
          ? 0.04
          : accent
          ? 0.15
          : 0.08,
    );
    final hairline = tint.withValues(
      alpha: inactive
          ? 0.07
          : accent
          ? 0.22
          : 0.14,
    );

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
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              customBorder: const CircleBorder(),
              splashColor: ink.withValues(alpha: 0.10),
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: fill,
                      border: Border.all(color: hairline, width: 0.8),
                    ),
                    child: Icon(
                      icon,
                      size: 19,
                      color: ink.withValues(alpha: inactive ? 0.38 : 0.92),
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
