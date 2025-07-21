part of 'collection.dart';

/// dart_eval bimodal wrapper for [Set]
class $Set<E> implements Set<E>, $Instance {
  /// Wrap a [Set] in a [$Set]
  $Set.wrap(this.$value);

  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc('dart:core', 'Set.from', __$Set$from.call);
    runtime.registerBridgeFunc(
        'dart:core', 'Set.fromIterable', __$Set$fromIterable.call);
    runtime.registerBridgeFunc('dart:core', 'Set.of', __$Set$of.call);
    runtime.registerBridgeFunc(
        'dart:core', 'Set.identity', __$Set$identity.call);
  }

  static const $type = BridgeTypeRef(CoreTypes.set);

  static const $declaration = BridgeClassDef(
      BridgeClassType(
        $type,
        $extends: BridgeTypeRef(CoreTypes.iterable),
        generics: {'E': BridgeGenericParam()},
      ),
      constructors: {
        'from': BridgeConstructorDef(
          BridgeFunctionDef(
            returns: BridgeTypeAnnotation($type),
            params: [
              BridgeParameter(
                'elements',
                BridgeTypeAnnotation(
                    BridgeTypeRef(CoreTypes.iterable, [BridgeTypeRef.ref('E')]),
                    nullable: false),
                false,
              )
            ],
            generics: {'E': BridgeGenericParam()},
          ),
          isFactory: true,
        ),
        'fromIterable': BridgeConstructorDef(
          BridgeFunctionDef(
            returns: BridgeTypeAnnotation($type),
            params: [
              BridgeParameter(
                'elements',
                BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.iterable),
                    nullable: false),
                false,
              )
            ],
            namedParams: [
              BridgeParameter(
                'transform',
                BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.function),
                    nullable: true),
                true,
              )
            ],
            generics: {'E': BridgeGenericParam()},
          ),
          isFactory: true,
        ),
        'of': BridgeConstructorDef(
          BridgeFunctionDef(
            returns: BridgeTypeAnnotation($type),
            params: [
              BridgeParameter(
                'elements',
                BridgeTypeAnnotation(
                    BridgeTypeRef(CoreTypes.iterable, [BridgeTypeRef.ref('E')]),
                    nullable: false),
                false,
              )
            ],
            generics: {'E': BridgeGenericParam()},
          ),
          isFactory: true,
        ),
        'identity': BridgeConstructorDef(
          BridgeFunctionDef(
            returns: BridgeTypeAnnotation($type),
            params: [],
            generics: {'E': BridgeGenericParam()},
          ),
          isFactory: true,
        ),
      },
      methods: {
        'add': BridgeMethodDef(
            BridgeFunctionDef(params: [
              BridgeParameter(
                  'value', BridgeTypeAnnotation(BridgeTypeRef.ref('E')), false),
            ], returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool))),
            isStatic: false),
        'addAll': BridgeMethodDef(
            BridgeFunctionDef(
                params: [
                  BridgeParameter(
                      'elements',
                      BridgeTypeAnnotation(BridgeTypeRef(
                          CoreTypes.iterable, [BridgeTypeRef.ref('E')])),
                      false),
                ],
                returns:
                    BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType))),
            isStatic: false),
        'remove': BridgeMethodDef(
            BridgeFunctionDef(params: [
              BridgeParameter(
                  'value',
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.object),
                      nullable: true),
                  false),
            ], returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool))),
            isStatic: false),
        'removeAll': BridgeMethodDef(
            BridgeFunctionDef(
                params: [
                  BridgeParameter(
                      'elements',
                      BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.iterable)),
                      false),
                ],
                returns:
                    BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType))),
            isStatic: false),
        'clear': BridgeMethodDef(
            BridgeFunctionDef(
                params: [],
                returns:
                    BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType))),
            isStatic: false),
        'contains': BridgeMethodDef(
          BridgeFunctionDef(params: [
            BridgeParameter(
                'element',
                BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.object),
                    nullable: true),
                false),
          ], returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool))),
          isStatic: false,
        ),
        'union': BridgeMethodDef(
            BridgeFunctionDef(
                params: [
                  BridgeParameter(
                      'other',
                      BridgeTypeAnnotation(BridgeTypeRef(
                          CoreTypes.set, [BridgeTypeRef.ref('E')])),
                      false),
                ],
                returns: BridgeTypeAnnotation(
                    BridgeTypeRef(CoreTypes.set, [BridgeTypeRef.ref('E')]))),
            isStatic: false),
        'intersection': BridgeMethodDef(
            BridgeFunctionDef(
                params: [
                  BridgeParameter(
                      'other',
                      BridgeTypeAnnotation(BridgeTypeRef(
                          CoreTypes.set, [BridgeTypeRef.ref('E')])),
                      false),
                ],
                returns: BridgeTypeAnnotation(
                    BridgeTypeRef(CoreTypes.set, [BridgeTypeRef.ref('E')]))),
            isStatic: false),
        'difference': BridgeMethodDef(
            BridgeFunctionDef(
                params: [
                  BridgeParameter(
                      'other',
                      BridgeTypeAnnotation(BridgeTypeRef(
                          CoreTypes.set, [BridgeTypeRef.ref('E')])),
                      false),
                ],
                returns: BridgeTypeAnnotation(
                    BridgeTypeRef(CoreTypes.set, [BridgeTypeRef.ref('E')]))),
            isStatic: false),
      },
      getters: {
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
        'length': BridgeMethodDef(
            BridgeFunctionDef(
                params: [],
                returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.int))),
            isStatic: false),
      },
      setters: {},
      fields: {},
      wrap: true);

  @override
  final Set<E> $value;

  late final $Instance _superclass = $Iterable.wrap($value);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'add':
        return __add;
      case 'addAll':
        return __addAll;
      case 'remove':
        return __remove;
      case 'removeAll':
        return __removeAll;
      case 'clear':
        return __clear;
      case 'contains':
        return __contains;
      case 'union':
        return __union;
      case 'intersection':
        return __intersection;
      case 'difference':
        return __difference;
      case 'isEmpty':
        return $bool($value.isEmpty);
      case 'isNotEmpty':
        return $bool($value.isNotEmpty);
      case 'length':
        return $int($value.length);
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }

  static const __$Set$from = $Function(_$Set$from);
  static $Value? _$Set$from(
      Runtime runtime, $Value? target, List<$Value?> args) {
    final elements = args[0]?.$value as Iterable;
    return $Set.wrap(Set.from(elements));
  }

  static const __$Set$fromIterable = $Function(_$Set$fromIterable);
  static $Value? _$Set$fromIterable(
      Runtime runtime, $Value? target, List<$Value?> args) {
    final elements = args[0]?.$value as Iterable;
    final transform = args[1] as EvalCallable?;

    if (transform != null) {
      final transformedElements =
          elements.map((e) => transform.call(runtime, null, [e]));
      return $Set.wrap(Set.from(transformedElements));
    } else {
      return $Set.wrap(Set.from(elements));
    }
  }

  static const __$Set$of = $Function(_$Set$of);
  static $Value? _$Set$of(Runtime runtime, $Value? target, List<$Value?> args) {
    final elements = args[0]?.$value as Iterable;
    return $Set.wrap(Set.of(elements));
  }

  static const __$Set$identity = $Function(_$Set$identity);
  static $Value? _$Set$identity(
      Runtime runtime, $Value? target, List<$Value?> args) {
    return $Set.wrap(Set.identity());
  }

  static const $Function __add = $Function(_add);
  static $Value? _add(Runtime runtime, $Value? target, List<$Value?> args) {
    final value = args[0]!;
    final result = (target!.$value as Set).add(value);
    return $bool(result);
  }

  static const $Function __addAll = $Function(_addAll);
  static $Value? _addAll(Runtime runtime, $Value? target, List<$Value?> args) {
    final elements = args[0]!.$value as Iterable;
    (target!.$value as Set).addAll(elements);
    return null;
  }

  static const $Function __remove = $Function(_remove);
  static $Value? _remove(Runtime runtime, $Value? target, List<$Value?> args) {
    final value = args[0];
    final result = (target!.$value as Set).remove(value);
    return $bool(result);
  }

  static const $Function __removeAll = $Function(_removeAll);
  static $Value? _removeAll(
      Runtime runtime, $Value? target, List<$Value?> args) {
    final elements = args[0]!.$value as Iterable;
    (target!.$value as Set).removeAll(elements);
    return null;
  }

  static const $Function __clear = $Function(_clear);
  static $Value? _clear(Runtime runtime, $Value? target, List<$Value?> args) {
    (target!.$value as Set).clear();
    return null;
  }

  static const $Function __contains = $Function(_contains);
  static $Value? _contains(
      Runtime runtime, $Value? target, List<$Value?> args) {
    final element = args[0];
    final result = (target!.$value as Set).contains(element);
    return $bool(result);
  }

  static const $Function __union = $Function(_union);
  static $Value? _union(Runtime runtime, $Value? target, List<$Value?> args) {
    final other = args[0]!.$value as Set;
    final result = (target!.$value as Set).union(other);
    return $Set.wrap(result);
  }

  static const $Function __intersection = $Function(_intersection);
  static $Value? _intersection(
      Runtime runtime, $Value? target, List<$Value?> args) {
    final other = args[0]!.$value as Set;
    final result = (target!.$value as Set).intersection(other);
    return $Set.wrap(result);
  }

  static const $Function __difference = $Function(_difference);
  static $Value? _difference(
      Runtime runtime, $Value? target, List<$Value?> args) {
    final other = args[0]!.$value as Set;
    final result = (target!.$value as Set).difference(other);
    return $Set.wrap(result);
  }

  @override
  Set get $reified => $value.map((e) => e is $Value ? e.$reified : e).toSet();

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType(CoreTypes.set);

  @override
  bool add(E value) => $value.add(value);

  @override
  void addAll(Iterable<E> elements) => $value.addAll(elements);

  @override
  Set<T> cast<T>() => $value.cast<T>();

  @override
  void clear() => $value.clear();

  @override
  bool contains(Object? element) => $value.contains(element);

  @override
  bool containsAll(Iterable<Object?> other) => $value.containsAll(other);

  @override
  Set<E> difference(Set<Object?> other) => $value.difference(other);

  @override
  Set<E> intersection(Set<Object?> other) => $value.intersection(other);

  @override
  E? lookup(Object? object) => $value.lookup(object);

  @override
  bool remove(Object? value) => $value.remove(value);

  @override
  void removeAll(Iterable<Object?> elements) => $value.removeAll(elements);

  @override
  void removeWhere(bool Function(E element) test) => $value.removeWhere(test);

  @override
  void retainAll(Iterable<Object?> elements) => $value.retainAll(elements);

  @override
  void retainWhere(bool Function(E element) test) => $value.retainWhere(test);

  @override
  Set<E> union(Set<E> other) => $value.union(other);

  @override
  Set<E> toSet() => $value.toSet();

  // Inherited from Iterable
  @override
  bool any(bool Function(E element) test) => $value.any(test);

  @override
  E elementAt(int index) => $value.elementAt(index);

  @override
  bool every(bool Function(E element) test) => $value.every(test);

  @override
  Iterable<T> expand<T>(Iterable<T> Function(E element) toElements) =>
      $value.expand(toElements);

  @override
  E get first => $value.first;

  @override
  E firstWhere(bool Function(E element) test, {E Function()? orElse}) =>
      $value.firstWhere(test, orElse: orElse);

  @override
  T fold<T>(T initialValue, T Function(T previousValue, E element) combine) =>
      $value.fold(initialValue, combine);

  @override
  Iterable<E> followedBy(Iterable<E> other) => $value.followedBy(other);

  @override
  void forEach(void Function(E element) action) => $value.forEach(action);

  @override
  bool get isEmpty => $value.isEmpty;

  @override
  bool get isNotEmpty => $value.isNotEmpty;

  @override
  Iterator<E> get iterator => $value.iterator;

  @override
  String join([String separator = ""]) => $value.join(separator);

  @override
  E get last => $value.last;

  @override
  E lastWhere(bool Function(E element) test, {E Function()? orElse}) =>
      $value.lastWhere(test, orElse: orElse);

  @override
  int get length => $value.length;

  @override
  Iterable<T> map<T>(T Function(E e) toElement) => $value.map(toElement);

  @override
  E reduce(E Function(E value, E element) combine) => $value.reduce(combine);

  @override
  E get single => $value.single;

  @override
  E singleWhere(bool Function(E element) test, {E Function()? orElse}) =>
      $value.singleWhere(test, orElse: orElse);

  @override
  Iterable<E> skip(int count) => $value.skip(count);

  @override
  Iterable<E> skipWhile(bool Function(E value) test) => $value.skipWhile(test);

  @override
  Iterable<E> take(int count) => $value.take(count);

  @override
  Iterable<E> takeWhile(bool Function(E value) test) => $value.takeWhile(test);

  @override
  List<E> toList({bool growable = true}) => $value.toList(growable: growable);

  @override
  Iterable<E> where(bool Function(E element) test) => $value.where(test);

  @override
  Iterable<T> whereType<T>() => $value.whereType<T>();
}

extension $SetExt<E> on Set<E>? {
  $Set<E>? get toEval {
    if (this == null) {
      return null;
    }

    return $Set<E>.wrap(this!);
  }
}
