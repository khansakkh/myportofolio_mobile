import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';

void main() {
  testWidgets('Profile and all menu actions work on a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());

    expect(find.text('MyPortfolio'), findsOneWidget);
    expect(find.text('2506536465'), findsOneWidget);
    expect(find.text('Khansa Khairunnisa Haikal'), findsOneWidget);
    expect(find.text('PBP C'), findsOneWidget);
    expect(tester.takeException(), isNull);

    for (final label in ['Lihat Proyek', 'Tambah Proyek', 'Logout']) {
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(SnackBar),
          matching: find.text('Kamu telah menekan tombol $label!'),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      if (label == 'Tambah Proyek') {
        expect(find.byType(ProjectFormPage), findsOneWidget);
        final context = tester.element(find.byType(ProjectFormPage));
        Navigator.pop(context);
        await tester.pumpAndSettle();
        expect(find.byType(MyHomePage), findsOneWidget);
      }
    }
  });

  testWidgets('Drawer replaces the current page in both directions', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Project'));
    await tester.pumpAndSettle();

    expect(find.byType(ProjectFormPage), findsOneWidget);
    expect(find.byType(MyHomePage), findsNothing);
    final formContext = tester.element(find.byType(ProjectFormPage));
    expect(Navigator.canPop(formContext), isFalse);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.byType(MyHomePage), findsOneWidget);
    expect(find.byType(ProjectFormPage), findsNothing);
    expect(Navigator.canPop(tester.element(find.byType(MyHomePage))), isFalse);
  });

  testWidgets('Empty or whitespace-only required fields prevent saving', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ProjectFormPage()));
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Deskripsi proyek tidak boleh kosong!'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);

    await tester.enterText(find.byType(TextFormField).at(0), '   ');
    await tester.enterText(find.byType(TextFormField).at(1), '   ');
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Deskripsi proyek tidak boleh kosong!'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Dialog shows every field and OK clears all form state', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ProjectFormPage()));
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'FoodWastey');
    await tester.enterText(fields.at(1), 'Aplikasi berbagi makanan');
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mobile Development').last);
    await tester.pumpAndSettle();
    await tester.enterText(fields.at(2), 'Flutter, Django');
    await tester.enterText(fields.at(3), 'https://example.com/foodwastey');
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    for (final text in [
      'Nama Proyek: FoodWastey',
      'Deskripsi: Aplikasi berbagi makanan',
      'Kategori: Mobile Development',
      'Teknologi: Flutter, Django',
      'Tautan: https://example.com/foodwastey',
    ]) {
      expect(find.text(text), findsOneWidget);
    }
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    final editableFields = tester.widgetList<EditableText>(
      find.byType(EditableText),
    );
    expect(
      editableFields.every((field) => field.controller.text.isEmpty),
      isTrue,
    );
    expect(find.text('Web Development'), findsOneWidget);

    await tester.enterText(fields.at(0), 'Proyek kedua');
    await tester.enterText(fields.at(1), 'Deskripsi baru');
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Nama Proyek: Proyek kedua'), findsOneWidget);
    expect(find.text('Kategori: Web Development'), findsOneWidget);
    expect(find.text('Teknologi: '), findsOneWidget);
    expect(find.text('Tautan: '), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
