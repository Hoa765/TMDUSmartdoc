// =============================================================================
// CHAT PROVIDER — Bộ quản lý trạng thái màn hình Chat
// =============================================================================
// LUỒNG THUẬT TOÁN CHÍNH (RAG - Retrieval Augmented Generation):
//
//   [Người dùng gõ câu hỏi]
//         ↓
//   sendMessage(text)
//         ↓
//   [Lưu câu hỏi vào Firestore]
//         ↓
//   [Gọi POST /chat/ask lên FastAPI Railway]
//         ↓  (Backend thực hiện RAG):
//         |   1. Embed câu hỏi → vector 768 chiều (Gemini text-embedding-004)
//         |   2. Tìm kiếm pgvector: cosine similarity trên Supabase
//         |   3. Lấy top-3 đoạn văn bản gần nhất (chunks)
//         |   4. Ghép context + hỏi Gemini 2.5 Flash
//         |   5. Trả về { answer, citations }
//         ↓
//   [Hiển thị câu trả lời + trích dẫn trang]
//         ↓
//   [Lưu câu trả lời AI vào Firestore]
//
// FALLBACK: Nếu backend lỗi → hiển thị thông báo lỗi thân thiện
// =============================================================================

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants.dart';
import '../../../shared/widgets/widgets.dart';

/// Một tin nhắn trong cuộc hội thoại.
/// [isAi] = true → tin nhắn từ AI, false → từ người dùng.
/// [citations] = danh sách trích dẫn trang trong tài liệu gốc.
class ChatMessage {
  final String text;
  final bool isAi;
  final List<CitationData> citations;

