import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import 'focus_ring.dart';

/// 首页同款磨砂顶栏：内容从背后透出并被模糊，底部一道极细亮线收边。
///
/// [child] 是顶栏内容（标题、按钮等）；作为 AppBar.flexibleSpace 使用时要
/// 传 [fill] = true，此时只铺一层模糊玻璃，文字与图标由 AppBar 自己绘制。
class FrostedHeader extends StatelessWidget {
  const FrostedHeader({super.key, this.child, this.fill = false});

  final Widget? child;
  final bool fill;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colors.surface.withValues(alpha: 0.66),
                colors.surface.withValues(alpha: 0.34),
              ],
            ),
            border: Border(
              bottom: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
            ),
          ),
          child: fill ? const SizedBox.expand() : child,
        ),
      ),
    );
  }
}

/// 玻璃标题胶囊：与首页「站源 / 搜索」胶囊同一套低对比磨砂语言，
/// 只加一层均匀玻璃 + 一圈极细描边，不加渐变高光、外发光。
/// 外层 Row + Spacer 保证在 AppBar / Expanded 的紧约束下仍按文字宽度收缩。
class GlassTitle extends StatelessWidget {
  const GlassTitle({super.key, required this.title, this.count});

  final String title;
  final String? count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final ink = dark ? Colors.white : theme.colorScheme.onSurface;
    return Row(
      children: [
        Semantics(
          header: true,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(19),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ink.withValues(alpha: dark ? 0.11 : 0.07),
                      ink.withValues(alpha: dark ? 0.05 : 0.025),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(19),
                  border: Border.all(
                    color: ink.withValues(alpha: dark ? 0.15 : 0.10),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          color: ink,
                        ),
                      ),
                    ),
                    if (count case final value?) ...[
                      const SizedBox(width: 6),
                      Text(
                        '· $value',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: ink.withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

/// 玻璃筛选胶囊：替代原来实心的 ChoiceChip / Material 色块，
/// 选中时用主题色低透明度玻璃，未选中用中性磨砂玻璃。
class GlassChip extends StatelessWidget {
  const GlassChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge,
    this.height = 36,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? badge;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final ink = dark ? Colors.white : colors.onSurface;
    final primary = colors.primary;
    return FocusRing(
      radius: 999,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Material(
            color: Colors.transparent,
            shape: const StadiumBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Container(
                height: height,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: selected
                      ? primary.withValues(alpha: dark ? 0.24 : 0.18)
                      : ink.withValues(alpha: dark ? 0.07 : 0.045),
                  border: Border.all(
                    color: selected
                        ? primary.withValues(alpha: 0.42)
                        : ink.withValues(alpha: 0.10),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 6,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: selected ? primary : ink,
                      ),
                    ),
                    if (badge case final value?)
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 12,
                          color: (selected ? primary : ink).withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 玻璃文字按钮：手机端顶栏的「编辑 / 全选 / 完成」等文字操作，
/// 与玻璃标题、玻璃圆钮保持同一套材质。电视端仍用实心 TextButton。
class GlassAction extends StatelessWidget {
  const GlassAction({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.focusNode,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final ink = dark ? Colors.white : theme.colorScheme.onSurface;
    final inactive = onPressed == null;
    return FocusRing(
      radius: 18,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              focusNode: focusNode,
              onTap: onPressed,
              borderRadius: BorderRadius.circular(18),
              splashColor: ink.withValues(alpha: 0.08),
              child: Container(
                height: 34,
                padding: const EdgeInsets.symmetric(horizontal: 13),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: ink.withValues(alpha: dark ? 0.09 : 0.055),
                  border: Border.all(
                    color: ink.withValues(alpha: dark ? 0.14 : 0.10),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 5,
                  children: [
                    if (icon case final value?)
                      Icon(
                        value,
                        size: 16,
                        color: ink.withValues(alpha: inactive ? 0.35 : 0.9),
                      ),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: ink.withValues(alpha: inactive ? 0.35 : 0.92),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
