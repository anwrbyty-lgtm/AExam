class Question {
  final String text;
  final String type;
  final List<String> options;
  final String correctAnswer;

  Question({
    required this.text,
    required this.type,
    this.options = const [],
    this.correctAnswer = '',
  });
}

class ExamData {
  final String subject;
  final String examType;
  final String grade;
  final String duration;
  final String period;
  final List<Question> trueFalseQuestions;
  final List<Question> mcqQuestions;

  ExamData({
    required this.subject,
    required this.examType,
    required this.grade,
    required this.duration,
    required this.period,
    this.trueFalseQuestions = const [],
    this.mcqQuestions = const [],
  });
}
