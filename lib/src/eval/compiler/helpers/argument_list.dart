import 'package:analyzer/dart/ast/ast.dart';
import 'package:dart_eval/src/eval/compiler/expression/expression.dart';
import 'package:dart_eval/src/eval/runtime/runtime.dart';
import 'package:dart_eval/src/eval/compiler/helpers/tearoff.dart';

import '../../../../dart_eval_bridge.dart';
import '../builtins.dart';
import '../context.dart';
import '../errors.dart';
import '../statement/variable_declaration.dart';
import '../type.dart';
import '../util.dart';
import '../variable.dart';

Pair<List<Variable>, Map<String, Variable>> compileArgumentList(
    CompilerContext ctx,
    ArgumentList argumentList,
    int decLibrary,
    List<FormalParameter> fpl,
    Declaration parameterHost,
    {List<Variable> before = const [],
    Map<String, TypeRef> resolveGenerics = const {},
    List<String> superParams = const [],
    AstNode? source}) {
  final _args = <Variable>[];
  final _push = <Variable>[];
  final _namedArgs = <String, Variable>{};

  final positional = <FormalParameter>[];
  final named = <String, FormalParameter>{};
  final namedExpr = <String, Expression>{};

  for (final param in fpl) {
    if (param.isNamed) {
      named[param.name!.lexeme] = param;
    } else {
      positional.add(param);
    }
  }

  var i = 0;
  Variable? $null;

  final resolveGenericsMap = <String, Set<TypeRef>>{};

  for (final param in positional) {
    // First check super params. Super params do not contain an expression.
    if (superParams.contains(param.name!.lexeme)) {
      final V = ctx.lookupLocal(param.name!.lexeme)!;
      _push.add(V);
      _args.add(V);
      i++;
      continue;
    }
    final arg =
        argumentList.arguments.length <= i ? null : argumentList.arguments[i];
    if (arg is NamedExpression) {
      if (param.isRequired) {
        throw CompileError('Not enough positional arguments');
      } else {
        $null ??= BuiltinValue().push(ctx);
        _push.add($null);
      }
    } else if (arg == null) {
      if (param.isRequired) {
        throw CompileError('Not enough positional arguments');
      } else if (param is DefaultFormalParameter) {
        // Default parameter values are handled at the call site
        $null ??= BuiltinValue().push(ctx);
        _push.add($null);
      } else {
        $null ??= BuiltinValue().push(ctx);
        _push.add($null);
      }
    } else {
      var paramType = CoreTypes.dynamic.ref(ctx);
      TypeAnnotation? typeAnnotation;

      if (param is SimpleFormalParameter) {
        typeAnnotation = param.type;
      } else if (param is FieldFormalParameter) {
        paramType = _resolveFieldFormalType(
          ctx,
          decLibrary,
          param,
          parameterHost,
          resolveGenerics: resolveGenerics,
        );

        // Aplicar resolveGenerics se o tipo for genérico
        if (resolveGenerics.containsKey(paramType.name)) {
          final resolvedType = resolveGenerics[paramType.name]!;
          paramType = resolvedType;
        }
      } else if (param is SuperFormalParameter) {
        paramType =
            resolveSuperFormalType(ctx, decLibrary, param, parameterHost);

        // Aplicar resolveGenerics se o tipo for genérico
        if (resolveGenerics.containsKey(paramType.name)) {
          final resolvedType = resolveGenerics[paramType.name]!;
          paramType = resolvedType;
        }

        // Para SuperFormalParameter, não há typeAnnotation - processar diretamente
        typeAnnotation = null;
      } else {
        throw CompileError('Unknown formal type ${param.runtimeType}');
      }

      if (typeAnnotation != null) {
        // Adicionar resolveGenerics ao contexto temporário para múltiplas bibliotecas
        for (final entry in resolveGenerics.entries) {
          // Adicionar à biblioteca especificada
          ctx.temporaryTypes[decLibrary] ??= {};
          ctx.temporaryTypes[decLibrary]![entry.key] = entry.value;

          // Adicionar também à biblioteca atual para garantir disponibilidade
          ctx.temporaryTypes[ctx.library] ??= {};
          ctx.temporaryTypes[ctx.library]![entry.key] = entry.value;
        }

        paramType = TypeRef.fromAnnotation(ctx, decLibrary, typeAnnotation);

        // Aplicar resolveGenerics se o tipo for genérico
        if (resolveGenerics.containsKey(paramType.name)) {
          final resolvedType = resolveGenerics[paramType.name]!;
          paramType = resolvedType;
        }
      }

      var _arg = compileExpression(arg, ctx, paramType);

      if (parameterHost is MethodDeclaration ||
          !paramType.isUnboxedAcrossFunctionBoundaries) {
        _arg = _arg.boxIfNeeded(ctx);
      } else if (paramType.isUnboxedAcrossFunctionBoundaries) {
        _arg = _arg.unboxIfNeeded(ctx);
      }

      if (_arg.type == CoreTypes.function.ref(ctx) &&
          _arg.scopeFrameOffset == -1) {
        _arg = _arg.tearOff(ctx);
      }

      TypeRef _realType = _arg.type;

      if (!_realType.resolveTypeChain(ctx).isAssignableTo(ctx, paramType)) {
        final bool isGeneric = isGenericType(ctx, _realType);

        if (isGeneric) {
          _realType = paramType;
        } else {
          throw CompileError(
            'Cannot assign argument of type ${_arg.type.toStringClear(ctx, paramType)} '
            'to parameter "${param.name!.lexeme}" of type ${paramType.toStringClear(ctx, _arg.type)}',
            source ?? parameterHost,
          );
        }
      }

      if (typeAnnotation != null) {
        final n = typeAnnotation is NamedType
            ? (typeAnnotation.name2.stringValue ?? typeAnnotation.name2.lexeme)
            : null;
        if (n != null && resolveGenerics.containsKey(n)) {
          resolveGenericsMap[n] ??= {};
          resolveGenericsMap[n]!.add(_realType);
        }
      }

      _args.add(_arg);
      _push.add(_arg);
    }

    i++;
  }

  for (final arg in argumentList.arguments) {
    if (arg is NamedExpression) {
      namedExpr[arg.name.label.name] = arg.expression;
    }
  }

  for (final n in named.entries) {
    final name = n.key;
    final _param = n.value;
    if (superParams.contains(name)) {
      final V = ctx.lookupLocal(name)!;
      _push.add(V);
      _namedArgs[name] = V;
      continue;
    }
    final param = (_param is DefaultFormalParameter ? _param.parameter : _param)
        as NormalFormalParameter;
    var paramType = CoreTypes.dynamic.ref(ctx);
    TypeAnnotation? typeAnnotation;
    if (param is SimpleFormalParameter) {
      typeAnnotation = param.type;
      if (typeAnnotation != null) {
        paramType = TypeRef.fromAnnotation(ctx, decLibrary, typeAnnotation);
      }
    } else if (param is FieldFormalParameter) {
      paramType = _resolveFieldFormalType(
        ctx,
        decLibrary,
        param,
        parameterHost,
        resolveGenerics: resolveGenerics,
      );
      // Aplicar resolveGenerics se o tipo for genérico
      if (resolveGenerics.containsKey(paramType.name)) {
        final resolvedType = resolveGenerics[paramType.name]!;
        paramType = resolvedType;
      }
      // FieldFormalParameter pode ter typeAnnotation explícita
      typeAnnotation = param.type;
    } else if (param is SuperFormalParameter) {
      paramType = resolveSuperFormalType(ctx, decLibrary, param, parameterHost);
      // Aplicar resolveGenerics se o tipo for genérico
      if (resolveGenerics.containsKey(paramType.name)) {
        paramType = resolveGenerics[paramType.name]!;
      }
    } else {
      throw CompileError('Unknown formal type ${param.runtimeType}');
    }

    if (typeAnnotation != null && param is SimpleFormalParameter) {
      // Para SimpleFormalParameter, usar typeAnnotation
      paramType = TypeRef.fromAnnotation(ctx, decLibrary, typeAnnotation);

      // Aplicar resolveGenerics se o tipo for genérico
      if (resolveGenerics.containsKey(paramType.name)) {
        paramType = resolveGenerics[paramType.name]!;
      }
    } else if (typeAnnotation != null && param is FieldFormalParameter) {
      // Para FieldFormalParameter com typeAnnotation explícita, usar typeAnnotation
      // mas manter a lógica de resolveGenerics que já foi aplicada
      final annotationType =
          TypeRef.fromAnnotation(ctx, decLibrary, typeAnnotation);

      // Se o tipo da annotation for genérico, resolver
      if (resolveGenerics.containsKey(annotationType.name)) {
        paramType = resolveGenerics[annotationType.name]!;
      } else {
        paramType = annotationType;
      }
    }

    if (namedExpr.containsKey(name)) {
      var _arg = compileExpression(namedExpr[name]!, ctx, paramType);
      if (parameterHost is MethodDeclaration ||
          !paramType.isUnboxedAcrossFunctionBoundaries) {
        _arg = _arg.boxIfNeeded(ctx);
      } else if (paramType.isUnboxedAcrossFunctionBoundaries) {
        _arg = _arg.unboxIfNeeded(ctx);
      }

      if (_arg.type == CoreTypes.function.ref(ctx) &&
          _arg.scopeFrameOffset == -1) {
        _arg = _arg.tearOff(ctx);
      }

      if (!_arg.type.resolveTypeChain(ctx).isAssignableTo(ctx, paramType)) {
        throw CompileError(
            'Cannot assign argument of type ${_arg.type.toStringClear(ctx, paramType)}'
            ' to parameter "${param.name!.lexeme}" of type ${paramType.toStringClear(ctx, _arg.type)}',
            source ?? parameterHost);
      }

      if (typeAnnotation != null) {
        final n = typeAnnotation is NamedType
            ? (typeAnnotation.name2.stringValue ?? typeAnnotation.name2.lexeme)
            : null;
        if (n != null && resolveGenerics.containsKey(n)) {
          resolveGenericsMap[n] ??= {};
          resolveGenericsMap[n]!.add(_arg.type);
        }
      }

      _push.add(_arg);
      _namedArgs[name] = _arg;
    } else {
      $null ??= BuiltinValue().push(ctx);
      _push.add($null);
    }
  }

  for (final generic in resolveGenericsMap.keys) {
    resolveGenerics[generic] =
        TypeRef.commonBaseType(ctx, resolveGenericsMap[generic]!);
  }

  for (final _arg in <Variable>[...before, ..._push]) {
    final argOp = PushArg.make(_arg.scopeFrameOffset);
    ctx.pushOp(argOp, PushArg.LEN);
  }

  return Pair(_args, _namedArgs);
}

