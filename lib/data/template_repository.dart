import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

/// data model for a template
class Template {
  final String title;
  final String content;

  Template({required this.title, required this.content});

  Map<String, dynamic> toJson() => {'title': title, 'content': content};

  factory Template.fromJson(Map<String, dynamic> json) {
    return Template(
      title: json['title'] ?? '',
      content: json['content'] ?? '',
    );
  }

  Template copyWith({String? title, String? content}) {
    return Template(
      title: title ?? this.title,
      content: content ?? this.content,
    );
  }
}

/// repository for managing templates and settings
class TemplateRepository {
  static const String _boxName = 'settings';
  static const int templateCount = 5;
  
  late Box _box;
  final ValueNotifier<List<Template>> templates = ValueNotifier([]);

  /// initialize hive
  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);

    // migrate old format or initialize defaults
    await _migrateOrInitialize();
    
    // load templates into memory
    _loadTemplates();
  }

  Future<void> _migrateOrInitialize() async {
    // check if we have new format data
    if (_box.containsKey('templates_v2')) {
      return;
    }

    // check for old format and migrate
    if (_box.containsKey('template_0')) {
      final migrated = <Map<String, dynamic>>[];
      for (int i = 0; i < 3; i++) {
        final content = _box.get('template_$i', defaultValue: '') as String;
        migrated.add({
          'title': 'Template ${i + 1}',
          'content': content,
        });
      }
      // add two more empty slots
      migrated.add({'title': 'Template 4', 'content': ''});
      migrated.add({'title': 'Template 5', 'content': ''});
      await _box.put('templates_v2', jsonEncode(migrated));
      return;
    }

    // initialize with defaults
    final defaults = [
      {'title': 'Greeting', 'content': 'Hello! How can I help you today?'},
      {'title': 'Thanks', 'content': 'Thank you for your email. I will get back to you shortly.'},
      {'title': 'Signature', 'content': 'Best regards,\nClipmunk User'},
      {'title': 'Custom 1', 'content': ''},
      {'title': 'Custom 2', 'content': ''},
    ];
    await _box.put('templates_v2', jsonEncode(defaults));
  }

  void _loadTemplates() {
    final jsonStr = _box.get('templates_v2', defaultValue: '[]') as String;
    try {
      final List<dynamic> list = jsonDecode(jsonStr);
      templates.value = list.map((e) => Template.fromJson(e)).toList();
    } catch (e) {
      templates.value = List.generate(
        templateCount,
        (i) => Template(title: 'Template ${i + 1}', content: ''),
      );
    }
  }

  /// get template content by index (for hotkey handler)
  String getTemplate(int index) {
    if (index < 0 || index >= templates.value.length) {
      return '';
    }
    return templates.value[index].content;
  }

  /// get template title by index
  String getTemplateTitle(int index) {
    if (index < 0 || index >= templates.value.length) {
      return '';
    }
    return templates.value[index].title;
  }

  /// get all templates as Template objects
  List<Template> getAllTemplates() {
    return List.from(templates.value);
  }

  /// save a single template
  Future<void> saveTemplate(int index, {String? title, String? content}) async {
    if (index < 0 || index >= templates.value.length) {
      return;
    }
    
    final updated = List<Template>.from(templates.value);
    updated[index] = updated[index].copyWith(title: title, content: content);
    templates.value = updated;
    
    await _persistTemplates();
  }

  /// save all templates
  Future<void> saveAllTemplates(List<Template> newTemplates) async {
    templates.value = List.from(newTemplates);
    await _persistTemplates();
  }

  Future<void> _persistTemplates() async {
    final jsonStr = jsonEncode(templates.value.map((t) => t.toJson()).toList());
    await _box.put('templates_v2', jsonStr);
  }

  /// get saved hotkey for a specific template index
  HotKey? getHotkey(int index) {
    final jsonStr = _box.get('hotkey_$index');
    if (jsonStr != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(jsonStr);
        return HotKey.fromJson(json);
      } catch (e) {
        debugPrint('error parsing hotkey: $e');
      }
    }
    return null;
  }

  /// save hotkey configuration
  Future<void> saveHotkey(int index, HotKey hotKey) async {
    final jsonStr = jsonEncode(hotKey.toJson());
    await _box.put('hotkey_$index', jsonStr);
  }

  /// get close window behavior (true = hide, false = quit)
  bool getHideOnClose() {
    return _box.get('hide_on_close', defaultValue: true) as bool;
  }

  /// save close window behavior
  Future<void> saveHideOnClose(bool hide) async {
    await _box.put('hide_on_close', hide);
  }

  /// check if this is the first launch (services guide not yet shown)
  bool isFirstLaunch() {
    return !(_box.get('services_guide_shown', defaultValue: false) as bool);
  }

  /// mark the services guide as shown
  Future<void> markServicesGuideShown() async {
    await _box.put('services_guide_shown', true);
  }
}
