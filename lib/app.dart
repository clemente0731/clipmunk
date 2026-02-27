import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'core/constants.dart';
import 'main.dart';
import 'ui/home_page.dart';

class ClipMunkApp extends StatefulWidget {
  const ClipMunkApp({super.key});

  @override
  State<ClipMunkApp> createState() => _ClipMunkAppState();
}

class _ClipMunkAppState extends State<ClipMunkApp> with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _initWindow();
    _initTray();
  }

  Future<void> _initWindow() async {
    WindowOptions windowOptions = const WindowOptions(
      size: Size(WindowConfig.width, WindowConfig.height),
      minimumSize: Size(WindowConfig.minWidth, WindowConfig.minHeight),
      center: true,
      title: 'Clipmunk',
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  Future<void> _initTray() async {
    await trayService.init(
      onShowWindow: () async {
        await windowManager.show();
        await windowManager.focus();
      },
      onExit: _exitApp,
      onPasteTemplate: (int index) async {
        final content = templateRepository.getTemplate(index);
        if (content.isNotEmpty) {
          await clipboardService.copyToClipboard(content);
        }
      },
      getTemplateLabel: (int index) {
        return templateRepository.getTemplateTitle(index);
      },
    );
  }

  Future<void> _exitApp() async {
    await hotkeyService.unregisterAll();
    await trayService.destroy();
    exit(0);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() {
    final shouldHide = templateRepository.getHideOnClose();
    if (shouldHide) {
      windowManager.hide();
    } else {
      _exitApp();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clipmunk',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Palette.bg,
        colorScheme: const ColorScheme.dark(
          surface: Palette.bg,
          primary: Palette.cyan,
          secondary: Palette.amber,
          error: Palette.statusError,
        ),
        // override text selection to match retro cyan
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Palette.cyan,
          selectionColor: Palette.cyanMuted,
          selectionHandleColor: Palette.cyan,
        ),
        fontFamily: Typo.monoFamily,
      ),
      home: const HomePage(),
    );
  }
}
