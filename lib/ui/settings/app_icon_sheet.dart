import 'package:flutter/material.dart';

import '../../app_device.dart';

class AppIconOption {
  const AppIconOption({this.id, required this.label, required this.asset});

  /// 备选图标名；null 表示默认图标。
  final String? id;
  final String label;
  final String asset;
}

const appIconOptions = [
  AppIconOption(label: '默认', asset: 'assets/icons/icon_default.png'),
  AppIconOption(id: 'IconC', label: 'C·星', asset: 'assets/icons/icon_c.png'),
  AppIconOption(id: 'IconT', label: '气泡·T', asset: 'assets/icons/icon_t.png'),
  AppIconOption(
    id: 'IconGear',
    label: '齿轮·太极',
    asset: 'assets/icons/icon_gear.png',
  ),
  AppIconOption(
    id: 'IconPlay',
    label: '播放·三角',
    asset: 'assets/icons/icon_play.png',
  ),
];

/// 弹出「应用图标」选择面板，返回是否成功切换。
Future<bool> showAppIconPicker(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    builder: (_) => const _AppIconSheet(),
  ).then((v) => v ?? false);
}

class _AppIconSheet extends StatefulWidget {
  const _AppIconSheet();

  @override
  State<_AppIconSheet> createState() => _AppIconSheetState();
}

class _AppIconSheetState extends State<_AppIconSheet> {
  String? _switching;

  Future<void> _pick(AppIconOption option) async {
    if (_switching != null) return;
    setState(() => _switching = option.id);
    final ok = await AppDevice.setAppIcon(option.id);
    if (!mounted) return;
    setState(() => _switching = null);
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('切换图标失败，请重试')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('应用图标', style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              '选择后 iOS 会弹出系统确认框，点确认即切换',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 12,
              childAspectRatio: .82,
              children: [
                for (final option in appIconOptions)
                  _IconCell(
                    option: option,
                    busy: _switching == option.id,
                    onTap: () => _pick(option),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IconCell extends StatelessWidget {
  const _IconCell({
    required this.option,
    required this.busy,
    required this.onTap,
  });

  final AppIconOption option;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: busy ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(option.asset, width: 64, height: 64),
                if (busy)
                  Container(
                    width: 64,
                    height: 64,
                    color: Colors.black45,
                    child: const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            option.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
