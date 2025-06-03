import 'package:hive/hive.dart';

part 'rejected_suggestion.g.dart';

@HiveType(typeId: 99)
class RejectedSuggestion {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String? suggestedCategory;

  @HiveField(2)
  final DateTime rejectedAt;

  RejectedSuggestion({
    required this.title,
    required this.suggestedCategory,
    required this.rejectedAt,
  });
}
