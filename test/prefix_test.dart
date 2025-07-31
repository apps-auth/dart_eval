import 'package:dart_eval/dart_eval.dart';
import 'package:test/test.dart';

void main() {
  group('Import prefix tests', () {
    late Compiler compiler;

    setUp(() {
      compiler = Compiler();
    });

    test('Basic prefix import access with variable', () {
      // Test accessing a variable through an import prefix
      final runtime = compiler.compileWriteAndLoad({
        'data_lib': {
          'constants.dart': '''
            class ConfigItem {
              final String name;
              final String value;
              
              ConfigItem({required this.name, required this.value});
              
              @override
              String toString() => 'ConfigItem(name: \$name)';
            }
            
            ConfigItem defaultConfig = ConfigItem(name: "app_setting", value: "production");
          '''
        },
        'consumer_app': {
          'main.dart': '''
            import 'package:data_lib/constants.dart' as config;
            
            String main() {
              return config.defaultConfig.name;
            }
          '''
        }
      });

      final result =
          runtime.executeLib('package:consumer_app/main.dart', 'main');
      expect(result.toString(), equals('\$"app_setting"'));
    });

    test('Prefix import access with function', () {
      // Test accessing a function through an import prefix
      final runtime = compiler.compileWriteAndLoad({
        'helper_lib': {
          'operations.dart': '''
            String processText(String input) {
              return 'Processed: \$input';
            }
            
            int computeValue(int x, int y) {
              return x * y + 5;
            }
          '''
        },
        'client_app': {
          'main.dart': '''
            import 'package:helper_lib/operations.dart' as helpers;
            
            String main() {
              final text = helpers.processText('data');
              final value = helpers.computeValue(3, 4);
              return '\$text | Value: \$value';
            }
          '''
        }
      });

      final result = runtime.executeLib('package:client_app/main.dart', 'main');
      expect(result.toString(), equals('\$"Processed: data | Value: 17"'));
    });

    test('Prefix import access with class', () {
      // Test accessing a class through an import prefix
      final runtime = compiler.compileWriteAndLoad({
        'domain_lib': {
          'entities.dart': '''
            class Product {
              final String code;
              final int price;
              
              Product(this.code, this.price);
              
              String getDetails() {
                return 'Product \$code costs \$price';
              }
            }
          '''
        },
        'app_core': {
          'main.dart': '''
            import 'package:domain_lib/entities.dart' as domain;
            
            String main() {
              final item = domain.Product('ABC123', 30);
              return item.getDetails();
            }
          '''
        }
      });

      final result = runtime.executeLib('package:app_core/main.dart', 'main');
      expect(result.toString(), equals('\$"Product ABC123 costs 30"'));
    });

    test('Multiple prefixes in same file', () {
      // Test using multiple import prefixes in the same file
      final runtime = compiler.compileWriteAndLoad({
        'calc_lib': {
          'numbers.dart': '''
            int sum(int x, int y) => x + y;
            int product(int x, int y) => x * y;
          '''
        },
        'text_lib': {
          'formatter.dart': '''
            String join(String a, String b) => a + b;
            String duplicate(String text, int count) {
              String output = '';
              for (int i = 0; i < count; i++) {
                output = output + text;
              }
              return output;
            }
          '''
        },
        'processor': {
          'main.dart': '''
            import 'package:calc_lib/numbers.dart' as calc;
            import 'package:text_lib/formatter.dart' as fmt;
            
            String main() {
              final numResult = calc.sum(7, 3) * calc.product(2, 2);
              final textResult = fmt.join('Test', ' ') + fmt.duplicate('*', 2);
              return 'Numbers: \$numResult, Text: \$textResult';
            }
          '''
        }
      });

      final result = runtime.executeLib('package:processor/main.dart', 'main');
      expect(result.toString(), equals('\$"Numbers: 40, Text: Test **"'));
    });

    test('Prefix import with complex object access', () {
      // Test accessing complex objects through prefixes
      final runtime = compiler.compileWriteAndLoad({
        'registry_lib': {
          'services.dart': '''
            class ServiceDefinition {
              final String id;
              final Function handler;
              
              ServiceDefinition({required this.id, required this.handler});
              
              @override
              String toString() => 'ServiceDefinition(id: \$id)';
            }
            
            ServiceDefinition defaultService = ServiceDefinition(
              id: "data-processor", 
              handler: () => "Processing data"
            );
          '''
        },
        'app_runner': {
          'main.dart': '''
            import 'package:registry_lib/services.dart' as registry;
            
            List<dynamic> main() {
              return [
                registry.defaultService,
                'Extra component'
              ];
            }
          '''
        }
      });

      final result =
          runtime.executeLib('package:app_runner/main.dart', 'main') as List;
      expect(result.length, equals(2));
      // Check that the first item is not null (the ServiceDefinition object was created successfully)
      expect(result[0], isNotNull);
      expect(result[1].toString(), equals('\$"Extra component"'));
    });

    test('Successful prefix access validates functionality', () {
      // Test that demonstrates prefix functionality working correctly
      final runtime = compiler.compileWriteAndLoad({
        'meta_lib': {
          'info.dart': '''
            const String systemName = 'Framework';
            const int buildNumber = 123;
            
            String getBuildInfo() {
              return '\$systemName build \$buildNumber';
            }
          '''
        },
        'host_app': {
          'main.dart': '''
            import 'package:meta_lib/info.dart' as meta;
            
            String main() {
              return meta.getBuildInfo();
            }
          '''
        }
      });

      final result = runtime.executeLib('package:host_app/main.dart', 'main');
      expect(result.toString(), equals('\$"Framework build 123"'));
    });

    test('Relative import with prefix - module structure', () {
      // Test relative imports through module structure
      final runtime = compiler.compileWriteAndLoad({
        'modules': {
          'providers.dart': '''
            class DataProvider {
              final String name;
              final Function loader;
              
              DataProvider({required this.name, required this.loader});
            }
            
            DataProvider mainProvider = DataProvider(
              name: "primary-data-source", 
              loader: () => "Loading core data"
            );
          ''',
          'main.dart': '''
            import 'providers.dart' as provider;
            
            List<dynamic> main() {
              return [
                provider.mainProvider,
              ];
            }
          '''
        }
      });

      final result =
          runtime.executeLib('package:modules/main.dart', 'main') as List;
      expect(result.length, equals(1));
      expect(result[0],
          isNotNull); // The DataProvider was successfully accessed via relative import prefix
    });

    test('Simple relative import with prefix validates core functionality', () {
      // Test that relative imports with prefixes work for the core use case
      final runtime = compiler.compileWriteAndLoad({
        'basic_lib': {
          'transformers.dart': '''
            String transform(String input) {
              return 'Transformed: \$input';
            }
          ''',
          'main.dart': '''
            import 'transformers.dart' as transform;
            
            String main() {
              return transform.transform('Sample');
            }
          '''
        }
      });

      final result = runtime.executeLib('package:basic_lib/main.dart', 'main');
      expect(result.toString(), equals('\$"Transformed: Sample"'));
    });
  });
}
