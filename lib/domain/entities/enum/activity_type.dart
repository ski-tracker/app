import 'package:ski_tracker/l10n/app_localizations.dart';

enum ActivityType { skiing, running, walking, cycling }

extension ActivityTypeExtension on ActivityType {
  String getTranslatedName(AppLocalizations localization) {
    switch (this) {
      case ActivityType.skiing:
        return localization.skiing;
      case ActivityType.running:
        return localization.running;
      case ActivityType.walking:
        return localization.walking;
      case ActivityType.cycling:
        return localization.cycling;
      default:
        return '';
    }
  }
}
