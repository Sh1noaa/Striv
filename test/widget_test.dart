import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strive/main.dart';
import 'package:strive/services/storage_service.dart';

void main() {
  testWidgets('Strive onboarding renders Ignis mascot and steps',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = StorageService();
    await storage.init();

    await tester.pumpWidget(
      ChangeNotifierProvider<StorageService>.value(
        value: storage,
        child: const StriveApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('TAHAP 1: IDENTITAS KOMANDAN'), findsOneWidget);
  });
}
