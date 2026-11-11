import 'package:flutter_test/flutter_test.dart';
import 'package:pay_vault/presentation/ai_advisor/ai_advisor_controller.dart';

import '../helpers/mock_repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAiAdvisorRepository fakeAiRepo;
  late FakeVaultRepository fakeVaultRepo;
  late FakeTransferRepository fakeTransferRepo;
  late AiAdvisorController controller;

  setUp(() {
    fakeAiRepo = FakeAiAdvisorRepository();
    fakeVaultRepo = FakeVaultRepository();
    fakeTransferRepo = FakeTransferRepository();

    controller = AiAdvisorController(
      fakeAiRepo,
      fakeVaultRepo,
      fakeTransferRepo,
    );
  });

  tearDown(() {
    controller.onClose();
  });

  group('AiAdvisorController Unit Tests', () {
    test('Loads initial chat history from repository', () async {
      await controller.loadChatHistory();
      expect(controller.messages.length, equals(1));
      expect(controller.messages.first.text, equals('AI Copilot initialized.'));
    });

    test(
      'Streams AI advice and guarantees isStreaming resets to false in finally',
      () async {
        await controller.loadChatHistory();
        expect(controller.isStreaming.value, isFalse);

        final future = controller.submitPrompt(
          'Analyze Currency Exchange Opportunities',
        );
        await future;

        expect(controller.isStreaming.value, isFalse);
        expect(
          controller.messages.length,
          equals(3),
        ); // initial + user + ai response
        expect(controller.messages.last.isUser, isFalse);
      },
    );

    test('Clears history and loads fresh initial welcome prompt', () async {
      await controller.clearHistory();
      expect(controller.messages.length, equals(1));
      expect(controller.messages.first.text, contains('history reset'));
    });
  });
}