Pair<List<Variable>, Map<String, Variable>>
    compileArgumentListWithKnownMethodArgs(
        CompilerContext ctx,
        ArgumentList argumentList,
        List<KnownMethodArg> params,
        Map<String, KnownMethodArg> namedParams,
        {List<Variable> before = const [],
        AstNode? source}) {
  final _args = <Variable>[];
  final _push = <Variable>[];
  final _namedArgs = <String, Variable>{};
  final namedExpr = <String, Expression>{};

  var i = 0;
  Variable? $null;

  for (final param in params) {
    if (param.optional && argumentList.arguments.length <= i) {
      break;
    }
    final arg = argumentList.arguments[i];
    if (arg is NamedExpression) {
      if (!param.optional) {
        throw CompileError('Not enough positional arguments');
      } else {
        $null ??= BuiltinValue().push(ctx);
        _push.add($null);
      }
    } else {
      var paramType = param.type ?? CoreTypes.dynamic.ref(ctx);

      var _arg = compileExpression(arg, ctx, paramType);
      _arg = _arg.boxIfNeeded(ctx);

      if (_arg.type == CoreTypes.function.ref(ctx) &&
          _arg.scopeFrameOffset == -1) {
        _arg = _arg.tearOff(ctx);
      }

      if (!_arg.type.resolveTypeChain(ctx).isAssignableTo(ctx, paramType)) {
        throw CompileError(
            'Cannot assign argument of type ${_arg.type} to parameter of type $paramType',
            argumentList);
      }
      _args.add(_arg);
      _push.add(_arg);
    }

    i++;
  }

  for (final arg in argumentList.arguments) {
    if (arg is NamedExpression) {
      namedExpr[arg.name.label.name] = arg.expression;
    }
  }

  for (final param in namedParams.values) {
    var paramType = param.type ?? CoreTypes.dynamic.ref(ctx);
    if (namedExpr.containsKey(param.name)) {
      final _arg = compileExpression(namedExpr[param.name]!, ctx, paramType)
          .boxIfNeeded(ctx);
      if (!_arg.type.resolveTypeChain(ctx).isAssignableTo(ctx, paramType)) {
        throw CompileError(
            'Cannot assign argument of type ${_arg.type} to parameter of type $paramType',
            source);
      }
      _push.add(_arg);
      _namedArgs[param.name] = _arg;
    } else {
      $null ??= BuiltinValue().push(ctx);
      _push.add($null);
    }
  }

  for (final _arg in [...before, ..._push]) {
    final argOp = PushArg.make(_arg.scopeFrameOffset);
    ctx.pushOp(argOp, PushArg.LEN);
  }

  return Pair(_args, _namedArgs);
}

