enum StaffDemoRole {
  employee,
  manager,
  accountant;

  static StaffDemoRole? tryParse(String? raw) {
    return switch (raw) {
      'employee' => StaffDemoRole.employee,
      'manager' => StaffDemoRole.manager,
      'accountant' => StaffDemoRole.accountant,
      _ => null,
    };
  }
}
