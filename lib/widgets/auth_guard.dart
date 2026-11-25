import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

Future<bool> ensureLoggedIn(BuildContext context) async {
  if (context.read<AuthState>().isLoggedIn) return true;
  final loggedIn = await Navigator.push<bool>(
    context,
    MaterialPageRoute(builder: (_) => const LoginScreen()),
  );
  return loggedIn ?? false;
}

Future<void> logoutAndNotify(BuildContext context) async {
  String message = 'Kamu sudah logout.';
  try {
    await context.read<AuthState>().logout();
  } catch (_) {
    message =
        'Sesi lokal sudah dihapus. Logout di server gagal; coba login lagi saat terhubung.';
  }
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
