// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SubscriptionInfo {

 int get upload; int get download; int get total; int get expire;
/// Create a copy of SubscriptionInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionInfoCopyWith<SubscriptionInfo> get copyWith => _$SubscriptionInfoCopyWithImpl<SubscriptionInfo>(this as SubscriptionInfo, _$identity);

  /// Serializes this SubscriptionInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SubscriptionInfo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionInfo&&(identical(other.upload, _this.upload) || other.upload == _this.upload)&&(identical(other.download, _this.download) || other.download == _this.download)&&(identical(other.total, _this.total) || other.total == _this.total)&&(identical(other.expire, _this.expire) || other.expire == _this.expire));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SubscriptionInfo;
  return Object.hash(runtimeType,_this.upload,_this.download,_this.total,_this.expire);
}

@override
String toString() {
  final _this = this as SubscriptionInfo;
  return 'SubscriptionInfo(upload: ${_this.upload}, download: ${_this.download}, total: ${_this.total}, expire: ${_this.expire})';
}


}

/// @nodoc
abstract mixin class $SubscriptionInfoCopyWith<$Res>  {
  factory $SubscriptionInfoCopyWith(SubscriptionInfo value, $Res Function(SubscriptionInfo) _then) = _$SubscriptionInfoCopyWithImpl;
@useResult
$Res call({
 int upload, int download, int total, int expire
});




}
/// @nodoc
class _$SubscriptionInfoCopyWithImpl<$Res>
    implements $SubscriptionInfoCopyWith<$Res> {
  _$SubscriptionInfoCopyWithImpl(this._self, this._then);

  final SubscriptionInfo _self;
  final $Res Function(SubscriptionInfo) _then;

/// Create a copy of SubscriptionInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? upload = null,Object? download = null,Object? total = null,Object? expire = null,}) {
  return _then(SubscriptionInfo(
upload: null == upload ? _self.upload : upload // ignore: cast_nullable_to_non_nullable
as int,download: null == download ? _self.download : download // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,expire: null == expire ? _self.expire : expire // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SubscriptionInfo].
extension SubscriptionInfoPatterns on SubscriptionInfo {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubscriptionInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubscriptionInfo() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubscriptionInfo value)  $default,){
final _that = this;
switch (_that) {
case _SubscriptionInfo():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubscriptionInfo value)?  $default,){
final _that = this;
switch (_that) {
case _SubscriptionInfo() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int upload,  int download,  int total,  int expire)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubscriptionInfo() when $default != null:
return $default(_that.upload,_that.download,_that.total,_that.expire);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int upload,  int download,  int total,  int expire)  $default,) {final _that = this;
switch (_that) {
case _SubscriptionInfo():
return $default(_that.upload,_that.download,_that.total,_that.expire);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int upload,  int download,  int total,  int expire)?  $default,) {final _that = this;
switch (_that) {
case _SubscriptionInfo() when $default != null:
return $default(_that.upload,_that.download,_that.total,_that.expire);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubscriptionInfo implements SubscriptionInfo {
  const _SubscriptionInfo({this.upload = 0, this.download = 0, this.total = 0, this.expire = 0});
  factory _SubscriptionInfo.fromJson(Map<String, dynamic> json) => _$SubscriptionInfoFromJson(json);

@override@JsonKey() final  int upload;
@override@JsonKey() final  int download;
@override@JsonKey() final  int total;
@override@JsonKey() final  int expire;

/// Create a copy of SubscriptionInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubscriptionInfoCopyWith<_SubscriptionInfo> get copyWith => __$SubscriptionInfoCopyWithImpl<_SubscriptionInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubscriptionInfoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscriptionInfo&&(identical(other.upload, upload) || other.upload == upload)&&(identical(other.download, download) || other.download == download)&&(identical(other.total, total) || other.total == total)&&(identical(other.expire, expire) || other.expire == expire));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,upload,download,total,expire);
}

@override
String toString() {
    return 'SubscriptionInfo(upload: $upload, download: $download, total: $total, expire: $expire)';
}


}

/// @nodoc
abstract mixin class _$SubscriptionInfoCopyWith<$Res> implements $SubscriptionInfoCopyWith<$Res> {
  factory _$SubscriptionInfoCopyWith(_SubscriptionInfo value, $Res Function(_SubscriptionInfo) _then) = __$SubscriptionInfoCopyWithImpl;
@override @useResult
$Res call({
 int upload, int download, int total, int expire
});




}
/// @nodoc
class __$SubscriptionInfoCopyWithImpl<$Res>
    implements _$SubscriptionInfoCopyWith<$Res> {
  __$SubscriptionInfoCopyWithImpl(this._self, this._then);

  final _SubscriptionInfo _self;
  final $Res Function(_SubscriptionInfo) _then;

/// Create a copy of SubscriptionInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? upload = null,Object? download = null,Object? total = null,Object? expire = null,}) {
  return _then(_SubscriptionInfo(
upload: null == upload ? _self.upload : upload // ignore: cast_nullable_to_non_nullable
as int,download: null == download ? _self.download : download // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,expire: null == expire ? _self.expire : expire // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$BundleMember {

 int get id;/// What this member's proxies are labelled with; null takes the label's
/// own prefix, as the merge page shows it.
 String? get prefix;/// How many proxies the member contributed to the last merge.
 int get proxies;
/// Create a copy of BundleMember
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BundleMemberCopyWith<BundleMember> get copyWith => _$BundleMemberCopyWithImpl<BundleMember>(this as BundleMember, _$identity);

  /// Serializes this BundleMember to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BundleMember;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BundleMember&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.prefix, _this.prefix) || other.prefix == _this.prefix)&&(identical(other.proxies, _this.proxies) || other.proxies == _this.proxies));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BundleMember;
  return Object.hash(runtimeType,_this.id,_this.prefix,_this.proxies);
}

@override
String toString() {
  final _this = this as BundleMember;
  return 'BundleMember(id: ${_this.id}, prefix: ${_this.prefix}, proxies: ${_this.proxies})';
}


}

/// @nodoc
abstract mixin class $BundleMemberCopyWith<$Res>  {
  factory $BundleMemberCopyWith(BundleMember value, $Res Function(BundleMember) _then) = _$BundleMemberCopyWithImpl;
@useResult
$Res call({
 int id, String? prefix, int proxies
});




}
/// @nodoc
class _$BundleMemberCopyWithImpl<$Res>
    implements $BundleMemberCopyWith<$Res> {
  _$BundleMemberCopyWithImpl(this._self, this._then);

  final BundleMember _self;
  final $Res Function(BundleMember) _then;

/// Create a copy of BundleMember
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? prefix = freezed,Object? proxies = null,}) {
  return _then(BundleMember(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,prefix: freezed == prefix ? _self.prefix : prefix // ignore: cast_nullable_to_non_nullable
as String?,proxies: null == proxies ? _self.proxies : proxies // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [BundleMember].
extension BundleMemberPatterns on BundleMember {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BundleMember value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BundleMember() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BundleMember value)  $default,){
final _that = this;
switch (_that) {
case _BundleMember():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BundleMember value)?  $default,){
final _that = this;
switch (_that) {
case _BundleMember() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String? prefix,  int proxies)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BundleMember() when $default != null:
return $default(_that.id,_that.prefix,_that.proxies);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String? prefix,  int proxies)  $default,) {final _that = this;
switch (_that) {
case _BundleMember():
return $default(_that.id,_that.prefix,_that.proxies);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String? prefix,  int proxies)?  $default,) {final _that = this;
switch (_that) {
case _BundleMember() when $default != null:
return $default(_that.id,_that.prefix,_that.proxies);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BundleMember implements BundleMember {
  const _BundleMember({required this.id, this.prefix, this.proxies = 0});
  factory _BundleMember.fromJson(Map<String, dynamic> json) => _$BundleMemberFromJson(json);

@override final  int id;
/// What this member's proxies are labelled with; null takes the label's
/// own prefix, as the merge page shows it.
@override final  String? prefix;
/// How many proxies the member contributed to the last merge.
@override@JsonKey() final  int proxies;

/// Create a copy of BundleMember
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BundleMemberCopyWith<_BundleMember> get copyWith => __$BundleMemberCopyWithImpl<_BundleMember>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BundleMemberToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BundleMember&&(identical(other.id, id) || other.id == id)&&(identical(other.prefix, prefix) || other.prefix == prefix)&&(identical(other.proxies, proxies) || other.proxies == proxies));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,prefix,proxies);
}

@override
String toString() {
    return 'BundleMember(id: $id, prefix: $prefix, proxies: $proxies)';
}


}

/// @nodoc
abstract mixin class _$BundleMemberCopyWith<$Res> implements $BundleMemberCopyWith<$Res> {
  factory _$BundleMemberCopyWith(_BundleMember value, $Res Function(_BundleMember) _then) = __$BundleMemberCopyWithImpl;
@override @useResult
$Res call({
 int id, String? prefix, int proxies
});




}
/// @nodoc
class __$BundleMemberCopyWithImpl<$Res>
    implements _$BundleMemberCopyWith<$Res> {
  __$BundleMemberCopyWithImpl(this._self, this._then);

  final _BundleMember _self;
  final $Res Function(_BundleMember) _then;

/// Create a copy of BundleMember
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? prefix = freezed,Object? proxies = null,}) {
  return _then(_BundleMember(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,prefix: freezed == prefix ? _self.prefix : prefix // ignore: cast_nullable_to_non_nullable
as String?,proxies: null == proxies ? _self.proxies : proxies // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$BundleReport {

 int get proxies; int get duplicates; int get groups;
/// Create a copy of BundleReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BundleReportCopyWith<BundleReport> get copyWith => _$BundleReportCopyWithImpl<BundleReport>(this as BundleReport, _$identity);

  /// Serializes this BundleReport to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BundleReport;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BundleReport&&(identical(other.proxies, _this.proxies) || other.proxies == _this.proxies)&&(identical(other.duplicates, _this.duplicates) || other.duplicates == _this.duplicates)&&(identical(other.groups, _this.groups) || other.groups == _this.groups));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BundleReport;
  return Object.hash(runtimeType,_this.proxies,_this.duplicates,_this.groups);
}

@override
String toString() {
  final _this = this as BundleReport;
  return 'BundleReport(proxies: ${_this.proxies}, duplicates: ${_this.duplicates}, groups: ${_this.groups})';
}


}

/// @nodoc
abstract mixin class $BundleReportCopyWith<$Res>  {
  factory $BundleReportCopyWith(BundleReport value, $Res Function(BundleReport) _then) = _$BundleReportCopyWithImpl;
@useResult
$Res call({
 int proxies, int duplicates, int groups
});




}
/// @nodoc
class _$BundleReportCopyWithImpl<$Res>
    implements $BundleReportCopyWith<$Res> {
  _$BundleReportCopyWithImpl(this._self, this._then);

  final BundleReport _self;
  final $Res Function(BundleReport) _then;

/// Create a copy of BundleReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? proxies = null,Object? duplicates = null,Object? groups = null,}) {
  return _then(BundleReport(
proxies: null == proxies ? _self.proxies : proxies // ignore: cast_nullable_to_non_nullable
as int,duplicates: null == duplicates ? _self.duplicates : duplicates // ignore: cast_nullable_to_non_nullable
as int,groups: null == groups ? _self.groups : groups // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [BundleReport].
extension BundleReportPatterns on BundleReport {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BundleReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BundleReport() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BundleReport value)  $default,){
final _that = this;
switch (_that) {
case _BundleReport():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BundleReport value)?  $default,){
final _that = this;
switch (_that) {
case _BundleReport() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int proxies,  int duplicates,  int groups)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BundleReport() when $default != null:
return $default(_that.proxies,_that.duplicates,_that.groups);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int proxies,  int duplicates,  int groups)  $default,) {final _that = this;
switch (_that) {
case _BundleReport():
return $default(_that.proxies,_that.duplicates,_that.groups);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int proxies,  int duplicates,  int groups)?  $default,) {final _that = this;
switch (_that) {
case _BundleReport() when $default != null:
return $default(_that.proxies,_that.duplicates,_that.groups);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BundleReport implements BundleReport {
  const _BundleReport({this.proxies = 0, this.duplicates = 0, this.groups = 0});
  factory _BundleReport.fromJson(Map<String, dynamic> json) => _$BundleReportFromJson(json);

@override@JsonKey() final  int proxies;
@override@JsonKey() final  int duplicates;
@override@JsonKey() final  int groups;

/// Create a copy of BundleReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BundleReportCopyWith<_BundleReport> get copyWith => __$BundleReportCopyWithImpl<_BundleReport>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BundleReportToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BundleReport&&(identical(other.proxies, proxies) || other.proxies == proxies)&&(identical(other.duplicates, duplicates) || other.duplicates == duplicates)&&(identical(other.groups, groups) || other.groups == groups));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,proxies,duplicates,groups);
}

@override
String toString() {
    return 'BundleReport(proxies: $proxies, duplicates: $duplicates, groups: $groups)';
}


}

/// @nodoc
abstract mixin class _$BundleReportCopyWith<$Res> implements $BundleReportCopyWith<$Res> {
  factory _$BundleReportCopyWith(_BundleReport value, $Res Function(_BundleReport) _then) = __$BundleReportCopyWithImpl;
@override @useResult
$Res call({
 int proxies, int duplicates, int groups
});




}
/// @nodoc
class __$BundleReportCopyWithImpl<$Res>
    implements _$BundleReportCopyWith<$Res> {
  __$BundleReportCopyWithImpl(this._self, this._then);

  final _BundleReport _self;
  final $Res Function(_BundleReport) _then;

/// Create a copy of BundleReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? proxies = null,Object? duplicates = null,Object? groups = null,}) {
  return _then(_BundleReport(
proxies: null == proxies ? _self.proxies : proxies // ignore: cast_nullable_to_non_nullable
as int,duplicates: null == duplicates ? _self.duplicates : duplicates // ignore: cast_nullable_to_non_nullable
as int,groups: null == groups ? _self.groups : groups // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ProfileBundle {

 List<BundleMember> get members; BundleReport get report;/// Member id to why its config could not join the last merge.
 Map<int, String> get failures; bool get collapsed;
/// Create a copy of ProfileBundle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileBundleCopyWith<ProfileBundle> get copyWith => _$ProfileBundleCopyWithImpl<ProfileBundle>(this as ProfileBundle, _$identity);

  /// Serializes this ProfileBundle to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProfileBundle;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileBundle&&const DeepCollectionEquality().equals(other.members, _this.members)&&(identical(other.report, _this.report) || other.report == _this.report)&&const DeepCollectionEquality().equals(other.failures, _this.failures)&&(identical(other.collapsed, _this.collapsed) || other.collapsed == _this.collapsed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProfileBundle;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.members),_this.report,const DeepCollectionEquality().hash(_this.failures),_this.collapsed);
}

@override
String toString() {
  final _this = this as ProfileBundle;
  return 'ProfileBundle(members: ${_this.members}, report: ${_this.report}, failures: ${_this.failures}, collapsed: ${_this.collapsed})';
}


}

/// @nodoc
abstract mixin class $ProfileBundleCopyWith<$Res>  {
  factory $ProfileBundleCopyWith(ProfileBundle value, $Res Function(ProfileBundle) _then) = _$ProfileBundleCopyWithImpl;
@useResult
$Res call({
 List<BundleMember> members, BundleReport report, Map<int, String> failures, bool collapsed
});


$BundleReportCopyWith<$Res> get report;

}
/// @nodoc
class _$ProfileBundleCopyWithImpl<$Res>
    implements $ProfileBundleCopyWith<$Res> {
  _$ProfileBundleCopyWithImpl(this._self, this._then);

  final ProfileBundle _self;
  final $Res Function(ProfileBundle) _then;

/// Create a copy of ProfileBundle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? members = null,Object? report = null,Object? failures = null,Object? collapsed = null,}) {
  return _then(ProfileBundle(
members: null == members ? _self.members : members // ignore: cast_nullable_to_non_nullable
as List<BundleMember>,report: null == report ? _self.report : report // ignore: cast_nullable_to_non_nullable
as BundleReport,failures: null == failures ? _self.failures : failures // ignore: cast_nullable_to_non_nullable
as Map<int, String>,collapsed: null == collapsed ? _self.collapsed : collapsed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of ProfileBundle
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BundleReportCopyWith<$Res> get report {
  
  return $BundleReportCopyWith<$Res>(_self.report, (value) {
    return _then(_self.copyWith(report: value));
  });
}
}


/// Adds pattern-matching-related methods to [ProfileBundle].
extension ProfileBundlePatterns on ProfileBundle {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileBundle value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileBundle() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileBundle value)  $default,){
final _that = this;
switch (_that) {
case _ProfileBundle():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileBundle value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileBundle() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<BundleMember> members,  BundleReport report,  Map<int, String> failures,  bool collapsed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileBundle() when $default != null:
return $default(_that.members,_that.report,_that.failures,_that.collapsed);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<BundleMember> members,  BundleReport report,  Map<int, String> failures,  bool collapsed)  $default,) {final _that = this;
switch (_that) {
case _ProfileBundle():
return $default(_that.members,_that.report,_that.failures,_that.collapsed);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<BundleMember> members,  BundleReport report,  Map<int, String> failures,  bool collapsed)?  $default,) {final _that = this;
switch (_that) {
case _ProfileBundle() when $default != null:
return $default(_that.members,_that.report,_that.failures,_that.collapsed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProfileBundle implements ProfileBundle {
  const _ProfileBundle({ List<BundleMember> members = const <BundleMember>[], this.report = const BundleReport(),  Map<int, String> failures = const <int, String>{}, this.collapsed = false}): _members = members,_failures = failures;
  factory _ProfileBundle.fromJson(Map<String, dynamic> json) => _$ProfileBundleFromJson(json);

 final  List<BundleMember> _members;
@override@JsonKey() List<BundleMember> get members {
  if (_members is EqualUnmodifiableListView) return _members;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_members);
}

@override@JsonKey() final  BundleReport report;
/// Member id to why its config could not join the last merge.
 final  Map<int, String> _failures;
/// Member id to why its config could not join the last merge.
@override@JsonKey() Map<int, String> get failures {
  if (_failures is EqualUnmodifiableMapView) return _failures;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_failures);
}

@override@JsonKey() final  bool collapsed;

/// Create a copy of ProfileBundle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileBundleCopyWith<_ProfileBundle> get copyWith => __$ProfileBundleCopyWithImpl<_ProfileBundle>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileBundleToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileBundle&&const DeepCollectionEquality().equals(other.members, _members)&&(identical(other.report, report) || other.report == report)&&const DeepCollectionEquality().equals(other.failures, _failures)&&(identical(other.collapsed, collapsed) || other.collapsed == collapsed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_members),report,const DeepCollectionEquality().hash(_failures),collapsed);
}

@override
String toString() {
    return 'ProfileBundle(members: $members, report: $report, failures: $failures, collapsed: $collapsed)';
}


}

/// @nodoc
abstract mixin class _$ProfileBundleCopyWith<$Res> implements $ProfileBundleCopyWith<$Res> {
  factory _$ProfileBundleCopyWith(_ProfileBundle value, $Res Function(_ProfileBundle) _then) = __$ProfileBundleCopyWithImpl;
@override @useResult
$Res call({
 List<BundleMember> members, BundleReport report, Map<int, String> failures, bool collapsed
});


@override $BundleReportCopyWith<$Res> get report;

}
/// @nodoc
class __$ProfileBundleCopyWithImpl<$Res>
    implements _$ProfileBundleCopyWith<$Res> {
  __$ProfileBundleCopyWithImpl(this._self, this._then);

  final _ProfileBundle _self;
  final $Res Function(_ProfileBundle) _then;

/// Create a copy of ProfileBundle
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? members = null,Object? report = null,Object? failures = null,Object? collapsed = null,}) {
  return _then(_ProfileBundle(
members: null == members ? _self._members : members // ignore: cast_nullable_to_non_nullable
as List<BundleMember>,report: null == report ? _self.report : report // ignore: cast_nullable_to_non_nullable
as BundleReport,failures: null == failures ? _self._failures : failures // ignore: cast_nullable_to_non_nullable
as Map<int, String>,collapsed: null == collapsed ? _self.collapsed : collapsed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of ProfileBundle
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BundleReportCopyWith<$Res> get report {
  
  return $BundleReportCopyWith<$Res>(_self.report, (value) {
    return _then(_self.copyWith(report: value));
  });
}
}


/// @nodoc
mixin _$Profile {

 int get id; ProfileType get type; String get label; String? get currentGroupName; String get url; String get ageSecretKey; DateTime? get lastUpdateDate; Duration get autoUpdateDuration; SubscriptionInfo? get subscriptionInfo; bool get autoUpdate; Map<String, String> get selectedMap; Set<String> get unfoldSet; ExtendType get extendType; int? get scriptId; String? get matchTarget; int? get order;/// What this profile merges; null for one that carries its own config.
 ProfileBundle? get bundle;/// Policy groups the reader switched off in the YAML rule switches. The
/// build drops them, the groups that name them, and the rules that point
/// at them.
 Set<String> get disabledGroups;@JsonKey(fromJson: ProfileOverrides.safeFromJson) ProfileOverrides get overrides;
/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileCopyWith<Profile> get copyWith => _$ProfileCopyWithImpl<Profile>(this as Profile, _$identity);

  /// Serializes this Profile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Profile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Profile&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.currentGroupName, _this.currentGroupName) || other.currentGroupName == _this.currentGroupName)&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.ageSecretKey, _this.ageSecretKey) || other.ageSecretKey == _this.ageSecretKey)&&(identical(other.lastUpdateDate, _this.lastUpdateDate) || other.lastUpdateDate == _this.lastUpdateDate)&&(identical(other.autoUpdateDuration, _this.autoUpdateDuration) || other.autoUpdateDuration == _this.autoUpdateDuration)&&(identical(other.subscriptionInfo, _this.subscriptionInfo) || other.subscriptionInfo == _this.subscriptionInfo)&&(identical(other.autoUpdate, _this.autoUpdate) || other.autoUpdate == _this.autoUpdate)&&const DeepCollectionEquality().equals(other.selectedMap, _this.selectedMap)&&const DeepCollectionEquality().equals(other.unfoldSet, _this.unfoldSet)&&(identical(other.extendType, _this.extendType) || other.extendType == _this.extendType)&&(identical(other.scriptId, _this.scriptId) || other.scriptId == _this.scriptId)&&(identical(other.matchTarget, _this.matchTarget) || other.matchTarget == _this.matchTarget)&&(identical(other.order, _this.order) || other.order == _this.order)&&(identical(other.bundle, _this.bundle) || other.bundle == _this.bundle)&&const DeepCollectionEquality().equals(other.disabledGroups, _this.disabledGroups)&&(identical(other.overrides, _this.overrides) || other.overrides == _this.overrides));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Profile;
  return Object.hashAll([runtimeType,_this.id,_this.type,_this.label,_this.currentGroupName,_this.url,_this.ageSecretKey,_this.lastUpdateDate,_this.autoUpdateDuration,_this.subscriptionInfo,_this.autoUpdate,const DeepCollectionEquality().hash(_this.selectedMap),const DeepCollectionEquality().hash(_this.unfoldSet),_this.extendType,_this.scriptId,_this.matchTarget,_this.order,_this.bundle,const DeepCollectionEquality().hash(_this.disabledGroups),_this.overrides]);
}

@override
String toString() {
  final _this = this as Profile;
  return 'Profile(id: ${_this.id}, type: ${_this.type}, label: ${_this.label}, currentGroupName: ${_this.currentGroupName}, url: ${_this.url}, ageSecretKey: ${_this.ageSecretKey}, lastUpdateDate: ${_this.lastUpdateDate}, autoUpdateDuration: ${_this.autoUpdateDuration}, subscriptionInfo: ${_this.subscriptionInfo}, autoUpdate: ${_this.autoUpdate}, selectedMap: ${_this.selectedMap}, unfoldSet: ${_this.unfoldSet}, extendType: ${_this.extendType}, scriptId: ${_this.scriptId}, matchTarget: ${_this.matchTarget}, order: ${_this.order}, bundle: ${_this.bundle}, disabledGroups: ${_this.disabledGroups}, overrides: ${_this.overrides})';
}


}

/// @nodoc
abstract mixin class $ProfileCopyWith<$Res>  {
  factory $ProfileCopyWith(Profile value, $Res Function(Profile) _then) = _$ProfileCopyWithImpl;
@useResult
$Res call({
 int id, ProfileType type, String label, String? currentGroupName, String url, String ageSecretKey, DateTime? lastUpdateDate, Duration autoUpdateDuration, SubscriptionInfo? subscriptionInfo, bool autoUpdate, Map<String, String> selectedMap, Set<String> unfoldSet, ExtendType extendType, int? scriptId, String? matchTarget, int? order, ProfileBundle? bundle, Set<String> disabledGroups,@JsonKey(fromJson: ProfileOverrides.safeFromJson) ProfileOverrides overrides
});


$SubscriptionInfoCopyWith<$Res>? get subscriptionInfo;$ProfileBundleCopyWith<$Res>? get bundle;$ProfileOverridesCopyWith<$Res> get overrides;

}
/// @nodoc
class _$ProfileCopyWithImpl<$Res>
    implements $ProfileCopyWith<$Res> {
  _$ProfileCopyWithImpl(this._self, this._then);

  final Profile _self;
  final $Res Function(Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? label = null,Object? currentGroupName = freezed,Object? url = null,Object? ageSecretKey = null,Object? lastUpdateDate = freezed,Object? autoUpdateDuration = null,Object? subscriptionInfo = freezed,Object? autoUpdate = null,Object? selectedMap = null,Object? unfoldSet = null,Object? extendType = null,Object? scriptId = freezed,Object? matchTarget = freezed,Object? order = freezed,Object? bundle = freezed,Object? disabledGroups = null,Object? overrides = null,}) {
  return _then(Profile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ProfileType,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,currentGroupName: freezed == currentGroupName ? _self.currentGroupName : currentGroupName // ignore: cast_nullable_to_non_nullable
as String?,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,ageSecretKey: null == ageSecretKey ? _self.ageSecretKey : ageSecretKey // ignore: cast_nullable_to_non_nullable
as String,lastUpdateDate: freezed == lastUpdateDate ? _self.lastUpdateDate : lastUpdateDate // ignore: cast_nullable_to_non_nullable
as DateTime?,autoUpdateDuration: null == autoUpdateDuration ? _self.autoUpdateDuration : autoUpdateDuration // ignore: cast_nullable_to_non_nullable
as Duration,subscriptionInfo: freezed == subscriptionInfo ? _self.subscriptionInfo : subscriptionInfo // ignore: cast_nullable_to_non_nullable
as SubscriptionInfo?,autoUpdate: null == autoUpdate ? _self.autoUpdate : autoUpdate // ignore: cast_nullable_to_non_nullable
as bool,selectedMap: null == selectedMap ? _self.selectedMap : selectedMap // ignore: cast_nullable_to_non_nullable
as Map<String, String>,unfoldSet: null == unfoldSet ? _self.unfoldSet : unfoldSet // ignore: cast_nullable_to_non_nullable
as Set<String>,extendType: null == extendType ? _self.extendType : extendType // ignore: cast_nullable_to_non_nullable
as ExtendType,scriptId: freezed == scriptId ? _self.scriptId : scriptId // ignore: cast_nullable_to_non_nullable
as int?,matchTarget: freezed == matchTarget ? _self.matchTarget : matchTarget // ignore: cast_nullable_to_non_nullable
as String?,order: freezed == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int?,bundle: freezed == bundle ? _self.bundle : bundle // ignore: cast_nullable_to_non_nullable
as ProfileBundle?,disabledGroups: null == disabledGroups ? _self.disabledGroups : disabledGroups // ignore: cast_nullable_to_non_nullable
as Set<String>,overrides: null == overrides ? _self.overrides : overrides // ignore: cast_nullable_to_non_nullable
as ProfileOverrides,
  ));
}
/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SubscriptionInfoCopyWith<$Res>? get subscriptionInfo {
    if (_self.subscriptionInfo == null) {
    return null;
  }

  return $SubscriptionInfoCopyWith<$Res>(_self.subscriptionInfo!, (value) {
    return _then(_self.copyWith(subscriptionInfo: value));
  });
}/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileBundleCopyWith<$Res>? get bundle {
    if (_self.bundle == null) {
    return null;
  }

  return $ProfileBundleCopyWith<$Res>(_self.bundle!, (value) {
    return _then(_self.copyWith(bundle: value));
  });
}/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileOverridesCopyWith<$Res> get overrides {
  
  return $ProfileOverridesCopyWith<$Res>(_self.overrides, (value) {
    return _then(_self.copyWith(overrides: value));
  });
}
}


/// Adds pattern-matching-related methods to [Profile].
extension ProfilePatterns on Profile {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Profile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Profile value)  $default,){
final _that = this;
switch (_that) {
case _Profile():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Profile value)?  $default,){
final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  ProfileType type,  String label,  String? currentGroupName,  String url,  String ageSecretKey,  DateTime? lastUpdateDate,  Duration autoUpdateDuration,  SubscriptionInfo? subscriptionInfo,  bool autoUpdate,  Map<String, String> selectedMap,  Set<String> unfoldSet,  ExtendType extendType,  int? scriptId,  String? matchTarget,  int? order,  ProfileBundle? bundle,  Set<String> disabledGroups, @JsonKey(fromJson: ProfileOverrides.safeFromJson)  ProfileOverrides overrides)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.id,_that.type,_that.label,_that.currentGroupName,_that.url,_that.ageSecretKey,_that.lastUpdateDate,_that.autoUpdateDuration,_that.subscriptionInfo,_that.autoUpdate,_that.selectedMap,_that.unfoldSet,_that.extendType,_that.scriptId,_that.matchTarget,_that.order,_that.bundle,_that.disabledGroups,_that.overrides);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  ProfileType type,  String label,  String? currentGroupName,  String url,  String ageSecretKey,  DateTime? lastUpdateDate,  Duration autoUpdateDuration,  SubscriptionInfo? subscriptionInfo,  bool autoUpdate,  Map<String, String> selectedMap,  Set<String> unfoldSet,  ExtendType extendType,  int? scriptId,  String? matchTarget,  int? order,  ProfileBundle? bundle,  Set<String> disabledGroups, @JsonKey(fromJson: ProfileOverrides.safeFromJson)  ProfileOverrides overrides)  $default,) {final _that = this;
switch (_that) {
case _Profile():
return $default(_that.id,_that.type,_that.label,_that.currentGroupName,_that.url,_that.ageSecretKey,_that.lastUpdateDate,_that.autoUpdateDuration,_that.subscriptionInfo,_that.autoUpdate,_that.selectedMap,_that.unfoldSet,_that.extendType,_that.scriptId,_that.matchTarget,_that.order,_that.bundle,_that.disabledGroups,_that.overrides);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  ProfileType type,  String label,  String? currentGroupName,  String url,  String ageSecretKey,  DateTime? lastUpdateDate,  Duration autoUpdateDuration,  SubscriptionInfo? subscriptionInfo,  bool autoUpdate,  Map<String, String> selectedMap,  Set<String> unfoldSet,  ExtendType extendType,  int? scriptId,  String? matchTarget,  int? order,  ProfileBundle? bundle,  Set<String> disabledGroups, @JsonKey(fromJson: ProfileOverrides.safeFromJson)  ProfileOverrides overrides)?  $default,) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.id,_that.type,_that.label,_that.currentGroupName,_that.url,_that.ageSecretKey,_that.lastUpdateDate,_that.autoUpdateDuration,_that.subscriptionInfo,_that.autoUpdate,_that.selectedMap,_that.unfoldSet,_that.extendType,_that.scriptId,_that.matchTarget,_that.order,_that.bundle,_that.disabledGroups,_that.overrides);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Profile implements Profile {
  const _Profile({required this.id, this.type = ProfileType.file, this.label = '', this.currentGroupName, this.url = '', this.ageSecretKey = '', this.lastUpdateDate, required this.autoUpdateDuration, this.subscriptionInfo, this.autoUpdate = true,  Map<String, String> selectedMap = const {},  Set<String> unfoldSet = const {}, this.extendType = ExtendType.standard, this.scriptId, this.matchTarget, this.order, this.bundle,  Set<String> disabledGroups = const <String>{}, @JsonKey(fromJson: ProfileOverrides.safeFromJson) this.overrides = const ProfileOverrides()}): _selectedMap = selectedMap,_unfoldSet = unfoldSet,_disabledGroups = disabledGroups;
  factory _Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

@override final  int id;
@override@JsonKey() final  ProfileType type;
@override@JsonKey() final  String label;
@override final  String? currentGroupName;
@override@JsonKey() final  String url;
@override@JsonKey() final  String ageSecretKey;
@override final  DateTime? lastUpdateDate;
@override final  Duration autoUpdateDuration;
@override final  SubscriptionInfo? subscriptionInfo;
@override@JsonKey() final  bool autoUpdate;
 final  Map<String, String> _selectedMap;
@override@JsonKey() Map<String, String> get selectedMap {
  if (_selectedMap is EqualUnmodifiableMapView) return _selectedMap;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_selectedMap);
}

 final  Set<String> _unfoldSet;
