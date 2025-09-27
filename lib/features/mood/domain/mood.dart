import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

/// 5 mức cảm xúc chính
enum Emotion5 { verySad, sad, neutral, happy, veryHappy }

/// Các cảm xúc phụ (chips)
enum AnotherEmotion {
  excited,
  relaxed,
  proud,
  hopeful,
  happy,
  enthusiastic,
  pitAPart, // file của em: pit-a-part.png
  refreshed,
  depressed,
  lonely,
  anxious,
  sad,
  angry,
  pressured,
  annoyed,
  tired,
}

/// Người liên quan
enum People { stranger, family, friends, partner, lover }

/// ================= Extensions: asset path, label, color =================

extension Emotion5X on Emotion5 {
  String get label => switch (this) {
    Emotion5.verySad => 'Very Sad',
    Emotion5.sad => 'Sad',
    Emotion5.neutral => 'Neutral',
    Emotion5.happy => 'Happy',
    Emotion5.veryHappy => 'Very Happy',
  };

  /// map sang file trong assets/emotion/
  String get assetPath => switch (this) {
    Emotion5.verySad => 'assets/emotion/verysad.png',
    Emotion5.sad => 'assets/emotion/sad-face.png',
    Emotion5.neutral => 'assets/emotion/neutral.png',
    Emotion5.happy => 'assets/emotion/happy.png',
    Emotion5.veryHappy => 'assets/emotion/veryhappy.png',
  };

  /// Màu nền gợi ý khi đã react mood ngày đó
  Color get color => switch (this) {
    Emotion5.verySad => const Color(0xFF8AA8FF),
    Emotion5.sad => const Color(0xFF7BA6C9),
    Emotion5.neutral => const Color(0xFFB0B0B0),
    Emotion5.happy => const Color(0xFFF4E087),
    Emotion5.veryHappy => const Color(0xFFFFE28A),
  };

  /// string để lưu DB
  String get db => switch (this) {
    Emotion5.verySad => 'very_sad',
    Emotion5.sad => 'sad',
    Emotion5.neutral => 'neutral',
    Emotion5.happy => 'happy',
    Emotion5.veryHappy => 'very_happy',
  };

  static Emotion5 fromDb(String s) => switch (s) {
    'very_sad' => Emotion5.verySad,
    'sad' => Emotion5.sad,
    'neutral' => Emotion5.neutral,
    'happy' => Emotion5.happy,
    'very_happy' => Emotion5.veryHappy,
    _ => Emotion5.neutral,
  };
}

extension AnotherEmotionX on AnotherEmotion {
  String get label => switch (this) {
    AnotherEmotion.excited => 'Excited',
    AnotherEmotion.relaxed => 'Relaxed',
    AnotherEmotion.proud => 'Proud',
    AnotherEmotion.hopeful => 'Hopeful',
    AnotherEmotion.happy => 'Happy',
    AnotherEmotion.enthusiastic => 'Enthusiastic',
    AnotherEmotion.pitAPart => 'Pit-a-part',
    AnotherEmotion.refreshed => 'Refreshed',
    AnotherEmotion.depressed => 'Depressed',
    AnotherEmotion.lonely => 'Lonely',
    AnotherEmotion.anxious => 'Anxious',
    AnotherEmotion.sad => 'Sad',
    AnotherEmotion.angry => 'Angry',
    AnotherEmotion.pressured => 'Pressured',
    AnotherEmotion.annoyed => 'Annoyed',
    AnotherEmotion.tired => 'Tired',
  };

  /// map sang file trong assets/anotheremotion/
  String get assetPath => switch (this) {
    AnotherEmotion.angry => 'assets/anotheremotion/angry.png',
    AnotherEmotion.annoyed => 'assets/anotheremotion/annoyed.png',
    AnotherEmotion.anxious => 'assets/anotheremotion/anxious.png',
    AnotherEmotion.depressed => 'assets/anotheremotion/depressed.png',
    AnotherEmotion.enthusiastic => 'assets/anotheremotion/enthusiastic.png',
    AnotherEmotion.excited => 'assets/anotheremotion/excited.png',
    AnotherEmotion.happy => 'assets/anotheremotion/happy.png',
    AnotherEmotion.hopeful => 'assets/anotheremotion/hopeful.png',
    AnotherEmotion.lonely => 'assets/anotheremotion/lonely.png',
    AnotherEmotion.pitAPart => 'assets/anotheremotion/pit-a-part.png',
    AnotherEmotion.pressured => 'assets/anotheremotion/pressured.png',
    AnotherEmotion.proud => 'assets/anotheremotion/proud.png',
    AnotherEmotion.refreshed => 'assets/anotheremotion/refreshed.png',
    AnotherEmotion.relaxed => 'assets/anotheremotion/relaxed.png',
    AnotherEmotion.sad => 'assets/anotheremotion/sad.png',
    AnotherEmotion.tired => 'assets/anotheremotion/tired.png',
  };

