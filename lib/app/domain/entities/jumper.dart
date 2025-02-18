class Jumper {
  final String? value;
  final int? questionNumber;

  Jumper({
    this.value,
    this.questionNumber});


  factory Jumper.fromJson(Map<String, dynamic> json) {
    return Jumper(
      value: json['value'],
      questionNumber: json['questionNumber'],
    );
  }
}