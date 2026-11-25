import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/screens/project_detail_screen.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

const projectJson = {
  'id': '123e4567-e89b-12d3-a456-426614174000',
  'title': 'FoodWastey',
  'description': 'Berbagi makanan',
  'tech_stack': 'Flutter, Django',
  'project_url': 'https://example.com/project',
  'project_image_url': '',
};

Widget withServices(Widget home, ApiClient api, {String? token}) {
  return MultiProvider(
    providers: [
      Provider<ApiClient>.value(value: api),
      ChangeNotifierProvider(
        create: (_) => AuthState(api, initialToken: token),
      ),
    ],
    child: MaterialApp(home: home),
  );
}

Future<void> fillProject(WidgetTester tester) async {
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), 'FoodWastey');
  await tester.enterText(fields.at(1), 'Berbagi makanan');
  await tester.enterText(fields.at(2), 'Flutter, Django');
  await tester.enterText(fields.at(3), 'https://example.com/project');
  await tester.ensureVisible(find.text('Save'));
}

void main() {
  test(
    'Project maps snake_case, defaults an absent image, and omits id on POST',
    () {
      final json = Map<String, dynamic>.from(projectJson)
        ..remove('project_image_url');
      final project = Project.fromJson(json);
      expect(project.techStack, 'Flutter, Django');
      expect(project.projectImageUrl, '');
      expect(project.toJson().containsKey('id'), isFalse);
      expect(project.toJson()['tech_stack'], 'Flutter, Django');
      json['project_image_url'] = null;
      expect(Project.fromJson(json).projectImageUrl, '');
    },
  );

  test(
    'GET is public and POST uses token authorization and serializer fields',
    () async {
      final api = ApiClient(
        client: MockClient((request) async {
          expect(request.url.path, '/api/v1/projects/');
          if (request.method == 'GET') {
            expect(request.headers.containsKey('authorization'), isFalse);
            return http.Response(jsonEncode([projectJson]), 200);
          }
          expect(request.headers['authorization'], 'Token example-token');
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['tech_stack'], 'Flutter, Django');
          expect(body.containsKey('id'), isFalse);
          return http.Response(jsonEncode(projectJson), 201);
        }),
      );
      expect((await api.getProjects()).single.title, 'FoodWastey');
      expect(
        (await api.createProject(
          Project.fromJson(projectJson),
          token: 'example-token',
        )).id,
        projectJson['id'],
      );
      api.close();
    },
  );

  test('login sends credentials as JSON and stores the token', () async {
    final api = ApiClient(
      client: MockClient((request) async {
        expect(request.url.path, '/api/v1/auth/token/');
        expect(jsonDecode(request.body), {
          'username': 'owner',
          'password': 'secret',
        });
        return http.Response('{"token":"example-token"}', 200);
      }),
    );
    final auth = AuthState(api);
    await auth.login('owner', 'secret');
    expect(auth.isLoggedIn, isTrue);
    expect(auth.token, 'example-token');
    auth.dispose();
    api.close();
  });

  test(
    'logout clears the local token and notifies even if the server fails',
    () async {
      final api = ApiClient(
        client: MockClient((request) async {
          expect(request.url.path, '/api/v1/auth/logout/');
          expect(request.headers['authorization'], 'Token example-token');
          return http.Response('Server error', 500);
        }),
      );
      final auth = AuthState(api, initialToken: 'example-token');
      var notified = false;
      auth.addListener(() => notified = true);
      await expectLater(auth.logout(), throwsA(isA<ApiException>()));
      expect(auth.token, isNull);
      expect(notified, isTrue);
      auth.dispose();
      api.close();
    },
  );

  testWidgets(
    'home remains readable on a narrow screen and guards Add Project',
    (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final api = ApiClient(
        client: MockClient((_) async => http.Response('[]', 200)),
      );
      addTearDown(api.close);
      await tester.pumpWidget(MyApp(apiClient: api));
      expect(find.text('2506536465'), findsOneWidget);
      expect(find.text('Khansa Khairunnisa Haikal'), findsOneWidget);
      await tester.tap(find.text('Tambah Proyek'));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();
      expect(find.text('Username tidak boleh kosong!'), findsOneWidget);
      expect(find.byType(ProjectFormPage), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'login returns to the guarded form and a real POST precedes success',
    (tester) async {
      var posted = false;
      final api = ApiClient(
        client: MockClient((request) async {
          if (request.url.path == '/api/v1/auth/token/') {
            return http.Response('{"token":"example-token"}', 200);
          }
          posted = true;
          expect(request.headers['authorization'], 'Token example-token');
          return http.Response(jsonEncode(projectJson), 201);
        }),
      );
      addTearDown(api.close);
      await tester.pumpWidget(MyApp(apiClient: api));
      await tester.tap(find.text('Tambah Proyek'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), 'owner');
      await tester.enterText(find.byType(TextFormField).at(1), 'secret');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();
      expect(find.byType(ProjectFormPage), findsOneWidget);
      await fillProject(tester);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(posted, isTrue);
      expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widgetList<EditableText>(find.byType(EditableText))
            .every((field) => field.controller.text.isEmpty),
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('invalid project URL prevents POST', (tester) async {
    var calls = 0;
    final api = ApiClient(
      client: MockClient((_) async {
        calls++;
        return http.Response('{}', 500);
      }),
    );
    addTearDown(api.close);
    await tester.pumpWidget(
      withServices(const ProjectFormPage(), api, token: 'example-token'),
    );
    await fillProject(tester);
    await tester.enterText(find.byType(TextFormField).at(3), 'not-a-url');
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(
      find.text('Masukkan URL http:// atau https:// yang valid.'),
      findsOneWidget,
    );
    expect(calls, 0);
  });

  testWidgets('expired token opens login without clearing the project fields', (
    tester,
  ) async {
    final api = ApiClient(
      client: MockClient(
        (request) async => http.Response(
          '{}',
          request.url.path == '/api/v1/auth/logout/' ? 204 : 401,
        ),
      ),
    );
    addTearDown(api.close);
    await tester.pumpWidget(
      withServices(const ProjectFormPage(), api, token: 'expired'),
    );
    await fillProject(tester);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    Navigator.pop(tester.element(find.byType(LoginScreen)));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<EditableText>(find.byType(EditableText).first)
          .controller
          .text,
      'FoodWastey',
    );
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets(
    'public projects load once and navigate to detail without an empty image',
    (tester) async {
      var calls = 0;
      final api = ApiClient(
        client: MockClient((_) async {
          calls++;
          return http.Response(jsonEncode([projectJson]), 200);
        }),
      );
      addTearDown(api.close);
      await tester.pumpWidget(withServices(const ProjectListScreen(), api));
      await tester.pumpAndSettle();
      expect(calls, 1);
      await tester.tap(find.text('FoodWastey'));
      await tester.pumpAndSettle();
      expect(find.byType(ProjectDetailScreen), findsOneWidget);
      expect(find.byType(Image), findsNothing);
      expect(find.text('Teknologi: Flutter, Django'), findsOneWidget);
    },
  );

  testWidgets('empty list supports refresh and failed requests support retry', (
    tester,
  ) async {
    var calls = 0;
    final api = ApiClient(
      client: MockClient((_) async {
        calls++;
        return calls == 1
            ? http.Response('error', 500)
            : http.Response('[]', 200);
      }),
    );
    addTearDown(api.close);
    await tester.pumpWidget(withServices(const ProjectListScreen(), api));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('No projects found.'), findsOneWidget);
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, 350));
    await tester.pumpAndSettle();
    expect(calls, 3);
    expect(tester.takeException(), isNull);
  });
}
