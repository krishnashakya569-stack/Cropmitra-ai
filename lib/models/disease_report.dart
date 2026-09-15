class DiseaseReport {
  final String crop;
  final String disease;
  final String location;
  final String symptoms;
  final DateTime date;

  const DiseaseReport({
    required this.crop,
    required this.disease,
    required this.location,
    required this.symptoms,
    required this.date,
  });
}

// Demo-only storage. Replace with a backend or local persistence later.
final List<DiseaseReport> localReports = [];