Pair<List<Variable>, Map<String, Variable>> compileArgumentListWithBridge(
    CompilerContext ctx, ArgumentList argumentList, BridgeFunctionDef function,
    {List<Variable> before = const [], List<String> superParams = const []}) {
  final _args = <Variable>[];
  final _push = <Variable>[];
  final _namedArgs = <String, Variable>{};
  final namedExpr = <String, Expression>{};

  var i = 0;
  Variable? $null;

  for (final param in function.params) {
    if (superParams.contains(param.name)) {
      final V = ctx.lookupLocal(param.name)!;
      _push.add(V);
      _args.add(V);
      i++;
      continue;
    }
    if (param.optional && argumentList.arguments.length <= i) {
      $null ??= BuiltinValue().push(ctx);
      _push.add($null);
      continue;
    }
    final arg = argumentList.arguments[i];
    if (arg is NamedExpression) {
      if (!param.optional) {
        throw CompileError('Not enough positional arguments');
      } else {
        $null ??= BuiltinValue().push(ctx);
        _push.add($null);
      }
    } else {
      var paramType = TypeRef.fromBridgeAnnotation(ctx, param.type);

      var _arg = compileExpression(arg, ctx, paramType);
      _arg = _arg.boxIfNeeded(ctx);
      if (_arg.type == CoreTypes.function.ref(ctx) &&
          _arg.scopeFrameOffset == -1) {
        _arg = _arg.tearOff(ctx);
      }
      if (!(param.type.nullable && _arg.type == CoreTypes.nullType.ref(ctx)) &&
          !_arg.type.resolveTypeChain(ctx).isAssignableTo(ctx, paramType)) {
        throw CompileError(
            'Cannot assign argument of type ${_arg.type} to parameter of type $paramType',
            argumentList);
      }
      _args.add(_arg);
      _push.add(_arg);
    }

    i++;
  }

  for (final arg in argumentList.arguments) {
    if (arg is NamedExpression) {
      namedExpr[arg.name.label.name] = arg.expression;
    }
  }

  for (final param in function.namedParams) {
    if (superParams.contains(param.name)) {
      final V = ctx.lookupLocal(param.name)!;
      _push.add(V);
      _namedArgs[param.name] = V;
    }
    var paramType = TypeRef.fromBridgeAnnotation(ctx, param.type);
    if (namedExpr.containsKey(param.name)) {
      var _arg = compileExpression(namedExpr[param.name]!, ctx, paramType)
          .boxIfNeeded(ctx);
      if (_arg.type == CoreTypes.function.ref(ctx) &&
          _arg.scopeFrameOffset == -1) {
        _arg = _arg.tearOff(ctx);
      }
      if (!_arg.type.resolveTypeChain(ctx).isAssignableTo(ctx, paramType)) {
        throw CompileError(
            'Cannot assign argument of type ${_arg.type} to parameter of type $paramType',
            argumentList);
      }
      _push.add(_arg);
      _namedArgs[param.name] = _arg;
    } else {
      $null ??= BuiltinValue().push(ctx);
      _push.add($null);
    }
  }

  for (final _arg in [...before, ..._push]) {
    final argOp = PushArg.make(_arg.scopeFrameOffset);
    ctx.pushOp(argOp, PushArg.LEN);
  }

  return Pair(_args, _namedArgs);
}

