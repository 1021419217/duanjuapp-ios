import 'dart:math' as math;

import 'models.dart';

enum PlaybackRecoveryAction { alternative, refresh, stop }

class PlaybackRecovery {
  static const minAttempts = 3;
  int _attempts = 0;
  bool _refreshed = false;

  void reset() {
    _attempts = 0;
    _refreshed = false;
  }

  PlaybackRecoveryAction next(PlaybackPlan plan) {
    // 多线路源要允许把每条线路都试一遍再放弃。原来固定 3 次，线路一多
    // 还没切完就报「自动恢复未成功」；上限随线路数放宽，并设硬顶防止死循环。
    final limit = math.min(math.max(minAttempts, plan.routeCount + 1), 8);
    if (_attempts >= limit) {
      return PlaybackRecoveryAction.stop;
    }
    if (plan.hasAlternative) {
      _attempts++;
      return PlaybackRecoveryAction.alternative;
    }
    if (!_refreshed) {
      _attempts++;
      _refreshed = true;
      return PlaybackRecoveryAction.refresh;
    }
    return PlaybackRecoveryAction.stop;
  }
}

class PlaybackHealth {
  static const stallTimeout = Duration(seconds: 20);
  Duration? _position;
  DateTime? _lastProgress;

  void reset() {
    _position = null;
    _lastProgress = null;
  }

  bool stalled({
    required Duration position,
    required bool playing,
    required bool foreground,
    required DateTime now,
  }) {
    if (!playing || !foreground || position != _position) {
      _position = position;
      _lastProgress = now;
      return false;
    }
    _lastProgress ??= now;
    return now.difference(_lastProgress!) >= stallTimeout;
  }
}
