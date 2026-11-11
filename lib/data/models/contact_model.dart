import '../../domain/entities/contact_entity.dart';

class ContactModel extends ContactEntity {
  const ContactModel({
    required super.id,
    required super.name,
    required super.handle,
    required super.avatarUrl,
    required super.iban,
    required super.lastTransferDate,
  });

  factory ContactModel.fromMap(Map<String, dynamic> map) {
    return ContactModel(
      id: map['id'] as String,
      name: map['name'] as String,
      handle: map['handle'] as String,
      avatarUrl: map['avatarUrl'] as String,
      iban: map['iban'] as String,
      lastTransferDate: map['lastTransferDate'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'handle': handle,
      'avatarUrl': avatarUrl,
      'iban': iban,
      'lastTransferDate': lastTransferDate,
    };
  }

  factory ContactModel.fromEntity(ContactEntity entity) {
    return ContactModel(
      id: entity.id,
      name: entity.name,
      handle: entity.handle,
      avatarUrl: entity.avatarUrl,
      iban: entity.iban,
      lastTransferDate: entity.lastTransferDate,
    );
  }
}
