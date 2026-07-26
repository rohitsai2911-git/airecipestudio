class Step {
  final int number;
  final String instruction;
  Step({required this.number, required this.instruction});
  factory Step.fromJson(Map<String, dynamic> json) => Step(
    number: json['number'] as int,
    instruction: json['instruction'] as String,
  );
  Map<String, dynamic> toJson() => {'number': number, 'instruction': instruction};
}
