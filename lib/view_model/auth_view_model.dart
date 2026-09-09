
import 'package:flutter/foundation.dart';
import '../data/auth_service.dart';
import '../models/user_profile.dart';
 
enum AuthStatus { checking, unauthenticated, authenticated }
 
class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;
 
  AuthViewModel(this._authService);
 
  AuthStatus _status = AuthStatus.checking;
  UserProfile? _currentUser;
  String? _errorMessage;
  bool _isLoading = false;
 
  AuthStatus get status => _status;
  UserProfile? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
 
  // ─── Inicialização ─────────────────────────────────────────────────────────
 
  /// Chamado no boot do app — restaura sessão persistida se existir.
  Future<void> checkSession() async {
    _status = AuthStatus.checking;
    notifyListeners();
 
    try {
      final user = await _authService.getActiveSession();
      if (user != null) {
        _currentUser = user;
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    }
 
    notifyListeners();
  }
 
  // ─── Login ─────────────────────────────────────────────────────────────────
 
  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    _clearError();
 
    try {
      final user = await _authService.login(email: email, password: password);
      _currentUser = user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }
 
  // ─── Cadastro ──────────────────────────────────────────────────────────────
 
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();
 
    try {
      final user = await _authService.register(
        name: name,
        email: email,
        password: password,
      );
      _currentUser = user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }
 
  // ─── Logout ────────────────────────────────────────────────────────────────
 
  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
 
  // ─── Helpers ───────────────────────────────────────────────────────────────
 
  void clearError() => _clearError();
 
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
 
  void _clearError() {
    _errorMessage = null;
  }
}