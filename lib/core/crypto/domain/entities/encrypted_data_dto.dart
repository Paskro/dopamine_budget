final class EncryptedDataDto {
  final String ciphertextBase64;
  final String nonceBase64;
  const EncryptedDataDto({
    required this.ciphertextBase64,
    required this.nonceBase64,
  });

  Map<String, String> toJson() => {
    'c': ciphertextBase64,
    'n': nonceBase64,
  };

  factory EncryptedDataDto.fromJson(Map<String, dynamic> json) =>
      EncryptedDataDto(
        ciphertextBase64: json['c'] as String,
        nonceBase64: json['n'] as String,
      );
}