import 'package:flutter/widgets.dart';
import 'package:moodlyy_application/l10n/app_localizations.dart';
import '../../mood/domain/mood.dart';

extension Emotion5L10n on Emotion5 {
  String l10n(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    switch (this) {
      case Emotion5.verySad:
        return t.emotion_very_sad;
      case Emotion5.sad:
        return t.emotion_sad;
      case Emotion5.neutral:
        return t.emotion_neutral;
      case Emotion5.happy:
        return t.emotion_happy;
      case Emotion5.veryHappy:
        return t.emotion_very_happy;
    }
  }
}

extension PeopleL10n on People {
  String l10n(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    switch (this) {
      case People.stranger:
        return t.people_stranger;
      case People.family:
        return t.people_family;
      case People.friends:
        return t.people_friends;
      case People.partner:
        return t.people_partner;
      case People.lover:
        return t.people_lover;
    }
  }
}

extension AnotherEmotionL10n on AnotherEmotion {
  String l10n(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    switch (this) {
      case AnotherEmotion.excited:
        return t.another_excited;
      case AnotherEmotion.relaxed:
        return t.another_relaxed;
      case AnotherEmotion.proud:
        return t.another_proud;
      case AnotherEmotion.hopeful:
        return t.another_hopeful;
      case AnotherEmotion.happy:
        return t.another_happy;
      case AnotherEmotion.enthusiastic:
        return t.another_enthusiastic;
      case AnotherEmotion.pitAPart:
        // key dùng snake case khớp ARB: another_pit_a_part
        return t.another_pit_a_part;
      case AnotherEmotion.refreshed:
        return t.another_refreshed;
      case AnotherEmotion.depressed:
        return t.another_depressed;
      case AnotherEmotion.lonely:
        return t.another_lonely;
      case AnotherEmotion.anxious:
        return t.another_anxious;
      case AnotherEmotion.sad:
        return t.another_sad;
      case AnotherEmotion.angry:
        return t.another_angry;
      case AnotherEmotion.pressured:
        return t.another_pressured;
      case AnotherEmotion.annoyed:
        return t.another_annoyed;
      case AnotherEmotion.tired:
        return t.another_tired;
    }
  }
}
