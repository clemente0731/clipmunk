import 'package:flutter_test/flutter_test.dart';
import 'package:clipmunk/data/template_repository.dart';

void main() {
  group('Template', () {
    test('fromJson creates template from valid json', () {
      final json = {'title': 'Greeting', 'content': 'Hello!'};
      final template = Template.fromJson(json);

      expect(template.title, 'Greeting');
      expect(template.content, 'Hello!');
    });

    test('fromJson handles missing fields with defaults', () {
      final template = Template.fromJson({});

      expect(template.title, '');
      expect(template.content, '');
    });

    test('toJson produces correct map', () {
      final template = Template(title: 'Test', content: 'Body');
      final json = template.toJson();

      expect(json['title'], 'Test');
      expect(json['content'], 'Body');
    });

    test('copyWith overrides specified fields only', () {
      final original = Template(title: 'A', content: 'B');
      final updated = original.copyWith(title: 'C');

      expect(updated.title, 'C');
      expect(updated.content, 'B');
    });

    test('copyWith with no args returns equivalent copy', () {
      final original = Template(title: 'A', content: 'B');
      final copy = original.copyWith();

      expect(copy.title, original.title);
      expect(copy.content, original.content);
    });
  });
}
