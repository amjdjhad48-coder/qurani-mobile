import 'package:qurani/features/parent_follow_up/domain/parent_follow_up.dart';
import 'package:qurani/features/parent_follow_up/domain/parent_follow_up_dispatch.dart';
import 'package:qurani/features/students/domain/phone_number_policy.dart';

final class ParentFollowUpRecipientPolicy {
  const ParentFollowUpRecipientPolicy({
    PhoneNumberPolicy phoneNumberPolicy = const PhoneNumberPolicy(),
  }) : this._(phoneNumberPolicy);

  const ParentFollowUpRecipientPolicy._(this._phoneNumberPolicy);

  final PhoneNumberPolicy _phoneNumberPolicy;

  ParentFollowUpRecipientResolution resolve({
    required int studentId,
    required String countryCode,
    required String nationalNumber,
  }) {
    final country = switch (countryCode.trim()) {
      '+967' => GuardianPhoneCountry.yemen,
      '+966' => GuardianPhoneCountry.saudiArabia,
      _ => null,
    };

    if (country == null) {
      return ParentFollowUpRecipientResolution(
        studentId: studentId,
        recipient: null,
        allowedChannels: const <ParentFollowUpChannel>[],
      );
    }

    try {
      final normalized = _phoneNumberPolicy.normalize(
        country: country,
        input: nationalNumber,
      );

      final channels = switch (country) {
        GuardianPhoneCountry.yemen => const <ParentFollowUpChannel>[
          ParentFollowUpChannel.sms,
          ParentFollowUpChannel.whatsapp,
        ],
        GuardianPhoneCountry.saudiArabia => const <ParentFollowUpChannel>[
          ParentFollowUpChannel.whatsapp,
        ],
      };

      return ParentFollowUpRecipientResolution(
        studentId: studentId,
        recipient: normalized.e164,
        allowedChannels: channels,
      );
    } on FormatException {
      return ParentFollowUpRecipientResolution(
        studentId: studentId,
        recipient: null,
        allowedChannels: const <ParentFollowUpChannel>[],
      );
    }
  }
}
