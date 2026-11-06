part of '../state.dart';

typedef ManagedOptions = ({
  Map<String, bool> values,
  Map<String, String> icons,
  List<String> groups,
  String? error,
});

/// The hosted script's switches, read once: every entry shows what this holds.
@Riverpod(keepAlive: true)
Future<ManagedOptions> managedOptions(Ref ref) async {
  final content = await ManagedScript.content();
  if (content == null) {
    return (
      values: const <String, bool>{},
      icons: const <String, String>{},
      groups: const <String>[],
      error: null,
    );
  }
  final declared = await extractRuleOptions(content);
  final stored = await ManagedScript.options();
  return (
    values: {
      for (final entry in declared.options.entries)
        entry.key: stored[entry.key] ?? entry.value,
    },
    icons: declared.icons,
    groups: declared.groups,
    error: declared.error,
  );
}
