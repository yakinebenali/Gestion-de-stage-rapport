import 'package:flutter_test/flutter_test.dart';

import 'package:rapportstage/main.dart';

void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    // Build the app with isLoggedIn = false
    await tester.pumpWidget(const MyApp(isLoggedIn: false));

    // Vérifie que le texte de bienvenue est affiché
    expect(find.text('Bienvenue dans l’application de gestion de stage'), findsOneWidget);
  });
}
