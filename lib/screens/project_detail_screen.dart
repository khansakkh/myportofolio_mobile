import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/project.dart';

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({required this.project, super.key});

  final Project project;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(project.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (project.projectImageUrl.isNotEmpty) ...[
              Image.network(
                project.projectImageUrl,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, error, stackTrace) => const SizedBox(
                  height: 100,
                  child: Center(child: Text('Gambar tidak dapat dimuat.')),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              project.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text('Teknologi: ${project.techStack}'),
            const SizedBox(height: 12),
            Text(project.description),
            const SizedBox(height: 16),
            SelectableText('URL proyek: ${project.projectUrl}'),
            if (project.id != null) ...[
              const SizedBox(height: 12),
              SelectableText('ID: ${project.id}'),
            ],
          ],
        ),
      ),
    );
  }
}
