import 'package:intl/intl.dart';

class AiMessageModel {
  final String id;
  final String text;
  final bool isUser;
  final int timestamp;
  final String category;

  const AiMessageModel({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    required this.category,
  });

  String get formattedTime {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('HH:mm').format(dt);
  }

  factory AiMessageModel.fromMap(Map<String, dynamic> map) {
    return AiMessageModel(
      id: map['id'] as String,
      text: map['text'] as String,
      isUser: (map['isUser'] as int) == 1,
      timestamp: map['timestamp'] as int,
      category: map['category'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'isUser': isUser ? 1 : 0,
      'timestamp': timestamp,
      'category': category,
    };
  }

  AiMessageModel copyWith({
    String? id,
    String? text,
    bool? isUser,
    int? timestamp,
    String? category,
  }) {
    return AiMessageModel(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      category: category ?? this.category,
    );
  }
}