/// Resolve o tipo de um FieldFormalParameter usando os tipos genéricos
TypeRef _resolveFieldFormalType(
  CompilerContext ctx,
  int decLibrary,
  FieldFormalParameter param,
  Declaration parameterHost, {
  Map<String, TypeRef>? resolveGenerics,
}) {
  if (parameterHost is! ConstructorDeclaration) {
    throw CompileError('Field formals can only occur in constructors');
  }
  final $class = parameterHost.parent as NamedCompilationUnitMember;

  // Garantir que os tipos genéricos da classe estão registrados
  // Isso é crítico para resolver field formal parameters com tipos genéricos
  if ($class is ClassDeclaration &&
      $class.typeParameters?.typeParameters != null) {
    // Registrar os tipos genéricos da classe no contexto temporário
    ctx.temporaryTypes[decLibrary] ??= {};
    for (final param in $class.typeParameters!.typeParameters) {
      final name = param.name.lexeme;

      // Sempre criar um TypeRef para o tipo genérico, não o bound
      // O bound é usado para verificações de tipo, não para o tipo em si
      ctx.temporaryTypes[decLibrary]![name] =
          TypeRef.cache(ctx, decLibrary, name);
    }
  }

  final baseType = TypeRef.lookupFieldType(ctx,
      TypeRef.lookupDeclaration(ctx, decLibrary, $class), param.name.lexeme,
      forFieldFormal: true, source: param);

  if (baseType != null) {
    if (resolveGenerics != null && resolveGenerics.containsKey(baseType.name)) {
      return resolveGenerics[baseType.name]!;
    }
    return baseType;
  }

  return CoreTypes.dynamic.ref(ctx);
}

