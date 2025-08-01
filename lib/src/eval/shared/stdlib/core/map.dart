part of 'collection.dart';

/// dart_eval bimodal wrapper for [Map]
class $Map<K, V> implements Map<K, V>, $Instance {
  /// Wrap a [Map] in a [$Map]
  $Map.wrap(this.$value);

  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc('dart:core', 'Map.from', __$Map$from.call);
    runtime.registerBridgeFunc(
        'dart:core', 'Map.fromEntries', __$Map$fromEntries.call);
  }

  static const $type = BridgeTypeRef(CoreTypes.map);

  static const $declaration = BridgeClassDef(
      BridgeClassType(
        $type,
        generics: {'K': BridgeGenericParam(), 'V': BridgeGenericParam()},
      ),
      constructors: {
        'from': BridgeConstructorDef(
          BridgeFunctionDef(
            returns: BridgeTypeAnnotation($type),
            params: [
              BridgeParameter(
                'other',
                BridgeTypeAnnotation($type, nullable: false),
                false,
              )
            ],
            generics: {'K': BridgeGenericParam(), 'V': BridgeGenericParam()},
          ),
          isFactory: true,
        ),
        'fromEntries': BridgeConstructorDef(
          BridgeFunctionDef(
            returns: BridgeTypeAnnotation($type),
            params: [
              BridgeParameter(
                'entries',
                BridgeTypeAnnotation(
                    BridgeTypeRef(CoreTypes.iterable, [
                      BridgeTypeRef(CoreTypes.mapEntry,
                          [BridgeTypeRef.ref('K'), BridgeTypeRef.ref('V')])
                    ]),
                    nullable: false),
                false,
              )
            ],
            generics: {'K': BridgeGenericParam(), 'V': BridgeGenericParam()},
          ),
          isFactory: true,
        ),
      },
      methods: {
        '[]': BridgeMethodDef(
            BridgeFunctionDef(params: [
              BridgeParameter(
                  'key', BridgeTypeAnnotation(BridgeTypeRef.ref('K')), false),
            ], returns: BridgeTypeAnnotation(BridgeTypeRef.ref('V'))),
            isStatic: false),
        '[]=': BridgeMethodDef(
            BridgeFunctionDef(params: [
              BridgeParameter(
                  'key', BridgeTypeAnnotation(BridgeTypeRef.ref('K')), false),
              BridgeParameter(
                  'value', BridgeTypeAnnotation(BridgeTypeRef.ref('V')), false),
            ], returns: BridgeTypeAnnotation(BridgeTypeRef.ref('V'))),
            isStatic: false),
        'length': BridgeMethodDef(
            BridgeFunctionDef(
                params: [],
                returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.int))),
            isStatic: false),
        'cast': BridgeMethodDef(
            BridgeFunctionDef(
                generics: {
                  'RK': BridgeGenericParam(),
                  'RV': BridgeGenericParam()
                },
                params: [],
                returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.map,
                    [BridgeTypeRef.ref('RK'), BridgeTypeRef.ref('RV')]))),
            isStatic: false),
        'addAll': BridgeMethodDef(
            BridgeFunctionDef(
                params: [
                  BridgeParameter(
                      'other',
                      BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.map,
                          [BridgeTypeRef.ref('K'), BridgeTypeRef.ref('V')])),
                      false),
                ],
                returns:
                    BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType))),
            isStatic: false),
        'containsKey': BridgeMethodDef(
          BridgeFunctionDef(params: [
            BridgeParameter(
                'key',
                BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.object),
                    nullable: true),
                false),
          ], returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool))),
          isStatic: false,
        ),
        'remove': BridgeMethodDef(
            BridgeFunctionDef(params: [
              BridgeParameter(
                  'key',
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.object),
                      nullable: true),
                  false),
            ], returns: BridgeTypeAnnotation(BridgeTypeRef.ref('V'))),
            isStatic: false),
        'putIfAbsent': BridgeMethodDef(
            BridgeFunctionDef(params: [
              BridgeParameter(
                  'key', BridgeTypeAnnotation(BridgeTypeRef.ref('K')), false),
              BridgeParameter(
                  'ifAbsent',
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.function)),
                  false),
            ], returns: BridgeTypeAnnotation(BridgeTypeRef.ref('V'))),
            isStatic: false),
      },
      getters: {
        'entries': BridgeMethodDef(BridgeFunctionDef(
            returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.iterable)))),
        'isEmpty': BridgeMethodDef(
            BridgeFunctionDef(
                params: [],
                returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool))),
            isStatic: false),
        'isNotEmpty': BridgeMethodDef(
            BridgeFunctionDef(
                params: [],
                returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool))),
            isStatic: false),
        'keys': BridgeMethodDef(
            BridgeFunctionDef(
                params: [],
                returns:
                    BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.iterable))),
            isStatic: false),
        'values': BridgeMethodDef(
            BridgeFunctionDef(
                params: [],
                returns:
                    BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.iterable))),
            isStatic: false),
      },
      setters: {},
      fields: {},
      wrap: true);

  @override
  final Map<K, V> $value;

  late final $Instance _superclass = $Object($value);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case '[]':
        return __indexGet;
      case '[]=':
        return __indexSet;
      case 'addAll':
        return __addAll;
      case 'cast':
        return __cast;
      case 'length':
        return $int($value.length);
      case 'containsKey':
        return __containsKey;
      case 'remove':
        return __remove;
      case 'putIfAbsent':
        return __putIfAbsent;
      case 'entries':
        return $Iterable.wrap(entries.map((e) => $MapEntry.wrap(e)));
      case 'isEmpty':
        return $bool($value.isEmpty);
      case 'isNotEmpty':
        return $bool($value.isNotEmpty);
      case 'keys':
        return $Iterable.wrap($value.keys);
      case 'values':
        return $Iterable.wrap($value.values);
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }

  static const __$Map$from = $Function(_$Map$from);
  static $Value? _$Map$from(
      Runtime runtime, $Value? target, List<$Value?> args) {
    final other = args[0]?.$value as Map;

    return $Map.wrap(Map.from(other));
  }

  static const __$Map$fromEntries = $Function(_$Map$fromEntries);
  static $Value? _$Map$fromEntries(
      Runtime runtime, $Value? target, List<$Value?> args) {
    final entries = args[0]?.$value as Iterable;
    final mapEntries = entries
        .map((e) => e is MapEntry ? e : (e as $Value).$value as MapEntry);

    return $Map.wrap(Map.fromEntries(mapEntries));
  }

  static const $Function __indexGet = $Function(indexGet);

  static $Value? indexGet(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final idx = args[0]!;
    final map = target!.$value as Map;
    dynamic v = map[idx];

    if (v == null) {
      v = map[idx.$reified];
    }

    if (v is $Value) {
      return v;
    } else {
      return runtime.wrap(v);
    }
  }

  static const $Function __indexSet = $Function(_indexSet);

  static $Value? _indexSet(
    Runtime runtime,
    $Value? target,
    List args,
  ) {
    var idx = args[0] ?? $null();
    var value = args[1] ?? $null();

    if (idx is! $Value) {
      idx = runtime.wrap(idx);
    }

    if (value is! $Value) {
      value = runtime.wrap(value);
    }

    return (target!.$value as Map)[idx] = value;
  }

  static const $Function __addAll = $Function(_addAll);

  static $Value? _addAll(Runtime runtime, $Value? target, List<$Value?> args) {
    final other = args[0]!;
    (target!.$value as Map).addAll(other.$value);
    return null;
  }

  static const $Function __cast = $Function(_cast);

  static $Value? _cast(Runtime runtime, $Value? target, List<$Value?> args) {
    return target;
  }

  static const $Function __containsKey = $Function(_containsKey);

  static $Value? _containsKey(
      Runtime runtime, $Value? target, List<$Value?> args) {
    return $bool((target!.$value as Map).containsKey(args[0]));
  }

  static const $Function __remove = $Function(_remove);

  static $Value? _remove(Runtime runtime, $Value? target, List<$Value?> args) {
    return (target!.$value as Map).remove(args[0]);
  }

  static const $Function __putIfAbsent = $Function(_putIfAbsent);

  static $Value? _putIfAbsent(
      Runtime runtime, $Value? target, List<$Value?> args) {
    final key = args[0];
    final ifAbsent = args[1] as EvalCallable;
    final map = target!.$value as Map;

    final result =
        map.putIfAbsent(key, () => ifAbsent.call(runtime, null, [])!);

    // Make sure the result is properly wrapped for dart_eval
    if (result is $Value) {
      return result;
    } else {
      return runtime.wrap(result);
    }
  }

  @override
  Map get $reified => $value.map((k, v) =>
      MapEntry(k is $Value ? k.$reified : k, v is $Value ? v.$reified : v));

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType(CoreTypes.map);

  @override
  V? operator [](Object? key) {
    final dynamic _key = key is $Value ? key.$reified : key;
    dynamic v = $value[_key];

    if (v is $Value) {
      return v as V?;
    } else {
      // v = runtime.wrap(v);
    }

    return v;
  }

  @override
  void operator []=(K key, V value) {
    $value[key] = value;
  }

  @override
  void addAll(Map<K, V> other) => $value.addAll(other);

  @override
  void addEntries(Iterable<MapEntry<K, V>> newEntries) =>
      $value.addEntries(newEntries);

  @override
  Map<RK, RV> cast<RK, RV>() => $value.cast<RK, RV>();

  @override
  void clear() {
    return $value.clear();
  }

  @override
  bool containsKey(Object? key) {
    return $value.containsKey(key);
  }

  @override
  bool containsValue(Object? value) {
    return $value.containsValue(value);
  }

  @override
  Iterable<MapEntry<K, V>> get entries => $value.entries;

  @override
  void forEach(void Function(K key, V value) action) {
    return $value.forEach(action);
  }

  @override
  bool get isEmpty => $value.isEmpty;

  @override
  bool get isNotEmpty => $value.isNotEmpty;

  @override
  Iterable<K> get keys => $value.keys;

  @override
  int get length => $value.length;

  @override
  Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> Function(K key, V value) convert) {
    return $value.map(convert);
  }

  @override
  V putIfAbsent(K key, V Function() ifAbsent) {
    return $value.putIfAbsent(key, ifAbsent);
  }

  @override
  V? remove(Object? key) => $value.remove(key);

  @override
  void removeWhere(bool Function(K key, V value) test) =>
      $value.removeWhere(test);

  @override
  V update(K key, V Function(V value) update, {V Function()? ifAbsent}) =>
      $value.update(key, update, ifAbsent: ifAbsent);

  @override
  void updateAll(V Function(K key, V value) update) => $value.updateAll(update);

  @override
  Iterable<V> get values => $value.values;
}

