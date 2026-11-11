class ContactEntity {
  final String id;
  final String name;
  final String handle;
  final String avatarUrl;
  final String iban;
  final int lastTransferDate;

  const ContactEntity({
    required this.id,
    required this.name,
    required this.handle,
    required this.avatarUrl,
    required this.iban,
    required this.lastTransferDate,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'PV';
  }

  ContactEntity copyWith({
    String? id,
    String? name,
    String? handle,
    String? avatarUrl,
    String? iban,
    int? lastTransferDate,
  }) {
    return ContactEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      handle: handle ?? this.handle,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      iban: iban ?? this.iban,
      lastTransferDate: lastTransferDate ?? this.lastTransferDate,
    );
  }
}