TypeRef resolveSuperFormalType(CompilerContext ctx, int decLibrary,
    SuperFormalParameter param, Declaration parameterHost) {
  if (parameterHost is! ConstructorDeclaration) {
    throw CompileError('Super formals can only occur in constructors');
  }
  var superConstructorName = '';
  final lastInit = parameterHost.initializers.isEmpty
      ? null
      : parameterHost.initializers.last;
  if (lastInit is SuperConstructorInvocation) {
    superConstructorName = lastInit.constructorName?.name ?? '';
  }
  final $class = parameterHost.parent as ClassDeclaration;
  final type = TypeRef.lookupDeclaration(ctx, decLibrary, $class);
  final $super = type.resolveTypeChain(ctx).extendsType ??
      (throw CompileError(
          'Class $type has no super class, so cannot use super formals',
          param));
  final superCstr = ctx.topLevelDeclarationsMap[$super.file]![
      '${$super.name}.$superConstructorName']!;
  if (superCstr.isBridge) {
    final fd = (superCstr.bridge as BridgeConstructorDef).functionDescriptor;

    // First, try to find in named parameters
    for (final _param in fd.namedParams) {
      if (_param.name == param.name.lexeme) {
        TypeRef t = TypeRef.fromBridgeAnnotation(ctx, _param.type);
        return t;
      }
    }

    // Then try positional parameters
    for (final _param in fd.params) {
      if (_param.name == param.name.lexeme) {
        return TypeRef.fromBridgeAnnotation(ctx, _param.type);
      }
    }

    // If parameter not found in bridge class, use dynamic as fallback
    // This allows any super.parameter to work with bridge classes
    return CoreTypes.dynamic.ref(ctx);
  } else {
    final cstr = superCstr.declaration as ConstructorDeclaration;
    for (final _param in cstr.parameters.parameters) {
      var __param =
          _param is DefaultFormalParameter ? _param.parameter : _param;
      if (__param.name?.lexeme != param.name.lexeme) {
        continue;
      }
      if (__param is SimpleFormalParameter) {
        final _type = __param.type;
        if (_type == null) {
          return CoreTypes.dynamic.ref(ctx);
        }
        return TypeRef.fromAnnotation(ctx, $super.file, _type);
      } else if (__param is FieldFormalParameter) {
        return _resolveFieldFormalType(ctx, decLibrary, __param, cstr);
      } else if (__param is SuperFormalParameter) {
        return resolveSuperFormalType(ctx, decLibrary, __param, cstr);
      } else {
        throw CompileError(
            'Unknown parameter type ${__param.runtimeType}', __param);
      }
    }
  }

  throw CompileError(
      'Could not find parameter ${param.name.value()} in the referenced superclass constructor',
      param,
      decLibrary);
}