extension $MapExt<K, V> on Map<K, V>? {
  $Map<K, V>? get toEval {
    if (this == null) {
      return null;
    }

    return $Map<K, V>.wrap(this!);
  }
}

/// dart_eval bimodal wrapper for [MapEntry]
class $MapEntry<K, V> implements MapEntry<K, V>, $Instance {
  /// Wrap a [MapEntry] in a [$MapEntry]
  $MapEntry.wrap(this.$value);

  static void configureForRuntime(Runtime runtime) {
    return runtime.registerBridgeFunc('dart:core', 'MapEntry.', _$new.call);
  }

  static const $declaration = BridgeClassDef(
      BridgeClassType(BridgeTypeRef(CoreTypes.mapEntry),
          generics: {'K': BridgeGenericParam(), 'V': BridgeGenericParam()}),
      constructors: {
        '': BridgeConstructorDef(BridgeFunctionDef(
            returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.mapEntry)),
            params: [
              BridgeParameter(
                  'key', BridgeTypeAnnotation(BridgeTypeRef.ref('K')), false),
              BridgeParameter(
                  'value', BridgeTypeAnnotation(BridgeTypeRef.ref('V')), false),
            ],
            generics: {
              'K': BridgeGenericParam(),
              'V': BridgeGenericParam()
            }))
      },
      getters: {},
      setters: {},
      fields: {
        'key': BridgeFieldDef(BridgeTypeAnnotation(BridgeTypeRef.ref('K'))),
        'value': BridgeFieldDef(BridgeTypeAnnotation(BridgeTypeRef.ref('V'))),
      },
      wrap: true);

  @override
  final MapEntry<K, V> $value;

  late final $Instance _superclass = $Object($value);

  static $Value? _$new(
      final Runtime runtime, final $Value? target, final List<$Value?> args) {
    return $MapEntry.wrap(MapEntry(args[0], args[1]));
  }

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'key':
        return key as $Value?;
      case 'value':
        return value as $Value?;
      default:
        return _superclass.$getProperty(runtime, identifier);
    }
  }

  @override
  int $getRuntimeType(Runtime runtime) =>
      runtime.lookupType(CoreTypes.mapEntry);

  @override
  MapEntry<K, V> get $reified => $value;

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    _superclass.$setProperty(runtime, identifier, value);
  }

  @override
  K get key => $value.key;

  @override
  V get value => $value.value;
}
