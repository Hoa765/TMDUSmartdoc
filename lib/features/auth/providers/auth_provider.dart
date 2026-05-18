// =============================================================================
// AUTH PROVIDER — Bộ quản lý xác thực người dùng (Firebase Auth)
// =============================================================================
// HAI LUỒNG ĐĂNG NHẬP:
//
// 1. EMAIL / PASSWORD:
//    signInWithEmailAndPassword(email, password)
//    → Firebase xác thực → trả về User object
//    → authStateChanges stream phát ra User mới → _user được cập nhật
//
// 2. GOOGLE SIGN-IN (khác nhau giữa Web và Android/iOS):
//
//    [Web]:
//      GoogleAuthProvider → signInWithPopup()
//      → Firebase mở cửa sổ popup Google chính thức
//      → Người dùng chọn tài khoản → Firebase nhận credential
//
//    [Android/iOS]:
//      GoogleSignIn.signIn() → GoogleSignInAccount
//         ↓
//      googleUser.authentication → { accessToken, idToken }
//         ↓
//      GoogleAuthProvider.credential(accessToken, idToken)
//         ↓
//      FirebaseAuth.signInWithCredential(credential)
//      → Firebase xác nhận credential → trả về UserCredential
//
// SAU KHI ĐĂNG NHẬP:
//   GoRouter redirect tự động chuyển /login → /home
//   (authStateChanges → notifyListeners → GoRouter re-evaluate redirect)
//
// ĐĂNG XUẤT:
//   googleSignIn.signOut() → xóa token Google
//   auth.signOut() → xóa Firebase session
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // GoogleSignIn: dùng OAuth 2.0 Web Client ID để xác định ứng dụng với Google
  // clientId bắt buộc trên Web; Android/iOS lấy từ google-services.json
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '197561823479-snjn78rkb2b9874a0pudcbqpkaglum32.apps.googleusercontent.com',
  );

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  String? get userName => _user?.displayName ?? _user?.email ?? 'Người dùng';
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  User? get user => _user;
  String? get errorMessage => _errorMessage;

  /// Constructor: lắng nghe stream trạng thái xác thực Firebase.
  ///
  /// authStateChanges() là một Stream:
  ///   - Phát ra User object khi đăng nhập thành công
  ///   - Phát ra null khi đăng xuất
  ///   - Tự phát lại ngay khi có listener mới (replay semantic)
  ///
  /// Bằng cách lắng nghe stream này, Provider luôn biết trạng thái auth
  /// hiện tại mà không cần polling hay kiểm tra thủ công.
  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners(); // GoRouter sẽ re-evaluate redirect khi _user thay đổi
    });
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseError(e.code);
      return false;
    } catch (e) {
      _errorMessage = 'Đã xảy ra lỗi. Vui lòng thử lại.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String email, String password, String displayName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (displayName.isNotEmpty) {
        await cred.user?.updateDisplayName(displayName);
      }
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseError(e.code);
      return false;
    } catch (e) {
      _errorMessage = 'Đã xảy ra lỗi. Vui lòng thử lại.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseError(e.code);
      return false;
    } catch (e) {
      _errorMessage = 'Đã xảy ra lỗi. Vui lòng thử lại.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email hoặc mật khẩu không đúng.';
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này.';
      case 'email-already-in-use':
        return 'Email này đã được sử dụng.';
      case 'weak-password':
        return 'Mật khẩu quá yếu. Vui lòng dùng ít nhất 6 ký tự.';
      case 'invalid-email':
        return 'Địa chỉ email không hợp lệ.';
      case 'too-many-requests':
        return 'Quá nhiều lần thử. Vui lòng thử lại sau.';
      case 'network-request-failed':
        return 'Lỗi kết nối mạng. Kiểm tra internet và thử lại.';
      default:
        return 'Đã xảy ra lỗi. Vui lòng thử lại.';
    }
  }

  /// Đăng nhập bằng Google (xử lý khác nhau trên Web vs Native).
  ///
  /// Trả về true nếu thành công, false nếu người dùng huỷ hoặc lỗi.
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (kIsWeb) {
        // ── WEB ──────────────────────────────────────────────────────────────
        // Trên Web, google_sign_in package không hoạt động tốt.
        // Dùng trực tiếp Firebase GoogleAuthProvider + signInWithPopup()
        // → Firebase mở cửa sổ popup OAuth 2.0 của Google
        // → Người dùng đồng ý → Firebase nhận auth code → trao đổi lấy token
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        await _auth.signInWithPopup(googleProvider);
        return true;
      } else {
        // ── ANDROID / iOS ─────────────────────────────────────────────────────
        // Bước 1: Mở màn hình chọn tài khoản Google (native UI)
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

        // Người dùng bấm "Huỷ" → googleUser = null
        if (googleUser == null) {
          _isLoading = false;
          notifyListeners();
          return false;
        }

        // Bước 2: Lấy credential từ tài khoản đã chọn
        // authentication trả về: accessToken (gọi Google APIs) + idToken (cho Firebase)
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        // Bước 3: Tạo Firebase credential từ Google tokens
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Bước 4: Đăng nhập Firebase với Google credential
        // Firebase verify idToken → tạo/cập nhật User record → trả về UserCredential
        await _auth.signInWithCredential(credential);
        return true;
      }
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Đăng xuất khỏi cả Google và Firebase.
  ///
  /// Thứ tự quan trọng: đăng xuất Google trước để xóa token local,
  /// sau đó đăng xuất Firebase để xóa session.
  /// authStateChanges sẽ phát ra null → GoRouter redirect về /login.
  Future<void> logout() async {
    await _googleSignIn.signOut(); // Xóa token Google trên thiết bị
    await _auth.signOut();         // Xóa Firebase session → authStateChanges phát null
  }
}
