import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/channels/gnss_channel.dart';
import '../state/providers.dart';

/// After the user changes location permission in system settings, the
/// telemetry EventChannel may stay subscribed; ping native so GNSS can attach.
class AndroidGnssResumeListener extends ConsumerStatefulWidget {
  final Widget child;

  const AndroidGnssResumeListener({super.key, required this.child});

  @override
  ConsumerState<AndroidGnssResumeListener> createState() =>
      _AndroidGnssResumeListenerState();
}

class _AndroidGnssResumeListenerState extends ConsumerState<AndroidGnssResumeListener>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    if (!Platform.isAndroid) return;
    unawaited(_onAndroidResumed());
  }

  Future<void> _onAndroidResumed() async {
    try {
      await GnssChannel.startListening();
    } catch (_) {}
    ref.invalidate(deviceCapabilitiesProvider);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