  ChatMessage({
    required this.text,
    required this.isAi,
    this.citations = const [],
  });
}

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _isLoadingHistory = false;
  bool _hasLoadedHistory = false;
  Timer? _responseTimer;

  String? _activeDocId;
  String? _activeDocTitle;
  // ID cuộc hội thoại — mỗi lần startNewConversation() tạo ID mới
  String _chatId = 'default_chat';

  String? get activeDocId => _activeDocId;
  String? get activeDocTitle => _activeDocTitle;

  /// Tạo cuộc hội thoại mới — tách biệt hoàn toàn với cuộc trước.
  /// Được gọi khi: upload PDF xong, bấm nút "+" trên chat screen,
  /// hoặc chọn tài liệu từ HomeScreen.
  void startNewConversation({String? docId, String? docTitle}) {
    _chatId = 'chat_${DateTime.now().millisecondsSinceEpoch}';
    _activeDocId = docId;
    _activeDocTitle = docTitle;
    _messages.clear();
    _hasLoadedHistory = true; // Cuộc mới = không có lịch sử cũ để tải
    final greeting = docTitle != null
        ? 'Xin chào! Tôi sẵn sàng trả lời câu hỏi về tài liệu "$docTitle".'
        : 'Xin chào! Tôi sẵn sàng trả lời câu hỏi về tài liệu của bạn.';
    _messages.add(ChatMessage(text: greeting, isAi: true));
    notifyListeners();
  }

  void setActiveDoc(String? docId, {String? docTitle}) {
    startNewConversation(docId: docId, docTitle: docTitle);
  }

  List<ChatMessage> get messages => _messages;
  bool get isTyping => _isTyping;
  bool get isLoadingHistory => _isLoadingHistory;

  // Lấy UID người dùng hiện tại (null nếu chưa đăng nhập)
  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  /// Constructor: khởi tạo tin nhắn chào mừng và tải lịch sử chat.
  ChatProvider() {
    // Tin nhắn chào mặc định khi mở app lần đầu
    _messages.add(
      ChatMessage(
        text: 'Xin chào! Tôi đã hoàn thành phân tích tài liệu "AI_Research_Paper_2026.pdf". Hôm nay tôi có thể giúp gì cho bạn?',
        isAi: true,
      ),
    );
    // Tự động tải lịch sử chat từ Firestore khi khởi động Provider
    loadHistory();
  }

  /// Tải lịch sử chat từ Firestore.
  ///
  /// Cấu trúc Firestore:
  ///   users/{uid}/chats/default_chat/messages/{messageId}
  ///     - text: String
  ///     - isAi: bool
  ///     - timestamp: Timestamp (dùng để sắp xếp theo thứ tự thời gian)
  ///     - citations: List<Map>
  ///
  /// Thuật toán:
  ///   1. Kiểm tra guard: nếu đã tải rồi hoặc đang tải → bỏ qua
  ///   2. Query Firestore, sắp xếp theo timestamp tăng dần (tin cũ nhất lên đầu)
  ///   3. Nếu có dữ liệu → xóa tin nhắn hiện tại, map từng document → ChatMessage
  ///   4. Đặt cờ _hasLoadedHistory = true để không tải lại
  Future<void> loadHistory() async {
    // Guard: tránh tải trùng lặp
    if (_hasLoadedHistory || _isLoadingHistory) return;
    final uid = _userId;
    if (uid == null) return; // Chưa đăng nhập → không có lịch sử

    _isLoadingHistory = true;
    notifyListeners();

    try {
      // Query Firestore: lấy tất cả messages, sắp xếp cũ → mới
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('chats')
          .doc(_chatId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .get();

      if (snapshot.docs.isNotEmpty) {
        _messages.clear(); // Xóa tin nhắn chào mặc định
        for (var doc in snapshot.docs) {
          final data = doc.data();

          // Parse danh sách trích dẫn từ Map → CitationData object
          final List<dynamic> citData = data['citations'] ?? [];
          final citations = citData
              .map((c) => CitationData(c['label'] ?? '', c['value'] ?? ''))
              .toList();

          _messages.add(
            ChatMessage(
              text: data['text'] ?? '',
              isAi: data['isAi'] ?? false,
              citations: citations,
            ),
          );
        }
      }
      _hasLoadedHistory = true;
    } catch (e) {
      debugPrint('Lỗi tải lịch sử chat từ Firestore: $e');
      // Không throw — giữ nguyên tin nhắn chào mặc định nếu Firestore lỗi
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  /// Gửi tin nhắn và nhận câu trả lời từ AI (RAG pipeline).
  ///
  /// LUỒNG THUẬT TOÁN ĐẦY ĐỦ:
  ///
  /// Bước 1 — Hiển thị ngay tin nhắn của user + bật animation "đang gõ"
  /// Bước 2 — Lưu tin nhắn user vào Firestore (async, không chờ)
  /// Bước 3 — Kiểm tra: nếu URL backend chưa được cài → dùng mock fallback
  /// Bước 4 — Lấy Firebase ID Token (JWT) để xác thực với backend
  /// Bước 5 — Gọi POST /chat/ask với { message, doc_id? }
  ///           Backend sẽ: embed → pgvector search → Gemini generate → trả về
  /// Bước 6 — Parse JSON response: lấy answer + citations
  /// Bước 7 — Lưu câu trả lời AI vào Firestore
  /// Bước 8 — Nếu lỗi → hiển thị thông báo lỗi thân thiện
  void sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Bước 1: Hiển thị tin nhắn người dùng ngay lập tức (optimistic UI)
    final userMessage = ChatMessage(text: text, isAi: false);
    _messages.add(userMessage);
    _isTyping = true; // Bật hiệu ứng "AI đang gõ..."
    notifyListeners();

    final uid = _userId;
    final user = FirebaseAuth.instance.currentUser;

    // Bước 2: Lưu tin nhắn user vào Firestore (fire-and-forget, không await)
    if (uid != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('chats')
            .doc(_chatId)
            .collection('messages')
            .add({
          'text': text,
          'isAi': false,
          'timestamp': FieldValue.serverTimestamp(), // Firestore tự điền thời gian server
          'citations': [],
        });
      } catch (e) {
        debugPrint('Lỗi lưu tin nhắn của User vào Firestore: $e');
      }
    }

    // Bước 3: Kiểm tra mock fallback
    // Nếu URL vẫn là placeholder HOẶC người dùng chưa đăng nhập → mock
    if (AppConstants.backendBaseUrl.contains('your-backend-railway-url') || user == null) {
      // Delay 1.5s giả lập AI đang "suy nghĩ"
      _responseTimer?.cancel();
      _responseTimer = Timer(const Duration(milliseconds: 1500), () async {
        _isTyping = false;
        final mockAiMessage = ChatMessage(
          text: 'Dựa trên tài liệu, Trí tuệ Nhân tạo đang ngày càng áp dụng các kiến trúc đa phương thức (multi-modal) để cải thiện hiểu biết ngữ cảnh. Điều này hoàn toàn phù hợp với câu hỏi của bạn về giới hạn tạo sinh.',
          isAi: true,
          citations: [CitationData('Trang', '12'), CitationData('Trang', '20')],
        );
        _messages.add(mockAiMessage);

        // Lưu mock response vào Firestore để lịch sử đồng bộ
        if (uid != null) {
          try {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .collection('chats')
                .doc(_chatId)
                .collection('messages')
                .add({
              'text': mockAiMessage.text,
              'isAi': true,
              'timestamp': FieldValue.serverTimestamp(),
              'citations': mockAiMessage.citations
                  .map((c) => {'label': c.label, 'value': c.value})
                  .toList(),
            });
          } catch (e) {
            debugPrint('Lỗi lưu tin nhắn AI mẫu vào Firestore: $e');
          }
        }
        notifyListeners();
      });
      return;
    }

    try {
      // Bước 4: Lấy Firebase ID Token để backend xác thực người dùng
      // ID Token là JWT, hết hạn sau 1 giờ, Firebase tự làm mới
      final idToken = await user.getIdToken();

      // Bước 5: Xây dựng request body
      // Nếu có _activeDocId → chỉ tìm trong tài liệu đó (match_chunks_by_doc)
      // Nếu không có → tìm trên toàn bộ tài liệu của user (match_chunks)
      final body = <String, dynamic>{'message': text};
      if (_activeDocId != null) body['doc_id'] = _activeDocId;

      // Gọi POST /chat/ask với timeout 30 giây
      // Backend RAG pipeline mất khoảng 2-5 giây (embed + pgvector + Gemini)
      final response = await http.post(
        Uri.parse('${AppConstants.backendBaseUrl}/chat/ask'),
        headers: {
          'Authorization': 'Bearer $idToken', // Xác thực Firebase
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      ).timeout(const Duration(seconds: 30));

      _isTyping = false;

      debugPrint('✅ Chat response [${response.statusCode}]: ${response.body.substring(0, response.body.length.clamp(0, 200))}');

      if (response.statusCode == 200) {
        // Bước 6: Parse JSON response từ backend
        // Cấu trúc: { "answer": "...", "citations": [{"label": "Trang", "value": "12"}] }
        final data = json.decode(response.body);
        final String answer = data['answer'] ?? '';
        final List<dynamic> citData = data['citations'] ?? [];
        final citations = citData
            .map((c) => CitationData(c['label'] ?? 'Trang', c['value']?.toString() ?? ''))
            .toList();

        final aiMessage = ChatMessage(
          text: answer,
          isAi: true,
          citations: citations,
        );
        _messages.add(aiMessage);

        // Bước 7: Lưu câu trả lời AI vào Firestore để lưu lịch sử lâu dài
        if (uid != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('chats')
              .doc(_chatId)
              .collection('messages')
              .add({
            'text': answer,
            'isAi': true,
            'timestamp': FieldValue.serverTimestamp(),
            'citations': citations
                .map((c) => {'label': c.label, 'value': c.value})
                .toList(),
          });
        }
      } else {
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      // Bước 8: Xử lý lỗi — phân biệt timeout vs lỗi mạng khác
      debugPrint('❌ Chat error: $e');
      _isTyping = false;

      // Phân loại lỗi để hiển thị thông báo phù hợp
      final errorDetail = e.toString().contains('TimeoutException')
          ? 'Máy chủ phản hồi quá chậm, vui lòng thử lại.'
          : 'Không kết nối được máy chủ AI. Kiểm tra mạng và thử lại.';

      final mockAiMessage = ChatMessage(
        text: errorDetail,
        isAi: true,
        citations: [],
      );
      _messages.add(mockAiMessage);

      // Lưu thông báo lỗi vào Firestore để biết lúc nào hệ thống bị lỗi
      if (uid != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('chats')
            .doc(_chatId)
            .collection('messages')
            .add({
          'text': mockAiMessage.text,
          'isAi': true,
          'timestamp': FieldValue.serverTimestamp(),
          'citations': [{'label': 'Ngoại tuyến', 'value': 'Hệ thống'}],
        });
      }
    } finally {
      // Luôn tắt animation "đang gõ" và thông báo UI cập nhật
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _responseTimer?.cancel(); // Dọn dẹp timer khi Widget bị huỷ
    super.dispose();
  }
}
