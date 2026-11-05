import 'package:fl_clash/common/bundle_merge.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _proxy(String name, [String server = 'example.com']) => {
  'name': name,
  'type': 'ss',
  'server': server,
  'port': 443,
  'cipher': 'aes-128-gcm',
  'password': 'secret',
};

MergeMember _member(String prefix, Map<String, dynamic> config) =>
    (prefix: prefix, label: prefix, config: config);

void main() {
  group('bundlePrefixOf', () {
    test('takes one or two Han characters', () {
      expect(bundlePrefixOf('机场A'), '机场');
      expect(bundlePrefixOf('飞鸟'), '飞鸟');
      expect(bundlePrefixOf('  '), '');
    });

    test('takes the alphanumeric run before the Han characters', () {
      expect(bundlePrefixOf('V2Board 机场'), 'V2Board');
      expect(bundlePrefixOf('##tag'), 'tag');
    });
  });

  group('mergeBundleConfigs', () {
    test('marks each member\'s proxies with its prefix', () {
      final result = mergeBundleConfigs([
        _member('甲', {
          'proxies': [_proxy('香港 01')],
        }),
        _member('乙', {
          'proxies': [_proxy('日本 01', 'b.example.com')],
        }),
      ]);
      expect(
        [for (final proxy in result.config['proxies'] as List) proxy['name']],
        ['[ 甲 ] - 香港 01', '[ 乙 ] - 日本 01'],
      );
      expect(result.report.proxies, 2);
    });

    test('keeps one copy of a proxy two members share', () {
      final shared = _proxy('香港 01');
      final result = mergeBundleConfigs([
        _member('甲', {
          'proxies': [shared],
          'proxy-groups': [
            {
              'name': '手动选择',
              'type': 'select',
              'proxies': ['香港 01'],
            },
          ],
        }),
        _member('乙', {
          'proxies': [Map.of(shared)],
          'proxy-groups': [
            {
              'name': '手动选择',
              'type': 'select',
              'proxies': ['香港 01'],
            },
          ],
        }),
      ]);
      expect((result.config['proxies'] as List).length, 1);
      expect(result.report.duplicates, 1);
      final group = (result.config['proxy-groups'] as List).single as Map;
      expect(group['proxies'], ['[ 甲 ] - 香港 01']);
    });

    test('joins groups of the same name and keeps the order', () {
      final result = mergeBundleConfigs([
        _member('甲', {
          'proxies': [_proxy('A')],
          'proxy-groups': [
            {
              'name': '手动选择',
              'type': 'select',
              'proxies': ['A'],
            },
            {
              'name': '自动选择',
              'type': 'url-test',
              'proxies': ['A'],
            },
          ],
        }),
        _member('乙', {
          'proxies': [_proxy('B', 'b.example.com')],
          'proxy-groups': [
            {
              'name': '自动选择',
              'type': 'url-test',
              'proxies': ['B'],
            },
            {
              'name': '分流',
              'type': 'select',
              'proxies': ['B'],
            },
          ],
        }),
      ]);
      final groups = [
        for (final group in result.config['proxy-groups'] as List)
          (group as Map)['name'],
      ];
      expect(groups, containsAll(['手动选择', '自动选择', '分流']));
      expect(groups.first, '手动选择');
      final auto = (result.config['proxy-groups'] as List).firstWhere(
        (group) => (group as Map)['name'] == '自动选择',
      );
      expect(auto['proxies'], ['[ 甲 ] - A', '[ 乙 ] - B']);
      expect(result.report.groups, 3);
    });

    test('follows member order in the rules and drops repeats', () {
      final result = mergeBundleConfigs([
        _member('甲', {
          'proxies': [_proxy('A')],
          'rules': ['DOMAIN-SUFFIX,a.com,手动选择', 'MATCH,DIRECT'],
        }),
        _member('乙', {
          'proxies': [_proxy('B')],
          'rules': ['DOMAIN-SUFFIX,b.com,手动选择', 'MATCH,DIRECT'],
        }),
      ]);
      expect(result.config['rules'], [
        'DOMAIN-SUFFIX,a.com,手动选择',
        'MATCH,DIRECT',
        'DOMAIN-SUFFIX,b.com,手动选择',
      ]);
    });

    test('renames a rule provider two members define differently', () {
      final result = mergeBundleConfigs([
        _member('甲', {
          'rule-providers': {
            'ads': {'type': 'http', 'url': 'https://a/ads.yaml'},
          },
          'rules': ['RULE-SET,ads,REJECT'],
        }),
        _member('乙', {
          'rule-providers': {
            'ads': {'type': 'http', 'url': 'https://b/ads.yaml'},
          },
          'rules': ['RULE-SET,ads,REJECT'],
        }),
      ]);
      final providers = result.config['rule-providers'] as Map;
      expect(providers.keys, containsAll(['ads', 'ads-2']));
      expect(result.config['rules'], [
        'RULE-SET,ads,REJECT',
        'RULE-SET,ads-2,REJECT',
      ]);
    });

    test('adds the members\' fake-ip filters once each', () {
      final result = mergeBundleConfigs([
        _member('甲', {
          'dns': {
            'enable': true,
            'fake-ip-filter': ['*.lan', 'localhost.ptlogin2.qq.com'],
          },
        }),
        _member('乙', {
          'dns': {
            'enable': false,
            'fake-ip-filter': ['*.lan', '+.stun.*.*'],
          },
        }),
      ]);
      final dns = result.config['dns'] as Map;
      expect(dns['enable'], true);
      expect(dns['fake-ip-filter'], [
        '*.lan',
        'localhost.ptlogin2.qq.com',
        '+.stun.*.*',
      ]);
    });

    test('keeps the first member\'s untouched keys', () {
      final result = mergeBundleConfigs([
        _member('甲', {'mode': 'rule', 'proxies': const []}),
        _member('乙', {'mode': 'global', 'proxies': const []}),
      ]);
      expect(result.config['mode'], 'rule');
    });
  });
}
