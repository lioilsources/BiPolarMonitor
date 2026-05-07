class DialogQuestion {
  final String questionId;    // "Q1"
  final String variant;       // "A" | "B" | "C"
  final String dimension;     // "orientation" | "abstraction" | ...
  final String text;

  const DialogQuestion({
    required this.questionId,
    required this.variant,
    required this.dimension,
    required this.text,
  });

  String get key => '$questionId$variant';  // e.g. "Q1B"

  factory DialogQuestion.fromJson(Map<String, dynamic> json) => DialogQuestion(
        questionId: json['question_id'] as String,
        variant: json['variant'] as String,
        dimension: json['dimension'] as String,
        text: json['text'] as String,
      );
}

class DialogSession {
  final String sessionId;
  final List<DialogQuestion> questions;
  final int suggestedDurationPerQuestion;

  const DialogSession({
    required this.sessionId,
    required this.questions,
    this.suggestedDurationPerQuestion = 30,
  });

  factory DialogSession.fromJson(Map<String, dynamic> json) => DialogSession(
        sessionId: json['session_id'] as String,
        questions: (json['questions'] as List)
            .map((q) => DialogQuestion.fromJson(q as Map<String, dynamic>))
            .toList(),
        suggestedDurationPerQuestion: json['suggested_duration_per_question'] as int? ?? 30,
      );
}

class QuestionTiming {
  final String questionId;
  final double startSeconds;
  final double? endSeconds;

  QuestionTiming({required this.questionId, required this.startSeconds, this.endSeconds});

  Map<String, dynamic> toJson() => {
        'start': startSeconds,
        if (endSeconds != null) 'end': endSeconds,
      };
}
