import 'package:flutter/material.dart';

import '../app_scope.dart';
import 'bar_button.dart';
import 'choice_panel.dart';
import 'focus_ring.dart';

class CategoryTabs<T> extends StatefulWidget {
  const CategoryTabs({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.onShowAll,
  });
  final List<ChoiceOption<T>> options;
  final T selected;
  final ValueChanged<T> onSelected;
  final void Function(BuildContext anchor)? onShowAll;

  @override
  State<CategoryTabs<T>> createState() => _CategoryTabsState<T>();
}

class _CategoryTabsState<T> extends State<CategoryTabs<T>> {
  final _scroll = ScrollController();
  final _keys = <T, GlobalKey>{};
  bool _overflows = false;

  @override
  void didUpdateWidget(covariant CategoryTabs<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _reveal());
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _reveal() {
    final context = _keys[widget.selected]?.currentContext;
    if (context == null || !mounted) return;
    Scrollable.ensureVisible(
      context,
      alignment: 0.5,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
    );
  }

  bool _metricsChanged(ScrollMetricsNotification notification) {
    final overflows = notification.metrics.maxScrollExtent > 0;
    if (overflows != _overflows) setState(() => _overflows = overflows);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final form = AppScope.formFactorOf(context);
    final colors = Theme.of(context).colorScheme;
    final (height, fontSize, padding, fade) = switch (form) {
      FormFactor.phone => (48.0, 15.0, 16.0, 20.0),
      FormFactor.pad || FormFactor.window => (48.0, 14.0, 14.0, 40.0),
      FormFactor.television => (44.0, 16.0, 16.0, 48.0),
    };
    _keys.removeWhere(
      (value, _) => !widget.options.any((option) => option.value == value),
    );
    final television = form == FormFactor.television;
    // 手机 / 平板端「全部分类」常驻右端并与标签栏垂直居中对齐，
    // 不再依赖标签是否溢出——随时可点，位置固定，用起来才顺手。
    // 电视端仍按遥控器习惯，仅在标签溢出时于左端显示。
    Widget? showAll;
    final onShowAll = widget.onShowAll;
    if (onShowAll != null) {
      if (television) {
        if (_overflows) {
          showAll = Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Builder(
              builder: (anchor) => BarButton(
                icon: Icons.grid_view_rounded,
                tooltip: '全部分类',
                onPressed: () => onShowAll(anchor),
              ),
            ),
          );
        }
      } else {
        showAll = _AllCategoriesChip(onShowAll: onShowAll);
      }
    }
    return Container(
      height: height,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.outlineVariant)),
      ),
      child: Row(
        children: [
          if (television) ?showAll,
          Expanded(
            child: Stack(
              children: [
                NotificationListener<ScrollMetricsNotification>(
                  onNotification: _metricsChanged,
                  child: ListView.builder(
                    controller: _scroll,
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.only(
                      left: form == FormFactor.phone ? 4 : 0,
                    ),
                    itemCount: widget.options.length,
                    itemBuilder: (context, index) {
                      final option = widget.options[index];
                      return KeyedSubtree(
                        key: _keys.putIfAbsent(option.value, GlobalKey.new),
                        child: _Tab(
                          label: option.label,
                          selected: option.value == widget.selected,
                          fontSize: fontSize,
                          padding: padding,
                          onTap: () => widget.onSelected(option.value),
                        ),
                      );
                    },
                  ),
                ),
                if (_overflows)
                  Positioned(
                    top: 0,
                    right: 0,
                    bottom: 0,
                    width: fade,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colors.surface.withValues(alpha: 0),
                              // 手机端顶栏浮在内容之上做磨砂，这里若用不透明
                              // 纯色收边，会在「全部分类」左侧糊出一整块白板，
                              // 还把最右侧标签吃掉。改成极淡渐隐即可。
                              colors.surface.withValues(
                                alpha: form == FormFactor.phone ? 0.16 : 1.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (!television) ?showAll,
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.selected,
    required this.fontSize,
    required this.padding,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final double fontSize;
  final double padding;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    // 选中态只保留一个完整的玻璃胶囊：由「文字 + 左右内边距」自己撑出尺寸，
    // 文字被完整包住、四周留白均匀，不再叠一条悬在胶囊外面的下划线。
    // 选中时把外层留白等量让给胶囊内边距，标签总宽度不变，切换不跳动。
    // 文字颜色跟随主题（onSurface），浅色顶栏下不会再出现白字消失。
    final ink = colors.onSurface;
    final accent = colors.primary;
    final labelColor = selected
        ? ink
        : ink.withValues(alpha: dark ? 0.66 : 0.72);
    return Semantics(
      selected: selected,
      child: FocusRing(
        radius: 17,
        offset: -3,
        child: InkWell(
          onTap: onTap,
          focusColor: Colors.transparent,
          borderRadius: BorderRadius.circular(17),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: selected ? 0 : padding,
              vertical: 7,
            ),
            child: Container(
              alignment: Alignment.center,
              padding: selected
                  ? const EdgeInsets.symmetric(horizontal: 16)
                  : EdgeInsets.zero,
              decoration: selected
                  ? BoxDecoration(
                      color: accent.withValues(alpha: dark ? 0.16 : 0.09),
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(
                        color: accent.withValues(alpha: dark ? 0.30 : 0.20),
                      ),
                    )
                  : null,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: labelColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 分类栏右端的「全部分类」入口：带图标的浅色胶囊 + 左侧细分隔线，
/// 与标签文字同一套视觉语言，固定居右、垂直居中，随手就能点到。
class _AllCategoriesChip extends StatelessWidget {
  const _AllCategoriesChip({required this.onShowAll});
  final void Function(BuildContext anchor) onShowAll;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Builder(
      builder: (anchor) => Padding(
        padding: const EdgeInsets.only(left: 8, right: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 1, height: 22, color: colors.outlineVariant),
            const SizedBox(width: 10),
            Tooltip(
              message: '全部分类',
              child: Material(
                color: colors.surfaceContainerHigh.withValues(alpha: 0.9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => onShowAll(anchor),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 11),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.outlineVariant),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.grid_view_rounded,
                          size: 15,
                          color: colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '全部分类',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
