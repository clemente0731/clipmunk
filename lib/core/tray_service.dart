import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:system_tray/system_tray.dart';

/// number of paste shortcuts shown in tray menu
const int trayPasteSlotCount = 3;

/// service for managing system tray
class TrayService {
  final SystemTray _tray = SystemTray();

  // cached callbacks for menu rebuilds
  VoidCallback? _onShowWindow;
  VoidCallback? _onExit;
  Future<void> Function(int index)? _onPasteTemplate;
  String Function(int index)? _getTemplateLabel;

  /// initialize system tray with menu
  Future<void> init({
    required VoidCallback onShowWindow,
    required VoidCallback onExit,
    required Future<void> Function(int index) onPasteTemplate,
    required String Function(int index) getTemplateLabel,
  }) async {
    _onShowWindow = onShowWindow;
    _onExit = onExit;
    _onPasteTemplate = onPasteTemplate;
    _getTemplateLabel = getTemplateLabel;

    // determine icon path based on platform
    String iconPath;
    if (Platform.isWindows) {
      iconPath = 'assets/icons/tray_icon.ico';
    } else {
      iconPath = 'assets/icons/tray_icon.png';
    }

    try {
      await _tray.initSystemTray(
        title: 'Clipmunk',
        iconPath: iconPath,
        toolTip: 'Clipmunk - Quick paste toolbox',
      );

      await _buildMenu();

      // register click handler
      _tray.registerSystemTrayEventHandler((eventName) {
        if (eventName == kSystemTrayEventClick) {
          onShowWindow();
        } else if (eventName == kSystemTrayEventRightClick) {
          _tray.popUpContextMenu();
        }
      });
    } catch (e) {
      debugPrint('failed to initialize system tray: $e');
    }
  }

  /// rebuild the context menu (call after template titles change)
  Future<void> refreshMenu() async {
    try {
      await _buildMenu();
    } catch (e) {
      debugPrint('failed to refresh tray menu: $e');
    }
  }

  Future<void> _buildMenu() async {
    final menu = Menu();

    final items = <MenuItemBase>[];

    // add paste shortcuts for the first N templates
    for (int i = 0; i < trayPasteSlotCount; i++) {
      final label = _getTemplateLabel?.call(i) ?? '';
      final displayLabel = label.isNotEmpty
          ? 'Paste ${i + 1}: $label'
          : 'Paste ${i + 1}';
      items.add(MenuItemLabel(
        label: displayLabel,
        onClicked: (_) => _onPasteTemplate?.call(i),
      ));
    }

    items.add(MenuSeparator());

    items.add(MenuItemLabel(
      label: 'Show Window',
      onClicked: (_) => _onShowWindow?.call(),
    ));
    items.add(MenuItemLabel(
      label: 'Quit Clipmunk',
      onClicked: (_) => _onExit?.call(),
    ));

    await menu.buildFrom(items);
    await _tray.setContextMenu(menu);
  }

  /// destroy tray when app exits
  Future<void> destroy() async {
    try {
      await _tray.destroy();
    } catch (e) {
      debugPrint('failed to destroy system tray: $e');
    }
  }
}
