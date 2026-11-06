import 'package:flutter/material.dart';

import '../app_scope.dart';
import 'bar_button.dart';
import 'page_header.dart';
import 'search_field.dart';

class SourceBar extends StatelessWidget {
  const SourceBar({
    super.key,
    required this.source,
    required this.onSwitchSource,
    required this.onOpenSearch,
    required this.onSearchSubmitted,
    this.searchController,
    this.televisionLeading,
    this.actions = const [],
    this.onShowAllCategories,
  });
  final String source;
  final void Function(BuildContext anchor) onSwitchSource;
  final VoidCallback onOpenSearch;
  final ValueChanged<String> onSearchSubmitted;
  final TextEditingController? searchController;
  final Widget? televisionLeading;
  final List<Widget> actions;

  /// 手机端把「全部分类」也收进顶栏操作组，让 4 个入口排在同一行。
  final void Function(BuildContext anchor)? onShowAllCategories;

  @override
  Widget build(BuildContext context) {
    final form = AppScope.formFactorOf(context);
    final hint = '在 $source 中搜索';
    final switcher = Builder(
      builder: (anchor) => BarButton(
        icon: Icons.public_rounded,
        tooltip: '切换站源',
        onPressed: () => onSwitchSource(anchor),
      ),
    );
    final search = BarButton(
      icon: Icons.search_rounded,
      tooltip: hint,
      onPressed: onOpenSearch,
      accent: true,
    );
    final showCategories = onShowAllCategories;
    final showAll = showCategories == null
        ? null
        : Builder(
            builder: (anchor) => BarButton(
              icon: Icons.grid_view_rounded,
              tooltip: '全部分类',
              onPressed: () => showCategories(anchor),
            ),
          );
    return switch (form) {
      FormFactor.phone => PageHeader(
        title: source,
        // 4 个入口等距成组：站源 · 全部分类 · 直播 · 搜索（主操作反色）。
        actions: [
          _actionRow([switcher, showAll, ...actions, search]),
        ],
      ),
      FormFactor.pad || FormFactor.window => PageHeader(
        title: source,
        actions: [
          switcher,
          const SizedBox(width: 4),
          SizedBox(
            width: MediaQuery.sizeOf(context).width >= 900 ? 320 : 240,
            child: SearchField(
              hint: hint,
              controller: searchController,
              onSubmitted: onSearchSubmitted,
            ),
          ),
          const SizedBox(width: 4),
          ...actions,
        ],
      ),
      FormFactor.television => SizedBox(
        height: 48,
        child: Row(
          spacing: 10,
          children: [
            ?televisionLeading,
            const Spacer(),
            Text(
              source,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            switcher,
            search,
            ...actions,
          ],
        ),
      ),
    };
  }

  /// 手机端操作组：等距 8px 排列，主操作（搜索）在最右且反色强调。
  Widget _actionRow(List<Widget?> items) {
    final children = items.whereType<Widget>().toList();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          children[i],
        ],
      ],
    );
  }
}
