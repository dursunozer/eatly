// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vision_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VisionLabel {

 String get description; double get score;
/// Create a copy of VisionLabel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VisionLabelCopyWith<VisionLabel> get copyWith => _$VisionLabelCopyWithImpl<VisionLabel>(this as VisionLabel, _$identity);

  /// Serializes this VisionLabel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VisionLabel&&(identical(other.description, description) || other.description == description)&&(identical(other.score, score) || other.score == score));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,description,score);

@override
String toString() {
  return 'VisionLabel(description: $description, score: $score)';
}


}

/// @nodoc
abstract mixin class $VisionLabelCopyWith<$Res>  {
  factory $VisionLabelCopyWith(VisionLabel value, $Res Function(VisionLabel) _then) = _$VisionLabelCopyWithImpl;
@useResult
$Res call({
 String description, double score
});




}
/// @nodoc
class _$VisionLabelCopyWithImpl<$Res>
    implements $VisionLabelCopyWith<$Res> {
  _$VisionLabelCopyWithImpl(this._self, this._then);

  final VisionLabel _self;
  final $Res Function(VisionLabel) _then;

/// Create a copy of VisionLabel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? description = null,Object? score = null,}) {
  return _then(_self.copyWith(
description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [VisionLabel].
extension VisionLabelPatterns on VisionLabel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VisionLabel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VisionLabel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VisionLabel value)  $default,){
final _that = this;
switch (_that) {
case _VisionLabel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VisionLabel value)?  $default,){
final _that = this;
switch (_that) {
case _VisionLabel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String description,  double score)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VisionLabel() when $default != null:
return $default(_that.description,_that.score);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String description,  double score)  $default,) {final _that = this;
switch (_that) {
case _VisionLabel():
return $default(_that.description,_that.score);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String description,  double score)?  $default,) {final _that = this;
switch (_that) {
case _VisionLabel() when $default != null:
return $default(_that.description,_that.score);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VisionLabel implements VisionLabel {
  const _VisionLabel({this.description = '', this.score = 0.0});
  factory _VisionLabel.fromJson(Map<String, dynamic> json) => _$VisionLabelFromJson(json);

@override@JsonKey() final  String description;
@override@JsonKey() final  double score;

/// Create a copy of VisionLabel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VisionLabelCopyWith<_VisionLabel> get copyWith => __$VisionLabelCopyWithImpl<_VisionLabel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VisionLabelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VisionLabel&&(identical(other.description, description) || other.description == description)&&(identical(other.score, score) || other.score == score));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,description,score);

@override
String toString() {
  return 'VisionLabel(description: $description, score: $score)';
}


}

/// @nodoc
abstract mixin class _$VisionLabelCopyWith<$Res> implements $VisionLabelCopyWith<$Res> {
  factory _$VisionLabelCopyWith(_VisionLabel value, $Res Function(_VisionLabel) _then) = __$VisionLabelCopyWithImpl;
@override @useResult
$Res call({
 String description, double score
});




}
/// @nodoc
class __$VisionLabelCopyWithImpl<$Res>
    implements _$VisionLabelCopyWith<$Res> {
  __$VisionLabelCopyWithImpl(this._self, this._then);

  final _VisionLabel _self;
  final $Res Function(_VisionLabel) _then;

/// Create a copy of VisionLabel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? description = null,Object? score = null,}) {
  return _then(_VisionLabel(
description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$NormalizedVertex {

 double get x; double get y;
/// Create a copy of NormalizedVertex
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NormalizedVertexCopyWith<NormalizedVertex> get copyWith => _$NormalizedVertexCopyWithImpl<NormalizedVertex>(this as NormalizedVertex, _$identity);

  /// Serializes this NormalizedVertex to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NormalizedVertex&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,x,y);

@override
String toString() {
  return 'NormalizedVertex(x: $x, y: $y)';
}


}

/// @nodoc
abstract mixin class $NormalizedVertexCopyWith<$Res>  {
  factory $NormalizedVertexCopyWith(NormalizedVertex value, $Res Function(NormalizedVertex) _then) = _$NormalizedVertexCopyWithImpl;
@useResult
$Res call({
 double x, double y
});




}
/// @nodoc
class _$NormalizedVertexCopyWithImpl<$Res>
    implements $NormalizedVertexCopyWith<$Res> {
  _$NormalizedVertexCopyWithImpl(this._self, this._then);

  final NormalizedVertex _self;
  final $Res Function(NormalizedVertex) _then;

/// Create a copy of NormalizedVertex
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? x = null,Object? y = null,}) {
  return _then(_self.copyWith(
x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [NormalizedVertex].
extension NormalizedVertexPatterns on NormalizedVertex {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NormalizedVertex value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NormalizedVertex() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NormalizedVertex value)  $default,){
final _that = this;
switch (_that) {
case _NormalizedVertex():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NormalizedVertex value)?  $default,){
final _that = this;
switch (_that) {
case _NormalizedVertex() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double x,  double y)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NormalizedVertex() when $default != null:
return $default(_that.x,_that.y);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double x,  double y)  $default,) {final _that = this;
switch (_that) {
case _NormalizedVertex():
return $default(_that.x,_that.y);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double x,  double y)?  $default,) {final _that = this;
switch (_that) {
case _NormalizedVertex() when $default != null:
return $default(_that.x,_that.y);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NormalizedVertex implements NormalizedVertex {
  const _NormalizedVertex({this.x = 0.0, this.y = 0.0});
  factory _NormalizedVertex.fromJson(Map<String, dynamic> json) => _$NormalizedVertexFromJson(json);

@override@JsonKey() final  double x;
@override@JsonKey() final  double y;

/// Create a copy of NormalizedVertex
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NormalizedVertexCopyWith<_NormalizedVertex> get copyWith => __$NormalizedVertexCopyWithImpl<_NormalizedVertex>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NormalizedVertexToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NormalizedVertex&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,x,y);

@override
String toString() {
  return 'NormalizedVertex(x: $x, y: $y)';
}


}

/// @nodoc
abstract mixin class _$NormalizedVertexCopyWith<$Res> implements $NormalizedVertexCopyWith<$Res> {
  factory _$NormalizedVertexCopyWith(_NormalizedVertex value, $Res Function(_NormalizedVertex) _then) = __$NormalizedVertexCopyWithImpl;
@override @useResult
$Res call({
 double x, double y
});




}
/// @nodoc
class __$NormalizedVertexCopyWithImpl<$Res>
    implements _$NormalizedVertexCopyWith<$Res> {
  __$NormalizedVertexCopyWithImpl(this._self, this._then);

  final _NormalizedVertex _self;
  final $Res Function(_NormalizedVertex) _then;

/// Create a copy of NormalizedVertex
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? x = null,Object? y = null,}) {
  return _then(_NormalizedVertex(
x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$VisionObject {

 String get name; double get score; List<NormalizedVertex> get polygon;
/// Create a copy of VisionObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VisionObjectCopyWith<VisionObject> get copyWith => _$VisionObjectCopyWithImpl<VisionObject>(this as VisionObject, _$identity);

  /// Serializes this VisionObject to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VisionObject&&(identical(other.name, name) || other.name == name)&&(identical(other.score, score) || other.score == score)&&const DeepCollectionEquality().equals(other.polygon, polygon));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,score,const DeepCollectionEquality().hash(polygon));

@override
String toString() {
  return 'VisionObject(name: $name, score: $score, polygon: $polygon)';
}


}

/// @nodoc
abstract mixin class $VisionObjectCopyWith<$Res>  {
  factory $VisionObjectCopyWith(VisionObject value, $Res Function(VisionObject) _then) = _$VisionObjectCopyWithImpl;
@useResult
$Res call({
 String name, double score, List<NormalizedVertex> polygon
});




}
/// @nodoc
class _$VisionObjectCopyWithImpl<$Res>
    implements $VisionObjectCopyWith<$Res> {
  _$VisionObjectCopyWithImpl(this._self, this._then);

  final VisionObject _self;
  final $Res Function(VisionObject) _then;

/// Create a copy of VisionObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? score = null,Object? polygon = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,polygon: null == polygon ? _self.polygon : polygon // ignore: cast_nullable_to_non_nullable
as List<NormalizedVertex>,
  ));
}

}


/// Adds pattern-matching-related methods to [VisionObject].
extension VisionObjectPatterns on VisionObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VisionObject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VisionObject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VisionObject value)  $default,){
final _that = this;
switch (_that) {
case _VisionObject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VisionObject value)?  $default,){
final _that = this;
switch (_that) {
case _VisionObject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  double score,  List<NormalizedVertex> polygon)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VisionObject() when $default != null:
return $default(_that.name,_that.score,_that.polygon);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  double score,  List<NormalizedVertex> polygon)  $default,) {final _that = this;
switch (_that) {
case _VisionObject():
return $default(_that.name,_that.score,_that.polygon);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  double score,  List<NormalizedVertex> polygon)?  $default,) {final _that = this;
switch (_that) {
case _VisionObject() when $default != null:
return $default(_that.name,_that.score,_that.polygon);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VisionObject implements VisionObject {
  const _VisionObject({this.name = '', this.score = 0.0, final  List<NormalizedVertex> polygon = const <NormalizedVertex>[]}): _polygon = polygon;
  factory _VisionObject.fromJson(Map<String, dynamic> json) => _$VisionObjectFromJson(json);

@override@JsonKey() final  String name;
@override@JsonKey() final  double score;
 final  List<NormalizedVertex> _polygon;
@override@JsonKey() List<NormalizedVertex> get polygon {
  if (_polygon is EqualUnmodifiableListView) return _polygon;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_polygon);
}


/// Create a copy of VisionObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VisionObjectCopyWith<_VisionObject> get copyWith => __$VisionObjectCopyWithImpl<_VisionObject>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VisionObjectToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VisionObject&&(identical(other.name, name) || other.name == name)&&(identical(other.score, score) || other.score == score)&&const DeepCollectionEquality().equals(other._polygon, _polygon));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,score,const DeepCollectionEquality().hash(_polygon));

@override
String toString() {
  return 'VisionObject(name: $name, score: $score, polygon: $polygon)';
}


}

/// @nodoc
abstract mixin class _$VisionObjectCopyWith<$Res> implements $VisionObjectCopyWith<$Res> {
  factory _$VisionObjectCopyWith(_VisionObject value, $Res Function(_VisionObject) _then) = __$VisionObjectCopyWithImpl;
@override @useResult
$Res call({
 String name, double score, List<NormalizedVertex> polygon
});




}
/// @nodoc
class __$VisionObjectCopyWithImpl<$Res>
    implements _$VisionObjectCopyWith<$Res> {
  __$VisionObjectCopyWithImpl(this._self, this._then);

  final _VisionObject _self;
  final $Res Function(_VisionObject) _then;

/// Create a copy of VisionObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? score = null,Object? polygon = null,}) {
  return _then(_VisionObject(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,polygon: null == polygon ? _self._polygon : polygon // ignore: cast_nullable_to_non_nullable
as List<NormalizedVertex>,
  ));
}


}


/// @nodoc
mixin _$VisionResult {

 List<VisionLabel> get labels; List<VisionObject> get objects;
/// Create a copy of VisionResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VisionResultCopyWith<VisionResult> get copyWith => _$VisionResultCopyWithImpl<VisionResult>(this as VisionResult, _$identity);

  /// Serializes this VisionResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VisionResult&&const DeepCollectionEquality().equals(other.labels, labels)&&const DeepCollectionEquality().equals(other.objects, objects));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(labels),const DeepCollectionEquality().hash(objects));

@override
String toString() {
  return 'VisionResult(labels: $labels, objects: $objects)';
}


}

/// @nodoc
abstract mixin class $VisionResultCopyWith<$Res>  {
  factory $VisionResultCopyWith(VisionResult value, $Res Function(VisionResult) _then) = _$VisionResultCopyWithImpl;
@useResult
$Res call({
 List<VisionLabel> labels, List<VisionObject> objects
});




}
/// @nodoc
class _$VisionResultCopyWithImpl<$Res>
    implements $VisionResultCopyWith<$Res> {
  _$VisionResultCopyWithImpl(this._self, this._then);

  final VisionResult _self;
  final $Res Function(VisionResult) _then;

/// Create a copy of VisionResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? labels = null,Object? objects = null,}) {
  return _then(_self.copyWith(
labels: null == labels ? _self.labels : labels // ignore: cast_nullable_to_non_nullable
as List<VisionLabel>,objects: null == objects ? _self.objects : objects // ignore: cast_nullable_to_non_nullable
as List<VisionObject>,
  ));
}

}


/// Adds pattern-matching-related methods to [VisionResult].
extension VisionResultPatterns on VisionResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VisionResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VisionResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VisionResult value)  $default,){
final _that = this;
switch (_that) {
case _VisionResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VisionResult value)?  $default,){
final _that = this;
switch (_that) {
case _VisionResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<VisionLabel> labels,  List<VisionObject> objects)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VisionResult() when $default != null:
return $default(_that.labels,_that.objects);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<VisionLabel> labels,  List<VisionObject> objects)  $default,) {final _that = this;
switch (_that) {
case _VisionResult():
return $default(_that.labels,_that.objects);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<VisionLabel> labels,  List<VisionObject> objects)?  $default,) {final _that = this;
switch (_that) {
case _VisionResult() when $default != null:
return $default(_that.labels,_that.objects);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VisionResult implements VisionResult {
  const _VisionResult({final  List<VisionLabel> labels = const <VisionLabel>[], final  List<VisionObject> objects = const <VisionObject>[]}): _labels = labels,_objects = objects;
  factory _VisionResult.fromJson(Map<String, dynamic> json) => _$VisionResultFromJson(json);

 final  List<VisionLabel> _labels;
@override@JsonKey() List<VisionLabel> get labels {
  if (_labels is EqualUnmodifiableListView) return _labels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_labels);
}

 final  List<VisionObject> _objects;
@override@JsonKey() List<VisionObject> get objects {
  if (_objects is EqualUnmodifiableListView) return _objects;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_objects);
}


/// Create a copy of VisionResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VisionResultCopyWith<_VisionResult> get copyWith => __$VisionResultCopyWithImpl<_VisionResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VisionResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VisionResult&&const DeepCollectionEquality().equals(other._labels, _labels)&&const DeepCollectionEquality().equals(other._objects, _objects));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_labels),const DeepCollectionEquality().hash(_objects));

@override
String toString() {
  return 'VisionResult(labels: $labels, objects: $objects)';
}


}

/// @nodoc
abstract mixin class _$VisionResultCopyWith<$Res> implements $VisionResultCopyWith<$Res> {
  factory _$VisionResultCopyWith(_VisionResult value, $Res Function(_VisionResult) _then) = __$VisionResultCopyWithImpl;
@override @useResult
$Res call({
 List<VisionLabel> labels, List<VisionObject> objects
});




}
/// @nodoc
class __$VisionResultCopyWithImpl<$Res>
    implements _$VisionResultCopyWith<$Res> {
  __$VisionResultCopyWithImpl(this._self, this._then);

  final _VisionResult _self;
  final $Res Function(_VisionResult) _then;

/// Create a copy of VisionResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? labels = null,Object? objects = null,}) {
  return _then(_VisionResult(
labels: null == labels ? _self._labels : labels // ignore: cast_nullable_to_non_nullable
as List<VisionLabel>,objects: null == objects ? _self._objects : objects // ignore: cast_nullable_to_non_nullable
as List<VisionObject>,
  ));
}


}

// dart format on
