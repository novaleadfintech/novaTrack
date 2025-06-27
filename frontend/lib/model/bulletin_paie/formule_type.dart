enum FormuleType {
  addition("Addition"),
  subtraction("Soustraction"),
  multiplication("Multiplication");
       

  final String label;
  const FormuleType(this.label);
}

String formuleTypeToString(FormuleType formule) {
  return formule.toString().split('.').last;
}

FormuleType formuleTypeFromJson(String formule) {
  return FormuleType.values
      .firstWhere((e) => e.toString().split('.').last == formule);
}
