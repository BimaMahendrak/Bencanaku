import '../controller/loginController.dart';

class SessionService {
  static final LoginController _loginController = LoginController();

  static Future<bool> checkAuthStatus() async {
    try {
      final isLoggedIn = await _loginController.isLoggedIn();
      final isValid = await _loginController.isSessionValid();
      
      print('Auth Status - Logged In: $isLoggedIn, Valid: $isValid');
      return isLoggedIn && isValid;
    } catch (e) {
      print('Auth Check Error: $e');
      return false;
    }
  }

  static Future<void> clearExpiredSession() async {
    try {
      final isValid = await _loginController.isSessionValid();
      if (!isValid) {
        await _loginController.logout();
      }
    } catch (e) {
      print('Clear Session Error: $e');
    }
  }

  static Future<String?> getUsername() async {
    return await _loginController.getUsername();
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    return await _loginController.getUserData();
  }

  static Future<void> logout() async {
    await _loginController.logout();
  }
}