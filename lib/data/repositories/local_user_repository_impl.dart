import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/utils/local_storage_service.dart';
import '../../core/utils/sharedPrefs_utils.dart';
import '../../domain/repositories/user_repository.dart';
import '../model/request/edit_password_request.dart';
import '../model/request/login_request.dart';
import '../model/request/send_new_password_request.dart';
import '../model/response/login_response.dart';

/// Local storage implementation of UserRepository
final localUserRepositoryProvider =
    Provider<UserRepository>((ref) => LocalUserRepoImpl());

interface class LocalUserRepoImpl extends UserRepository {
  LocalUserRepoImpl();

  @override
  Future<int> register(LoginRequest request) async {
    // Check if user already exists
    final exists = await LocalStorageService.userExists(request.username);
    if (exists) {
      throw Exception('User already exists');
    }

    // Register user in local storage
    final userId = await LocalStorageService.registerUser(
      request.username,
      request.password,
    );

    // Auto-login after registration
    await login(request);

    return userId;
  }

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    // Verify credentials
    final isValid = await LocalStorageService.verifyUser(
      request.username,
      request.password,
    );

    if (!isValid) {
      throw Exception('Invalid username or password');
    }

    // Generate mock tokens (in real app, these would come from backend)
    final mockToken = 'local_token_${DateTime.now().millisecondsSinceEpoch}';
    final mockRefreshToken = 'local_refresh_${DateTime.now().millisecondsSinceEpoch}';

    // Save tokens
    await PrefsUtils.setJwt(mockToken);
    await PrefsUtils.setRefreshToken(mockRefreshToken);

    return LoginResponse(
      token: mockToken,
      refreshedToken: mockRefreshToken,
      message: 'Login successful (local mode)',
    );
  }

  @override
  Future<void> logout() async {
    await PrefsUtils.removeJwt();
    await PrefsUtils.removeRefreshToken();
  }

  @override
  Future<void> deleteaccount() async {
    // In local mode, just clear tokens
    await logout();
  }

  @override
  Future<void> sendNewPasswordByMail(SendNewPasswordRequest request) async {
    // In local mode, this is a no-op
    // In a real implementation, you might want to show a message
    throw Exception('Password reset not available in local mode');
  }

  @override
  Future<void> editPassword(EditPasswordRequest request) async {
    // In local mode, password editing is not implemented
    // You could extend LocalStorageService to support this
    throw Exception('Password editing not available in local mode');
  }
}