@override@JsonKey() Set<String> get unfoldSet {
  if (_unfoldSet is EqualUnmodifiableSetView) return _unfoldSet;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_unfoldSet);
}

@override@JsonKey() final  ExtendType extendType;
@override final  int? scriptId;
@override final  String? matchTarget;
@override final  int? order;
/// What this profile merges; null for one that carries its own config.
@override final  ProfileBundle? bundle;
/// Policy groups the reader switched off in the YAML rule switches. The
/// build drops them, the groups that name them, and the rules that point
/// at them.
 final  Set<String> _disabledGroups;
/// Policy groups the reader switched off in the YAML rule switches. The
/// build drops them, the groups that name them, and the rules that point
/// at them.
@override@JsonKey() Set<String> get disabledGroups {
  if (_disabledGroups is EqualUnmodifiableSetView) return _disabledGroups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_disabledGroups);
}

@override@JsonKey(fromJson: ProfileOverrides.safeFromJson) final  ProfileOverrides overrides;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileCopyWith<_Profile> get copyWith => __$ProfileCopyWithImpl<_Profile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Profile&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.label, label) || other.label == label)&&(identical(other.currentGroupName, currentGroupName) || other.currentGroupName == currentGroupName)&&(identical(other.url, url) || other.url == url)&&(identical(other.ageSecretKey, ageSecretKey) || other.ageSecretKey == ageSecretKey)&&(identical(other.lastUpdateDate, lastUpdateDate) || other.lastUpdateDate == lastUpdateDate)&&(identical(other.autoUpdateDuration, autoUpdateDuration) || other.autoUpdateDuration == autoUpdateDuration)&&(identical(other.subscriptionInfo, subscriptionInfo) || other.subscriptionInfo == subscriptionInfo)&&(identical(other.autoUpdate, autoUpdate) || other.autoUpdate == autoUpdate)&&const DeepCollectionEquality().equals(other.selectedMap, _selectedMap)&&const DeepCollectionEquality().equals(other.unfoldSet, _unfoldSet)&&(identical(other.extendType, extendType) || other.extendType == extendType)&&(identical(other.scriptId, scriptId) || other.scriptId == scriptId)&&(identical(other.matchTarget, matchTarget) || other.matchTarget == matchTarget)&&(identical(other.order, order) || other.order == order)&&(identical(other.bundle, bundle) || other.bundle == bundle)&&const DeepCollectionEquality().equals(other.disabledGroups, _disabledGroups)&&(identical(other.overrides, overrides) || other.overrides == overrides));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,type,label,currentGroupName,url,ageSecretKey,lastUpdateDate,autoUpdateDuration,subscriptionInfo,autoUpdate,const DeepCollectionEquality().hash(_selectedMap),const DeepCollectionEquality().hash(_unfoldSet),extendType,scriptId,matchTarget,order,bundle,const DeepCollectionEquality().hash(_disabledGroups),overrides]);
}

