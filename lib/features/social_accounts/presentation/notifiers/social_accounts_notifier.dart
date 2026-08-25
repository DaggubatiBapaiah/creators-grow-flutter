import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/errors/app_error.dart';
import '../../data/repositories/social_accounts_repository.dart';
import '../../domain/models/social_account.dart';

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
      state = AsyncData(accounts);
    } on AppError catch (e, stack) {
      state = AsyncError(e, stack);
    } catch (e, stack) {
      state = AsyncError(UnknownError(e.toString()), stack);
    }
  }

  Future<void> connectMeta() async {
    try {
      // We now call the authenticated POST endpoint to generate the secure OAuth URL.
      // Dio interceptor handles the JWT automatically.
      final url = await _repository.getMetaConnectUrl();
      final uri = Uri.parse(url);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw const ServerError('Could not open OAuth connection page in browser.');
      }
    } catch (e) {
      state = AsyncError(
        e is AppError ? e : UnknownError(e.toString()),
        StackTrace.current
      );
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
