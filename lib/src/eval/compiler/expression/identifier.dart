import 'package:analyzer/dart/ast/ast.dart';
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:dart_eval/src/eval/bridge/declaration.dart';
import 'package:dart_eval/src/eval/compiler/context.dart';
import 'package:dart_eval/src/eval/compiler/errors.dart';
import 'package:dart_eval/src/eval/compiler/reference.dart';
import 'package:dart_eval/src/eval/compiler/source.dart';
import 'package:dart_eval/src/eval/compiler/type.dart';
import 'package:dart_eval/src/eval/compiler/variable.dart';

import '../util.dart';

Variable compileIdentifier(Identifier id, CompilerContext ctx) {
  return compileIdentifierAsReference(id, ctx).getValue(ctx, id);
}

Reference compileIdentifierAsReference(Identifier id, CompilerContext ctx) {
  if (id is SimpleIdentifier) {
    return IdentifierReference(null, id.name);
  } else if (id is PrefixedIdentifier) {
    try {
      // First try to compile the prefix as a normal identifier/variable
      final L = compileIdentifier(id.prefix, ctx);
      return IdentifierReference(L, id.identifier.name);
    } catch (e) {
      // If that fails, check if this is a static member access
      final prefixName = id.prefix.name;
      final memberName = id.identifier.name;

      // Look for a static declaration with the pattern 'ClassName.memberName'
      final staticDeclaration =
          resolveStaticDeclaration(ctx, ctx.library, prefixName, memberName);

      if (staticDeclaration != null) {
        // This is a static member access like ClassName.staticMember
        return IdentifierReference(null, '$prefixName.$memberName');
      }

      // Check if this is an import prefix access like prefix.member
      final prefixDeclaration =
          ctx.visibleDeclarations[ctx.library]?[prefixName];
      if (prefixDeclaration != null && prefixDeclaration.children != null) {
        // This is an import prefix, look for the member in its children
        final memberDeclaration = prefixDeclaration.children![memberName];
        if (memberDeclaration != null) {
          // Add this declaration temporarily to the current library's visible declarations
          // so the normal resolution process can find it
          ctx.visibleDeclarations[ctx.library]![memberName] =
              DeclarationOrPrefix(declaration: memberDeclaration);

          // Return a normal identifier reference that will now resolve correctly
          return IdentifierReference(null, memberName);
        }
      }

      // If all approaches fail, rethrow the original error
      rethrow;
    }
  }
  throw CompileError('Unknown identifier ${id.runtimeType}');
}

Variable compilePrefixedIdentifier(
    String prefix, String name, CompilerContext ctx) {
  return compilePrefixedIdentifierAsReference(prefix, name).getValue(ctx);
}

Reference compilePrefixedIdentifierAsReference(
    String prefix, String identifier) {
  return PrefixedIdentifierReference(prefix, identifier);
}

Pair<TypeRef, DeclarationOrBridge>? resolveInstanceDeclaration(
    CompilerContext ctx, int library, String $class, String name) {
  final dec = ctx.instanceDeclarationsMap[library]![$class]?[name];

  if (dec != null) {
    final $type = ctx.visibleTypes[library]![$class]!;
    return Pair($type, DeclarationOrBridge(-1, declaration: dec));
  }

  final _$classDec = ctx.topLevelDeclarationsMap[library]![$class]!;

  if (_$classDec.isBridge) {
    final bridge = _$classDec.bridge as BridgeClassDef;
    final method = bridge.methods[name];
    if (method != null) {
      final $type = ctx.visibleTypes[library]![$class]!;
      return Pair($type, DeclarationOrBridge(-1, bridge: method));
    }
    final getter = bridge.getters[name];
    final setter = bridge.setters[name];

    if (getter != null || setter != null) {
      final $type = ctx.visibleTypes[library]![$class]!;
      final _setter = setter == null
          ? null
          : DeclarationOrBridge<MethodDeclaration, BridgeMethodDef>(-1,
              bridge: setter);
      return Pair($type, GetSet(-1, bridge: getter, setter: _setter));
    }

    final field = bridge.fields[name];
    if (field != null) {
      final $type = ctx.visibleTypes[library]![$class]!;
      return Pair($type, DeclarationOrBridge(-1, bridge: field));
    }

    final $extends = bridge.type.$extends;
    if ($extends != null) {
      final _type = TypeRef.fromBridgeTypeRef(ctx, $extends);
      if (_type.file < 0) {
        return null;
      }
      return resolveInstanceDeclaration(ctx, _type.file, _type.name, name);
    }

    return null;
  } else {
    final getter = ctx.instanceDeclarationsMap[library]![$class]?['$name*g'];
    final setter = ctx.instanceDeclarationsMap[library]![$class]?['$name*s'];
    if (getter != null || setter != null) {
      final $type = ctx.visibleTypes[library]![$class]!;
      final getset = GetSet(-1,
          declaration: getter as MethodDeclaration,
          setter: setter == null
              ? null
              : DeclarationOrBridge(-1,
                  declaration: setter as MethodDeclaration));
      return Pair($type, getset);
    }
  }
  final _$dec = _$classDec.declaration!;
  final $withClause = _$dec is ClassDeclaration
      ? _$dec.withClause
      : (_$dec is EnumDeclaration ? _$dec.withClause : null);
  final $extendsClause = _$dec is ClassDeclaration ? _$dec.extendsClause : null;
  if ($withClause != null) {
    for (final $mixin in $withClause.mixinTypes) {
      final mixinType = ctx.visibleTypes[library]![$mixin.name2.stringValue!]!;
      final result =
          resolveInstanceDeclaration(ctx, mixinType.file, mixinType.name, name);
      if (result != null) {
        return result;
      }
    }
  }
  if ($extendsClause != null) {
    final extendsType = ctx.visibleTypes[library]![
        $extendsClause.superclass.name2.stringValue ??
            $extendsClause.superclass.name2.value()]!;
    return resolveInstanceDeclaration(
        ctx, extendsType.file, extendsType.name, name);
  } else {
    final $type = ctx.visibleTypes[library]![$class]!;
    final objectType = CoreTypes.object.ref(ctx);
    if ($type != objectType) {
      return resolveInstanceDeclaration(ctx, objectType.file, 'Object', name);
    }
  }
  return null;
}

class GetSet extends DeclarationOrBridge<MethodDeclaration, BridgeMethodDef> {
  GetSet(super.sourceLib, {this.setter, super.declaration, super.bridge});

  DeclarationOrBridge<MethodDeclaration, BridgeMethodDef>? setter;
}

DeclarationOrBridge<Declaration, BridgeDeclaration>? resolveStaticDeclaration(
    CompilerContext ctx, int library, String $class, String name) {
  return ctx.topLevelDeclarationsMap[library]!['${$class}.$name'];
}
