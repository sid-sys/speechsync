import 'dart:convert';
import 'package:intl/intl.dart';

class NoteModel {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final String? translatedContent;
  final String? tone;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.translatedContent,
    this.tone,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'translatedContent': translatedContent,
    'tone': tone,
  };

  factory NoteModel.fromJson(Map<String, dynamic> json) => NoteModel(
    id: json['id'],
    title: json['title'],
    content: json['content'],
    createdAt: DateTime.parse(json['createdAt']),
    translatedContent: json['translatedContent'],
    tone: json['tone'],
  );

  String get formattedDate => DateFormat('MMM d, h:mm a').format(createdAt);
}
