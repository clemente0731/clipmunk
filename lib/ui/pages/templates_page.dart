import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants.dart';
import '../../core/hotkey_service.dart';
import '../../data/template_repository.dart';
import '../../main.dart';
import '../widgets/retro.dart';

class TemplatesPage extends StatefulWidget {
  final ValueChanged<bool>? onDirtyChanged;

  const TemplatesPage({super.key, this.onDirtyChanged});

  @override
  State<TemplatesPage> createState() => TemplatesPageState();
}

class TemplatesPageState extends State<TemplatesPage> {
  late List<TextEditingController> _titleControllers;
  late List<TextEditingController> _contentControllers;
  int? _expandedIndex;
  bool _hasUnsavedChanges = false;

  bool get hasUnsavedChanges => _hasUnsavedChanges;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    final templates = templateRepository.getAllTemplates();
    _titleControllers = templates
        .map((t) => TextEditingController(text: t.title))
        .toList();
    _contentControllers = templates
        .map((t) => TextEditingController(text: t.content))
        .toList();
  }

  @override
  void dispose() {
    for (var c in _titleControllers) {
      c.dispose();
    }
    for (var c in _contentControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _markDirty() {
    if (!_hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = true);
      widget.onDirtyChanged?.call(true);
    }
  }

  /// public save method so parent can trigger save (e.g. tab switch, Cmd+S)
  Future<void> save() async {
    if (!_hasUnsavedChanges) return;
    await _doSave();
  }

  Future<void> _doSave() async {
    final templates = <Template>[];
    for (int i = 0; i < _titleControllers.length; i++) {
      templates.add(Template(
        title: _titleControllers[i].text,
        content: _contentControllers[i].text,
      ));
    }
    await templateRepository.saveAllTemplates(templates);
    // refresh tray menu so paste labels stay in sync
    await trayService.refreshMenu();
    // sync templates to native UserDefaults for macOS Services
    final contents = templates.map((t) => t.content).toList();
    await clipboardService.syncTemplatesToNative(contents);
    setState(() => _hasUnsavedChanges = false);
    widget.onDirtyChanged?.call(false);

    if (mounted) {
      _showToast('SAVED');
    }
  }

  Future<void> _copyToClipboard(int index) async {
    final content = _contentControllers[index].text;
    if (content.isEmpty) {
      _showToast('EMPTY', isError: true);
      return;
    }
    await Clipboard.setData(ClipboardData(text: content));
    _showToast('COPIED');
  }

  void _showToast(String message, {bool isError = false}) {
    if (!mounted) return;
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => RetroToast(message: message, isError: isError),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }

  String _formatHotkey(int index) {
    final hotkey = hotkeyService.getHotkeyForIndex(index);
    return HotkeyService.formatHotkey(hotkey);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Palette.bg,
      child: Column(
        children: [
          // toolbar
          _buildToolbar(),

          // template list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(Grid.x3),
              itemCount: _titleControllers.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: Grid.x2),
                  child: _TemplateRow(
                    index: index,
                    titleController: _titleControllers[index],
                    contentController: _contentControllers[index],
                    hotkeyLabel: _formatHotkey(index),
                    isExpanded: _expandedIndex == index,
                    onTap: () {
                      setState(() {
                        if (_expandedIndex == index) {
                          _expandedIndex = null;
                        } else {
                          _expandedIndex = index;
                        }
                      });
                    },
                    onCopy: () => _copyToClipboard(index),
                    onChanged: _markDirty,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Grid.x3,
        vertical: Grid.x2,
      ),
      decoration: const BoxDecoration(
        color: Palette.bgPanel,
        border: Border(
          bottom: BorderSide(color: Palette.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          RetroSectionHeader(title: 'Template Slots'),
          const Spacer(),
          if (_hasUnsavedChanges)
            Padding(
              padding: const EdgeInsets.only(right: Grid.x2),
              child: RetroLed(active: true, activeColor: Palette.amber, size: 5),
            ),
          RetroButton(
            label: _hasUnsavedChanges ? 'Save' : 'Saved',
            onPressed: _hasUnsavedChanges ? _doSave : null,
            compact: true,
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// template row - collapsed shows title + preview, expanded shows editor
// =============================================================================

class _TemplateRow extends StatefulWidget {
  final int index;
  final TextEditingController titleController;
  final TextEditingController contentController;
  final String hotkeyLabel;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onCopy;
  final VoidCallback onChanged;

  const _TemplateRow({
    required this.index,
    required this.titleController,
    required this.contentController,
    required this.hotkeyLabel,
    required this.isExpanded,
    required this.onTap,
    required this.onCopy,
    required this.onChanged,
  });

  @override
  State<_TemplateRow> createState() => _TemplateRowState();
}

class _TemplateRowState extends State<_TemplateRow> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final hasContent = widget.contentController.text.isNotEmpty;
    final borderColor = widget.isExpanded
        ? Palette.borderAccent.withOpacity(0.4)
        : (_hovering ? Palette.borderActive : Palette.border);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Container(
        decoration: BoxDecoration(
          color: Palette.bgPanel,
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header
            GestureDetector(
              onTap: widget.onTap,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Grid.x3,
                  vertical: Grid.x2,
                ),
                child: Row(
                  children: [
                    // expand indicator
                    Text(
                      widget.isExpanded ? '▾' : '▸',
                      style: Typo.caption.copyWith(
                        color: widget.isExpanded ? Palette.cyan : Palette.textTertiary,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(width: Grid.x2),

                    // index badge
                    RetroBadge(
                      text: '${widget.index + 1}',
                      active: hasContent,
                    ),
                    const SizedBox(width: Grid.x3),

                    // title
                    Expanded(
                      child: Text(
                        widget.titleController.text.isEmpty
                            ? '---'
                            : widget.titleController.text,
                        style: Typo.label.copyWith(
                          color: widget.titleController.text.isEmpty
                              ? Palette.textTertiary
                              : Palette.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // hotkey chip
                    RetroHotkeyChip(label: widget.hotkeyLabel),
                    const SizedBox(width: Grid.x2),

                    // copy button
                    RetroButton(
                      label: 'CPY',
                      onPressed: hasContent ? widget.onCopy : null,
                      compact: true,
                    ),
                  ],
                ),
              ),
            ),

            // preview (collapsed, has content)
            if (!widget.isExpanded && hasContent)
              Padding(
                padding: const EdgeInsets.only(
                  left: Grid.x3,
                  right: Grid.x3,
                  bottom: Grid.x2,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(Grid.x2),
                  decoration: BoxDecoration(
                    color: Palette.bgInput,
                    border: Border(
                      left: BorderSide(
                        color: Palette.cyanDim.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    widget.contentController.text,
                    style: Typo.caption.copyWith(color: Palette.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

            // expanded editor
            if (widget.isExpanded) ...[
              const RetroDivider(),
              _buildEditor(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEditor() {
    return Padding(
      padding: const EdgeInsets.all(Grid.x3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // title field
          Row(
            children: [
              SizedBox(
                width: 48,
                child: Text(
                  'TITLE',
                  style: Typo.tiny.copyWith(
                    color: Palette.textTertiary,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(width: Grid.x2),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Palette.bgInput,
                    border: Border(
                      bottom: BorderSide(color: Palette.border, width: 1),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: Grid.x2,
                    vertical: Grid.x1,
                  ),
                  child: TextField(
                    controller: widget.titleController,
                    style: Typo.body.copyWith(color: Palette.textPrimary),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      hintText: 'enter title...',
                      hintStyle: Typo.body.copyWith(color: Palette.textTertiary),
                    ),
                    onChanged: (_) => widget.onChanged(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: Grid.x3),

          // content field
          Text(
            'CONTENT',
            style: Typo.tiny.copyWith(
              color: Palette.textTertiary,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: Grid.x1),
          Container(
            constraints: const BoxConstraints(minHeight: 80),
            decoration: BoxDecoration(
              color: Palette.bgInput,
              border: Border.all(color: Palette.border, width: 1),
            ),
            padding: const EdgeInsets.all(Grid.x2),
            child: TextField(
              controller: widget.contentController,
              maxLines: 5,
              minLines: 3,
              style: Typo.body.copyWith(color: Palette.textPrimary),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: 'enter template content...',
                hintStyle: Typo.body.copyWith(color: Palette.textTertiary),
              ),
              onChanged: (_) => widget.onChanged(),
            ),
          ),
        ],
      ),
    );
  }
}
