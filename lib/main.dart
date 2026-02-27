import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'core/hotkey_service.dart';
import 'core/tray_service.dart';
import 'core/clipboard_service.dart';
import 'data/template_repository.dart';

late TemplateRepository templateRepository;
late HotkeyService hotkeyService;
late TrayService trayService;
late ClipboardService clipboardService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // initialize window manager
  await windowManager.ensureInitialized();

  // initialize data and services
  templateRepository = TemplateRepository();
  await templateRepository.init();

  hotkeyService = HotkeyService();
  clipboardService = ClipboardService();
  trayService = TrayService();

  // setup hotkey callback
  hotkeyService.onHotkeyPressed = (int templateIndex) async {
    final content = templateRepository.getTemplate(templateIndex);
    if (content.isNotEmpty) {
      await clipboardService.copyToClipboard(content);
    }
  };

  // register hotkeys
  try {
    await hotkeyService.register();
  } catch (e) {
    debugPrint('warning: failed to register hotkeys: $e');
  }

  // sync templates to native UserDefaults for macOS Services
  final allTemplates = templateRepository.getAllTemplates();
  final contents = allTemplates.map((t) => t.content).toList();
  await clipboardService.syncTemplatesToNative(contents);

  runApp(const ClipMunkApp());
}
