/// Temporary auth service (NO real login yet).
/// Step 2 will replace the body of [signIn] with Firebase Auth.
/// The screens only call this class, so they won't need to change.
class AuthService {
  Future<void> signIn({required String email, required String password}) async {
    await Future.delayed(const Duration(seconds: 1)); // fake network wait
    // Placeholder rule so we can test the error state:
    if (password == 'wrong') {
      throw const AuthException('Incorrect email or password.');
    }
  }
}
 
class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
 
  @override
  String toString() => message;
}