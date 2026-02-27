import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants.dart';
import '../data/template_repository.dart';
import '../main.dart';
import 'widgets/retro.dart';
import 'pages/templates_page.dart';
import 'pages/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentTab = 0;
  bool _isDirty = false;
  final GlobalKey<TemplatesPageState> _templatesKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showFirstLaunchGuideIfNeeded();
    });
  }

  void _switchTab(int index) {
    if (index == _currentTab) return;
    // auto-save when leaving templates tab
    if (_currentTab == 0) {
      _templatesKey.currentState?.save();
    }
    setState(() => _currentTab = index);
  }

  Future<void> _showFirstLaunchGuideIfNeeded() async {
    if (!Platform.isMacOS) {
      return;
    }
    if (!templateRepository.isFirstLaunch()) {
      return;
    }
    if (!mounted) {
      return;
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Palette.bgPanel,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: Palette.cyan, width: 1),
          ),
          child: Container(
            width: 380,
            padding: const EdgeInsets.all(Grid.x6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // header
                Row(
                  children: [
                    Text(
                      '◆',
                      style: Typo.caption.copyWith(
                        color: Palette.amber,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: Grid.x2),
                    Text(
                      'SETUP GUIDE',
                      style: Typo.heading.copyWith(
                        color: Palette.amber,
                        letterSpacing: 2.0,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Grid.x4),
                Container(height: 1, color: Palette.border),
                const SizedBox(height: Grid.x4),

                // body
                Text(
                  'How Clipmunk works:',
                  style: Typo.label.copyWith(color: Palette.textPrimary),
                ),
                const SizedBox(height: Grid.x3),
                _guideStep('1', 'Set up your text templates in the Templates tab'),
                const SizedBox(height: Grid.x2),
                _guideStep('2', 'Press hotkey (⌘⌥1-5) to copy template to clipboard'),
                const SizedBox(height: Grid.x2),
                _guideStep('3', 'Press ⌘V to paste in any app'),
                const SizedBox(height: Grid.x4),

                // note
                Container(
                  padding: const EdgeInsets.all(Grid.x3),
                  decoration: BoxDecoration(
                    color: Palette.amberMuted,
                    border: Border.all(color: Palette.amberDim, width: 1),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '!',
                        style: Typo.label.copyWith(color: Palette.amber),
                      ),
                      const SizedBox(width: Grid.x2),
                      Expanded(
                        child: Text(
                          'Hotkeys instantly load templates into your clipboard. You can also enable right-click Services in System Settings → Keyboard → Shortcuts.',
                          style: Typo.caption.copyWith(
                            color: Palette.textPrimary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Grid.x5),

                // buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    RetroButton(
                      label: 'OPEN SETTINGS',
                      onPressed: () {
                        _openKeyboardShortcutSettings();
                      },
                      compact: true,
                    ),
                    const SizedBox(width: Grid.x3),
                    RetroButton(
                      label: 'GOT IT',
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      compact: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    await templateRepository.markServicesGuideShown();
  }

  Future<void> _openKeyboardShortcutSettings() async {
    try {
      await Process.run('open', [
        'x-apple.systempreferences:com.apple.Keyboard-Settings.extension',
      ]);
    } catch (e) {
      debugPrint('failed to open keyboard shortcut settings: $e');
    }
  }

  Widget _guideStep(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: Palette.cyan, width: 1),
          ),
          child: Text(
            number,
            style: Typo.badge.copyWith(fontSize: 10),
          ),
        ),
        const SizedBox(width: Grid.x2),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              text,
              style: Typo.caption.copyWith(
                color: Palette.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.keyS, meta: true): () {
          _templatesKey.currentState?.save();
        },
        const SingleActivator(LogicalKeyboardKey.keyS, control: true): () {
          _templatesKey.currentState?.save();
        },
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: Palette.bg,
          body: Column(
            children: [
              _buildTitleBar(),
              _buildTabBar(),
              Expanded(
                child: IndexedStack(
                  index: _currentTab,
                  children: [
                    TemplatesPage(
                      key: _templatesKey,
                      onDirtyChanged: (dirty) {
                        setState(() => _isDirty = dirty);
                      },
                    ),
                    const SettingsPage(),
                  ],
                ),
              ),
              _buildStatusBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleBar() {
    return Container(
      height: Grid.x8,
      padding: const EdgeInsets.symmetric(horizontal: Grid.x4),
      decoration: const BoxDecoration(
        color: Palette.bgPanel,
        border: Border(
          bottom: BorderSide(color: Palette.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          // app identity
          Text(
            '◆',
            style: Typo.caption.copyWith(color: Palette.cyan, fontSize: 10),
          ),
          const SizedBox(width: Grid.x2),
          Text(
            'CLIP·MUNK',
            style: Typo.heading.copyWith(
              color: Palette.textPrimary,
              letterSpacing: 2.0,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          Text(
            'v${AppMeta.version}',
            style: Typo.tiny.copyWith(color: Palette.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Palette.bgPanel,
        border: Border(
          bottom: BorderSide(color: Palette.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          RetroTabItem(
            label: 'Templates',
            active: _currentTab == 0,
            onTap: () => _switchTab(0),
          ),
          Container(width: 1, height: Grid.x6, color: Palette.border),
          RetroTabItem(
            label: 'Settings',
            active: _currentTab == 1,
            onTap: () => _switchTab(1),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      height: Grid.x5,
      padding: const EdgeInsets.symmetric(horizontal: Grid.x4),
      decoration: const BoxDecoration(
        color: Palette.bgPanel,
        border: Border(
          top: BorderSide(color: Palette.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          RetroLed(
            active: true,
            activeColor: _isDirty ? Palette.amber : Palette.statusActive,
            size: 4,
          ),
          const SizedBox(width: Grid.x2),
          Text(
            _isDirty ? 'UNSAVED' : 'READY',
            style: Typo.tiny.copyWith(
              color: _isDirty ? Palette.amber : Palette.textTertiary,
              letterSpacing: 1.0,
              fontSize: 9,
            ),
          ),
          const Spacer(),
          Text(
            '${TemplateRepository.templateCount} SLOTS',
            style: Typo.tiny.copyWith(
              color: Palette.textTertiary,
              letterSpacing: 1.0,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}