@override
String toString() {
    return 'Profile(id: $id, type: $type, label: $label, currentGroupName: $currentGroupName, url: $url, ageSecretKey: $ageSecretKey, lastUpdateDate: $lastUpdateDate, autoUpdateDuration: $autoUpdateDuration, subscriptionInfo: $subscriptionInfo, autoUpdate: $autoUpdate, selectedMap: $selectedMap, unfoldSet: $unfoldSet, extendType: $extendType, scriptId: $scriptId, matchTarget: $matchTarget, order: $order, bundle: $bundle, disabledGroups: $disabledGroups, overrides: $overrides)';
}


}

/// @nodoc
abstract mixin class _$ProfileCopyWith<$Res> implements $ProfileCopyWith<$Res> {
  factory _$ProfileCopyWith(_Profile value, $Res Function(_Profile) _then) = __$ProfileCopyWithImpl;
@override @useResult
$Res call({
 int id, ProfileType type, String label, String? currentGroupName, String url, String ageSecretKey, DateTime? lastUpdateDate, Duration autoUpdateDuration, SubscriptionInfo? subscriptionInfo, bool autoUpdate, Map<String, String> selectedMap, Set<String> unfoldSet, ExtendType extendType, int? scriptId, String? matchTarget, int? order, ProfileBundle? bundle, Set<String> disabledGroups,@JsonKey(fromJson: ProfileOverrides.safeFromJson) ProfileOverrides overrides
});


@override $SubscriptionInfoCopyWith<$Res>? get subscriptionInfo;@override $ProfileBundleCopyWith<$Res>? get bundle;@override $ProfileOverridesCopyWith<$Res> get overrides;

}
/// @nodoc
class __$ProfileCopyWithImpl<$Res>
    implements _$ProfileCopyWith<$Res> {
  __$ProfileCopyWithImpl(this._self, this._then);

  final _Profile _self;
  final $Res Function(_Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? label = null,Object? currentGroupName = freezed,Object? url = null,Object? ageSecretKey = null,Object? lastUpdateDate = freezed,Object? autoUpdateDuration = null,Object? subscriptionInfo = freezed,Object? autoUpdate = null,Object? selectedMap = null,Object? unfoldSet = null,Object? extendType = null,Object? scriptId = freezed,Object? matchTarget = freezed,Object? order = freezed,Object? bundle = freezed,Object? disabledGroups = null,Object? overrides = null,}) {
  return _then(_Profile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ProfileType,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,currentGroupName: freezed == currentGroupName ? _self.currentGroupName : currentGroupName // ignore: cast_nullable_to_non_nullable
as String?,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,ageSecretKey: null == ageSecretKey ? _self.ageSecretKey : ageSecretKey // ignore: cast_nullable_to_non_nullable
as String,lastUpdateDate: freezed == lastUpdateDate ? _self.lastUpdateDate : lastUpdateDate // ignore: cast_nullable_to_non_nullable
as DateTime?,autoUpdateDuration: null == autoUpdateDuration ? _self.autoUpdateDuration : autoUpdateDuration // ignore: cast_nullable_to_non_nullable
as Duration,subscriptionInfo: freezed == subscriptionInfo ? _self.subscriptionInfo : subscriptionInfo // ignore: cast_nullable_to_non_nullable
as SubscriptionInfo?,autoUpdate: null == autoUpdate ? _self.autoUpdate : autoUpdate // ignore: cast_nullable_to_non_nullable
as bool,selectedMap: null == selectedMap ? _self._selectedMap : selectedMap // ignore: cast_nullable_to_non_nullable
as Map<String, String>,unfoldSet: null == unfoldSet ? _self._unfoldSet : unfoldSet // ignore: cast_nullable_to_non_nullable
as Set<String>,extendType: null == extendType ? _self.extendType : extendType // ignore: cast_nullable_to_non_nullable
as ExtendType,scriptId: freezed == scriptId ? _self.scriptId : scriptId // ignore: cast_nullable_to_non_nullable
as int?,matchTarget: freezed == matchTarget ? _self.matchTarget : matchTarget // ignore: cast_nullable_to_non_nullable
as String?,order: freezed == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int?,bundle: freezed == bundle ? _self.bundle : bundle // ignore: cast_nullable_to_non_nullable
as ProfileBundle?,disabledGroups: null == disabledGroups ? _self._disabledGroups : disabledGroups // ignore: cast_nullable_to_non_nullable
as Set<String>,overrides: null == overrides ? _self.overrides : overrides // ignore: cast_nullable_to_non_nullable
as ProfileOverrides,
  ));
}

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SubscriptionInfoCopyWith<$Res>? get subscriptionInfo {
    if (_self.subscriptionInfo == null) {
    return null;
  }

  return $SubscriptionInfoCopyWith<$Res>(_self.subscriptionInfo!, (value) {
    return _then(_self.copyWith(subscriptionInfo: value));
  });
}/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileBundleCopyWith<$Res>? get bundle {
    if (_self.bundle == null) {
    return null;
  }

  return $ProfileBundleCopyWith<$Res>(_self.bundle!, (value) {
    return _then(_self.copyWith(bundle: value));
  });
}/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileOverridesCopyWith<$Res> get overrides {
  
  return $ProfileOverridesCopyWith<$Res>(_self.overrides, (value) {
    return _then(_self.copyWith(overrides: value));
  });
}
}

