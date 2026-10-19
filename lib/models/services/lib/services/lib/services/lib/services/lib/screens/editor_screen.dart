import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../models/exam_data.dart';
import '../services/pdf_service.dart';

class EditorScreen extends StatefulWidget {
  @override
  _EditorScreenState createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final _subjectController = TextEditingController(text: "فيزياء");
  final _gradeController = TextEditingController(text: "الأول");
  final _durationController = TextEditingController(text: "30 دقيقة");
  bool _isLoading = false;

  Future<void> _generatePdf() async {
    setState(() => _isLoading = true);
    final exam = ExamData(
      subject: _subjectController.text,
      examType: "اختبار شهري",
      grade: _gradeController.text,
      duration: _durationController.text,
      period: "الفترة الأولى",
      trueFalseQuestions: [
        Question(text: "السرعة هي المسافة المقطوعة في وحدة الزمن", type: 'true_false'),
        Question(text: "القوة تقاس بالنيوتن", type: 'true_false'),
        Question(text: "الكتلة تتغير بتغير المكان", type: 'true_false'),
      ],
      mcqQuestions: [
        Question(text: "ما هي وحدة قياس القوة؟", type: 'mcq', options: ["الجول", "النيوتن", "الواط"]),
      ],
    );

    try {
      final pdfBytes = await PdfService.generateExam(exam);
      await Printing.layoutPdf(onLayout: (format) async => pdfBytes, name: "امتحان_${exam.subject}.pdf");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("حدث خطأ: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("محرر الامتحانات"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _subjectController, decoration: const InputDecoration(labelText: "المادة")),
            TextField(controller: _gradeController, decoration: const InputDecoration(labelText: "الصف")),
            TextField(controller: _durationController, decoration: const InputDecoration(labelText: "الزمن")),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _generatePdf,
              child: _isLoading ? const CircularProgressIndicator() : const Text("توليد ومعاينة PDF"),
            ),
          ],
        ),
      ),
    );
  }
}
