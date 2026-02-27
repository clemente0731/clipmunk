import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// number of templates exposed to macOS Services right-click menu
const int nativeServiceSlotCount = 3;

/// service for clipboard operations (copy-only, App Store sandbox compatible)
class ClipboardService {
  static const _templateChannel = MethodChannel('com.clipmunk.templates');

  /// copy text to clipboard (user pastes manually with Cmd+V / Ctrl+V)
  Future<void> copyToClipboard(String text) async {
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
