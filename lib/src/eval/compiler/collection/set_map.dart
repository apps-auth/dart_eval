import 'package:analyzer/dart/ast/ast.dart';
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:dart_eval/src/eval/compiler/context.dart';
import 'package:dart_eval/src/eval/compiler/errors.dart';
import 'package:dart_eval/src/eval/compiler/expression/expression.dart';
import 'package:dart_eval/src/eval/compiler/type.dart';
import 'package:dart_eval/src/eval/compiler/util.dart';
import 'package:dart_eval/src/eval/compiler/variable.dart';
import 'package:dart_eval/src/eval/runtime/runtime.dart';

const _boxSetOrMapElements = true;

Variable compileSetOrMapLiteral(SetOrMapLiteral l, CompilerContext ctx) {
  TypeRef? specifiedKeyType, specifiedValueType;
  bool isSet = false;
  final typeArgs = l.typeArguments;
  if (typeArgs != null) {
    final argCount = typeArgs.arguments.length;
    if (argCount == 1) {
      // Set literal
      isSet = true;
      specifiedKeyType =
          TypeRef.fromAnnotation(ctx, ctx.library, typeArgs.arguments[0]);
    } else if (argCount == 2) {
      // Map literal
      specifiedKeyType =
          TypeRef.fromAnnotation(ctx, ctx.library, typeArgs.arguments[0]);
      specifiedValueType =
          TypeRef.fromAnnotation(ctx, ctx.library, typeArgs.arguments[1]);
    }
  }

  Variable? _collection;

  final elements = l.elements;

  // If no type arguments specified, try to infer from elements
  if (!isSet && typeArgs == null && elements.isNotEmpty) {
    // If all elements are expressions (not MapLiteralEntry), it's a Set
    isSet = elements.every((e) => e is Expression);
  }

  ctx.beginAllocScope();
  final keyResultTypes = <TypeRef>[];
  final valueResultTypes = <TypeRef>[];
  for (final e in elements) {
    final _result = compileSetOrMapElement(e, _collection, ctx,
        specifiedKeyType, specifiedValueType, _boxSetOrMapElements);
    _collection = _result.first;
    keyResultTypes.addAll(_result.second.map((e) => e.first));
    valueResultTypes.addAll(_result.second.map((e) => e.second));
  }
  var isEmpty = false;
  if (_collection == null) {
    isEmpty = true;
    if (isSet || (specifiedValueType == null && specifiedKeyType != null)) {
      // Create Set using PushSet operation
      ctx.pushOp(PushSet.make(), PushSet.LEN);
      _collection = Variable.alloc(
          ctx,
          CoreTypes.set.ref(ctx).copyWith(specifiedTypeArgs: [
            specifiedKeyType ?? CoreTypes.dynamic.ref(ctx),
          ], boxed: false));
    } else {
      // make an empty Map
      ctx.pushOp(PushMap.make(), PushMap.LEN);
      _collection = Variable.alloc(
          ctx,
          CoreTypes.map.ref(ctx).copyWith(specifiedTypeArgs: [
            specifiedKeyType ?? CoreTypes.dynamic.ref(ctx),
            specifiedValueType ?? CoreTypes.dynamic.ref(ctx),
          ], boxed: false));
    }
  }
  ctx.endAllocScope(popAdjust: -1);
  ctx.scopeFrameOffset++;
  ctx.allocNest.last++;

  // Always handle type inference correctly for both empty and non-empty collections
  if (isSet || (specifiedValueType == null && specifiedKeyType != null)) {
    // For Set literals, we only have one type argument
    final inferredKeyType = isEmpty
        ? (specifiedKeyType ?? CoreTypes.dynamic.ref(ctx))
        : TypeRef.commonBaseType(ctx, keyResultTypes.toSet());

    return Variable(
        _collection.scopeFrameOffset,
        _collection.type.copyWith(boxed: false, specifiedTypeArgs: [
          inferredKeyType,
        ]));
  } else {
    // For Map literals, we have two type arguments
    final inferredKeyType = isEmpty
        ? (specifiedKeyType ?? CoreTypes.dynamic.ref(ctx))
        : TypeRef.commonBaseType(ctx, keyResultTypes.toSet());
    final inferredValueType = isEmpty
        ? (specifiedValueType ?? CoreTypes.dynamic.ref(ctx))
        : TypeRef.commonBaseType(ctx, valueResultTypes.toSet());

    return Variable(
        _collection.scopeFrameOffset,
        _collection.type.copyWith(boxed: false, specifiedTypeArgs: [
          inferredKeyType,
          inferredValueType,
        ]));
  }
}

Pair<Variable, List<Pair<TypeRef, TypeRef>>> compileSetOrMapElement(
    CollectionElement e,
    Variable? setOrMap,
    CompilerContext ctx,
    TypeRef? specifiedKeyType,
    TypeRef? specifiedValueType,
    bool box) {
  if (e is Expression) {
    // Handle Set element
    if (setOrMap == null) {
      // Create a new Set using PushSet operation
      ctx.pushOp(PushSet.make(), PushSet.LEN);
      setOrMap = Variable.alloc(
          ctx,
          CoreTypes.set.ref(ctx).copyWith(specifiedTypeArgs: [
            specifiedKeyType ?? CoreTypes.dynamic.ref(ctx),
          ], boxed: false));
    }
    // For Set elements, treat the expression as both key and value
    final elementVariable = compileExpression(e, ctx);
    final keyType = elementVariable.type;
    // Box the element if necessary
    final boxedElement =
        box ? elementVariable.boxIfNeeded(ctx) : elementVariable;
    // Add to Set (treated as Map with same key/value)
    ctx.pushOp(
        MapSet.make(setOrMap.scopeFrameOffset, boxedElement.scopeFrameOffset,
            boxedElement.scopeFrameOffset),
        MapSet.LEN);
    return Pair(setOrMap, [Pair(keyType, keyType)]);
  } else if (e is MapLiteralEntry) {
    if (setOrMap == null) {
      ctx.pushOp(PushMap.make(), PushMap.LEN);
      setOrMap = Variable.alloc(
          ctx,
          CoreTypes.map.ref(ctx).copyWith(specifiedTypeArgs: [
            specifiedKeyType ?? CoreTypes.dynamic.ref(ctx),
            specifiedValueType ?? CoreTypes.dynamic.ref(ctx),
          ], boxed: false));
    }

    var _key = compileExpression(e.key, ctx);

    if (specifiedKeyType != null &&
        !_key.type.isAssignableTo(ctx, specifiedKeyType)) {
      throw CompileError(
          'Cannot use key of type ${_key.type} in map of type <$specifiedKeyType, $specifiedValueType>');
    }

    var _value = compileExpression(e.value, ctx);

    if (specifiedValueType != null &&
        !_value.type.isAssignableTo(ctx, specifiedValueType)) {
      throw CompileError(
          'Cannot use value of type ${_value.type} in map of type <$specifiedKeyType, $specifiedValueType>');
    }

    if (box) {
      _key = _key.boxIfNeeded(ctx);
      _value = _value.boxIfNeeded(ctx);
    }

    ctx.pushOp(
        MapSet.make(setOrMap.scopeFrameOffset, _key.scopeFrameOffset,
            _value.scopeFrameOffset),
        MapSet.LEN);

    return Pair(setOrMap, [Pair(_key.type, _value.type)]);
  }

  throw CompileError('Unknown set or map collection element ${e.runtimeType}');
}
