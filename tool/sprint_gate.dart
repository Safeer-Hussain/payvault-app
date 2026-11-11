// ignore_for_file: avoid_print
import 'dart:io';

Future<void> main(List<String> args) async {
  print('========================================================');
  print('PAYVAULT SPRINT GATEKEEPER');
  print('========================================================');

  final steps = [
    _GateStep(
      name: 'Flutter Pub Get',
      executable: 'flutter',
      arguments: ['pub', 'get'],
    ),
    _GateStep(
      name: 'Dart Code Formatting (lib, test)',
      executable: 'dart',
      arguments: ['format', '--output=none', '--set-exit-if-changed', 'lib', 'test'],
    ),
    _GateStep(
      name: 'Flutter Analyze (Zero Warning Rule)',
      executable: 'flutter',
      arguments: ['analyze', '--no-pub'],
    ),
    _GateStep(
      name: 'Flutter Automated Tests',
      executable: 'flutter',
      arguments: ['test', '--no-pub'],
    ),
  ];

  for (int i = 0; i < steps.length; i++) {
    final step = steps[i];
    print('\n[Phase ${i + 1}/${steps.length}] Executing: ${step.name}...');
    final stopwatch = Stopwatch()..start();

    final result = await Process.run(
      step.executable,
      step.arguments,
      runInShell: true,
    );

    stopwatch.stop();

    if (result.stdout.toString().trim().isNotEmpty) {
      print(result.stdout.toString().trim());
    }

    if (result.exitCode != 0) {
      if (result.stderr.toString().trim().isNotEmpty) {
        print(result.stderr.toString().trim());
      }
      print('\nSprint Gate Verification FAILED at Phase ${i + 1}: ${step.name}');
      exit(result.exitCode);
    }

    print('Phase ${i + 1} passed in ${stopwatch.elapsedMilliseconds}ms.');
  }

  print('\n========================================================');
  print('ALL PAYVAULT SPRINT GATES PASSED (100% CLEAN ARCHITECTURE)');
  print('========================================================');
  exit(0);
}

class _GateStep {
  final String name;
  final String executable;
  final List<String> arguments;

  _GateStep({
    required this.name,
    required this.executable,
    required this.arguments,
  });
}
