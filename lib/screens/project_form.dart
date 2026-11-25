import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  String _techStack = '';
  String _projectUrl = '';
  String _imageUrl = '';
  bool _isSubmitting = false;

  String? _required(String? value) => value == null || value.trim().isEmpty
      ? 'Kolom ini tidak boleh kosong!'
      : null;

  String? _url(String? value, {bool optional = false}) {
    if (value == null || value.trim().isEmpty) {
      return optional ? null : 'URL proyek tidak boleh kosong!';
    }
    final uri = Uri.tryParse(value.trim());
    if (uri == null ||
        !uri.hasAuthority ||
        uri.host.isEmpty ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      return 'Masukkan URL http:// atau https:// yang valid.';
    }
    return null;
  }

  Future<void> _submit() async {
    if (_isSubmitting || !_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final loggedIn = await ensureLoggedIn(context);
      if (!mounted || !loggedIn) return;
      final token = context.read<AuthState>().token;
      if (token == null) return;
      final project = await context.read<ApiClient>().createProject(
        Project(
          title: _title.trim(),
          description: _description.trim(),
          techStack: _techStack.trim(),
          projectUrl: _projectUrl.trim(),
          projectImageUrl: _imageUrl.trim(),
        ),
        token: token,
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Proyek berhasil ditambahkan!'),
          content: Text('${project.title} sudah tersimpan di server.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      _formKey.currentState!.reset();
      _title = _description = _techStack = _projectUrl = _imageUrl = '';
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.statusCode == 401) {
        try {
          await context.read<AuthState>().logout();
        } catch (_) {
          // AuthState clears the local token even when revocation fails.
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Sesi berakhir. Login kembali, lalu tekan Save untuk mengirim ulang.',
            ),
          ),
        );
        await ensureLoggedIn(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error.statusCode == 403
                  ? 'Akun ini tidak memiliki izin menambahkan proyek (403).'
                  : 'Proyek gagal disimpan (${error.statusCode}). Periksa isian formulir.',
            ),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tidak dapat menghubungi server. Isian formulir tetap tersimpan.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Project Form')),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                enabled: !_isSubmitting,
                onChanged: (value) => _title = value,
                validator: _required,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                enabled: !_isSubmitting,
                maxLines: 5,
                onChanged: (value) => _description = value,
                validator: _required,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Tech Stack',
                  hintText: 'Flutter, Django',
                  border: OutlineInputBorder(),
                ),
                enabled: !_isSubmitting,
                onChanged: (value) => _techStack = value,
                validator: _required,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Project URL',
                  border: OutlineInputBorder(),
                ),
                enabled: !_isSubmitting,
                keyboardType: TextInputType.url,
                onChanged: (value) => _projectUrl = value,
                validator: _url,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Project Image URL (Optional)',
                  border: OutlineInputBorder(),
                ),
                enabled: !_isSubmitting,
                keyboardType: TextInputType.url,
                onChanged: (value) => _imageUrl = value,
                validator: (value) => _url(value, optional: true),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
