import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/errors/app_error.dart';
import '../../data/repositories/social_accounts_repository.dart';
import '../../domain/models/social_account.dart';
import '../../domain/models/social_platform.dart';

final socialAccountsNotifierProvider = StateNotifierProvider<SocialAccountsNotifier, AsyncValue<List<SocialAccount>>>((ref) {
  final repository = ref.watch(socialAccountsRepositoryProvider);
  return SocialAccountsNotifier(repository);
});

class SocialAccountsNotifier extends StateNotifier<AsyncValue<List<SocialAccount>>> {
  final SocialAccountsRepository _repository;

  SocialAccountsNotifier(this._repository) : super(const AsyncLoading()) {
    fetchAccounts();
  }

  Future<void> fetchAccounts() async {
    state = const AsyncLoading();
    try {
      final accounts = await _repository.getConnectedAccounts();
      print('[FORENSIC] NOTIFIER STATE = PASS (Received ${accounts.length} accounts)');
      if (accounts.isNotEmpty) {
        print('[FORENSIC] NOTIFIER ACCOUNTS = ${accounts.map((e) => e.platform.name).toList()}');
      }
      state = AsyncData(accounts);
    } on AppError catch (e, stack) {
      print('[FORENSIC] NOTIFIER STATE = FAIL ($e)');
      state = AsyncError(e, stack);
    } catch (e, stack) {
      print('[FORENSIC] NOTIFIER STATE = FAIL ($e)');
      state = AsyncError(UnknownError(e.toString()), stack);
    }
  }

  Future<void> connectPlatform(SocialPlatform platform) async {
    try {
      // We now call the authenticated POST endpoint to generate the secure OAuth URL.
      // Dio interceptor handles the JWT automatically.
      final url = await _repository.getConnectUrl(platform);
      final uri = Uri.parse(url);
      
      bool launched = false;
      try {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
      
      if (!launched) {
        throw const ServerError('Could not open OAuth connection page in browser.');
      }

      // Start background polling for OAuth completion
      _pollForConnection(platform);
    } on AppError {
      rethrow;
    } catch (e) {
      throw UnknownError('Could not open OAuth connection page in browser: ${e.toString()}');
    }
  }

  void _pollForConnection(SocialPlatform platform) async {
    // Poll every 3 seconds for up to 3 minutes (60 iterations) to reliably detect
    // when the backend OAuth callback successfully finishes processing and updates the DB.
    for (int i = 0; i < 60; i++) {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      
      try {
        final accounts = await _repository.getConnectedAccounts();
        final newlyConnected = accounts.any((acc) => acc.platform == platform);
        
        if (newlyConnected) {
          state = AsyncData(accounts);
          break; // Stop polling once detected
        }
      } catch (_) {
        // Ignore silent polling errors
      }
    }
  }

  Future<void> disconnectAccount(String id) async {
    final currentAccounts = state.value ?? [];
    state = const AsyncLoading();
    try {
      await _repository.disconnectAccount(id);
      final updated = currentAccounts.where((acc) => acc.id != id).toList();
      state = AsyncData(updated);
    } on AppError catch (e, stack) {
      state = AsyncError(e, stack);
    } catch (e, stack) {
      state = AsyncError(UnknownError(e.toString()), stack);
    }
  }
}
