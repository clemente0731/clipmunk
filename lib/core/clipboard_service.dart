import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// number of templates exposed to macOS Services right-click menu
const int nativeServiceSlotCount = 3;

/// service for clipboard operations and simulating paste
class ClipboardService {
  static const _channel = MethodChannel('com.clipmunk.clipboard');
  static const _templateChannel = MethodChannel('com.clipmunk.templates');

  /// copy text to clipboard and simulate paste action
  Future<void> copyAndPaste(String text) async {
    if (text.isEmpty) {
      return;
    }

    // write to clipboard
    await Clipboard.setData(ClipboardData(text: text));

    // brief delay to ensure clipboard is ready
    await Future.delayed(const Duration(milliseconds: 50));

    // simulate paste keystroke
    await _simulatePaste();
  }

  /// simulate Ctrl+V (Win) or Cmd+V (Mac) keystroke
  Future<void> _simulatePaste() async {
    try {
      await _channel.invokeMethod('simulatePaste');
    } catch (e) {
      // fallback: if platform channel not implemented,
      // clipboard is already set - user can paste manually
      debugPrint('paste simulation not available: $e');
    }
  }

  /// copy text to clipboard only (no paste simulation)
  Future<void> copyOnly(String text) async {
    if (text.isEmpty) {
      return;
    }
    await Clipboard.setData(ClipboardData(text: text));
  }

  /// sync template contents to native UserDefaults
  /// so macOS NSServices handlers can read them
  Future<void> syncTemplatesToNative(List<String> contents) async {
    try {
      final Map<String, String> args = {};
      final count = contents.length < nativeServiceSlotCount
          ? contents.length
          : nativeServiceSlotCount;
      for (int i = 0; i < count; i++) {
        args['paste_template_$i'] = contents[i];
      }
      await _templateChannel.invokeMethod('syncTemplates', args);
    } catch (e) {
      debugPrint('failed to sync templates to native: $e');
    }
  }
}
