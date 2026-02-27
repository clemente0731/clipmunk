import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import '../data/template_repository.dart';
import '../main.dart'; 

/// service for managing global hotkeys
class HotkeyService {
  Function(int templateIndex)? onHotkeyPressed;

  /// register all global hotkeys based on saved or default config
  Future<void> register() async {
    await unregisterAll();

    for (int i = 0; i < TemplateRepository.templateCount; i++) {
      HotKey hotKey = getHotkeyForIndex(i);
      await _registerHotkey(hotKey, i);
    }
  }

  /// get effective hotkey (saved > default)
  HotKey getHotkeyForIndex(int index) {
    // try to get saved hotkey first
    final saved = templateRepository.getHotkey(index);
    if (saved != null) return saved;

    // fallback to defaults: Cmd+Option+N (Mac) or Ctrl+Alt+N (Win)
    final modifiers = Platform.isMacOS
        ? [HotKeyModifier.meta, HotKeyModifier.alt]
        : [HotKeyModifier.control, HotKeyModifier.alt];

    // map index to digit key (1-5 for indices 0-4)
    final digitKeys = [
      PhysicalKeyboardKey.digit1,
      PhysicalKeyboardKey.digit2,
      PhysicalKeyboardKey.digit3,
      PhysicalKeyboardKey.digit4,
      PhysicalKeyboardKey.digit5,
    ];

    final key = (index >= 0 && index < digitKeys.length) 
        ? digitKeys[index] 
        : PhysicalKeyboardKey.digit1;

    return HotKey(
      key: key,
      modifiers: modifiers,
      scope: HotKeyScope.system,
    );
  }

  Future<void> _registerHotkey(HotKey hotKey, int index) async {
    try {
      await hotKeyManager.register(
        hotKey,
        keyDownHandler: (_) => onHotkeyPressed?.call(index),
      );
    } catch (e) {
      debugPrint('failed to register hotkey for template $index: $e');
    }
  }

  /// update hotkey for a specific template
  Future<void> updateHotkey(int index, HotKey newHotkey) async {
    await templateRepository.saveHotkey(index, newHotkey);
    await register();
  }

  Future<void> unregisterAll() async {
    await hotKeyManager.unregisterAll();
  }

  /// format a hotkey into a human-readable string (e.g. "⌘⌥1")
  static String formatHotkey(HotKey? hk) {
    if (hk == null) return '---';

    final parts = <String>[];
    for (final mod in hk.modifiers ?? []) {
      if (Platform.isMacOS) {
        switch (mod) {
          case HotKeyModifier.meta:
            parts.add('⌘');
            break;
          case HotKeyModifier.alt:
            parts.add('⌥');
            break;
          case HotKeyModifier.control:
            parts.add('⌃');
            break;
          case HotKeyModifier.shift:
            parts.add('⇧');
            break;
          default:
            break;
        }
      } else {
        switch (mod) {
          case HotKeyModifier.meta:
            parts.add('Win+');
            break;
          case HotKeyModifier.alt:
            parts.add('Alt+');
            break;
          case HotKeyModifier.control:
            parts.add('Ctrl+');
            break;
          case HotKeyModifier.shift:
            parts.add('Shift+');
            break;
          default:
            break;
        }
      }
    }

    final keyCode = hk.logicalKey.keyId;
    if (keyCode >= 0x00070001e && keyCode <= 0x000700027) {
      int digit = keyCode - 0x00070001e + 1;
      if (digit == 10) digit = 0;
      parts.add('$digit');
    } else {
      parts.add(hk.logicalKey.debugName ?? '?');
    }

    return parts.join('');
  }
}
