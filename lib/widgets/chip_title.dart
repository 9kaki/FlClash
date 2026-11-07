import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:flutter/widgets.dart';

class ExpireChip extends StatelessWidget {
  /// Null stands for a provider that never expires.
  final DateTime? expire;

  /// The wording for a subscription that has no expiry to show.
  final String? label;

  final TextStyle? style;

  const ExpireChip({super.key, this.expire, this.label, this.style});

  static const _padding = EdgeInsets.symmetric(horizontal: 8, vertical: 2);

  static String _labelOf(
    BuildContext context,
    DateTime? expire,
    String? label,
  ) => expire?.show ?? label ?? context.appLocalizations.infiniteTime;

  static TextStyle _styleOf(BuildContext context, TextStyle? style) =>
      style ?? AppTextStyle.caption1.of(context, emphasized: true);

  static double widthOf(
    BuildContext context,
    DateTime? expire, [
    String? label,
    TextStyle? style,
  ]) =>
      MeasureScope.of(context)
          .computeTextSize(
            Text(
              _labelOf(context, expire, label),
              style: _styleOf(context, style),
            ),
          )
          .width +
      _padding.horizontal;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final expire = this.expire;
    final color = expire != null && expire.isBeforeNow
        ? colorScheme.error
        : colorScheme.primary;
    return Tooltip(
      message: context.appLocalizations.expireTime,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: color.opacity15,
          shape: AppShape.full,
        ),
        child: Padding(
          padding: _padding,
          child: Text(
            _labelOf(context, expire, label),
            maxLines: 1,
            style: _styleOf(context, style).copyWith(color: color),
          ),
        ),
      ),
    );
  }
}

/// A title followed by an optional count chip and an expiry chip. The expiry
/// chip gives way before it would squeeze the title below half the row.
class ChipTitle extends StatelessWidget {
  final String title;
  final String? chip;
  final DateTime? expire;

  /// Shows the expiry chip as "long term" for a provider without one, so a
  /// resource that never expires still reads like one that does.
  final bool permanent;

  final TextStyle? style;

  /// The style of the expiry chip alone, for a row that needs it smaller.
  final TextStyle? expireStyle;

  const ChipTitle({
    super.key,
    required this.title,
    this.chip,
    this.expire,
    this.permanent = false,
    this.style,
    this.expireStyle,
  });

  static const _gap = 8.0;

  bool get _showsExpiry => expire != null || permanent;

  String? _longTermLabel(BuildContext context) =>
      permanent && expire == null
      ? context.appLocalizations.longTermSubscription
      : null;

  bool _fitsExpire(BuildContext context, double maxWidth, DateTime? expire) {
    final chip = this.chip;
    final titleWidth = MeasureScope.of(context)
        .computeTextSize(
          Text(title, style: DefaultTextStyle.of(context).style.merge(style)),
        )
        .width;
    final chipsWidth =
        (chip == null ? 0 : TonalChip.widthOf(context, chip) + _gap) +
        ExpireChip.widthOf(
          context,
          expire,
          _longTermLabel(context),
          expireStyle,
        ) +
        _gap;
    return maxWidth - chipsWidth >= min(titleWidth, maxWidth / 2);
  }

  @override
  Widget build(BuildContext context) {
    final style = this.style;
    final chip = this.chip;
    final expire = this.expire;
    final text = Text(
      title,
      style: style,
      strutStyle: StrutStyle.fromTextStyle(
        DefaultTextStyle.of(context).style.merge(style),
        forceStrutHeight: true,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textWidthBasis: TextWidthBasis.longestLine,
    );
    if (chip == null && !_showsExpiry) {
      return text;
    }
    final colorScheme = context.colorScheme;
    Widget row({required bool showExpire}) => Row(
      spacing: _gap,
      children: [
        Flexible(child: text),
        if (chip != null)
          TonalChip(
            label: chip,
            color: context.raisedSurfaceLevel.colorOf(colorScheme),
            foregroundColor: colorScheme.onSurfaceVariant,
          ),
        if (showExpire)
          ExpireChip(
            expire: expire,
            label: _longTermLabel(context),
            style: expireStyle,
          ),
      ],
    );
    if (!_showsExpiry) {
      return row(showExpire: false);
    }
    return LayoutBuilder(
      builder: (context, constraints) =>
          row(showExpire: _fitsExpire(context, constraints.maxWidth, expire)),
    );
  }
}
