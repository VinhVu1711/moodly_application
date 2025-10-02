import 'package:flutter/widgets.dart';
import 'package:moodlyy_application/l10n/app_localizations.dart';

extension CtxL10n on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
