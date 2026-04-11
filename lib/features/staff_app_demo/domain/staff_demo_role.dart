enum StaffDemoRole {
  employee,
  manager,
  accountant;

  static StaffDemoRole? tryParse(final String? raw) {
    return switch (raw) {
      'employee' => StaffDemoRole.employee,
      'manager' => StaffDemoRole.manager,
      'accountant' => StaffDemoRole.accountant,
      _ => null,
    };
  }
}