/// @nodoc
mixin _$DisabledRule {

 int get profileId; int get ruleId;
/// Create a copy of DisabledRule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DisabledRuleCopyWith<DisabledRule> get copyWith => _$DisabledRuleCopyWithImpl<DisabledRule>(this as DisabledRule, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DisabledRule;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DisabledRule&&(identical(other.profileId, _this.profileId) || other.profileId == _this.profileId)&&(identical(other.ruleId, _this.ruleId) || other.ruleId == _this.ruleId));
}


@override
int get hashCode {
  final _this = this as DisabledRule;
  return Object.hash(runtimeType,_this.profileId,_this.ruleId);
}

@override
String toString() {
  final _this = this as DisabledRule;
  return 'DisabledRule(profileId: ${_this.profileId}, ruleId: ${_this.ruleId})';
}


}

/// @nodoc
abstract mixin class $DisabledRuleCopyWith<$Res>  {
  factory $DisabledRuleCopyWith(DisabledRule value, $Res Function(DisabledRule) _then) = _$DisabledRuleCopyWithImpl;
@useResult
$Res call({
 int profileId, int ruleId
});




}
/// @nodoc
class _$DisabledRuleCopyWithImpl<$Res>
    implements $DisabledRuleCopyWith<$Res> {
  _$DisabledRuleCopyWithImpl(this._self, this._then);

  final DisabledRule _self;
  final $Res Function(DisabledRule) _then;

/// Create a copy of DisabledRule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? profileId = null,Object? ruleId = null,}) {
  return _then(DisabledRule(
profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as int,ruleId: null == ruleId ? _self.ruleId : ruleId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DisabledRule].
extension DisabledRulePatterns on DisabledRule {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DisabledRule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DisabledRule() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DisabledRule value)  $default,){
final _that = this;
switch (_that) {
case _DisabledRule():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DisabledRule value)?  $default,){
final _that = this;
switch (_that) {
case _DisabledRule() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int profileId,  int ruleId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DisabledRule() when $default != null:
return $default(_that.profileId,_that.ruleId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int profileId,  int ruleId)  $default,) {final _that = this;
switch (_that) {
case _DisabledRule():
return $default(_that.profileId,_that.ruleId);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int profileId,  int ruleId)?  $default,) {final _that = this;
switch (_that) {
case _DisabledRule() when $default != null:
return $default(_that.profileId,_that.ruleId);case _:
  return null;

}
}

}

/// @nodoc


class _DisabledRule implements DisabledRule {
  const _DisabledRule({required this.profileId, required this.ruleId});
  

@override final  int profileId;
@override final  int ruleId;

/// Create a copy of DisabledRule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DisabledRuleCopyWith<_DisabledRule> get copyWith => __$DisabledRuleCopyWithImpl<_DisabledRule>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DisabledRule&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.ruleId, ruleId) || other.ruleId == ruleId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,profileId,ruleId);
}

@override
String toString() {
    return 'DisabledRule(profileId: $profileId, ruleId: $ruleId)';
}


}

/// @nodoc
abstract mixin class _$DisabledRuleCopyWith<$Res> implements $DisabledRuleCopyWith<$Res> {
  factory _$DisabledRuleCopyWith(_DisabledRule value, $Res Function(_DisabledRule) _then) = __$DisabledRuleCopyWithImpl;
@override @useResult
$Res call({
 int profileId, int ruleId
});




}
/// @nodoc
class __$DisabledRuleCopyWithImpl<$Res>
    implements _$DisabledRuleCopyWith<$Res> {
  __$DisabledRuleCopyWithImpl(this._self, this._then);

  final _DisabledRule _self;
  final $Res Function(_DisabledRule) _then;

/// Create a copy of DisabledRule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? profileId = null,Object? ruleId = null,}) {
  return _then(_DisabledRule(
profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as int,ruleId: null == ruleId ? _self.ruleId : ruleId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