  /// string để lưu DB (dùng luôn name, trừ pit-a-part)
  String get db => switch (this) {
    AnotherEmotion.pitAPart => 'pit-a-part',
    _ => name,
  };

  static AnotherEmotion fromDb(String s) {
    if (s == 'pit-a-part') return AnotherEmotion.pitAPart;
    return AnotherEmotion.values.firstWhere(
      (e) => e.name == s,
      orElse: () => AnotherEmotion.happy,
    );
  }
}

extension PeopleX on People {
  String get label => switch (this) {
    People.stranger => 'Stranger',
    People.family => 'Family',
    People.friends => 'Friends',
    People.partner => 'Partner',
    People.lover => 'Lover',
  };

  String get assetPath => switch (this) {
    People.family => 'assets/people/family.png',
    People.friends => 'assets/people/friends.png',
    People.lover => 'assets/people/lover.png',
    People.partner => 'assets/people/partner.png',
    People.stranger => 'assets/people/stranger.png',
  };

  String get db => name;
  static People fromDb(String s) => People.values.firstWhere(
    (e) => e.name == s,
    orElse: () => People.stranger,
  );
}

/// ========================= Entity =========================
class Mood {
  final String? id; // uuid từ server
  final DateTime day; // yyyy-mm-dd (00:00 local)
  final Emotion5 emotion; // cảm xúc chính
  final List<AnotherEmotion> another;
  final List<People> people;
  final String? note;

  // ✅ NEW: đọc timestamp từ Supabase để tính streak theo NGÀY log thực
  final DateTime? createdAt; // map 'created_at'
  final DateTime? updatedAt; // map 'updated_at'

  Mood({
    this.id,
    required this.day,
    required this.emotion,
    this.another = const [],
    this.people = const [],
    this.note,
    this.createdAt, // NEW
    this.updatedAt, // NEW
  });

  Mood copyWith({
    String? id,
    DateTime? day,
    Emotion5? emotion,
    List<AnotherEmotion>? another,
    List<People>? people,
    String? note,
    DateTime? createdAt, // NEW
    DateTime? updatedAt, // NEW
  }) {
    return Mood(
      id: id ?? this.id,
      day: day ?? this.day,
      emotion: emotion ?? this.emotion,
      another: another ?? this.another,
      people: people ?? this.people,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt, // NEW
      updatedAt: updatedAt ?? this.updatedAt, // NEW
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Mood &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          normalizeDate(day) == normalizeDate(other.day) &&
          emotion == other.emotion &&
          listEquals(another, other.another) &&
          listEquals(people, other.people) &&
          note == other.note;

  @override
  int get hashCode =>
      (id ?? '').hashCode ^
      normalizeDate(day).hashCode ^
      emotion.hashCode ^
      Object.hashAll(another) ^
      Object.hashAll(people) ^
      (note ?? '').hashCode;

  Map<String, dynamic> toJson(String userId) => {
    'user_id': userId,
    'day': normalizeDate(day).toIso8601String(),
    'emotion': emotion.db,
    'another_emotions': another.map((e) => e.db).toList(),
    'people': people.map((e) => e.db).toList(),
    'note': note,
    // ❌ Không gửi created_at/updated_at — Supabase tự set
  };

  static Mood fromJson(Map<String, dynamic> j) => Mood(
    id: j['id'] as String?,
    day: DateTime.parse(j['day'] as String).toLocal(),
    emotion: Emotion5X.fromDb(j['emotion'] as String),
    another: ((j['another_emotions'] as List?) ?? [])
        .cast<String>()
        .map(AnotherEmotionX.fromDb)
        .toList(),
    people: ((j['people'] as List?) ?? [])
        .cast<String>()
        .map(PeopleX.fromDb)
        .toList(),
    note: j['note'] as String?,
    // ✅ NEW: parse timestamp (có thể null với data cũ)
    createdAt: j['created_at'] != null
        ? DateTime.parse(j['created_at'] as String).toLocal()
        : null,
    updatedAt: j['updated_at'] != null
        ? DateTime.parse(j['updated_at'] as String).toLocal()
        : null,
  );
}
