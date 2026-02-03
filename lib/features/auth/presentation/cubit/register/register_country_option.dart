import 'package:equatable/equatable.dart';

class CountryOption extends Equatable {
  const CountryOption({
    required this.code,
    required this.name,
    required this.dialCode,
  });

  final String code;
  final String name;
  final String dialCode;

  String get flagEmoji {
    if (code.length != 2) {
      return '🏳️';
    }
    const int base = 0x1F1E6;
    const int alphaBase = 65;
    final List<int> chars = code
        .toUpperCase()
        .codeUnits
        .map((final unit) => base + unit - alphaBase)
        .toList();
    return String.fromCharCodes(chars);
  }

  static const CountryOption defaultCountry = CountryOption(
    code: 'US',
    name: 'United States',
    dialCode: '+1',
  );

  @override
  List<Object> get props => <Object>[code, name, dialCode];
}

const List<CountryOption> kSupportedCountries = <CountryOption>[
  CountryOption.defaultCountry,
  CountryOption(code: 'CA', name: 'Canada', dialCode: '+1'),
  CountryOption(code: 'GB', name: 'United Kingdom', dialCode: '+44'),
  CountryOption(code: 'DE', name: 'Germany', dialCode: '+49'),
  CountryOption(code: 'FR', name: 'France', dialCode: '+33'),
  CountryOption(code: 'AU', name: 'Australia', dialCode: '+61'),
  CountryOption(code: 'IN', name: 'India', dialCode: '+91'),
  CountryOption(code: 'JP', name: 'Japan', dialCode: '+81'),
  CountryOption(code: 'CN', name: 'China', dialCode: '+86'),
  CountryOption(code: 'TR', name: 'Turkey', dialCode: '+90'),
  CountryOption(code: 'BR', name: 'Brazil', dialCode: '+55'),
  CountryOption(code: 'ZA', name: 'South Africa', dialCode: '+27'),
];
