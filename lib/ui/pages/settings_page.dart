import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import '../../core/constants.dart';
import '../../core/hotkey_service.dart';
import '../../data/template_repository.dart';
import '../../main.dart';
import '../widgets/retro.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<HotKey?> _hotkeys = [];
  bool _hideOnClose = false;
  int? _recordingIndex;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final count = TemplateRepository.templateCount;
    setState(() {
      _hotkeys = List.generate(count, (i) => hotkeyService.getHotkeyForIndex(i));
      _hideOnClose = templateRepository.getHideOnClose();
    });
  }

  Future<void> _updateHotkey(int index, HotKey hotkey) async {
    await hotkeyService.updateHotkey(index, hotkey);

    final nextIndex = index + 1;
    final isLast = nextIndex >= TemplateRepository.templateCount;
    setState(() {
      _recordingIndex = isLast ? null : nextIndex;
    });
    _load();
  }

  Future<void> _toggleHideOnClose(bool value) async {
    await templateRepository.saveHideOnClose(value);
    setState(() => _hideOnClose = value);
  }

  String _formatHotkey(HotKey? hk) {
    return HotkeyService.formatHotkey(hk);
  }

  @override
  Widget build(BuildContext context) {
    final templates = templateRepository.getAllTemplates();

    return Container(
      color: Palette.bg,
      child: ListView(
        padding: const EdgeInsets.all(Grid.x3),
        children: [
          // hotkeys section
          RetroSectionHeader(
            title: 'Hotkey Bindings',
            trailing: _recordingIndex != null
                ? 'RECORDING ${_recordingIndex! + 1}/${TemplateRepository.templateCount}'
                : 'CLICK TO RECORD',
          ),
          RetroPanel(
            child: Column(
              children: List.generate(_hotkeys.length, (i) {
                final isLast = i == _hotkeys.length - 1;
                final templateTitle = (templates.length > i)
                    ? templates[i].title
                    : 'Slot ${i + 1}';

                return Column(
                  children: [
                    _HotkeyRow(
                      index: i,
                      title: templateTitle,
                      hotkey: _hotkeys[i],
                      isRecording: _recordingIndex == i,
                      onStartRecording: () {
                        setState(() => _recordingIndex = i);
                      },
                      onHotkeyRecorded: (hk) => _updateHotkey(i, hk),
                      onCancelRecording: () {
                        setState(() => _recordingIndex = null);
                      },
                      formatHotkey: _formatHotkey,
                    ),
                    if (!isLast) const RetroDivider(),
                  ],
                );
              }),
            ),
          ),

          const SizedBox(height: Grid.x6),

          // behavior section
          const RetroSectionHeader(title: 'Behavior'),
          RetroPanel(
            child: _ToggleRow(
              label: 'HIDE TO TRAY ON CLOSE',
              description: 'keep running in background',
              value: _hideOnClose,
              onChanged: _toggleHideOnClose,
            ),
          ),

          const SizedBox(height: Grid.x6),

          // about section
          const RetroSectionHeader(title: 'System Info'),
          _buildAboutPanel(),
        ],
      ),
    );
  }

  Widget _buildAboutPanel() {
    return RetroPanel(
      padding: const EdgeInsets.all(Grid.x3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // retro "icon" - pixel art style
              Container(
                width: Grid.x8,
                height: Grid.x8,
                decoration: BoxDecoration(
                  color: Palette.bgElevated,
                  border: Border.all(color: Palette.cyan.withOpacity(0.3), width: 1),
                ),
                child: Center(
                  child: Text(
                    '◆',
                    style: Typo.heading.copyWith(
                      color: Palette.cyan,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: Grid.x3),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CLIP·MUNK',
                    style: Typo.label.copyWith(
                      color: Palette.textPrimary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: Grid.x1),
                  Text(
                    'VERSION ${AppMeta.version}',
                    style: Typo.tiny.copyWith(
                      color: Palette.textTertiary,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: Grid.x3),
          const RetroDivider(),
          const SizedBox(height: Grid.x3),
          Text(
            'A chipmunk-fast paste toolbox for quick text templates.\n'
            'Retro-futurism 16-bit dot-matrix interface.',
            style: Typo.caption.copyWith(
              color: Palette.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// hotkey row - shows slot index, title, and hotkey binding
// =============================================================================

class _HotkeyRow extends StatefulWidget {
  final int index;
  final String title;
  final HotKey? hotkey;
  final bool isRecording;
  final VoidCallback onStartRecording;
  final Function(HotKey) onHotkeyRecorded;
  final VoidCallback onCancelRecording;
  final String Function(HotKey?) formatHotkey;

  const _HotkeyRow({
    required this.index,
    required this.title,
    required this.hotkey,
    required this.isRecording,
    required this.onStartRecording,
    required this.onHotkeyRecorded,
    required this.onCancelRecording,
    required this.formatHotkey,
  });

  @override
  State<_HotkeyRow> createState() => _HotkeyRowState();
}

class _HotkeyRowState extends State<_HotkeyRow> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Container(
        color: _hovering ? Palette.bgElevated.withOpacity(0.3) : Colors.transparent,
        padding: const EdgeInsets.symmetric(
          horizontal: Grid.x3,
          vertical: Grid.x2,
        ),
        child: Row(
          children: [
            // slot badge
            RetroBadge(
              text: '${widget.index + 1}',
              active: true,
              activeColor: Palette.amber,
            ),
            const SizedBox(width: Grid.x3),

            // title
            Expanded(
              child: Text(
                widget.title,
                style: Typo.body.copyWith(color: Palette.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // hotkey display / recorder
            if (widget.isRecording)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Grid.x2,
                      vertical: Grid.x1,
                    ),
                    decoration: BoxDecoration(
                      color: Palette.bgInput,
                      border: Border.all(color: Palette.cyan.withOpacity(0.5), width: 1),
                    ),
                    child: HotKeyRecorder(
                      onHotKeyRecorded: widget.onHotkeyRecorded,
                      initalHotKey: widget.hotkey,
                    ),
                  ),
                  const SizedBox(width: Grid.x2),
                  GestureDetector(
                    onTap: widget.onCancelRecording,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Text(
                        '×',
                        style: Typo.label.copyWith(
                          color: Palette.textTertiary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              GestureDetector(
                onTap: widget.onStartRecording,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: RetroHotkeyChip(
                    label: widget.formatHotkey(widget.hotkey),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// toggle row for boolean settings
// =============================================================================

class _ToggleRow extends StatelessWidget {
  final String label;
  final String? description;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    this.description,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Grid.x3,
        vertical: Grid.x2,
      ),
      child: Row(
        children: [
          RetroLed(active: value, activeColor: Palette.cyan, size: 6),
          const SizedBox(width: Grid.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Typo.body.copyWith(color: Palette.textPrimary),
                ),
                if (description != null) ...[
                  const SizedBox(height: Grid.x1),
                  Text(
                    description!,
                    style: Typo.tiny.copyWith(color: Palette.textTertiary),
                  ),
                ],
              ],
            ),
          ),
          // retro toggle - flat, no rounded
          GestureDetector(
            onTap: () => onChanged(!value),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                width: 36,
                height: 18,
                decoration: BoxDecoration(
                  color: value ? Palette.cyanMuted : Palette.bgElevated,
                  border: Border.all(
                    color: value ? Palette.cyanDim : Palette.border,
                    width: 1,
                  ),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 120),
                  alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: 14,
                    height: 14,
                    margin: const EdgeInsets.all(1),
                    color: value ? Palette.cyan : Palette.textTertiary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
