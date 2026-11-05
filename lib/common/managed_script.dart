import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:path/path.dart';

/// The template the editor starts from when the managed script is empty.
const managedScriptTemplate = '''
// 托管模式脚本
// @version 1
//
// 每个参与合并的订阅都会先经过这里，再和其余订阅合并：
//   main(config) 收到一份解析后的单订阅配置，返回它会参与合并的内容。
// 用于统一节点命名、清理机场塞进节点列表的提示项，或重建策略组与分流。
// 把脚本来源设为链接，即可整体替换成本文件；同步与版本以 // @version 为准。

function main(config) {
  return config;
}
''';

/// Where a managed script came from, and what it declares.
typedef ManagedScriptState = ({
  String? source,
  bool hasContent,
  String? version,
  DateTime? updatedAt,
});

/// The script each member's config passes through before a merge, kept apart
/// from the scripts a profile uses so merging never depends on one profile.
class ManagedScript {
  const ManagedScript._();

  static final _versionPattern = RegExp(
    r'^//\s*@version\s+(\S+)\s*$',
    multiLine: true,
  );

  static Future<String> _directory() async {
    final home = await appPath.homeDirPath;
    return join(home, 'managed');
  }

  static Future<File> _scriptFile() async {
    return File(join(await _directory(), 'script.js'));
  }

  static Future<File> _settingFile() async {
    return File(join(await _directory(), 'settings.json'));
  }

  static Future<Map<String, dynamic>> _settings() async {
    final file = await _settingFile();
    if (!await file.exists()) {
      return <String, dynamic>{};
    }
    try {
      final decoded = json.decode(await file.readAsString());
      return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  static Future<void> _writeSettings(Map<String, dynamic> settings) async {
    final file = await _settingFile();
    await file.parent.create(recursive: true);
    await file.safeWriteAsString(json.encode(settings));
  }

  static Future<String?> source() async {
    final value = (await _settings())['source'];
    if (value is! String || value.trim().isEmpty) {
      return null;
    }
    return value.trim();
  }

  static Future<void> setSource(String? url) async {
    final settings = await _settings();
    final value = url?.trim();
    if (value == null || value.isEmpty) {
      settings.remove('source');
    } else {
      settings['source'] = value;
    }
    await _writeSettings(settings);
  }

  static Future<Map<String, bool>> options() async {
    try {
      final value = (await _settings())['options'];
      return {
        if (value is Map)
          for (final entry in value.entries)
            '${entry.key}': entry.value == true,
      };
    } catch (_) {
      return const {};
    }
  }

  static Future<void> setOptions(Map<String, bool> options) async {
    final settings = await _settings();
    settings['options'] = options;
    await _writeSettings(settings);
  }

  static Future<DateTime?> updatedAt() async {
    final value = (await _settings())['updatedAt'];
    return value is String ? DateTime.tryParse(value) : null;
  }

  static String? versionOf(String content) =>
      _versionPattern.firstMatch(content)?.group(1);

  static Future<String?> readContent() async {
    try {
      final file = await _scriptFile();
      if (!await file.exists()) {
        return null;
      }
      final content = await file.readAsString();
      return content.trim().isEmpty ? null : content;
    } catch (_) {
      return null;
    }
  }

  /// Whether a merge should run a script at all.
  static Future<bool> get isEnabled async =>
      await source() != null || await readContent() != null;

  static Future<ManagedScriptState> state() async {
    try {
      final content = await readContent();
      return (
        source: await source(),
        hasContent: content != null,
        version: content == null ? null : versionOf(content),
        updatedAt: await updatedAt(),
      );
    } catch (_) {
      return (source: null, hasContent: false, version: null, updatedAt: null);
    }
  }

  static Future<void> saveContent(String content) async {
    final file = await _scriptFile();
    await file.parent.create(recursive: true);
    await file.safeWriteAsString(content);
    final settings = await _settings();
    settings['updatedAt'] = DateTime.now().toIso8601String();
    await _writeSettings(settings);
  }

  static Future<void> restore() async {
    final file = await _scriptFile();
    if (await file.exists()) {
      await file.safeDelete();
    }
    final settings = await _settings();
    settings.remove('source');
    settings.remove('updatedAt');
    await _writeSettings(settings);
  }

  /// Downloads the source and keeps it, so a merge runs offline afterwards.
  static Future<String> sync() async {
    final url = await source();
    if (url == null) {
      throw const MessageException('no managed script source');
    }
    final response = await request.getTextResponseForUrl(url);
    final content = response.data;
    if (content is! String || !content.contains('function main')) {
      throw const MessageException('the source is not a script');
    }
    await saveContent(content);
    return versionOf(content) ?? '';
  }

  /// What a merge runs: the local copy, else the source, else nothing.
  static Future<String?> content() async {
    try {
      return await _content();
    } catch (error) {
      commonPrint.log('managed script could not load: $error');
      return null;
    }
  }

  static Future<String?> _content() async {
    final local = await readContent();
    if (local != null) {
      return local;
    }
    final url = await source();
    if (url == null) {
      return null;
    }
    final response = await request.getTextResponseForUrl(url);
    final content = response.data;
    if (content is! String || !content.contains('function main')) {
      return null;
    }
    await saveContent(content);
    return content;
  }
}
