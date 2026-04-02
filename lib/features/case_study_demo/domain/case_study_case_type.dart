/// Clinical case category for the dentist case-study demo.
enum CaseStudyCaseType {
  implant,
  ortho,
  cosmetic,
  general,
}

extension CaseStudyCaseTypeX on CaseStudyCaseType {
  String get storageName => name;

  static CaseStudyCaseType? tryParse(final String? raw) {
    if (raw == null || raw.isEmpty) return null;
    for (final CaseStudyCaseType v in CaseStudyCaseType.values) {
      if (v.name == raw) return v;
    }
    return null;
  }
}
