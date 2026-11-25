import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:test/test.dart';

const payload = {
  'id': '123e4567-e89b-12d3-a456-426614174000',
  'title': 'FoodWastey',
  'description': 'Berbagi makanan',
  'tech_stack': 'Flutter, Django',
  'project_url': 'https://example.com/project',
  'project_image_url': '',
};

void main() {
  test(
    'Project defaults missing/null image URLs and does not send the server id',
    () {
      final json = Map<String, dynamic>.from(payload)
        ..remove('project_image_url');
      final project = Project.fromJson(json);
      expect(project.projectImageUrl, '');
      expect(project.techStack, 'Flutter, Django');
      expect(project.toJson().containsKey('id'), isFalse);
      json['project_image_url'] = null;
      expect(Project.fromJson(json).projectImageUrl, '');
    },
  );

  test(
    'GET projects is public and handles a trailing base URL slash',
    () async {
      final api = ApiClient(
        baseUrl: 'http://localhost:8000/',
        client: MockClient((request) async {
          expect(request.method, 'GET');
          expect(
            request.url.toString(),
            'http://localhost:8000/api/v1/projects/',
          );
          expect(request.headers.containsKey('authorization'), isFalse);
          return http.Response(jsonEncode([payload]), 200);
        }),
      );
      addTearDown(api.close);
      expect((await api.getProjects()).single.title, 'FoodWastey');
    },
  );

  test('POST sends JSON serializer fields with token authentication', () async {
    final api = ApiClient(
      client: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/v1/projects/');
        expect(request.headers['authorization'], 'Token example-token');
        expect(request.headers['content-type'], contains('application/json'));
        final json = jsonDecode(request.body) as Map<String, dynamic>;
        expect(json['tech_stack'], 'Flutter, Django');
        expect(json.containsKey('id'), isFalse);
        expect(json.containsKey('techStack'), isFalse);
        return http.Response(jsonEncode(payload), 201);
      }),
    );
    addTearDown(api.close);
    expect(
      (await api.createProject(
        Project.fromJson(payload),
        token: 'example-token',
      )).id,
      payload['id'],
    );
  });

  test('login exchanges JSON credentials for a token', () async {
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
    addTearDown(api.close);
    expect(await api.obtainToken('owner', 'secret'), 'example-token');
  });

  test('logout accepts an empty 204 response', () async {
    final api = ApiClient(
      client: MockClient((request) async {
        expect(request.url.path, '/api/v1/auth/logout/');
        expect(request.method, 'POST');
        expect(request.headers['authorization'], 'Token example-token');
        return http.Response('', 204);
      }),
    );
    addTearDown(api.close);
    await api.logout(token: 'example-token');
  });

  test('non-success status codes remain available to the caller', () async {
    final api = ApiClient(
      client: MockClient(
        (_) async => http.Response('{"detail":"Invalid token"}', 401),
      ),
    );
    addTearDown(api.close);
    await expectLater(
      api.createProject(Project.fromJson(payload), token: 'expired'),
      throwsA(
        isA<ApiException>().having(
          (error) => error.statusCode,
          'statusCode',
          401,
        ),
      ),
    );
  });
}
